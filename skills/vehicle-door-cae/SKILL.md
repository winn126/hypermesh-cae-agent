---
name: vehicle-door-cae
description: This skill should be used when planning, auditing, or executing the stage-gated vehicle-door CAD-to-CAE workflow through the HyperMesh CAE Agent plugin, including model management, midsurface extraction, cleanup handoff, baobian handoff, 2D meshing, mesh-review assistance, shared-node alignment, and engineer-reviewed connections.
---

# Vehicle-door CAE Workflow

## Required checks

Confirm the active model, output directory, solver template, and MCP connection before issuing Tcl. Read references/workflow-contract.md before a model-changing operation. Read references/hypermesh17-constraints.md before using HyperMesh Tcl or GUI listener calls.

For component renaming or recolouring, read references/component-visual-palette.md before changing the model. Treat colour as visual metadata only: preserve component membership, geometry, mesh, properties, connectors, and existing names unless the engineer has separately approved a rename.

For a request to connect, merge, equivalence, replace, or align baobian with neiban, waiban, neiban_midface, or waiban_midface, read both references/baobian-board-interface-guide.md and references/baobian-interface-node-merge-guide.md, then query the matching local knowledge cards before changing the model.

For a request to run, plan, audit, hand off, or explain the complete vehicle-door preprocessing workflow, first read references/vehicle-door-full-workflow.md and query hm17.vehicle_door.full_preprocess. Record the current stage state and do not cross a stage gate without its required engineer acceptance. Treat phases 1, 2, and 5 as agent-led; phase 3 and phase 6 as engineer-led with agent assistance; phase 4 as engineer-only with no agent mutation; and phase 7 as engineer-approved agent execution.

For a request mentioning Nastran, MAT1, PSHELL, shell property, material, or thickness assignment, state that this delivery package does not create, modify, or assign material, thickness, or solver properties. Stop and hand the request to the engineer's project-specific property template or manual workflow; never infer material values, card attributes, units, or thicknesses from component names, colours, or mesh size.

For a request to scan, review, create, supplement, or manage spot welds, glue, or RBE2 connectors, first read references/connector-reference-components-and-file-lifecycle.md and query hm17.connectors.reference_component_management plus hm17.rule.model_file_lifecycle. Before scanning, inventory the point-weld and glue reference geometry. Prefer one logical reference component per type: connector_ref_spot_weld and connector_ref_glue. Move only unambiguous reference geometry; never move panel mesh, structural parts, properties, loads, or realized connectors merely to consolidate candidates.

## Execution discipline

Save every generated Tcl in the current run directory. Before each large model-changing phase, Save As to a new date/time/phase/operation-named `.hm` output rather than overwriting the accepted input. Create recovery snapshots only before destructive substeps within that phase. Poll asynchronous GUI jobs to completion and stop on any Tcl, connection, output-file, or verification error. Write an audit record and a cleanup manifest after every successful large step; delete only that phase's verified `before`/`checkpoint` files after the accepted output exists, never the original input.

## Baobian-to-panel interfaces

Treat `baobian` as the immutable reference mesh for the approved interface workflow: never mutate baobian. Process one adjacent plate per pass, then verify it before moving to the other plate. Do not use whole-model or three-component equivalence, and do not alter mesh outside the confirmed interface region.

The engineer guide permits a 1.0 mm Edge Equivalence tolerance only for a confirmed `baobian` + one-adjacent-plate interface and only after Preview Equi; it is not a global default. Use local combine/split or local remeshing on the plate side to make node counts correspond, use Replace in the direction from the plate to `baobian` for residual pairs, and stop for engineer review if the preview has extra candidates, would affect baobian, or leaves an abnormal interface free edge.

Select only strongly classified inner baobian interface free edges as automatic alignment candidates. A nearest node inside a distance tolerance is not enough. Exclude every physical outer free edge, every edge adjacent to or overlapping an excluded outer segment, and every ambiguous edge. Do not raise the controlled 1.0 mm interface tolerance to 3.0 mm for automatic mutation; a wider distance may be reported for engineer review only. When an in-tolerance node is not merged, diagnose boundary membership, one-to-one topology, mark scope, and many-to-one ambiguity before changing tolerance.

When a non-corner triangle or a sharp local size mismatch appears at the plate-to-baobian interface, remesh only a deliberately enlarged local patch on the plate side: include the triangle and its immediate transition elements, preserve the baobian boundary, then re-check node count and edge segmentation. Do not use a global remesh or alter baobian to repair a local target-side topology mismatch.

## Functional visualisation

Classify collectors by function before assigning colours: main body, repeated hardware, spot welds, adhesive, and other approved categories. For main-body components, determine physical position from the model or an engineer-confirmed mapping before assigning the inner/outer/window colour family; never infer a permanent semantic name solely from a colour.

Use the calibrated HM17 palettes and the role-to-colour allocation in references/component-visual-palette.md. Use `tcl/visualization/apply-functional-palette.tcl` as the execution template. Populate only the component-ID mapping after reviewing the active model, run its per-component verification, and retain the executed Tcl with the run artifacts.

## Human-review boundary

Require explicit engineer approval before creating spot-weld, glue, or circular-RBE2 connectors. Stop for review when geometry source, thickness source, meshing criteria, quality result, or reference-geometry classification is ambiguous. Preserve the selected marker/reference component names and entity counts in the connection audit.

For a request mentioning an RBE2, rigid-spider, circular hole, circular free edge, or two nearby circular rings, use the default 5 mm centre tolerance unless the engineer supplies another value. Present `paired_circles` first, then `ambiguous_pair`, then `single_circle`; never infer which ambiguous loop pair should be connected. For an RBE2-only request, first call `analyze_circular_rbe2_candidates` on the saved `.hm` model, then open `open_circular_rbe2_review_panel` only for engineer approval/rejection. For a complete connection scan, call `open_spot_weld_review_panel(..., include_rbe2=True)` so it performs the same read-only RBE2 scan and opens the one three-page panel for point welds, glue, and RBE2; do not source a legacy panel separately. The panel alone may invoke the bundled, checksum-embedded macro after saving a recovery model and clearing the node mark; inspect `get_circular_rbe2_review_audit` afterward. Apply the detailed HM17 lessons in `references/rbe2-review-lessons.md`, including the integrated-macro creation boundary, namespace-qualified Tcl file I/O, resilient repeated scans, and candidate-by-candidate audit handling.

## File lifecycle

For every model-changing operation, create a date/time/phase/operation-named output model rather than overwriting the input. Keep the original input, current accepted output, executed Tcl, logs, audit, and manifest together. After each accepted large phase, remove only the phase-local recovery/checkpoint files that appear in the manifest's deletion list; retain older accepted outputs unless the engineer approves final-delivery consolidation. Never delete the original input automatically.

## Scope boundary

Do not invent mesh sizes, quality limits, naming taxonomies, materials, thicknesses, or connector rules. Use only values explicitly supplied by the engineer or measured and audited from the active model.
