# CAE Run Contract

## Required inputs

Record the active input model, intended solver template, requested phase and operation, output directory, engineer-provided acceptance criteria, and the planned Save As output path before a model-changing action. For point-weld and glue review, also record the actual reference component name, ID, entity count, and any unresolved reference geometry.

## Required outputs

For every large workflow step, create an independent Save As `.hm` output and retain the input reference, accepted output, executed Tcl, execution log, audit log, run manifest, and final report. Keep recovery/checkpoint models only until the accepted output is written and audited successfully; then delete only the phase-local paths listed in the manifest cleanup record. Never overwrite or automatically delete the original input.

## Run states

- planned: no Tcl has been sent to HyperMesh.
- running: a Tcl job is queued or executing.
- completed: the intended final model and audit artifacts exist.
- stopped: a connection, Tcl, file-output, or verification failure requires diagnosis.

## Confidence labels

- Green: requested operation completed and required verification passed.
- Yellow: operation completed with an explicit warning or pending engineer review.
- Red: operation stopped, an output is missing, or a required verification failed.

## Human approval

Require the engineer's final confirmation before applying weld, glue, or RBE2 connectors. Record the candidate basis, reference component mapping, reviewer decision, Save As output model, and phase-local cleanup record in the run manifest.
