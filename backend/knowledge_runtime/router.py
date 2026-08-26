from __future__ import annotations

import json
import re
import time
from pathlib import Path
from typing import Any

from .store import load_cards, search_index


PROVENANCE_RANK = {
    "official_standard": 4,
    "engineer_confirmed": 3,
    "validated_case": 2,
    "candidate_experience": 1,
}
REVIEW_TAGS = {"mesh", "topology", "connector", "spot_weld", "glue", "rbe2"}
TOKEN_RE = re.compile(r"[A-Za-z0-9_]+|[\u3400-\u9fff]+", re.UNICODE)


def _tokens(value: str) -> list[str]:
    tokens: list[str] = []
    for token in TOKEN_RE.findall(value or ""):
        token = token.casefold()
        if not token.strip():
            continue
        if all("\u3400" <= char <= "\u9fff" for char in token):
            tokens.extend(token[index : index + 2] for index in range(len(token) - 1))
        else:
            tokens.append(token)
    return tokens


def _card_text(card: dict[str, Any]) -> str:
    fields = [
        card.get("title", ""),
        card.get("summary", ""),
        *(card.get("tags") or []),
        *(card.get("triggers") or []),
        *(card.get("preconditions") or []),
    ]
    for step in card.get("steps") or []:
        fields.append(step if isinstance(step, str) else str(step))
    for check in card.get("verification") or []:
        fields.append(check if isinstance(check, str) else str(check))
    return " ".join(str(field) for field in fields).casefold()


def _scope_matches(card: dict[str, Any], component_names: list[str]) -> bool:
    scope = card.get("scope") or {}
    include = {str(value).casefold() for value in scope.get("include") or []}
    exclude = {str(value).casefold() for value in scope.get("exclude") or []}
    names = {str(value).casefold() for value in component_names}
    if names & exclude:
        return False
    if include and names and not (names & include):
        return False
    # An omitted component list means the caller has not scoped the model yet;
    # keep scoped cards visible so the agent can ask for component confirmation
    # instead of silently hiding the relevant workflow.
    return True


def _version_matches(card: dict[str, Any], hm_version: str) -> bool:
    versions = {str(value) for value in card.get("hm_versions") or []}
    return str(hm_version) in versions or "*" in versions


def _match_score(card: dict[str, Any], intent: str) -> int:
    if str(card.get("id", "")).casefold() == str(intent).strip().casefold():
        # An explicit card ID is a routing instruction, not a fuzzy keyword
        # query.  Keep it scoreable as a defensive fallback if callers pass a
        # pre-filtered candidate list.
        return 10_000
    text = _card_text(card)
    query_tokens = _tokens(intent)
    if not query_tokens:
        return 0
    score = 0
    for token in query_tokens:
        if token in text:
            score += 1
            if token in {str(value).casefold() for value in card.get("triggers") or []}:
                score += 2
            if token in str(card.get("title", "")).casefold():
                score += 1
    return score


def _requires_review(card: dict[str, Any], risk_mode: str) -> bool:
    if bool(card.get("requires_engineer_review")):
        return True
    if card.get("status") == "candidate" or card.get("provenance") == "candidate_experience":
        return True
    if card.get("risk") == "high":
        return True
    if risk_mode == "conservative":
        tags = {str(value).casefold() for value in card.get("tags") or []}
        if tags & REVIEW_TAGS:
            return True
        if card.get("kind") in {"procedure", "mesh_rule", "engineering_case"}:
            return True
    return False


def _load_candidates(
    *,
    knowledge_root: Path,
    intent: str,
    database_path: Path | None,
) -> tuple[list[dict[str, Any]], str]:
    if database_path is not None:
        indexed = search_index(database_path, intent, limit=100)
        if indexed:
            return indexed, "sqlite_fts5"
    return load_cards(knowledge_root), "file_scan"


def query_knowledge(
    *,
    knowledge_root: Path,
    intent: str,
    hm_version: str = "17",
    component_names: list[str] | None = None,
    risk_mode: str = "conservative",
    database_path: Path | None = None,
) -> dict[str, Any]:
    """Return a ranked, version-aware knowledge decision without side effects."""
    if risk_mode not in {"conservative", "permissive"}:
        raise ValueError("risk_mode must be conservative or permissive")
    components = list(component_names or [])
    root = Path(knowledge_root)
    exact_intent = str(intent).strip().casefold()
    exact_cards = [
        card
        for card in load_cards(root)
        if str(card.get("id", "")).casefold() == exact_intent
    ]
    if exact_cards:
        candidates = exact_cards
        source = "exact_card_id"
    else:
        candidates, source = _load_candidates(
            knowledge_root=root, intent=intent, database_path=database_path
        )
    matches: list[tuple[int, int, str, dict[str, Any]]] = []
    for card in candidates:
        if card.get("status") == "deprecated":
            continue
        if not _version_matches(card, hm_version):
            continue
        if not _scope_matches(card, components):
            continue
        score = _match_score(card, intent)
        if score <= 0:
            continue
        total = score * 10 + PROVENANCE_RANK.get(str(card.get("provenance")), 0)
        try:
            workflow_order = int(card.get("workflow_order", 9999))
        except (TypeError, ValueError):
            workflow_order = 9999
        matches.append((workflow_order, total, str(card.get("id")), card))
    matches.sort(key=lambda entry: (entry[0], -entry[1], entry[2]))
    unique_cards: list[dict[str, Any]] = []
    seen: set[str] = set()
    for _, _, item_id, card in matches:
        if item_id not in seen:
            seen.add(item_id)
            unique_cards.append(card)
    required_checks: list[str] = []
    review_required = False
    for card in unique_cards:
        review_required = review_required or _requires_review(card, risk_mode)
        for precondition in card.get("preconditions") or []:
            text = f"前置条件：{precondition}"
            if text not in required_checks:
                required_checks.append(text)
        for verification in card.get("verification") or []:
            text = f"后置验证：{verification}"
            if text not in required_checks:
                required_checks.append(text)
    if not unique_cards:
        recommended = "ask_engineer"
        unknowns = [
            f"没有找到适用于 HyperMesh {hm_version} 的知识卡片",
            f"未命中任务意图：{intent}",
        ]
    elif review_required:
        recommended = "engineer_review"
        unknowns = []
    else:
        recommended = "execute"
        unknowns = []
    return {
        "success": True,
        "request": {
            "intent": intent,
            "hm_version": str(hm_version),
            "component_names": components,
            "risk_mode": risk_mode,
        },
        "matches": unique_cards,
        "required_checks": required_checks,
        "review_required": review_required,
        "unknowns": unknowns,
        "recommended_next_step": recommended,
        "source": source,
    }


def write_query_evidence(result: dict[str, Any], run_dir: Path) -> Path:
    """Persist a complete, human-readable knowledge-routing decision."""
    directory = Path(run_dir)
    directory.mkdir(parents=True, exist_ok=True)
    payload = {
        "schema_version": 1,
        "recorded_at": time.strftime("%Y-%m-%dT%H:%M:%S%z"),
        "request": result.get("request", {}),
        "matched_ids": [item.get("id") for item in result.get("matches", [])],
        "matches": result.get("matches", []),
        "required_checks": result.get("required_checks", []),
        "review_required": bool(result.get("review_required")),
        "unknowns": result.get("unknowns", []),
        "recommended_next_step": result.get("recommended_next_step"),
        "source": result.get("source"),
    }
    path = directory / "knowledge_hits.json"
    path.write_text(json.dumps(payload, ensure_ascii=False, sort_keys=True, indent=2) + "\n", encoding="utf-8")
    return path
