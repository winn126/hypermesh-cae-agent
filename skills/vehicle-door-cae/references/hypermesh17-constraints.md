# HyperMesh 17 Operational Constraints

- Run lengthy visible-GUI operations through the asynchronous GUI listener and poll the job to completion.
- Save a Tcl file before sending it to HyperMesh; retain the executed file with the run artifacts.
- Read back the intended geometry, mesh, connector, colour, or other relevant result after a model-changing Tcl operation.
- Treat GUI listener loss, an unresponsive HyperMesh session, Tcl errors, missing model output, and failed readback as a stopped run. Do not retry blindly in a loop.
- Use an explicit staging filename when a HyperMesh save may cause an overwrite confirmation.
- Keep the solver template explicit because HyperMesh 17 Tcl card attributes depend on the active template.
