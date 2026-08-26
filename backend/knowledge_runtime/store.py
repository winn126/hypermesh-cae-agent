from __future__ import annotations

import json
import re
import sqlite3
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Iterable


COMMON_REQUIRED_FIELDS = (
    "id",
    "kind",
    "title",
    "status",
    "provenance",
    "confidence",
    "hm_versions",
    "tags",
    "triggers",
    "risk",
    "requires_engineer_review",
    "updated_at",
)
ALLOWED_KINDS = {"procedure", "mesh_rule", "engineering_case", "source"}
ALLOWED_STATUSES = {"active", "candidate", "deprecated"}
ALLOWED_PROVENANCE = {
    "official_standard",
    "engineer_confirmed",
    "validated_case",
    "candidate_experience",
}
ALLOWED_CONFIDENCE = {"green", "yellow", "red"}
ALLOWED_RISK = {"low", "medium", "high"}
PRODUCTION_DIRECTORIES = ("procedures", "rules", "cases", "sources")
_TOKEN_RE = re.compile(r"[\w\u3400-\u9fff]+", re.UNICODE)


@dataclass(frozen=True)
class ValidationResult:
    valid: bool
    errors: list[str]


def load_json(path: Path) -> dict[str, Any]:
    """Load one UTF-8 JSON object and reject non-object roots."""
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        raise ValueError(f"Unable to load JSON knowledge item {path}: {exc}") from exc
    if not isinstance(value, dict):
        raise ValueError(f"Knowledge item {path} must have an object root.")
    return value


def _is_string_list(value: Any) -> bool:
    return isinstance(value, list) and all(isinstance(entry, str) for entry in value)


def validate_item(item: dict[str, Any]) -> ValidationResult:
    """Validate the runtime-critical portion of the card contract.

    The checked subset intentionally mirrors the JSON schemas without adding a
    third-party JSON-schema dependency to the offline runtime.
    """
    errors: list[str] = []
    if not isinstance(item, dict):
        return ValidationResult(False, ["item must be a JSON object"])
    for field in COMMON_REQUIRED_FIELDS:
        if field not in item:
            errors.append(f"missing required field: {field}")
    if not isinstance(item.get("id"), str) or not item.get("id", "").strip():
        errors.append("id must be a non-empty string")
    if item.get("kind") not in ALLOWED_KINDS:
        errors.append(f"kind must be one of {sorted(ALLOWED_KINDS)}")
    if item.get("status") not in ALLOWED_STATUSES:
        errors.append(f"status must be one of {sorted(ALLOWED_STATUSES)}")
    if item.get("provenance") not in ALLOWED_PROVENANCE:
        errors.append(f"provenance must be one of {sorted(ALLOWED_PROVENANCE)}")
    if item.get("confidence") not in ALLOWED_CONFIDENCE:
        errors.append(f"confidence must be one of {sorted(ALLOWED_CONFIDENCE)}")
    if item.get("risk") not in ALLOWED_RISK:
        errors.append(f"risk must be one of {sorted(ALLOWED_RISK)}")
    if not _is_string_list(item.get("hm_versions")) or not item.get("hm_versions"):
        errors.append("hm_versions must be a non-empty string list")
    for field in ("tags", "triggers"):
        if not _is_string_list(item.get(field)):
            errors.append(f"{field} must be a string list")
    if not isinstance(item.get("title"), str) or not item.get("title", "").strip():
        errors.append("title must be a non-empty string")
    if not isinstance(item.get("requires_engineer_review"), bool):
        errors.append("requires_engineer_review must be boolean")
    if not isinstance(item.get("updated_at"), str) or len(item.get("updated_at", "")) < 10:
        errors.append("updated_at must be an ISO date string")
    for list_field in ("preconditions", "steps", "verification", "evidence"):
        if list_field in item and not isinstance(item[list_field], list):
            errors.append(f"{list_field} must be an array when present")
    if item.get("kind") == "procedure":
        if not isinstance(item.get("steps"), list) or not item.get("steps"):
            errors.append("procedure steps must be a non-empty array")
        if not isinstance(item.get("verification"), list) or not item.get("verification"):
            errors.append("procedure verification must be a non-empty array")
    if item.get("kind") == "engineering_case":
        if not isinstance(item.get("case_evidence"), list) or not item.get("case_evidence"):
            errors.append("engineering_case case_evidence must be a non-empty array")
    return ValidationResult(not errors, errors)


def _iter_production_paths(knowledge_root: Path) -> Iterable[Path]:
    for directory_name in PRODUCTION_DIRECTORIES:
        directory = knowledge_root / directory_name
        if not directory.exists():
            continue
        yield from sorted(directory.rglob("*.json"))


def load_cards(knowledge_root: Path) -> list[dict[str, Any]]:
    """Load and validate production cards, excluding schemas and test fixtures."""
    cards: list[dict[str, Any]] = []
    for path in _iter_production_paths(Path(knowledge_root)):
        item = load_json(path)
        result = validate_item(item)
        if result.valid:
            cards.append(item)
    return sorted(cards, key=lambda item: str(item["id"]))


