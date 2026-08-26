# HyperMesh 17 functional component palette

## Purpose

Use colour to reveal component function at a glance without turning the model
into a high-saturation rainbow. Apply the palette after components have been
named or classified; colour must never be used as evidence of a component's
physical role.

## Classification order

1. Separate functional groups: main body, repeated hardware, spot welds,
   adhesive, and any engineer-approved special group.
2. Subclass the main body by physical position using geometry, display review,
   or an engineer-confirmed mapping: inner panel/inner structure, outer panel,
   and window or upper-sheet region.
3. Use a light, medium, and dark variant only to distinguish parts within the
   same group. Keep the family unchanged.
4. Preserve existing collector names and part numbers unless renaming is an
   explicitly approved operation.

## Calibrated HM17 palette indices

These values were checked against the installed HyperMesh 2017 swatches, not
assumed from palette index order.

| Function | HM17 colours | Intent |
| --- | --- | --- |
| Inner panel / inner structure | 21, 22, 23, 24 | blue: light to dark |
| Outer panel | 49, 50, 51 | orange: light to dark |
| Window / upper sheet | 53, 54, 55 | green: light to dark |
| Spot weld | 17, 18 | bright red family |
| Adhesive | 19 | dark red; visually distinct from spot welds |
| Repeated clips / fasteners | 37, 38, 39 | restrained violet family |

Avoid black, white, and the neutral-grey range for role-bearing collectors:
they are weak on both dark and light backgrounds. Reserve yellow for warnings
or review states rather than ordinary production parts.

## Execution contract

- Inspect all active components and prepare the component-ID mapping before
  sending Tcl.
- Confirm the active model and save a recovery model before a large visual
  reclassification that the engineer wants persisted.
- Use `*colormark components 1 <colour>` and read the resulting `color` value
  back with `hm_getvalue` for each component.
- Stop on a missing component or a colour mismatch; do not silently continue.
- Record the exact Tcl and final model path in the current run artifacts.

## Example visual mapping

For a door with a blue inner panel, orange outer skin, green upper sheet, red
weld and adhesive entities, and violet repeated clips, populate the template
with the reviewed component IDs. The template deliberately has no model-
specific IDs so that it cannot recolour the wrong model by default.
