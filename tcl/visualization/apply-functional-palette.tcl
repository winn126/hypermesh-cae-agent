# HyperMesh 17 functional palette application template.
# Copy this file to the run directory, then replace the empty palette_map with
# reviewed component-ID / HM17-colour pairs. Keep comments outside Tcl lists.
# Example: set palette_map {9 22 23 50 15 54 5 17 22 19 7 38}

set palette_map {}

if {[llength $palette_map] == 0} {
    error "No component-colour pairs supplied. Review the active model and populate palette_map before execution."
}
if {[expr {[llength $palette_map] % 2}] != 0} {
    error "palette_map must contain component-ID / colour pairs"
}

puts "MCP_FUNCTIONAL_PALETTE_BEGIN|pairs=[expr {[llength $palette_map] / 2}]"
set changed 0
foreach {component_id target_color} $palette_map {
    *createmark components 1 $component_id
    if {[hm_marklength components 1] != 1} {
        error "Missing expected component id $component_id"
    }
    set component_name [hm_getvalue comps id=$component_id dataname=name]
    *colormark components 1 $target_color
    set actual_color [hm_getvalue comps id=$component_id dataname=color]
    if {$actual_color != $target_color} {
        error "Colour verification failed for id=$component_id name=$component_name expected=$target_color actual=$actual_color"
    }
    incr changed
    puts "MCP_FUNCTIONAL_PALETTE_COMPONENT|id=$component_id|name=$component_name|color=$actual_color"
}
*clearmarkall 1
puts "MCP_FUNCTIONAL_PALETTE_COMPLETE|changed=$changed"