def _flatten_text(value: Any) -> str:
    if isinstance(value, dict):
        return " ".join(_flatten_text(value[key]) for key in sorted(value))
    if isinstance(value, list):
        return " ".join(_flatten_text(entry) for entry in value)
    if value is None:
        return ""
    return str(value)


def _search_text(item: dict[str, Any]) -> str:
    fields = (
        item.get("title", ""),
        item.get("summary", ""),
        item.get("tags", []),
        item.get("triggers", []),
        item.get("scope", {}),
        item.get("preconditions", []),
        item.get("steps", []),
        item.get("verification", []),
    )
    return _flatten_text(fields)


def build_index(knowledge_root: Path, database_path: Path) -> dict[str, Any]:
    """Rebuild an FTS5 index from production cards in a deterministic order."""
    knowledge_root = Path(knowledge_root)
    database_path = Path(database_path)
    database_path.parent.mkdir(parents=True, exist_ok=True)
    cards: list[dict[str, Any]] = []
    errors: list[dict[str, Any]] = []
    for path in _iter_production_paths(knowledge_root):
        try:
            item = load_json(path)
        except ValueError as exc:
            errors.append({"path": str(path), "errors": [str(exc)]})
            continue
        validation = validate_item(item)
        if validation.valid:
            cards.append(item)
        else:
            errors.append({"path": str(path), "errors": validation.errors})
    cards.sort(key=lambda item: str(item["id"]))
    try:
        connection = sqlite3.connect(database_path)
        try:
            connection.executescript(
                """
                DROP TABLE IF EXISTS knowledge_fts;
                DROP TABLE IF EXISTS knowledge_items;
                CREATE TABLE knowledge_items (
                    item_id TEXT PRIMARY KEY,
                    kind TEXT NOT NULL,
                    title TEXT NOT NULL,
                    provenance TEXT NOT NULL,
                    confidence TEXT NOT NULL,
                    status TEXT NOT NULL,
                    hm_versions_json TEXT NOT NULL,
                    tags_json TEXT NOT NULL,
                    triggers_json TEXT NOT NULL,
                    scope_json TEXT NOT NULL,
                    content_json TEXT NOT NULL,
                    search_text TEXT NOT NULL
                );
                CREATE VIRTUAL TABLE knowledge_fts USING fts5(
                    item_id UNINDEXED,
                    title,
                    search_text
                );
                """
            )
            for item in cards:
                content = json.dumps(item, ensure_ascii=False, sort_keys=True)
                values = (
                    str(item["id"]),
                    str(item["kind"]),
                    str(item["title"]),
                    str(item["provenance"]),
                    str(item["confidence"]),
                    str(item["status"]),
                    json.dumps(item["hm_versions"], ensure_ascii=False, sort_keys=True),
                    json.dumps(item["tags"], ensure_ascii=False, sort_keys=True),
                    json.dumps(item["triggers"], ensure_ascii=False, sort_keys=True),
                    json.dumps(item.get("scope", {}), ensure_ascii=False, sort_keys=True),
                    content,
                    _search_text(item),
                )
                connection.execute(
                    "INSERT INTO knowledge_items VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                    values,
                )
                connection.execute(
                    "INSERT INTO knowledge_fts(item_id, title, search_text) VALUES (?, ?, ?)",
                    (str(item["id"]), str(item["title"]), _search_text(item)),
                )
            connection.commit()
        finally:
            connection.close()
    except sqlite3.Error as exc:
        errors.append({"path": str(database_path), "errors": [f"SQLite index error: {exc}"]})
    return {
        "success": bool(cards) and not errors,
        "indexed_count": len(cards),
        "error_count": len(errors),
        "errors": errors,
        "database_path": str(database_path),
    }


def _fts_query(query: str) -> str:
    tokens = _TOKEN_RE.findall(query)
    if not tokens:
        return ""
    return " OR ".join('"' + token.replace('"', '""') + '"*' for token in tokens)


def search_index(database_path: Path, query: str, limit: int = 20) -> list[dict[str, Any]]:
    """Search the generated index and return complete cards in stable order."""
    database_path = Path(database_path)
    if not database_path.exists() or not str(query).strip():
        return []
    expression = _fts_query(str(query))
    if not expression:
        return []
    try:
        connection = sqlite3.connect(database_path)
        connection.row_factory = sqlite3.Row
        try:
            rows = connection.execute(
                """
                SELECT k.content_json
                FROM knowledge_fts AS f
                JOIN knowledge_items AS k ON k.item_id = f.item_id
                WHERE knowledge_fts MATCH ?
                ORDER BY bm25(knowledge_fts), k.item_id
                LIMIT ?
                """,
                (expression, max(1, int(limit))),
            ).fetchall()
        finally:
            connection.close()
    except sqlite3.Error:
        return []
    result: list[dict[str, Any]] = []
    for row in rows:
        try:
            result.append(json.loads(row["content_json"]))
        except (TypeError, json.JSONDecodeError):
            continue
    return result
