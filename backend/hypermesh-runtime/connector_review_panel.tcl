# Unified HyperMesh 17 connector-review runtime asset.
# Contains point-weld and glue review UI, circular-RBE2 review UI, and an
# embedded copy of the approved RBE2 TclPro byte-code macro.
# Embedded macro SHA-256: 8E9B8313F2E223B7079B3517407E0315EFEAFADF246F45F742F42A059A4B712D
# Do not split this file without also restoring the guarded lazy macro loader.
# Guarded HM17 review UI for circular free-edge RBE2 candidates.
# RBE2 creation remains gated by an explicit engineer approval and confirmation.

# Reset review-only RBE2 state before this template's namespace defaults are
# evaluated. The connector macro itself is deliberately process-wide and is
# retained; candidates and UI state must never cross from one HM model to
# another.
set _mcp_rbe2_same_model 0
if {[info exists ::mcp_circular_rbe2_review::model_path] && $::mcp_circular_rbe2_review::model_path ne ""} {
    catch {
        set _mcp_rbe2_same_model [expr {
            [file normalize $::mcp_circular_rbe2_review::model_path] eq [file normalize "__MCP_SPOT_MODEL_PATH__"]
        }]
    }
}
if {!$_mcp_rbe2_same_model} {
    catch {destroy .mcpCircularRbe2Review}
    namespace eval ::mcp_circular_rbe2_review {
        foreach name {candidate_rows decisions current_index model_path output_path backup_path audit_path applied backup_written output_save_pending summary_widget candidate_label detail_label review_counts_label status_label} {
            unset -nocomplain $name
        }
    }
}

namespace eval ::mcp_circular_rbe2_review {
    variable window .mcpCircularRbe2Review
    variable candidate_rows {}
    variable decisions
    variable current_index 0
    variable model_path ""
    variable output_path ""
    variable backup_path ""
    variable audit_path ""
    variable embedded_macro_loaded 0
    variable applied 0
    variable embedded_macro_base64 {
aWYge1tjYXRjaCB7cGFja2FnZSByZXF1aXJlIHRiY2xvYWQgMS42fSBlcnJdID09IDF9IHsNCiAgICByZXR1cm4gLWNvZGUg
ZXJyb3IgIltpbmZvIHNjcmlwdF06IFRoZSBUY2xQcm8gQnl0ZUNvZGUgTG9hZGVyIGlzIG5vdCBhdmFpbGFibGUgb3IgZG9l
cyBub3Qgc3VwcG9ydCB0aGUgY29ycmVjdCB2ZXJzaW9uIC0tICRlcnIiDQp9DQp0YmNsb2FkOjpiY2V2YWwgew0KVGNsUHJv
IEJ5dGVDb2RlIDIgMCAxLjcgOC41DQozIDAgMjcgNyAwIDAgMjggMCA0IDMgMyAtMSAtMQ0KMjcNCipCRTwhKEgmcyEvSFc8
IS1FYDwhLyNHcHYtVEE5dih3ISENCjMNCjcvMHYNCjMNCjtaRSENCjcNCngNCjQNCixDSHJADQp4DQoyMA0KSElhOkB2Q05h
RSUyWlM/LWppJ0ZyWiFpQw0KeA0KNA0KJU58KEYNCnANCjU4IDAgNzEyIDI5IDggMCAyOTYgMyA4IDU4IDc0IC0xIC0xDQo3
MTINCncwRTwhLWZTcyFKQWVgQi9KSEslIzNXVyE5USZRJjpOMiwhLm9BdiEjMEU8ITssOXMhNzRXVyFrdiEhIS9UTjwhMmtp
aiUubA0KdnB2N2lTcyFGM1dXIXlYJj0hJjlOPCEnOU48IS9FYDwhNClmcyE1diEhITQhISEhdy08PCEyZitwdjwyQnMhNXYh
ISEuISEhDQohPUlBSSY9TjIsITIzbCshdzZOPCE/PlRzIVE0NSwhUkg0JiEjMEU8ITV8Lz0hQF53ISE7byEhITAvPjp2NXYh
ISEvISEhITMNCmxyPCFkLC58djdTOnF2QER8cyE1diEhIS4hISEhNjBmOT09TjIsIS1pOHYhPy0/PCo1O0wzd2JJMiowUzEl
bSM0LGY9IUI4Iw0KPiE4Pkdwdj1OMiwhLm9BdiEjMEU8IU5KZnMhNXYhISEuISEhITZ0VkgmQU4yLCE8bmsjISMwRTwhQDVD
M3c9KTk9IStFYDwhDQpDTC9JJkJOMiwhL3VKdiEtMkMzd0M1P1B3OF53ISEuSCEhISwmdGwjVWJlYEJvNFlgOSMzV1chRF5y
MSVHNXYhIWk0NCwhMSwNCnx2IS0yQzN3PWFtXjpXaGVgQjY0eWAndio8PCFNak5MJTk3SkUnS3BTaCU4XnchIS9LISEhPEBp
ZyVBJlp0ITV2ISEhYSMhIQ0KITkraUgmWFJfdyF4aFohQzF5KS0mIzNXVyFHT0pJJkIybHQhNXYhISEjIyEhITkraUgmWlJf
dyFyRyZwQjc9dicoIzNXVyFXDQo2LCsnLV4jKyE1dmBIJkxOMiwhND8pLCEsLDozd2YhcShDWVpUSyUzfEU8IUw2R0YnMEtX
PCErM0U8ITE5TjwhLXwvPSE4TTENCnF2NG89NiM3VnBpdyc/YFchKE5BOXY8eTFSIzhedyEhNFohISEjKiohITBBcGl3UE5M
Yic4XnchIS5IISEhQXNhYSdWN248dg0KQlllYEItOGdpd3YqPDwhVSYncyFYJzAuJnVBTzhzRHJ2bSM4XnchIS1FISEhUGxM
SyZAVUpJJiw8ZnEsUTFWYDBCWWVgQi04DQpnaXd2Kjw8IU9pJnMhTT1ST3d1QU84c008Jm0jOF53ISE2YCEhITg9ZWAnUDlH
QihBOG85dkJgVzwhQDJvPSFQcUg0dztsSnMNCiFINHFpdytXQTl2R2s1VXZBJTI/IUU/MyEhDQo1OA0KNV93biNSIWoxJVZS
V0wlQE1rcHZpOGhDKFNGQG4jUTQqTCVFaExSI0Zfa3B2RWhMUiNLSUVMJWRmKCwnYUQzQSlrcCoxJTtIDQohDQo3NA0KRllQ
dCEvdyohITMzdConfDE+K0JCM0BDKVV4RTElaS8pMCZBLGZzcnA9dCY6UTlQJyg9Y1dycmFlVTJsO3VpcnIjNWk4WFpVDQo+
RkJoLERHJ05SKmt3WmozMSU0MyENCjI5DQp4DQoxMA0KaEwjNEJ0KlU7QFRldw0KeA0KNA0Kc15vUkENCngNCjENClIhDQp4
DQo0Mg0KVFRTQ2tMfEFLWiVfRTRNT0VBR2o0dU1efFN2LHd5eS9HKWsoO2FFSnFuZkpXVFRTQ2t8UScNCmkNCjANCngNCjEz
DQojKHEtRHdMNjxASiNKYUREdg0KeA0KOA0KPzJLKEZtRjVTQQ0KeA0KOQ0KNHw8SkRxZmBhRTd2DQp4DQo3DQpwTlIuRGkq
RS0NCngNCjANCg0KeA0KMTENCmhMIzRCKGFRPEBoOmcrDQp4DQozDQosa08nDQppDQoyDQp4DQoyMQ0KZ3A+PEBuamtTQUlv
Vy9EKkZ1U0FGTEZlQjB2DQp4DQo0DQp1S2hnQw0KeA0KMTENCjE5RFRBdGZSLkRgVUgsDQp4DQo0DQonTkIsRQ0KeA0KNA0K
ODFHSjANCngNCjE2DQpkKGFwQHxANVNBKUZoUEIrMEsoRg0KeA0KNg0KJVJJSURDU3cNCngNCjMNCll0fCsNCngNCjYNCjo8
eWxCTFl3DQp4DQozDQpgQHUsDQp4DQoxMw0KVi5sPCtSJzhzK1goOHMrQyENCngNCjUNCnNeb1JBP3YNCngNCjI3DQo5Qik1
Qm88JWxCKG08SkRoMUJxQGk/SUlEazlEVEF5N2crDQp4DQo2DQpBbXdjMTdvdg0KeA0KMTANCitqYlNBbndVO0BUZXcNCngN
CjMNCnhJUSwNCjgNCkwgMCAxMzggNjMgMjIyIDIwMiAtMQ0KTCAwIDIwMiAxMiAyMjIgLTEgLTENCkwgMCAzNDIgMjg4IDY1
NCA2MzEgLTENCkwgMCA2MzEgMTIgNjU0IC0xIC0xDQpMIDEgNDE1IDE4OSA2MjggNjA1IC0xDQpMIDEgNjA1IDEyIDYyOCAt
MSAtMQ0KTCAyIDQ1MSAxMjcgNjAyIDU3OSAtMQ0KTCAyIDU3OSAxMiA2MDIgLTEgLTENCjANCjEgMjINCjQNCiVOfChGDQow
IDAgMjU2DQoxMw0KJ05CLEVtP2M4QW1wWWpCMHYNCjEgMCAwDQoxOQ0KJ05CLEVtP2M4QV5DLDhBa1dtSURlSS0sDQoyIDAg
MA0KOQ0KMG90KUYwQWNjRVQhDQozIDAgMA0KMTANCngrWFk/YiUrWT9EUHcNCjQgMCAwDQo3DQonTkIsRU5lfCsNCjUgMCAw
DQoxDQo3dg0KNiAwIDANCjgNCidOQixFKiE+azANCjcgMCAwDQo3DQoueG1kRGl0fCsNCjggMCAwDQo4DQosYXVXQC5PWjhB
DQo5IDAgMA0KMTANCnU5Y1NBaTw7b0FZKCUNCjEwIDAgMA0KMTcNCnU5Y1NBaTw7b0ElN1ZnQyZLI0RGNHYNCjExIDAgMA0K
MTENCjhwYTExaiNUYkVOZXwrDQoxMiAwIDANCjENCjV2DQoxMyAwIDANCjkNCnU5Y1NBaTw7b0E7dg0KMTQgMCAwDQoxNQ0K
dTljU0FpPDtvQW5eLDxAeWVmKw0KMTUgMCAwDQo4DQp1OWNTQSdgOTBEDQoxNiAwIDANCjINCklfdw0KMTcgMCAwDQoxOQ0K
J05CLEVtP2M4QW1wWWpCZ0g8SkRjJ2ktDQoxOCAwIDANCjENCjZ2DQoxOSAwIDANCjEwDQp1OWNTQWcqWjhBVDclDQoyMCAw
IDANCjEwDQpxYSdaPy9GXlo/RFB3DQoyMSAwIDANCngNCjE1DQpISWE6QHZDTmFFJTJaUz95MGcoDQpwDQoxNCAwIDIxNiAz
MiAwIDAgODAgMCAxMiAxNCAxNCAtMSAtMQ0KMjE2DQo0Oyw+IThedyEhLkghISF3M0U8IUtEZWBCLkEtMCV2Kjw8IThTYnQh
KT9XPCE1cnlUdi5aL3MhNXYhISE2ISEhISlLaTwhNXINCnlUdjwuV0gmL2Z2cHY3QT46djQ7dGwjMEtXPCE8ZTY0dzdHKHF2
PE4yLCFGVXF3ISMwRTwhPGBgPCE2RU48ITxUTjwhQjgjPg0KIUZENT4hTyglcnZEOEtzITV2ISEhSiEhISE5cUg0d0AlaFZ2
PCh4NHc1Mm89IUo+LD4hSEo+PiFOYmI+IXlqeUkmRGcndylLDQohQz8pWnV3ISp4KUA8KmBEIXMqUE9oM3dIamk1d0N0KD8h
SCs7PyF4MUQ/IWA9Vj8hT28mdiENCjE0DQpCWHJMJU9VTjEleDxzbyNZZiENCjE0DQpNWCFQd1lGbU93VCcmeSpOYyENCjMy
DQp4DQoxOA0KZitoKmtnJ0lUTlBFJjhLZihWZGpCVScNCngNCjE4DQpRV3Ypa21DNT9MeVIqbkxUVFNDa3xRJw0KeA0KNg0K
ZihWZGpCVScNCngNCjcNCigjO0VGJ0xyLQ0KeA0KMQ0KTyENCngNCjgNCjc8RmlDd2Q3aEMNCngNCjINCnhrdw0KeA0KMTAN
CjNEY2NFLCZNRUZPKCUNCngNCjgNCk1oVCxFO0E7RUYNCngNCjENClIhDQp4DQo4DQp1dVcvRDx2ZSNIDQp4DQoxNA0KMSFE
VkdAQEwoMjY3MWIxMHx2DQp4DQo2DQo3WURFRlRudw0KeA0KNA0KWSh4TjENCngNCjUNCkt0KHlHQHYNCngNCjgNCjlvVy9E
bWdZOEENCngNCjg2DQoxOURUQXRmUi5EJkswLEVtSzdoQy4/YzhBTSFHPitOUnlIM2xKRlc+ZC9RTUFhLkUwMnFKdlc+M2sx
SzBfJSpqMVY7aHg+LkoNClBKMDgmKmoxQ2pJVj5iOmAxMTdKQS0zbzh5Vj5gYEJQQCczdg0KeA0KNg0KPjYtOEFTeXcNCngN
CjINCjJsdg0KeA0KNQ0KPSxzSkRAdg0KeA0KMQ0KWSENCngNCjQNCloxIWoxDQp4DQoyMA0KSElhOkB2Q05hRSUyWlM/LWpp
J0ZyWiFpQw0KeA0KMTENCnVncnBAK0tUZkRpdHwrDQp4DQo3DQoxYTJYQGg6ZysNCngNCjQNCnMnLThBDQp4DQo0DQpSTGhB
Rw0KaQ0KMA0KeA0KNw0KOGY8aUNyWGMsDQp4DQo1DQovRjk3QUR2DQp4DQoyDQotfHYNCngNCjUNCi9GOTdBRXYNCjANCjAN
CjEgNw0KNA0KJU58KEYNCjAgMCAyNTYNCjkNCjBvdClGMEFjY0VSIQ0KMSAwIDANCjkNCjBvdClGMEFjY0VVIQ0KMiAwIDAN
CjkNCjBvdClGMEFjY0VWIQ0KMyAwIDANCjcNCnJOPEpEcExjLA0KNCAwIDANCjMNCitfSiYNCjUgMCAwDQozDQosZVMmDQo2
IDAgMA0KeA0KMTUNCnJwd2hDO1oyYjM8PzwrRWZxVCsNCjANCjANCn0NCg==
    }
    variable center_tolerance 5.0
    variable backup_written 0
    variable output_save_pending 0
    variable summary_widget ""
    variable candidate_label ""
    variable detail_label ""
    variable review_counts_label ""
    variable status_label ""
}

# HM17 sources Tcl through the Windows ANSI code page.  User-visible Chinese
# is therefore represented as ASCII hex and explicitly decoded as UTF-8.
proc ::mcp_circular_rbe2_review::text {utf8_hex} {
    return [encoding convertfrom utf-8 [binary format H* $utf8_hex]]
}

proc ::mcp_circular_rbe2_review::json_escape {text} {
    return [string map [list "\\" "\\\\" "\"" "\\\"" "\n" "\\n" "\r" "\\r" "\t" "\\t"] $text]
}

proc ::mcp_circular_rbe2_review::decode_base64_compat {encoded} {
    # HyperMesh 17 ships Tcl 8.5, which has no "binary decode base64"
    # ensemble. Decode the embedded TclPro payload with Tcl 8.5 core commands
    # only, then evaluate it through the guarded lazy loader.
    set alphabet "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    array set values {}
    set value 0
    foreach character [split $alphabet ""] {
        set values($character) $value
        incr value
    }
    set clean [string map [list "\n" "" "\r" "" "\t" "" " " ""] $encoded]
    set length [string length $clean]
    if {$length == 0 || [expr {$length % 4}] != 0} {
        return -code error "invalid base64 payload length"
    }
    set hex ""
    for {set offset 0} {$offset < $length} {incr offset 4} {
        foreach {char0 char1 char2 char3} [split [string range $clean $offset [expr {$offset + 3}]] ""] {}
        if {$char0 eq "=" || $char1 eq "=" || ![info exists values($char0)] || ![info exists values($char1)]} {
            return -code error "invalid base64 payload near character $offset"
        }
        set is_last [expr {$offset + 4 == $length}]
        if {!$is_last && ($char2 eq "=" || $char3 eq "=")} {
            return -code error "base64 padding is allowed only in the final quartet"
        }
        if {$char2 eq "=" && $char3 ne "="} {
            return -code error "invalid base64 padding near character [expr {$offset + 2}]"
        }
        set value0 $values($char0)
        set value1 $values($char1)
        set value2 0
        set value3 0
        if {$char2 ne "="} {
            if {![info exists values($char2)]} {
                return -code error "invalid base64 payload near character [expr {$offset + 2}]"
            }
            set value2 $values($char2)
        }
        if {$char3 ne "="} {
            if {![info exists values($char3)]} {
                return -code error "invalid base64 payload near character [expr {$offset + 3}]"
            }
            set value3 $values($char3)
        }
        append hex [format %02x [expr {($value0 << 2) | ($value1 >> 4)}]]
        if {$char2 ne "="} {
            append hex [format %02x [expr {(($value1 & 15) << 4) | ($value2 >> 2)}]]
        }
        if {$char3 ne "="} {
            append hex [format %02x [expr {(($value2 & 3) << 6) | $value3}]]
        }
    }
    return [binary format H* $hex]
}

proc ::mcp_circular_rbe2_review::load_embedded_macro {} {
    variable embedded_macro_loaded
    variable embedded_macro_base64
    if {$embedded_macro_loaded && [llength [info procs Create_rbe2_to_shell]] > 0} {return}
    if {[catch {set macro_script [::mcp_circular_rbe2_review::decode_base64_compat $embedded_macro_base64]} decode_error]} {
        return -code error "Unable to decode the embedded RBE2 creation macro: $decode_error"
    }
    if {[catch {uplevel #0 $macro_script} load_error]} {
        return -code error $load_error
    }
    if {[llength [info procs Create_rbe2_to_shell]] == 0} {
        return -code error "The embedded RBE2 creation macro did not define Create_rbe2_to_shell."
    }
    set embedded_macro_loaded 1
}

proc ::mcp_circular_rbe2_review::all_rbe2_elements {} {
    set result {}
    *createmark elems 1 "all"
    foreach element_id [hm_getmark elems 1] {
        if {![catch {hm_getvalue elems id=$element_id dataname=config} config] && $config == 55} {
            lappend result $element_id
        }
    }
    return [lsort -integer $result]
}

proc ::mcp_circular_rbe2_review::rbe2_center_node_is_used {node_id} {
    # The embedded macro receives the candidate's representative free-edge
    # node(s). An existing config-55 element using that node proves that the
    # corresponding RBE2 has already been realized in this model.
    if {![string is integer -strict $node_id] || $node_id <= 0} {return 0}
    foreach element_id [::mcp_circular_rbe2_review::all_rbe2_elements] {
        if {[catch {set element_nodes [hm_getvalue elems id=$element_id dataname=nodes]}]} {continue}
        if {[lsearch -exact $element_nodes $node_id] >= 0} {return 1}
    }
    return 0
}

proc ::mcp_circular_rbe2_review::candidate_has_existing_rbe2 {center_node_ids} {
    # Treat any occupied centre as a duplicate guard. A paired candidate with
    # one already-realized side is ambiguous, not safe to create automatically.
    # The engineer can deliberately add a different manual candidate if needed.
    if {[llength $center_node_ids] == 0} {return 0}
    foreach node_id $center_node_ids {
        if {[::mcp_circular_rbe2_review::rbe2_center_node_is_used $node_id]} {return 1}
    }
    return 0
}

proc ::mcp_circular_rbe2_review::restore_full_display {} {
    # Follow the point-weld/glue restore path: component display flags alone
    # cannot undo a graphics mask left by a previous HM17 review action.
    catch {*numbersclear}
    catch {*unmaskall}
    catch {*displayall}
    catch {*displayallgeometry}
    catch {*window 0 0 0 0 0}
}

proc ::mcp_circular_rbe2_review::focus_center_nodes {center_node_ids} {
    set coordinates {}
    foreach node_id $center_node_ids {
        if {[catch {
            set x [hm_getvalue nodes id=$node_id dataname=x]
            set y [hm_getvalue nodes id=$node_id dataname=y]
            set z [hm_getvalue nodes id=$node_id dataname=z]
        }]} {continue}
        lappend coordinates [list $x $y $z]
    }
    if {[llength $coordinates] == 0} {return}
    set cx 0.0
    set cy 0.0
    set cz 0.0
    foreach coordinate $coordinates {
        foreach {x y z} $coordinate {}
        set cx [expr {$cx + $x}]
        set cy [expr {$cy + $y}]
        set cz [expr {$cz + $z}]
    }
    set count [llength $coordinates]
    set cx [expr {$cx / $count}]
    set cy [expr {$cy / $count}]
    set cz [expr {$cz / $count}]
    set spread 0.0
    foreach coordinate $coordinates {
        foreach {x y z} $coordinate {}
        set distance [expr {sqrt(($x-$cx)*($x-$cx) + ($y-$cy)*($y-$cy) + ($z-$cz)*($z-$cz))}]
        if {$distance > $spread} {set spread $distance}
    }
    catch {*graphuserwindow_byXYZandR $cx $cy $cz [expr {max(30.0, $spread + 30.0)}]}
}

proc ::mcp_circular_rbe2_review::show_current {} {
    variable candidate_rows
    variable current_index
    variable decisions
    variable summary_widget
    variable candidate_label
    variable detail_label
    variable status_label
    if {[llength $candidate_rows] == 0} {
        ::mcp_circular_rbe2_review::update_review_counts
        set candidate_label [::mcp_circular_rbe2_review::text e69caae689bee588b0e997ade59088e59c86e5bda2e887aae794b1e8beb9e58099e98089e38082]
        set detail_label ""
        if {$status_label eq ""} {set status_label [::mcp_circular_rbe2_review::text e8afb7e5aea1e6a0b8e58099e98089efbc9be7a1aee8aea4e68896e68e92e999a4e5908ee4bc9ae887aae58aa8e58887e68da2e588b0e4b88be4b880e69da1e38082]}
        if {$summary_widget ne "" && [winfo exists $summary_widget]} {
            $summary_widget configure -text "$candidate_label\n$status_label"
        }
        return
    }

    set row [lindex $candidate_rows $current_index]
    lassign $row candidate_id kind representative_node_id center_node_ids review_label component_ids
    set decision pending
    if {[info exists decisions($candidate_id)]} {set decision $decisions($candidate_id)}

    set kind_label $kind
    switch -- $kind {
        paired_circles {set kind_label [::mcp_circular_rbe2_review::text e58f8ce59c86e58099e98089]}
        ambiguous_pair {set kind_label [::mcp_circular_rbe2_review::text e6ada7e4b989e58f8ce59c86e58099e98089]}
        single_circle {set kind_label [::mcp_circular_rbe2_review::text e5ada4e7ab8be59c86e58099e98089]}
    }
    set decision_label $decision
    switch -- $decision {
        pending {set decision_label [::mcp_circular_rbe2_review::text e5be85e5aea1e6a0b8]}
        approved {set decision_label [::mcp_circular_rbe2_review::text e5b7b2e689b9e58786]}
        rejected {set decision_label [::mcp_circular_rbe2_review::text e5b7b2e68b92e7bb9d]}
        applied {set decision_label [::mcp_circular_rbe2_review::text e5b7b2e5889be5bbba]}
        existing {set decision_label "\u5df2\u5b58\u5728\uff08\u5df2\u9632\u91cd\uff09"}
    }

    set summary_text "[::mcp_circular_rbe2_review::text e58099e98089] [expr {$current_index + 1}] / [llength $candidate_rows]"
    append summary_text "\n[::mcp_circular_rbe2_review::text e7b1bbe59e8befbc9a]$kind_label"
    append summary_text "\n$review_label"
    append summary_text "\n[::mcp_circular_rbe2_review::text e79bb8e585b3e7bb84e4bbb6efbc9a]$component_ids"
    append summary_text "\n[::mcp_circular_rbe2_review::text e4bba3e8a1a8e88a82e782b9efbc9a]$representative_node_id"
    append summary_text "\n[::mcp_circular_rbe2_review::text e5aea1e69fa5e78ab6e68081efbc9a]$decision_label"
    ::mcp_circular_rbe2_review::update_review_counts
    set candidate_label "[::mcp_circular_rbe2_review::text e58099e98089] [expr {$current_index + 1}] / [llength $candidate_rows]"
    set detail_label $summary_text
    if {$status_label eq ""} {set status_label [::mcp_circular_rbe2_review::text e8afb7e5aea1e6a0b8e58099e98089efbc9be7a1aee8aea4e68896e68e92e999a4e5908ee4bc9ae887aae58aa8e58887e68da2e588b0e4b88be4b880e69da1e38082]}
    if {$summary_widget ne "" && [winfo exists $summary_widget]} {
        $summary_widget configure -text "$detail_label\n$status_label"
    }

    # Reuse the glue review display sequence.  A real graphics mask gives a
    # deterministic local view in HM17; hide/show entity flags do not.
    ::mcp_circular_rbe2_review::restore_full_display
    set component_id_list [split $component_ids ","]
    set mark_command [list *createmark elems 1 "by comp id"]
    eval $mark_command $component_id_list
    catch {*numbersclear}
    catch {*unmaskall}
    catch {*maskall}
    catch {*unmaskentitymark elems 1}
    # The local zoom is centred on the midpoint of one circle or the paired
    # circles.  Highlighting happens after the graphical focus refresh.
    ::mcp_circular_rbe2_review::focus_center_nodes $center_node_ids
    catch {hm_highlightmark elems 1 highlight}
    catch {eval [linsert $component_id_list 0 *createmark components 1]; hm_highlightmark components 1 highlight}
    catch {*clearmark nodes 1}
    if {[llength $center_node_ids] > 0} {
        catch {eval [linsert $center_node_ids 0 *createmark nodes 1]; *unmaskentitymark nodes 1}
        catch {eval [linsert $center_node_ids 0 *createmark nodes 1]; hm_highlightmark nodes 1 highlight; *numbersmark nodes 1 1}
    }
}

proc ::mcp_circular_rbe2_review::set_current_decision {decision} {
    variable candidate_rows
    variable current_index
    variable decisions
    variable status_label
    if {[llength $candidate_rows] == 0} {return}
    set candidate_id [lindex [lindex $candidate_rows $current_index] 0]
    # A retry may revisit all rows. Never turn a successfully created row back
    # into an approved row, or it would create a duplicate RBE2.
    if {[info exists decisions($candidate_id)] && $decisions($candidate_id) eq "applied"} {
        set status_label "\u8be5\u5019\u9009\u5df2\u521b\u5efa\uff0c\u4e0d\u80fd\u518d\u6b21\u6279\u51c6\u3002"
        ::mcp_circular_rbe2_review::show_current
        return
    }
    if {[info exists decisions($candidate_id)] && $decisions($candidate_id) eq "existing"} {
        set status_label "\u8be5\u5019\u9009\u5728\u5f53\u524d\u6a21\u578b\u4e2d\u5df2\u5b58\u5728 RBE2\uff0c\u4e0d\u80fd\u518d\u6b21\u6279\u51c6\u3002"
        ::mcp_circular_rbe2_review::show_current
        return
    }
    set decisions($candidate_id) $decision
    ::mcp_circular_rbe2_review::update_review_counts
    if {$current_index < [expr {[llength $candidate_rows] - 1}]} {
        if {$decision eq "approved"} {
            set status_label [::mcp_circular_rbe2_review::text e5b7b2e7a1aee8aea4efbc9ae6ada4e69da1e5be85e69c80e7bb88e5889be5bbbaefbc9be5b7b2e887aae58aa8e58887e68da2e588b0e4b88be4b880e69da1e38082]
        } else {
            set status_label [::mcp_circular_rbe2_review::text e5b7b2e68e92e999a4efbc9ae6ada4e69da1e4b88de4bc9ae5889be5bbba2052424532efbc9be5b7b2e887aae58aa8e58887e68da2e588b0e4b88be4b880e69da1e38082]
        }
        ::mcp_circular_rbe2_review::next_candidate 1
        return
    }
    if {$decision eq "approved"} {
        set status_label [::mcp_circular_rbe2_review::text e5b7b2e7a1aee8aea4e69c80e5908ee4b880e69da1efbc9be8afb7e782b9e587bbe5889be5bbbae68980e69c89e5b7b2e7a1aee8aea42052424532e38082]
    } else {
        set status_label [::mcp_circular_rbe2_review::text e5b7b2e68e92e999a4e69c80e5908ee4b880e69da1efbc9be8afb7e6a0b8e5afb9e5b7b2e7a1aee8aea4e9a1b9e5908ee5868de5889be5bbbae38082]
    }
    ::mcp_circular_rbe2_review::show_current
}

proc ::mcp_circular_rbe2_review::next_candidate {delta} {
    variable candidate_rows
    variable current_index
    if {[llength $candidate_rows] == 0} {return}
    set current_index [expr {max(0, min([llength $candidate_rows] - 1, $current_index + $delta))}]
    ::mcp_circular_rbe2_review::show_current
}

proc ::mcp_circular_rbe2_review::step {delta} {
    ::mcp_circular_rbe2_review::next_candidate $delta
}

proc ::mcp_circular_rbe2_review::update_review_counts {} {
    variable candidate_rows
    variable decisions
    variable review_counts_label
    set approved 0
    set rejected 0
    set pending 0
    set created 0
    set existing 0
    foreach row $candidate_rows {
        set candidate_id [lindex $row 0]
        set decision pending
        if {[info exists decisions($candidate_id)]} {set decision $decisions($candidate_id)}
        switch -- $decision {
            approved {incr approved}
            rejected {incr rejected}
            applied {incr created}
            existing {incr existing}
            default {incr pending}
        }
    }
    set review_counts_label "[::mcp_circular_rbe2_review::text e5b7b2e7a1aee8aea4efbc9a]$approved    [::mcp_circular_rbe2_review::text e5b7b2e68e92e999a4efbc9a]$rejected    [::mcp_circular_rbe2_review::text e5be85e5aea1e6a0b8efbc9a]$pending    [::mcp_circular_rbe2_review::text e5b7b2e5889be5bbba]$created    \u5df2\u5b58\u5728\uff1a$existing"
}

proc ::mcp_circular_rbe2_review::shell_components_for_nodes {center_node_ids} {
    set component_ids {}
    foreach node_id $center_node_ids {
        catch {*clearmark elems 1}
        if {[catch {*createmark elems 1 "by node" $node_id}]} {continue}
        foreach element_id [hm_getmark elems 1] {
            set config -1
            catch {set config [hm_getvalue elems id=$element_id dataname=config]}
            # Only use shell collectors to define the local review view.
            if {$config != 103 && $config != 104} {continue}
            set component_id -1
            catch {set component_id [hm_getentityvalue elems $element_id collector.id 0]}
            if {$component_id > 0} {lappend component_ids $component_id}
        }
    }
    return [lsort -integer -unique $component_ids]
}

proc ::mcp_circular_rbe2_review::review_window {} {
    variable window
    if {[info exists ::mcp_spot_weld_review::window] && [winfo exists $::mcp_spot_weld_review::window]} {
        return $::mcp_spot_weld_review::window
    }
    return $window
}

proc ::mcp_circular_rbe2_review::hide_review_for_selection {} {
    set review_window [::mcp_circular_rbe2_review::review_window]
    catch {wm attributes $review_window -topmost 0}
    catch {wm withdraw $review_window}
    return $review_window
}

proc ::mcp_circular_rbe2_review::restore_review_after_selection {review_window} {
    catch {wm deiconify $review_window}
    if {[llength [info procs ::mcp_spot_weld_review::keep_window_on_top]] > 0} {
        catch {::mcp_spot_weld_review::keep_window_on_top $review_window}
    } else {
        catch {wm attributes $review_window -topmost 1}
        catch {raise $review_window}
    }
}

proc ::mcp_circular_rbe2_review::manual_add_pair {} {
    variable candidate_rows
    variable current_index
    variable decisions
    variable summary_widget
    variable status_label

    # A manually supplied pair uses the exact same deferred approval and
    # creation path as a scan-derived pair; this button never creates RBE2.
    # The modal selector must not sit behind a topmost review panel in HM17.
    ::mcp_circular_rbe2_review::restore_full_display
    set review_window [::mcp_circular_rbe2_review::hide_review_for_selection]
    catch {*clearmark nodes 1}
    *createmarkpanel nodes 1 [::mcp_circular_rbe2_review::text e98089e68ba9e4b8a4e4b8aae59c86e5ad94e59c86e5bf83e88a82e782b9]
    set center_node_ids [lsort -integer -unique [hm_getmark nodes 1]]
    ::mcp_circular_rbe2_review::restore_review_after_selection $review_window
    if {[llength $center_node_ids] != 2} {
        set status_label [::mcp_circular_rbe2_review::text e4babae5b7a5e8a1a5e58aa0e58f96e6b688efbc9ae5bf85e9a1bbe98089e68ba9e4b8a4e4b8aae4b88de5908ce79a84e59c86e5ad94e59c86e5bf83e88a82e782b9e38082]
        if {$summary_widget ne "" && [winfo exists $summary_widget]} {
            $summary_widget configure -text $status_label
        }
        return
    }
    set component_ids [::mcp_circular_rbe2_review::shell_components_for_nodes $center_node_ids]
    if {[llength $component_ids] == 0} {
        if {$summary_widget ne "" && [winfo exists $summary_widget]} {
            $summary_widget configure -text [::mcp_circular_rbe2_review::text e4babae5b7a5e8a1a5e58aa0e58f96e6b688efbc9ae68980e98089e59c86e5bf83e69caae585b3e88194e588b0e5a3b3e58d95e58583e7bb84e4bbb6e38082]
        }
        return
    }
    foreach row $candidate_rows {
        set existing_nodes [lsort -integer -unique [lindex $row 3]]
        if {$existing_nodes eq $center_node_ids} {
            if {$summary_widget ne "" && [winfo exists $summary_widget]} {
                $summary_widget configure -text [::mcp_circular_rbe2_review::text e4babae5b7a5e8a1a5e58aa0e58f96e6b688efbc9ae8afa5e59c86e5ad94e5afb9e5b7b2e59ca8e58099e98089e58897e8a1a8e4b8ade38082]
            }
            return
        }
    }
    set candidate_id "manual_pair:n[lindex $center_node_ids 0]:n[lindex $center_node_ids 1]"
    set review_label "manual n[lindex $center_node_ids 0] <-> n[lindex $center_node_ids 1]"
    set component_text [join $component_ids ,]
    lappend candidate_rows [list $candidate_id paired_circles [lindex $center_node_ids 0] $center_node_ids $review_label $component_text]
    set decisions($candidate_id) approved
    set current_index [expr {[llength $candidate_rows] - 1}]
    set status_label [::mcp_circular_rbe2_review::text e5b7b2e4babae5b7a5e8a1a5e58aa0e4b880e5afb9e59c86e5ad94efbc9be8afb7e5a48de6a0b8e5908ee5868de7bb9fe4b880e5889be5bbbae38082]
    ::mcp_circular_rbe2_review::update_review_counts
    ::mcp_circular_rbe2_review::show_current
    if {$summary_widget ne "" && [winfo exists $summary_widget]} {
        # Keep the browser detail, but add a concise completion indication.
        $summary_widget configure -text "[$summary_widget cget -text]\n[::mcp_circular_rbe2_review::text e5b7b2e4babae5b7a5e8a1a5e58aa0e4b880e5afb9e59c86e5ad94efbc9be8afb7e5a48de6a0b8e5908ee5868de7bb9fe4b880e5889be5bbbae38082]"
    }
}

proc ::mcp_circular_rbe2_review::close {} {
    variable window
    # Return the visible model to its normal state when review is finished.
    ::mcp_circular_rbe2_review::restore_full_display
    catch {*clearmark nodes 1}
    catch {hm_viewfit}
    destroy $window
}

proc ::mcp_circular_rbe2_review::write_audit {candidate_id kind node_id status detail new_rbe2_ids} {
    variable audit_path
    variable model_path
    variable output_path
    # This namespace also exposes an ``open`` UI procedure.  Qualify Tcl's
    # built-in file command so audit logging never dispatches to that UI.
    set file [::open $audit_path a]
    set timestamp [clock format [clock seconds] -format "%Y-%m-%dT%H:%M:%S"]
    set created_id_json [join $new_rbe2_ids ,]
    puts $file "{\"timestamp\":\"[::mcp_circular_rbe2_review::json_escape $timestamp]\",\"candidate_id\":\"[::mcp_circular_rbe2_review::json_escape $candidate_id]\",\"kind\":\"[::mcp_circular_rbe2_review::json_escape $kind]\",\"representative_node_id\":$node_id,\"status\":\"[::mcp_circular_rbe2_review::json_escape $status]\",\"detail\":\"[::mcp_circular_rbe2_review::json_escape $detail]\",\"input_model_path\":\"[::mcp_circular_rbe2_review::json_escape $model_path]\",\"output_model_path\":\"[::mcp_circular_rbe2_review::json_escape $output_path]\",\"new_rbe2_ids\":\[$created_id_json\]}"
    # This namespace also exposes a ``close`` UI procedure.  Close the audit
    # file through Tcl's global built-in command.
    ::close $file
}

proc ::mcp_circular_rbe2_review::invoke_integrated_rbe2 {} {
    variable window
    # The legacy byte-code macro is embedded below.  Load it only after an
    # engineer has approved a candidate, then remove any legacy macro window.
    if {[llength [info procs Create_rbe2_to_shell]] == 0} {
        set previous_children [winfo children .]
        if {[catch {::mcp_circular_rbe2_review::load_embedded_macro} source_error]} {
            return -code error $source_error
        }
        foreach child [winfo children .] {
            if {$child ne $window && [lsearch -exact $previous_children $child] < 0} {
                catch {destroy $child}
            }
        }
    }
    return [Create_rbe2_to_shell]
}

proc ::mcp_circular_rbe2_review::apply_approved {} {
    variable candidate_rows
    variable decisions
    variable backup_path
    variable model_path
    variable output_path
    variable backup_written
    variable applied
    variable output_save_pending
    variable status_label
    variable audit_path
    if {$applied} {
        set status_label "\u672c\u4f1a\u8bdd\u5df2\u521b\u5efa RBE2\uff0c\u4e3a\u907f\u514d\u91cd\u590d\u521b\u5efa\u5df2\u9501\u5b9a\u3002"
        tk_messageBox -icon info -type ok -message $status_label
        return
    }
    set approved_rows {}
    foreach row $candidate_rows {
        set candidate_id [lindex $row 0]
        if {[info exists decisions($candidate_id)] && $decisions($candidate_id) eq "approved"} {
            lappend approved_rows $row
        }
    }
    if {[llength $approved_rows] == 0} {
        if {$output_save_pending} {
            if {[catch {*writefile $output_path 1} save_error]} {
                set status_label "\u7ed3\u679c\u6a21\u578b\u4fdd\u5b58\u5931\u8d25\uff1a$save_error"
                tk_messageBox -icon error -type ok -message "$status_label\nAudit: $audit_path"
                return
            }
            set output_save_pending 0
            set applied 1
            ::mcp_circular_rbe2_review::restore_full_display
            set status_label "\u5df2\u5c06\u4e0a\u6b21\u521b\u5efa\u7684 RBE2 \u4fdd\u5b58\u4e3a\uff1a$output_path"
            tk_messageBox -icon info -type ok -message "$status_label\nAudit: $audit_path"
            return
        }
        tk_messageBox -icon info -type ok -message [::mcp_circular_rbe2_review::text e5b09ae69caae689b9e58786e4bbbbe4bd95e58099e98089efbc8ce6a8a1e59e8be69caae58f91e7949fe694b9e58aa8e38082]
        return
    }
    if {[tk_messageBox -icon question -type yesno -default no -message "[::mcp_circular_rbe2_review::text e5b086e4b8ba20][llength $approved_rows][::mcp_circular_rbe2_review::text 20e4b8aae5b7b2e689b9e58786e58099e98089e5889be5bbba2052424532e38082e7b3bbe7bb9fe4bc9ae58588e4bf9de5ad98e681a2e5a48de6a8a1e59e8befbc8ce698afe590a6e7bba7e7bbadefbc9f]"] ne "yes"} {
        return
    }
    if {!$backup_written} {
        if {[catch {*writefile $backup_path 1} backup_error]} {
            tk_messageBox -icon error -type ok -message "[::mcp_circular_rbe2_review::text e697a0e6b395e4bf9de5ad98e681a2e5a48de6a8a1e59e8befbc9a]\n$backup_error"
            return
        }
        set backup_written 1
    }
    set successful_candidate_ids {}
    set failed_candidate_ids {}
    set existing_candidate_ids {}
    set created_with_warning_candidate_ids {}
    set created_elements 0
    foreach row $approved_rows {
        lassign $row candidate_id kind representative_node_id center_node_ids review_label component_ids
        # Recheck before every macro call: an earlier candidate in this same
        # batch may already have used a centre node from a later paired row.
        if {[::mcp_circular_rbe2_review::candidate_has_existing_rbe2 $center_node_ids]} {
            set decisions($candidate_id) existing
            ::mcp_circular_rbe2_review::write_audit $candidate_id $kind $representative_node_id "existing" "candidate already has an RBE2 at one or more center nodes" {}
            lappend existing_candidate_ids $candidate_id
            continue
        }
        set before [::mcp_circular_rbe2_review::all_rbe2_elements]
        catch {*clearmark nodes 1}
        eval *createmark nodes 1 $center_node_ids
        # The legacy macro may report an error after creating an element.  Take
        # the after-snapshot before classifying the attempt so retry never
        # duplicates a real RBE2 that was already added to the model.
        set macro_failed [catch {::mcp_circular_rbe2_review::invoke_integrated_rbe2} create_error]
        set after [::mcp_circular_rbe2_review::all_rbe2_elements]
        set created {}
        foreach element_id $after {if {[lsearch -exact $before $element_id] < 0} {lappend created $element_id}}
        if {$macro_failed && [llength $created] == 0} {
            ::mcp_circular_rbe2_review::write_audit $candidate_id $kind $representative_node_id "failed" $create_error {}
            lappend failed_candidate_ids $candidate_id
            continue
        }
        if {[llength $created] == 0} {
            set create_error "macro returned without a new RBE2 element"
            ::mcp_circular_rbe2_review::write_audit $candidate_id $kind $representative_node_id "failed" $create_error {}
            lappend failed_candidate_ids $candidate_id
            continue
        }
        if {$macro_failed} {
            ::mcp_circular_rbe2_review::write_audit $candidate_id $kind $representative_node_id "created_with_warning" $create_error $created
            lappend created_with_warning_candidate_ids $candidate_id
        } else {
            ::mcp_circular_rbe2_review::write_audit $candidate_id $kind $representative_node_id "created" [::mcp_circular_rbe2_review::text e5b7a5e7a88be5b888e7a1aee8aea4] $created
        }
        lappend successful_candidate_ids $candidate_id
        set decisions($candidate_id) applied
        incr created_elements [llength $created]
    }
    ::mcp_circular_rbe2_review::update_review_counts
    if {[llength $successful_candidate_ids] == 0} {
        if {[llength $existing_candidate_ids] > 0 && [llength $failed_candidate_ids] == 0} {
            set status_label "RBE2 creation skipped: [llength $existing_candidate_ids] candidate(s) already have an RBE2 at one or more center nodes: [join $existing_candidate_ids {, }]. No model changes were made."
            tk_messageBox -icon info -type ok -message "$status_label\nAudit: $audit_path"
            return
        }
        set status_label "RBE2 creation incomplete: created 0 candidate(s), failed [llength $failed_candidate_ids] candidate(s): [join $failed_candidate_ids {, }]. Review the audit log and retry the failed candidates."
        tk_messageBox -icon warning -type ok -message "$status_label\nAudit: $audit_path"
        return
    }
    set output_save_pending 1
    if {[catch {*writefile $output_path 1} save_error]} {
        set status_label "RBE2 creation incomplete: created [llength $successful_candidate_ids] candidate(s), failed [llength $failed_candidate_ids] candidate(s), but saving the result failed: $save_error"
        tk_messageBox -icon error -type ok -message "$status_label\nAudit: $audit_path"
        return
    }
    set output_save_pending 0
    if {[llength $failed_candidate_ids] > 0} {
        set status_label "RBE2 creation incomplete: created [llength $successful_candidate_ids] candidate(s), skipped-existing [llength $existing_candidate_ids] candidate(s): [join $existing_candidate_ids {, }], failed [llength $failed_candidate_ids] candidate(s): [join $failed_candidate_ids {, }]. Created-with-warning candidate(s): [join $created_with_warning_candidate_ids {, }]. Successful candidates were saved to: $output_path. Retry only the failed candidates after reviewing the audit log."
        tk_messageBox -icon warning -type ok -message "$status_label\nAudit: $audit_path"
        return
    }
    if {[llength $created_with_warning_candidate_ids] > 0} {
        set applied 1
        ::mcp_circular_rbe2_review::restore_full_display
        set status_label "RBE2 creation completed with warnings: created [llength $successful_candidate_ids] candidate(s), skipped-existing [llength $existing_candidate_ids] candidate(s): [join $existing_candidate_ids {, }], warning candidate(s): [join $created_with_warning_candidate_ids {, }]. Result model: $output_path. Review the audit log before continuing."
        tk_messageBox -icon warning -type ok -message "$status_label\nAudit: $audit_path"
        return
    }
    set applied 1
    ::mcp_circular_rbe2_review::restore_full_display
    set status_label "RBE2 created [llength $successful_candidate_ids] candidate(s), skipped-existing [llength $existing_candidate_ids] candidate(s): [join $existing_candidate_ids {, }], new RBE2 elements: $created_elements. Result model: $output_path"
    tk_messageBox -icon info -type ok -message "$status_label\nAudit: $audit_path"
}

proc ::mcp_circular_rbe2_review::configure {model output backup audit candidates tolerance} {
    variable candidate_rows
    variable model_path
    variable output_path
    variable backup_path
    variable audit_path
    variable center_tolerance
    variable current_index
    variable decisions
    variable backup_written
    variable applied
    variable output_save_pending
    variable candidate_label
    variable detail_label
    variable status_label
    set candidate_rows $candidates
    set model_path $model
    set output_path $output
    set backup_path $backup
    set audit_path $audit
    set center_tolerance $tolerance
    set current_index 0
    catch {array unset decisions}
    array set decisions {}
    foreach row $candidate_rows {
        set candidate_id [lindex $row 0]
        set center_node_ids [lindex $row 3]
        if {[::mcp_circular_rbe2_review::candidate_has_existing_rbe2 $center_node_ids]} {
            set decisions($candidate_id) existing
        }
    }
    set backup_written 0
    set applied 0
    set output_save_pending 0
    set candidate_label ""
    set detail_label ""
    set status_label [::mcp_circular_rbe2_review::text e8afb7e5aea1e6a0b8e58099e98089efbc9be7a1aee8aea4e68896e68e92e999a4e5908ee4bc9ae887aae58aa8e58887e68da2e588b0e4b88be4b880e69da1e38082]
    ::mcp_circular_rbe2_review::update_review_counts
}

proc ::mcp_circular_rbe2_review::build_ui {page} {
    variable summary_widget
    ttk::label $page.heading -text [::mcp_circular_rbe2_review::text e59c86e5bda2e887aae794b1e8beb9202f205242453220e5aea1e69fa5efbc88e99c80e5b7a5e7a88be5b888e7a1e8aea4efbc89] -font {TkDefaultFont 11 bold}
    ttk::label $page.candidate -textvariable ::mcp_circular_rbe2_review::candidate_label -font {{Microsoft YaHei UI} 11 bold}
    ttk::label $page.counts -textvariable ::mcp_circular_rbe2_review::review_counts_label -font {{Microsoft YaHei UI} 10}
    ttk::label $page.detail -textvariable ::mcp_circular_rbe2_review::detail_label -justify left -anchor w -wraplength 700
    set summary_widget $page.detail
    ttk::frame $page.navigation
    ttk::button $page.navigation.previous -text [::mcp_circular_rbe2_review::text e4b88ae4b880e69da1] -command {::mcp_circular_rbe2_review::next_candidate -1}
    ttk::button $page.navigation.next -text [::mcp_circular_rbe2_review::text e4b88be4b880e69da1] -command {::mcp_circular_rbe2_review::next_candidate 1}
    ttk::button $page.navigation.approve -text [::mcp_circular_rbe2_review::text e689b9e58786e5bd93e5898de58099e98089] -command {::mcp_circular_rbe2_review::set_current_decision approved}
    ttk::button $page.navigation.reject -text [::mcp_circular_rbe2_review::text e68b92e7bb9de5bd93e5898de58099e98089] -command {::mcp_circular_rbe2_review::set_current_decision rejected}
    ttk::frame $page.manual
    ttk::button $page.manual.add -text [::mcp_circular_rbe2_review::text e4babae5b7a5e8a1a5e58aa0e4b880e5afb9e59c86e5ad94] -command {::mcp_circular_rbe2_review::manual_add_pair}
    ttk::button $page.apply -text [::mcp_circular_rbe2_review::text e5889be5bbbae5b7b2e689b9e587862052424532] -command {::mcp_circular_rbe2_review::apply_approved}
    ttk::label $page.status -textvariable ::mcp_circular_rbe2_review::status_label -justify left -anchor w -wraplength 700
    pack $page.heading -anchor w
    pack $page.candidate -anchor w -pady {8 2}
    pack $page.counts -anchor w -pady 2
    pack $page.detail -anchor w -pady 6
    pack $page.navigation.previous $page.navigation.next $page.navigation.approve $page.navigation.reject -side left -padx 3
    pack $page.navigation -fill x -pady 4
    pack $page.manual.add -side left -padx 3
    pack $page.manual -fill x -pady 4
    pack $page.apply -anchor w -pady 4
    pack $page.status -anchor w -pady {4 0}
    ::mcp_circular_rbe2_review::show_current
}

proc ::mcp_circular_rbe2_review::open {model output backup audit candidates tolerance} {
    variable window
    variable candidate_rows
    variable model_path
    variable output_path
    variable backup_path
    variable audit_path
    variable center_tolerance
    # The standalone RBE2 window and the unified three-tab window share the
    # same namespace. Keep them mutually exclusive to avoid stale controls.
    catch {::mcp_spot_weld_review::close_panel}
    catch {destroy .mcp_spot_weld_review}
    if {[winfo exists $window]} {destroy $window}
    ::mcp_circular_rbe2_review::configure $model $output $backup $audit $candidates $tolerance
    toplevel $window
    wm title $window [::mcp_circular_rbe2_review::text e59c86e5bda2e887aae794b1e8beb9205242453220e5aea1e69fa5]
    wm attributes $window -topmost 1
    frame $window.body -padx 10 -pady 10
    label $window.body.heading -text [::mcp_circular_rbe2_review::text e59c86e5bda2e887aae794b1e8beb9202f205242453220e5aea1e69fa5efbc88e99c80e5b7a5e7a88be5b888e7a1aee8aea4efbc89] -font {TkDefaultFont 11 bold}
    label $window.body.summary -justify left -anchor w -width 72
    set ::mcp_circular_rbe2_review::summary_widget $window.body.summary
    pack $window.body.heading -anchor w
    pack $window.body.summary -anchor w -pady 10
    frame $window.actions
    button $window.actions.previous -text [::mcp_circular_rbe2_review::text e4b88ae4b880e69da1] -command {::mcp_circular_rbe2_review::step -1}
    button $window.actions.next -text [::mcp_circular_rbe2_review::text e4b88be4b880e69da1] -command {::mcp_circular_rbe2_review::step 1}
    button $window.actions.approve -text [::mcp_circular_rbe2_review::text e689b9e58786e5bd93e5898de58099e98089] -command {::mcp_circular_rbe2_review::set_current_decision approved}
    button $window.actions.reject -text [::mcp_circular_rbe2_review::text e68b92e7bb9de5bd93e5898de58099e98089] -command {::mcp_circular_rbe2_review::set_current_decision rejected}
    button $window.actions.manual -text [::mcp_circular_rbe2_review::text e4babae5b7a5e8a1a5e58aa0e4b880e5afb9e59c86e5ad94] -command {::mcp_circular_rbe2_review::manual_add_pair}
    button $window.actions.apply -text [::mcp_circular_rbe2_review::text e5889be5bbbae5b7b2e689b9e587862052424532] -command {::mcp_circular_rbe2_review::apply_approved}
    button $window.actions.close -text [::mcp_circular_rbe2_review::text e585b3e997adefbc88e4b88de5868de694b9e58aa8efbc89] -command {::mcp_circular_rbe2_review::close}
    pack $window.actions.previous $window.actions.next $window.actions.approve $window.actions.reject $window.actions.manual $window.actions.apply $window.actions.close -side left -padx 3
    pack $window.body -fill both -expand 1
    pack $window.actions -fill x -padx 10 -pady 10
    ::mcp_circular_rbe2_review::show_current
}

# HyperMesh 2017 point-weld review panel.
# This file is a template. The MCP fills its configuration values before
# sending it to an already-visible HyperMesh GUI listener.

# A listener can remain alive while the engineer opens a different model. Check
# the target model before retaining an unfinished review; stale component/node
# IDs must never be applied to the next model.
set _mcp_spot_same_model 0
if {[info exists ::mcp_spot_weld_review::model_path] && $::mcp_spot_weld_review::model_path ne ""} {
    catch {
        set _mcp_spot_same_model [expr {
            [file normalize $::mcp_spot_weld_review::model_path] eq [file normalize "__MCP_SPOT_MODEL_PATH__"]
        }]
    }
}
if {!$_mcp_spot_same_model} {
    catch {destroy .mcp_spot_weld_review}
    namespace eval ::mcp_spot_weld_review {
        foreach name {marker_aliases excluded_component_names marker_max_size center_tolerance triangular_center_tolerance default_tolerance default_diameter model_path output_path backup_path audit_path rule_history_path session_id window candidates marker_options marker_component_id marker_component_ids current_index applied fe_components tolerance_var diameter_var manual_kind candidate_label review_counts_label detail_label status_label triage_rows marker_selector_ids} {
            unset -nocomplain $name
        }
    }
}

set _mcp_glue_same_model 0
if {[info exists ::mcp_glue_review::model_path] && $::mcp_glue_review::model_path ne ""} {
    catch {
        set _mcp_glue_same_model [expr {
            [file normalize $::mcp_glue_review::model_path] eq [file normalize "__MCP_GLUE_MODEL_PATH__"]
        }]
    }
}
if {!$_mcp_glue_same_model} {
    namespace eval ::mcp_glue_review {
        foreach name {marker_aliases default_tolerance default_mesh_size model_path output_path backup_path audit_path session_id marker_component_id marker_component_name marker_component_ids scan_all_components candidates current_index applied show_marker_ring tolerance_var mesh_size_var mesh_count_label candidate_label review_counts_label detail_label status_label} {
            unset -nocomplain $name
        }
    }
}

namespace eval ::mcp_spot_weld_review {
    # Preserve an unfinished review if this template is reloaded in the same
    # HyperMesh session. Only the first source initializes each variable.
    foreach {name value} [list \
        marker_aliases [list __MCP_SPOT_MARKER_ALIASES__] \
        excluded_component_names [list __MCP_SPOT_EXCLUDED_COMPONENTS__] \
        marker_max_size __MCP_SPOT_MARKER_MAX_SIZE__ \
        center_tolerance __MCP_SPOT_CENTER_TOLERANCE__ \
        triangular_center_tolerance __MCP_SPOT_TRIANGULAR_CENTER_TOLERANCE__ \
        default_tolerance __MCP_SPOT_DEFAULT_TOLERANCE__ \
        default_diameter __MCP_SPOT_DEFAULT_DIAMETER__ \
        model_path "__MCP_SPOT_MODEL_PATH__" \
        output_path "__MCP_SPOT_OUTPUT_PATH__" \
        backup_path "__MCP_SPOT_BACKUP_PATH__" \
        audit_path "__MCP_SPOT_AUDIT_PATH__" \
        rule_history_path "__MCP_SPOT_RULE_HISTORY_PATH__" \
        session_id "__MCP_SPOT_SESSION_ID__" \
        window .mcp_spot_weld_review \
        candidates {} \
        marker_options {} \
        marker_component_id -1 \
        marker_component_ids {} \
        current_index 0 \
        applied 0 \
        fe_components {} \
        tolerance_var __MCP_SPOT_DEFAULT_TOLERANCE__ \
        diameter_var __MCP_SPOT_DEFAULT_DIAMETER__ \
        manual_kind cylinder \
        candidate_label "Scanning weld-marker components..." \
        review_counts_label "\u5df2\u786e\u8ba4\uff1a0    \u5df2\u6392\u9664\uff1a0    \u5f85\u5ba1\u6838\uff1a0" \
        detail_label "" \
        status_label "" \
        triage_rows __MCP_TRIAGE_ROWS__] {
        variable $name
        if {![info exists $name]} {set $name $value}
    }
}

# Glue review lives in the same top-level window as the spot-weld review.  It
# deliberately keeps its own review state so switching pages or reloading this
# Tcl template never loses an engineer's mesh edits.
namespace eval ::mcp_glue_review {
    foreach {name value} [list \
        marker_aliases [list __MCP_GLUE_MARKER_ALIASES__] \
        default_tolerance __MCP_GLUE_DEFAULT_TOLERANCE__ \
        default_mesh_size __MCP_GLUE_DEFAULT_MESH_SIZE__ \
        model_path "__MCP_GLUE_MODEL_PATH__" \
        output_path "__MCP_GLUE_OUTPUT_PATH__" \
        backup_path "__MCP_GLUE_BACKUP_PATH__" \
        audit_path "__MCP_GLUE_AUDIT_PATH__" \
        session_id "__MCP_GLUE_SESSION_ID__" \
        marker_component_id -1 \
        marker_component_name "" \
        marker_component_ids {} \
        scan_all_components 1 \
        candidates {} \
        current_index 0 \
        applied 0 \
        show_marker_ring 1 \
        tolerance_var __MCP_GLUE_DEFAULT_TOLERANCE__ \
        mesh_size_var __MCP_GLUE_DEFAULT_MESH_SIZE__ \
        mesh_count_label "\u5f53\u524d\u80f6\u7c98\u7f51\u683c\uff1a0" \
        candidate_label "\u7b49\u5f85\u626b\u63cf\u80f6\u7c98\u5706\u73af\u6807\u8bb0..." \
        review_counts_label "\u5df2\u786e\u8ba4\uff1a0    \u5df2\u6392\u9664\uff1a0    \u5f85\u5ba1\u6838\uff1a0" \
        detail_label "" \
        status_label ""] {
        variable $name
        if {![info exists $name]} {set $name $value}
    }
}

# ---------- Glue marker / mesh-patch review ----------

proc ::mcp_glue_review::d3 {x1 y1 z1 x2 y2 z2} {
    return [expr {sqrt(($x1-$x2)*($x1-$x2)+($y1-$y2)*($y1-$y2)+($z1-$z2)*($z1-$z2))}]
}

proc ::mcp_glue_review::positive_number {value field_name} {
    if {[catch {set number [expr {double($value)}]}] || $number <= 0.0} {
        return -code error "$field_name\u5fc5\u987b\u662f\u5927\u4e8e 0 \u7684\u6570\u5b57\u3002"
    }
    return $number
}

proc ::mcp_glue_review::component_name {cid} {
    if {[catch {set name [hm_getvalue comps id=$cid dataname=name]}]} {return "component-$cid"}
    return $name
}

proc ::mcp_glue_review::surface_box {sid} {
    foreach {x0 y0 z0 x1 y1 z1} [join [hm_getgeometrybox surfs $sid]] {}
    return [list $x0 $y0 $z0 $x1 $y1 $z1]
}

proc ::mcp_glue_review::surface_center {sid} {
    foreach {x0 y0 z0 x1 y1 z1} [surface_box $sid] {}
    return [list [expr {($x0+$x1)/2.0}] [expr {($y0+$y1)/2.0}] [expr {($z0+$z1)/2.0}]]
}

proc ::mcp_glue_review::surface_dimensions {sid} {
    foreach {x0 y0 z0 x1 y1 z1} [surface_box $sid] {}
    return [list [expr {$x1-$x0}] [expr {$y1-$y0}] [expr {$z1-$z0}]]
}

proc ::mcp_glue_review::pair_box {sid1 sid2} {
    foreach {a0 b0 c0 a1 b1 c1} [surface_box $sid1] {}
    foreach {d0 e0 f0 d1 e1 f1} [surface_box $sid2] {}
    return [list [expr {min($a0,$d0)}] [expr {min($b0,$e0)}] [expr {min($c0,$f0)}] [expr {max($a1,$d1)}] [expr {max($b1,$e1)}] [expr {max($c1,$f1)}]]
}

proc ::mcp_glue_review::box_center {box} {
    foreach {x0 y0 z0 x1 y1 z1} $box {}
    return [list [expr {($x0+$x1)/2.0}] [expr {($y0+$y1)/2.0}] [expr {($z0+$z1)/2.0}]]
}

proc ::mcp_glue_review::box_radius {box} {
    foreach {x0 y0 z0 x1 y1 z1} $box {}
    return [expr {max(35.0, sqrt(($x1-$x0)*($x1-$x0)+($y1-$y0)*($y1-$y0)+($z1-$z0)*($z1-$z0))*1.2)}]
}

proc ::mcp_glue_review::list_unique {items} {
    return [lsort -integer -unique $items]
}

proc ::mcp_glue_review::list_difference {left right} {
    set result {}
    foreach item $left {
        if {[lsearch -exact $right $item] < 0} {lappend result $item}
    }
    return [list_unique $result]
}

proc ::mcp_glue_review::component_shell_elements {cid} {
    set result {}
    catch {*createmark elems 1 "by comp id" $cid}
    foreach eid [hm_getmark elems 1] {
        # HyperMesh 2017 shell configurations: 103 = tria, 104 = quad.
        set config -1
        catch {set config [hm_getvalue elems id=$eid dataname=config]}
        if {$config == 103 || $config == 104} {lappend result $eid}
    }
    return $result
}

proc ::mcp_glue_review::element_center {eid} {
    set nodes [hm_getvalue elems id=$eid dataname=nodes]
    set x 0.0; set y 0.0; set z 0.0; set count 0
    foreach nid $nodes {
        foreach {nx ny nz} [lindex [hm_nodevalue $nid] 0] {}
        set x [expr {$x+$nx}]
        set y [expr {$y+$ny}]
        set z [expr {$z+$nz}]
        incr count
    }
    if {$count == 0} {return {0 0 0}}
    return [list [expr {$x/double($count)}] [expr {$y/double($count)}] [expr {$z/double($count)}]]
}

proc ::mcp_glue_review::element_in_box {eid box {padding 0.0}} {
    foreach {x y z} [element_center $eid] {}
    foreach {x0 y0 z0 x1 y1 z1} $box {}
    return [expr {$x >= $x0-$padding && $x <= $x1+$padding && $y >= $y0-$padding && $y <= $y1+$padding && $z >= $z0-$padding && $z <= $z1+$padding}]
}

proc ::mcp_glue_review::is_glue_marker_component {cid} {
    variable marker_component_ids
    if {[lsearch -exact $marker_component_ids $cid] >= 0} {return 1}
    set name [string tolower [component_name $cid]]
    # Do not link a reviewed glue patch to auto-created result collectors.
    if {[string match "auto*" $name] || [string match "*connector*" $name]} {return 1}
    return 0
}

proc ::mcp_glue_review::free_marker_surfaces {cid} {
    set solid_surfaces {}
    *createmark solids 1 "all"
    foreach solid [hm_getmark solids 1] {
        if {[hm_getentityvalue solids $solid collector.id 0] != $cid} {continue}
        foreach sid [hm_getsurfacesfromsolid $solid] {lappend solid_surfaces $sid}
    }
    set solid_surfaces [list_unique $solid_surfaces]
    set result {}
    *createmark surfs 1 "all"
    foreach sid [hm_getmark surfs 1] {
        if {[hm_getentityvalue surfs $sid collector.id 0] != $cid} {continue}
        if {[lsearch -exact $solid_surfaces $sid] >= 0} {continue}
        # A glue annulus side is represented as a four-edge, free surface.
        if {[llength [join [hm_getsurfaceedges $sid]]] != 4} {continue}
        lappend result $sid
    }
    return [lsort -integer $result]
}

proc ::mcp_glue_review::shared_surface_edges {sid1 sid2} {
    set shared {}
    set second_edges [join [hm_getsurfaceedges $sid2]]
    foreach edge [join [hm_getsurfaceedges $sid1]] {
        if {[lsearch -exact $second_edges $edge] >= 0} {lappend shared $edge}
    }
    return [lsort -integer -unique $shared]
}

proc ::mcp_glue_review::surface_pair_score {sid1 sid2} {
    # A glue marker is an open cylinder: two circular-side faces meet on two
    # common generatrix edges; there are deliberately no top/bottom cap faces.
    # Bounding-box proximity alone would join unrelated free faces.
    if {[llength [shared_surface_edges $sid1 $sid2]] != 2} {return -1.0}
    foreach {x1 y1 z1} [surface_center $sid1] {}
    foreach {x2 y2 z2} [surface_center $sid2] {}
    set center_distance [d3 $x1 $y1 $z1 $x2 $y2 $z2]
    set relative_difference 0.0
    set largest 0.0
    foreach a [surface_dimensions $sid1] b [surface_dimensions $sid2] {
        set scale [expr {max(0.1, abs($a), abs($b))}]
        set relative_difference [expr {$relative_difference + abs($a-$b)/$scale}]
        if {$scale > $largest} {set largest $scale}
    }
    # Each pair is made of two close, similarly sized faces of one annular
    # marker.  Returning -1 prevents accidental pairing across markers.
    if {$center_distance > max(15.0, $largest*0.70) || $relative_difference > 0.65} {return -1.0}
    return [expr {$center_distance + 10.0*$relative_difference}]
}

proc ::mcp_glue_review::pair_marker_surfaces {surface_ids} {
    set remaining $surface_ids
    set pairs {}
    while {[llength $remaining] >= 2} {
        set first [lindex $remaining 0]
        set remaining [lrange $remaining 1 end]
        set best_index -1
        set best_score 1e99
        for {set index 0} {$index < [llength $remaining]} {incr index} {
            set second [lindex $remaining $index]
            set score [surface_pair_score $first $second]
            if {$score >= 0 && $score < $best_score} {set best_score $score; set best_index $index}
        }
        if {$best_index < 0} {continue}
        set second [lindex $remaining $best_index]
        set remaining [lreplace $remaining $best_index $best_index]
        lappend pairs [list $first $second]
    }
    return $pairs
}

proc ::mcp_glue_review::linked_shell_components {center tolerance} {
    foreach {x y z} $center {}
    set linked {}
    *createmark components 1 "all"
    foreach cid [hm_getmark components 1] {
        if {[is_glue_marker_component $cid]} {continue}
        set shell_ids [component_shell_elements $cid]
        if {[llength $shell_ids] == 0} {continue}
        eval [linsert $shell_ids 0 *createmark elems 1]
        if {[catch {set node [hm_getclosestnode $x $y $z 1]}] || $node == 0} {continue}
        foreach {nx ny nz} [lindex [hm_nodevalue $node] 0] {}
        set distance [d3 $x $y $z $nx $ny $nz]
        if {$distance <= $tolerance} {lappend linked [list $distance $cid]}
    }
    return [lsort -real -index 0 $linked]
}

proc ::mcp_glue_review::nearest_shell_component_to_surface {sid tolerance} {
    # The two free faces of an open-cylinder marker face opposite structural
    # parts.  Query each face independently; the first item is the nearest
    # shell component within the permitted glue gap.
    set links [linked_shell_components [surface_center $sid] $tolerance]
    if {[llength $links] == 0} {return {}}
    return [lindex $links 0]
}

proc ::mcp_glue_review::outer_marker_edge_ids {surface_ids} {
    # A valid GL marker is two half-cylinder faces.  Their two shared straight
    # generatrices are internal seams; the remaining four curved lines are the
    # two visible circular cross-section edges.
    if {[llength $surface_ids] != 2} {return {}}
    foreach {sid1 sid2} $surface_ids {}
    set all_edges [concat [join [hm_getsurfaceedges $sid1]] [join [hm_getsurfaceedges $sid2]]]
    return [list_difference $all_edges [shared_surface_edges $sid1 $sid2]]
}

proc ::mcp_glue_review::line_endpoint_pair {line_id} {
    if {[catch {set start [hm_getlinestartpoint $line_id]}] || [catch {set end [hm_getlineendpoint $line_id]}]} {return {}}
    if {[llength $start] != 3 || [llength $end] != 3} {return {}}
    return [list $start $end]
}

proc ::mcp_glue_review::points_coincident {left right} {
    if {[llength $left] != 3 || [llength $right] != 3} {return 0}
    foreach {lx ly lz} $left {}
    foreach {rx ry rz} $right {}
    return [expr {[d3 $lx $ly $lz $rx $ry $rz] < 1.0e-4}]
}

proc ::mcp_glue_review::outer_cross_section_edge_ids {surface_ids} {
    # Choose one complete small circular section: it consists of two free arc
    # lines that share an endpoint.  Either end is geometrically equivalent;
    # using one keeps discovery as fast as the former two-face lookup while
    # avoiding any marker-centre association.
    set outer_edges [outer_marker_edge_ids $surface_ids]
    if {[llength $outer_edges] != 4} {return {}}
    set first [lindex $outer_edges 0]
    set first_endpoints [line_endpoint_pair $first]
    if {[llength $first_endpoints] != 2} {return {}}
    foreach other [lrange $outer_edges 1 end] {
        set other_endpoints [line_endpoint_pair $other]
        if {[llength $other_endpoints] != 2} {continue}
        foreach first_point $first_endpoints {
            foreach other_point $other_endpoints {
                if {[points_coincident $first_point $other_point]} {return [list $first $other]}
            }
        }
    }
    return {}
}

proc ::mcp_glue_review::line_midpoint {line_id} {
    if {[catch {set point [hm_getcoordinatesofpointsonline $line_id 0.5]}]} {return {}}
    # HM 2017 wraps this coordinate triple in a one-item list.
    if {[llength $point] == 1 && [llength [lindex $point 0]] == 3} {set point [lindex $point 0]}
    if {[llength $point] != 3} {return {}}
    return $point
}

proc ::mcp_glue_review::cross_section_edge_shell_components {surface_ids tolerance} {
    # Identify the two structural bodies from the outside of a small circular
    # marker section.  Distances are measured from the two opposite free arcs,
    # not from the marker-box/surface centre.  We retain the closest distance
    # per component, and require the normal two-component result downstream.
    set edge_ids [outer_cross_section_edge_ids $surface_ids]
    if {[llength $edge_ids] != 2} {return [list {} $edge_ids]}
    array set minimum_distance {}
    array set hit_count {}
    foreach edge_id $edge_ids {
        set point [line_midpoint $edge_id]
        if {[llength $point] != 3} {continue}
        foreach link [linked_shell_components $point $tolerance] {
            foreach {distance cid} $link {}
            if {$cid <= 0} {continue}
            if {![info exists minimum_distance($cid)] || $distance < $minimum_distance($cid)} {set minimum_distance($cid) $distance}
            if {![info exists hit_count($cid)]} {set hit_count($cid) 0}
            incr hit_count($cid)
        }
    }
    set ranked {}
    foreach cid [array names minimum_distance] {
        # The first item is the primary sort key.  A repeated edge hit breaks
        # equal-distance ties in favour of a component present around the ring.
        lappend ranked [list $minimum_distance($cid) [expr {-$hit_count($cid)}] $cid]
    }
    set ranked [lsort -real -index 0 $ranked]
    set links {}
    foreach entry $ranked {lappend links [list [lindex $entry 0] [lindex $entry 2]]}
    return [list $links $edge_ids]
}

proc ::mcp_glue_review::primary_cross_section_edge_shell_components {surface_ids tolerance} {
    # Keep the nearest structural component for each opposite outer arc.  This
    # supplements the aggregate ranking and detects two shell layers that are
    # intentionally stored in one component; it never auto-creates a connector.
    set edge_ids [outer_cross_section_edge_ids $surface_ids]
    if {[llength $edge_ids] != 2} {return [list {} $edge_ids]}
    set primary_links {}
    foreach edge_id $edge_ids {
        set point [line_midpoint $edge_id]
        if {[llength $point] != 3} {lappend primary_links {}; continue}
        set links [linked_shell_components $point $tolerance]
        if {[llength $links] == 0} {lappend primary_links {}; continue}
        lappend primary_links [lindex $links 0]
    }
    return [list $primary_links $edge_ids]
}

# The following routines deliberately select a glue patch by projected AREA,
# never by an element centre or by a marker bounding box.  The box is retained
# only as a generous performance cull before the exact overlap calculation.

proc ::mcp_glue_review::v_sub {a b} {
    foreach {ax ay az} $a {}
    foreach {bx by bz} $b {}
    return [list [expr {$ax-$bx}] [expr {$ay-$by}] [expr {$az-$bz}]]
}

proc ::mcp_glue_review::v_dot {a b} {
    foreach {ax ay az} $a {}
    foreach {bx by bz} $b {}
    return [expr {$ax*$bx+$ay*$by+$az*$bz}]
}

proc ::mcp_glue_review::v_cross {a b} {
    foreach {ax ay az} $a {}
    foreach {bx by bz} $b {}
    return [list [expr {$ay*$bz-$az*$by}] [expr {$az*$bx-$ax*$bz}] [expr {$ax*$by-$ay*$bx}]]
}

proc ::mcp_glue_review::v_length {a} {
    return [expr {sqrt([v_dot $a $a])}]
}

proc ::mcp_glue_review::v_unit {a} {
    set length [v_length $a]
    if {$length < 1.0e-10} {return {}}
    foreach {x y z} $a {}
    return [list [expr {$x/$length}] [expr {$y/$length}] [expr {$z/$length}]]
}

proc ::mcp_glue_review::element_points {eid} {
    set points {}
    foreach nid [hm_getvalue elems id=$eid dataname=nodes] {
        set xyz [lindex [hm_nodevalue $nid] 0]
        if {[llength $xyz] >= 3} {lappend points [lrange $xyz 0 2]}
    }
    return $points
}

proc ::mcp_glue_review::element_box_intersects_box {eid box {padding 15.0}} {
    set points [element_points $eid]
    if {[llength $points] == 0} {return 0}
    foreach {x0 y0 z0 x1 y1 z1} $box {}
    set ex0 1e99; set ey0 1e99; set ez0 1e99
    set ex1 -1e99; set ey1 -1e99; set ez1 -1e99
    foreach point $points {
        foreach {x y z} $point {}
        if {$x < $ex0} {set ex0 $x}; if {$x > $ex1} {set ex1 $x}
        if {$y < $ey0} {set ey0 $y}; if {$y > $ey1} {set ey1 $y}
        if {$z < $ez0} {set ez0 $z}; if {$z > $ez1} {set ez1 $z}
    }
    return [expr {$ex1 >= $x0-$padding && $ex0 <= $x1+$padding && \
                  $ey1 >= $y0-$padding && $ey0 <= $y1+$padding && \
                  $ez1 >= $z0-$padding && $ez0 <= $z1+$padding}]
}

proc ::mcp_glue_review::element_surface_normal {eid} {
    set points [element_points $eid]
    if {[llength $points] < 3} {return {}}
    set first [lindex $points 0]
    for {set index 1} {$index < [expr {[llength $points]-1}]} {incr index} {
        set left [v_sub [lindex $points $index] $first]
        set right [v_sub [lindex $points [expr {$index+1}]] $first]
        set normal [v_unit [v_cross $left $right]]
        if {[llength $normal] == 3} {return $normal}
    }
    return {}
}

proc ::mcp_glue_review::source_projection_frame {cid center} {
    # A glue patch normally lies on one locally planar source-side sheet.  Use
    # its closest shell as the projection plane; both the ring and every shell
    # are then orthogonally represented in this same local u/v plane.
    set nearest 0
    set nearest_distance 1e99
    foreach eid [component_shell_elements $cid] {
        foreach {x y z} [element_center $eid] {}
        foreach {cx cy cz} $center {}
        set distance [d3 $x $y $z $cx $cy $cz]
        if {$distance < $nearest_distance} {
            set nearest $eid
            set nearest_distance $distance
        }
    }
    if {$nearest <= 0} {return {}}
    set normal [element_surface_normal $nearest]
    set points [element_points $nearest]
    if {[llength $normal] != 3 || [llength $points] == 0} {return {}}
    # Pick a stable in-plane basis even when the source shell is parallel to Z.
    set u [v_unit [v_cross {0.0 0.0 1.0} $normal]]
    if {[llength $u] != 3} {set u [v_unit [v_cross {0.0 1.0 0.0} $normal]]}
    if {[llength $u] != 3} {return {}}
    set v [v_unit [v_cross $normal $u]]
    if {[llength $v] != 3} {return {}}
    return [dict create origin [lindex $points 0] normal $normal u $u v $v source_element_id $nearest]
}

proc ::mcp_glue_review::project_point_2d {point frame} {
    set delta [v_sub $point [dict get $frame origin]]
    return [list [v_dot $delta [dict get $frame u]] [v_dot $delta [dict get $frame v]]]
}

proc ::mcp_glue_review::point2_compare {left right} {
    foreach {lx ly} $left {}
    foreach {rx ry} $right {}
    if {$lx < $rx} {return -1}
    if {$lx > $rx} {return 1}
    if {$ly < $ry} {return -1}
    if {$ly > $ry} {return 1}
    return 0
}

proc ::mcp_glue_review::cross2 {origin left right} {
    foreach {ox oy} $origin {}
    foreach {lx ly} $left {}
    foreach {rx ry} $right {}
    return [expr {($lx-$ox)*($ry-$oy)-($ly-$oy)*($rx-$ox)}]
}

proc ::mcp_glue_review::polygon_signed_area {polygon} {
    if {[llength $polygon] < 3} {return 0.0}
    set twice_area 0.0
    set count [llength $polygon]
    for {set index 0} {$index < $count} {incr index} {
        foreach {x1 y1} [lindex $polygon $index] {}
        foreach {x2 y2} [lindex $polygon [expr {($index+1)%$count}]] {}
        set twice_area [expr {$twice_area+$x1*$y2-$y1*$x2}]
    }
    return [expr {$twice_area/2.0}]
}

proc ::mcp_glue_review::polygon_area {polygon} {
    return [expr {abs([polygon_signed_area $polygon])}]
}

proc ::mcp_glue_review::ensure_ccw {polygon} {
    if {[polygon_signed_area $polygon] < 0.0} {return [lreverse $polygon]}
    return $polygon
}

proc ::mcp_glue_review::convex_hull_2d {points} {
    set ordered [lsort -command ::mcp_glue_review::point2_compare $points]
    set unique {}
    foreach point $ordered {
        if {[llength $unique] == 0} {lappend unique $point; continue}
        foreach {x y} $point {}
        foreach {last_x last_y} [lindex $unique end] {}
        if {[expr {abs($x-$last_x) > 1.0e-7 || abs($y-$last_y) > 1.0e-7}]} {lappend unique $point}
    }
    if {[llength $unique] < 3} {return {}}
    set lower {}
    foreach point $unique {
        while {[llength $lower] >= 2 && [cross2 [lindex $lower end-1] [lindex $lower end] $point] <= 1.0e-9} {
            set lower [lreplace $lower end end]
        }
        lappend lower $point
    }
    set upper {}
    foreach point [lreverse $unique] {
        while {[llength $upper] >= 2 && [cross2 [lindex $upper end-1] [lindex $upper end] $point] <= 1.0e-9} {
            set upper [lreplace $upper end end]
        }
        lappend upper $point
    }
    set hull [concat [lrange $lower 0 end-1] [lrange $upper 0 end-1]]
    if {[llength $hull] < 3} {return {}}
    return [ensure_ccw $hull]
}

proc ::mcp_glue_review::line_intersection_2d {start end clip_start clip_end} {
    foreach {sx sy} $start {}
    foreach {ex ey} $end {}
    foreach {ax ay} $clip_start {}
    foreach {bx by} $clip_end {}
    set rx [expr {$ex-$sx}]; set ry [expr {$ey-$sy}]
    set qx [expr {$bx-$ax}]; set qy [expr {$by-$ay}]
    set denominator [expr {$rx*$qy-$ry*$qx}]
    if {[expr {abs($denominator)}] < 1.0e-12} {return $end}
    set t [expr {(($ax-$sx)*$qy-($ay-$sy)*$qx)/$denominator}]
    return [list [expr {$sx+$t*$rx}] [expr {$sy+$t*$ry}]]
}

proc ::mcp_glue_review::clip_polygon_2d {subject clip_polygon} {
    set output $subject
    set clip_polygon [ensure_ccw $clip_polygon]
    set count [llength $clip_polygon]
    for {set index 0} {$index < $count} {incr index} {
        if {[llength $output] == 0} {break}
        set clip_start [lindex $clip_polygon $index]
        set clip_end [lindex $clip_polygon [expr {($index+1)%$count}]]
        set input $output
        set output {}
        set start [lindex $input end]
        foreach end $input {
            set start_side [cross2 $clip_start $clip_end $start]
            set end_side [cross2 $clip_start $clip_end $end]
            set start_inside [expr {$start_side >= -1.0e-9}]
            set end_inside [expr {$end_side >= -1.0e-9}]
            if {$end_inside} {
                if {!$start_inside} {lappend output [line_intersection_2d $start $end $clip_start $clip_end]}
                lappend output $end
            } elseif {$start_inside} {
                lappend output [line_intersection_2d $start $end $clip_start $clip_end]
            }
            set start $end
        }
    }
    return $output
}

proc ::mcp_glue_review::projected_overlap_ratio {eid footprint frame} {
    set element_polygon {}
    foreach point [element_points $eid] {lappend element_polygon [project_point_2d $point $frame]}
    if {[llength $element_polygon] < 3} {return 0.0}
    set element_area [polygon_area $element_polygon]
    if {$element_area < 1.0e-9} {return 0.0}
    set intersection [clip_polygon_2d [ensure_ccw $element_polygon] $footprint]
    return [expr {[polygon_area $intersection]/$element_area}]
}

proc ::mcp_glue_review::marker_projection_footprint {source_component_id surface_ids marker_box} {
    # The two GL faces together are an open cylinder.  Its four non-shared
    # curved boundary lines are sampled, projected onto the source shell plane,
    # and their convex hull is the actual projected glue footprint.  Shared
    # generatrix lines are internal seams, not part of the footprint boundary.
    if {[llength $surface_ids] != 2} {return {}}
    foreach {sid1 sid2} $surface_ids {}
    set frame [source_projection_frame $source_component_id [box_center $marker_box]]
    if {$frame eq ""} {return {}}
    set shared [shared_surface_edges $sid1 $sid2]
    set boundary [list_difference [concat [join [hm_getsurfaceedges $sid1]] [join [hm_getsurfaceedges $sid2]]] $shared]
    if {[llength $boundary] != 4} {return {}}
    set projected_points {}
    foreach line_id $boundary {
        for {set step 0} {$step <= 16} {incr step} {
            set parameter [expr {$step/16.0}]
            if {[catch {set point [hm_getcoordinatesofpointsonline $line_id $parameter]}]} {return {}}
            # HM 2017 returns this API as a one-item list whose item is the
            # actual x/y/z triple; normalise it before 3-D projection.
            if {[llength $point] == 1 && [llength [lindex $point 0]] == 3} {set point [lindex $point 0]}
            if {[llength $point] == 3} {lappend projected_points [project_point_2d $point $frame]}
        }
    }
    set footprint [convex_hull_2d $projected_points]
    if {[llength $footprint] < 3 || [polygon_area $footprint] < 1.0e-8} {return {}}
    return [dict create frame $frame polygon $footprint boundary_line_ids $boundary]
}

proc ::mcp_glue_review::projected_patch_elements {source_component_id surface_ids marker_box} {
    # An element is automatically selected only when >= 30% of its projected
    # source-shell area overlaps the projected open-cylinder footprint.  There
    # is intentionally no "edge mesh" warning: engineers can still add/remove
    # shells explicitly in the same review panel.
    set footprint_info [marker_projection_footprint $source_component_id $surface_ids $marker_box]
    if {$footprint_info eq ""} {return {}}
    set footprint [dict get $footprint_info polygon]
    set frame [dict get $footprint_info frame]
    set result {}
    foreach eid [component_shell_elements $source_component_id] {
        if {![element_box_intersects_box $eid $marker_box 15.0]} {continue}
        set ratio [projected_overlap_ratio $eid $footprint $frame]
        if {$ratio >= 0.3-1.0e-9} {lappend result $eid}
    }
    return [list_unique $result]
}

proc ::mcp_glue_review::local_elements {component_ids box patch_ids} {
    set nearby $patch_ids
    foreach cid $component_ids {
        foreach eid [component_shell_elements $cid] {
            if {[element_in_box $eid $box 15.0]} {lappend nearby $eid}
        }
    }
    return [list_unique $nearby]
}

proc ::mcp_glue_review::candidate_from_pair {surface_ids} {
    variable default_tolerance
    variable marker_component_id
    foreach {sid1 sid2} $surface_ids {}
    set box [pair_box $sid1 $sid2]
    set center [box_center $box]
    set component_ids {}
    set distances {}
    # Do not use the marker centre to infer structural bodies.  The two parts
    # are identified from the outer arcs of one small circular cross-section.
    # This remains reliable when the cylinder centre lies in a gap or on only
    # one of the two sheets.
    foreach {edge_links edge_ids} [cross_section_edge_shell_components $surface_ids $default_tolerance] {}
    foreach item [lrange $edge_links 0 1] {
        lappend component_ids [lindex $item 1]
        lappend distances [format %.4f [lindex $item 0]]
    }
    foreach {primary_edge_links ignored_primary_edge_ids} [primary_cross_section_edge_shell_components $surface_ids $default_tolerance] {}
    set same_component_two_sides 0
    if {[llength $component_ids] == 1 && [llength $primary_edge_links] == 2 && \
        [llength [lindex $primary_edge_links 0]] == 2 && \
        [llength [lindex $primary_edge_links 1]] == 2 && \
        [lindex [lindex $primary_edge_links 0] 1] == [lindex $component_ids 0] && \
        [lindex [lindex $primary_edge_links 1] 1] == [lindex $component_ids 0]} {
        set same_component_two_sides 1
    }
    set association_method outer_cross_section_edge_nearest_shell
    if {$same_component_two_sides} {set association_method outer_cross_section_edges_same_component_possible}
    set source_component_id 0
    set patch_ids {}
    if {[llength $component_ids] == 2} {
        set source_component_id [lindex $component_ids 0]
        set patch_ids [projected_patch_elements $source_component_id $surface_ids $box]
    }
    set status review
    set reason open_cylinder_two_side_faces
    if {$same_component_two_sides} {
        set reason single_component_double_layer_confirmation_required
    } elseif {[llength $component_ids] != 2} {
        set reason "linked_shell_component_count_[llength $component_ids]"
    } elseif {[llength $patch_ids] == 0} {
        set reason no_source_mesh_in_projected_marker_region
    }
    return [dict create kind glue_area status $status reason $reason decision pending marker_component_id $marker_component_id surface_ids $surface_ids shared_edge_ids [shared_surface_edges $sid1 $sid2] association_edge_line_ids $edge_ids association_method $association_method same_component_two_sides $same_component_two_sides patch_selection_method projected_overlap_ge_30pct center $center marker_box $box component_ids $component_ids component_distances $distances source_component_id $source_component_id auto_element_ids $patch_ids element_ids $patch_ids added_element_ids {} removed_element_ids {} link_tolerance $default_tolerance mesh_size $::mcp_glue_review::default_mesh_size]
}

proc ::mcp_glue_review::candidate_key {candidate} {
    return [join [lsort -integer [dict get $candidate surface_ids]] ,]
}

proc ::mcp_glue_review::candidate_triage_id {candidate} {
    return "glue:[join [lsort -integer [dict get $candidate surface_ids]] ,]:[join [lsort -integer [dict get $candidate component_ids]] ,]"
}

proc ::mcp_glue_review::apply_triage {} {
    variable candidates
    if {![info exists ::mcp_spot_weld_review::triage_rows] || [llength $::mcp_spot_weld_review::triage_rows] == 0} {return}
    array set triage_by_id {}
    foreach row $::mcp_spot_weld_review::triage_rows {
        foreach {candidate_id state confidence reason ai_reasons} $row {}
        set triage_by_id($candidate_id) [list $state $confidence $reason $ai_reasons]
    }
    set updated {}
    foreach candidate $candidates {
        set candidate_id [candidate_triage_id $candidate]
        if {[info exists triage_by_id($candidate_id)]} {
            foreach {state confidence reason ai_reasons} $triage_by_id($candidate_id) {}
            dict set candidate triage_state $state
            dict set candidate triage_reason $reason
            dict set candidate ai_confidence $confidence
            dict set candidate ai_reasons $ai_reasons
            dict set candidate decision [expr {$state eq "green_pending_submit" ? "approved" : "pending"}]
        }
        lappend updated $candidate
    }
    set candidates $updated
    update_review_counts
}

proc ::mcp_glue_review::candidate_priority {candidate} {
    # Put entries an engineer can actually approve first.  Incomplete geometry
    # remains in the audit list for review/exclusion, but never blocks the
    # beginning of a normal glue-review session.
    if {[llength [dict get $candidate component_ids]] == 2 && [llength [dict get $candidate element_ids]] > 0} {return 0}
    if {[llength [dict get $candidate component_ids]] == 2} {return 1}
    return 2
}

proc ::mcp_glue_review::compare_candidates {first second} {
    set first_priority [candidate_priority $first]
    set second_priority [candidate_priority $second]
    if {$first_priority != $second_priority} {return [expr {$first_priority-$second_priority}]}
    return [expr {[lindex [lsort -integer [dict get $first surface_ids]] 0]-[lindex [lsort -integer [dict get $second surface_ids]] 0]}]
}

proc ::mcp_glue_review::scan_candidates {} {
    variable marker_component_id
    variable marker_component_name
    variable marker_component_ids
    variable scan_all_components
    variable candidates
    variable current_index
    variable status_label
    set candidates {}
    set marker_component_id -1
    set marker_component_name ""
    set marker_component_ids {}
    # Candidate isolation masks entities in HM17.  Restore the full model
    # before collecting components so every source, including `cankao`, is
    # included in this topology scan.
    restore_full_display
    *createmark components 1 "all"
    foreach cid [hm_getmark components 1] {
        set free_surfaces [free_marker_surfaces $cid]
        if {[llength $free_surfaces] < 2} {continue}
        set pairs [pair_marker_surfaces $free_surfaces]
        if {[llength $pairs] == 0} {continue}
        lappend marker_component_ids $cid
        set marker_component_id $cid
        foreach pair $pairs {lappend candidates [candidate_from_pair $pair]}
    }
    set candidates [lsort -command ::mcp_glue_review::compare_candidates $candidates]
    set current_index 0
    update_review_counts
    if {$marker_component_id <= 0} {
        set status_label "\u5168\u7ec4\u4ef6\u62d3\u6251\u626b\u63cf\u672a\u627e\u5230\u5f00\u53e3\u5706\u67f1\u80f6\u7c98\u6807\u8bb0\u3002\u672a\u521b\u5efa\u4efb\u4f55 connector\u3002"
    } else {
        set marker_component_name "\u5168\u7ec4\u4ef6\u62d3\u6251\u626b\u63cf"
        set status_label "\u5df2\u4ece [llength $marker_component_ids] \u4e2a\u7ec4\u4ef6\u626b\u63cf\u5230 [llength $candidates] \u4e2a\u80f6\u7c98\u5019\u9009\uff1b\u5148\u6821\u5bf9\u7f51\u683c\u8d34\u7247\uff0c\u518d\u786e\u8ba4\u3002"
    }
    show_current
}

proc ::mcp_glue_review::update_review_counts {} {
    variable candidates
    variable review_counts_label
    set approved 0; set rejected 0; set pending 0
    foreach candidate $candidates {
        switch -- [dict get $candidate decision] {
            approved {incr approved}
            rejected {incr rejected}
            default {incr pending}
        }
    }
    set review_counts_label "\u5df2\u786e\u8ba4\uff1a$approved    \u5df2\u6392\u9664\uff1a$rejected    \u5f85\u5ba1\u6838\uff1a$pending"
}

proc ::mcp_glue_review::candidate_summary {candidate} {
    set names {}
    foreach cid [dict get $candidate component_ids] {lappend names "[component_name $cid] (#$cid)"}
    set surfaces [join [dict get $candidate surface_ids] {, }]
    set automatic [llength [dict get $candidate auto_element_ids]]
    set current [llength [dict get $candidate element_ids]]
    set added [llength [dict get $candidate added_element_ids]]
    set removed [llength [dict get $candidate removed_element_ids]]
    set topology "\u5f00\u53e3\u5706\u67f1\uff1a\u672a\u8bb0\u5f55\u5171\u4eab\u6bcd\u7ebf"
    if {[dict exists $candidate shared_edge_ids]} {set topology "\u5f00\u53e3\u5706\u67f1\uff1a\u5171\u4eab\u6bcd\u7ebf [join [dict get $candidate shared_edge_ids] {, }]\uff08\u65e0\u7aef\u76d6\uff09"}
    set face_mapping "\u5c0f\u5706\u622a\u9762\u5916\u8fb9\u7f18\u5173\u8054\uff1a\u672a\u8bc6\u522b"
    if {[dict exists $candidate association_edge_line_ids]} {
        set edge_names {}
        foreach cid [dict get $candidate component_ids] {lappend edge_names "[component_name $cid] (#$cid)"}
        set face_mapping "\u5c0f\u5706\u622a\u9762\u5916\u8fb9\u7f18 [join [dict get $candidate association_edge_line_ids] {, }] -> [join $edge_names {, }]"
    }
    return "\u80f6\u7c98\u6807\u8bb0\u9762\uff1a$surfaces\n$topology\n$face_mapping\n\u5173\u8054\u6784\u4ef6\uff1a[join $names {, }]\n\u7f51\u683c\u6e90\u4fa7\u6784\u4ef6\uff1a[dict get $candidate source_component_id]    \u8ddd\u79bb\uff1a[join [dict get $candidate component_distances] {, }] mm\n\u81ea\u52a8\u7f51\u683c\uff08\u5706\u73af\u6295\u5f71\u91cd\u53e0\u226530%\uff09\uff1a$automatic    \u5f53\u524d\u7f51\u683c\uff1a$current    \u4eba\u5de5\u589e\u52a0\uff1a$added    \u4eba\u5de5\u51cf\u5c11\uff1a$removed\n\u8fde\u63a5\u5bb9\u5dee\uff1a[format %.3f [dict get $candidate link_tolerance]] mm    \u533a\u57df\u7f51\u683c\u5c3a\u5bf8\uff1a[format %.3f [dict get $candidate mesh_size]] mm\n\u5224\u5b9a\uff1a[dict get $candidate status] / [dict get $candidate reason]    \u5f53\u524d\u51b3\u5b9a\uff1a[dict get $candidate decision]"
}

proc ::mcp_glue_review::update_mesh_count {candidate} {
    variable mesh_count_label
    set automatic [llength [dict get $candidate auto_element_ids]]
    set current [llength [dict get $candidate element_ids]]
    set added [llength [dict get $candidate added_element_ids]]
    set removed [llength [dict get $candidate removed_element_ids]]
    set mesh_count_label "\u5f53\u524d\u5df2\u9009\u80f6\u7c98\u7f51\u683c\uff1a$current \u4e2a    \u81ea\u52a8\u521d\u9009\uff08\u6295\u5f71\u91cd\u53e0>=30%\uff09\uff1a$automatic \u4e2a    \u4eba\u5de5\u589e\u52a0\uff1a$added    \u4eba\u5de5\u51cf\u5c11\uff1a$removed"
}

proc ::mcp_glue_review::restore_full_display {} {
    catch {*numbersclear}
    catch {*unmaskall}
    catch {*displayall}
    catch {*displayallgeometry}
    catch {*window 0 0 0 0 0}
}

proc ::mcp_glue_review::unmask_marker_ring_reference {} {
    variable marker_component_id
    if {$marker_component_id <= 0} {return}
    # In HM 2017, unmasking a component alone does not reliably unmask its
    # geometry after *maskall.  Explicitly restore the collector's free
    # surfaces and solids so the engineer can actually see the GL ring.
    catch {*createmark components 1 $marker_component_id; *unmaskentitymark components 1}
    set marker_surfaces {}
    *createmark surfs 1 "all"
    foreach sid [hm_getmark surfs 1] {
        if {[catch {set owner [hm_getentityvalue surfs $sid collector.id 0]}]} {continue}
        if {$owner == $marker_component_id} {lappend marker_surfaces $sid}
    }
    if {[llength $marker_surfaces] > 0} {
        catch {eval [linsert $marker_surfaces 0 *createmark surfs 1]; *unmaskentitymark surfs 1}
    }
    set marker_solids {}
    *createmark solids 1 "all"
    foreach solid [hm_getmark solids 1] {
        if {[catch {set owner [hm_getentityvalue solids $solid collector.id 0]}]} {continue}
        if {$owner == $marker_component_id} {lappend marker_solids $solid}
    }
    if {[llength $marker_solids] > 0} {
        catch {eval [linsert $marker_solids 0 *createmark solids 1]; *unmaskentitymark solids 1}
    }
}

proc ::mcp_glue_review::isolate_current {candidate} {
    variable marker_component_id
    variable show_marker_ring
    set component_ids [dict get $candidate component_ids]
    set patch_ids [dict get $candidate element_ids]
    set surface_ids [dict get $candidate surface_ids]
    set box [dict get $candidate marker_box]
    # The large GL ring solid stays masked.  The two extracted free faces that
    # define this open-cylinder marker remain visible as the mesh-review datum.
    catch {*numbersclear}
    catch {*unmaskall}
    catch {*maskall}
    if {$show_marker_ring} {unmask_marker_ring_reference}
    set nearby [local_elements $component_ids $box $patch_ids]
    if {[llength $nearby] > 0} {
        catch {eval [linsert $nearby 0 *createmark elems 1]; *unmaskentitymark elems 1}
    }
    if {[llength $surface_ids] > 0} {
        catch {eval [linsert $surface_ids 0 *createmark surfs 1]; *unmaskentitymark surfs 1}
    }
    foreach {x y z} [dict get $candidate center] {}
    catch {*graphuserwindow_byXYZandR $x $y $z [box_radius $box]}
    # graphuserwindow refreshes the graphics buffer in HM 2017, so highlighting
    # must happen afterwards or it becomes visually invisible.
    if {[llength $patch_ids] > 0} {
        catch {eval [linsert $patch_ids 0 *createmark elems 1]; hm_highlightmark elems 1 highlight; *numbersmark elems 1 1}
    }
    if {[llength $surface_ids] > 0} {
        catch {eval [linsert $surface_ids 0 *createmark surfs 1]; hm_highlightmark surfs 1 highlight; *numbersmark surfs 1 1}
    }
}

proc ::mcp_glue_review::show_editable_mesh {candidate} {
    variable marker_component_id
    variable show_marker_ring
    set source_component_id [dict get $candidate source_component_id]
    set box [dict get $candidate marker_box]
    set patch_ids [dict get $candidate element_ids]
    set surface_ids [dict get $candidate surface_ids]
    # During add/remove, only the current source-side local shell mesh is
    # visible and selectable.  The second linked component is restored as soon
    # as the selection panel closes, keeping the edit unambiguous.
    catch {*numbersclear}
    catch {*unmaskall}
    catch {*maskall}
    if {$show_marker_ring} {unmask_marker_ring_reference}
    set allowed [local_elements [list $source_component_id] $box $patch_ids]
    if {[llength $allowed] > 0} {catch {eval [linsert $allowed 0 *createmark elems 1]; *unmaskentitymark elems 1}}
    if {[llength $surface_ids] > 0} {catch {eval [linsert $surface_ids 0 *createmark surfs 1]; *unmaskentitymark surfs 1}}
    foreach {x y z} [dict get $candidate center] {}
    catch {*graphuserwindow_byXYZandR $x $y $z [box_radius $box]}
    if {[llength $patch_ids] > 0} {catch {eval [linsert $patch_ids 0 *createmark elems 1]; hm_highlightmark elems 1 highlight; *numbersmark elems 1 1}}
    if {[llength $surface_ids] > 0} {catch {eval [linsert $surface_ids 0 *createmark surfs 1]; hm_highlightmark surfs 1 highlight; *numbersmark surfs 1 1}}
}

proc ::mcp_glue_review::patch_connected {element_ids} {
    if {[llength $element_ids] <= 1} {return 1}
    array set visited {}
    set queue [list [lindex $element_ids 0]]
    set visited([lindex $element_ids 0]) 1
    while {[llength $queue] > 0} {
        set current [lindex $queue 0]
        set queue [lrange $queue 1 end]
        set current_nodes [hm_getvalue elems id=$current dataname=nodes]
        foreach other $element_ids {
            if {[info exists visited($other)]} {continue}
            set connected 0
            foreach node [hm_getvalue elems id=$other dataname=nodes] {
                if {[lsearch -exact $current_nodes $node] >= 0} {set connected 1; break}
            }
            if {$connected} {set visited($other) 1; lappend queue $other}
        }
    }
    return [expr {[array size visited] == [llength $element_ids]}]
}

proc ::mcp_glue_review::validate_patch {candidate element_ids} {
    set component_ids [dict get $candidate component_ids]
    set source_component_id [dict get $candidate source_component_id]
    if {[llength $component_ids] != 2 || $source_component_id <= 0} {
        return [list 0 "\u5fc5\u987b\u5148\u627e\u5230\u6070\u597d 2 \u4e2a\u5173\u8054\u7f51\u683c\u6784\u4ef6\u3002"]
    }
    if {[llength $element_ids] == 0} {return [list 0 "\u80f6\u7c98\u7f51\u683c\u4e0d\u80fd\u4e3a\u7a7a\u3002"]}
    foreach eid $element_ids {
        set owner [hm_getentityvalue elems $eid collector.id 0]
        set config [hm_getvalue elems id=$eid dataname=config]
        if {$owner != $source_component_id || !($config == 103 || $config == 104)} {
            return [list 0 "element $eid \u4e0d\u5c5e\u4e8e\u5f53\u524d\u80f6\u7c98\u7f51\u683c\u6e90\u4fa7\u7684 shell \u7ec4\u4ef6\u3002"]
        }
    }
    if {![patch_connected $element_ids]} {return [list 0 "\u7f51\u683c\u8d34\u7247\u5fc5\u987b\u4fdd\u6301\u8fde\u901a\uff1b\u8bf7\u6062\u590d\u4e2d\u95f4\u7f51\u683c\u6216\u5206\u4e3a\u4e24\u6761\u80f6\u7c98\u3002"]}
    return [list 1 ""]
}

proc ::mcp_glue_review::store_patch {candidate element_ids} {
    set element_ids [list_unique $element_ids]
    dict set candidate element_ids $element_ids
    set original [dict get $candidate auto_element_ids]
    dict set candidate added_element_ids [list_difference $element_ids $original]
    dict set candidate removed_element_ids [list_difference $original $element_ids]
    return $candidate
}

proc ::mcp_glue_review::hide_review_for_selection {} {
    set review_window $::mcp_spot_weld_review::window
    catch {wm attributes $review_window -topmost 0}
    catch {wm withdraw $review_window}
    return $review_window
}

proc ::mcp_glue_review::restore_review_after_selection {review_window} {
    catch {wm deiconify $review_window}
    catch {::mcp_spot_weld_review::keep_window_on_top $review_window}
}

proc ::mcp_glue_review::manual_associate_from_elements {} {
    variable candidates
    variable current_index
    variable status_label
    if {[llength $candidates] == 0} {return}
    set candidate [lindex $candidates $current_index]
    # This is intentionally element-based, not component-browser based.  Use
    # two simple modal selections rather than asking the engineer to remember
    # Ctrl/selection order inside one large panel.
    restore_full_display
    set review_window [hide_review_for_selection]
    catch {*clearmark elems 1}
    *createmarkpanel elems 1 "\u7b2c 1 \u6b65\uff1a\u5728\u9700\u8981\u94fa\u767d\u8272\u80f6\u7c98\u7f51\u683c\u7684\u4e00\u4fa7\uff0c\u53ea\u9009 1 \u4e2a shell\u3002\u9009\u597d\u540e\u5728\u9762\u677f\u4e2d\u786e\u8ba4\u9009\u62e9\u3002"
    set source_selected [hm_getmark elems 1]
    if {[llength $source_selected] != 1} {
        restore_review_after_selection $review_window
        set status_label "\u4eba\u5de5\u5173\u8054\u53d6\u6d88\uff1a\u7b2c 1 \u6b65\u5fc5\u987b\u53ea\u9009 1 \u4e2a\u767d\u8272\u80f6\u7c98\u7f51\u683c\u6240\u5728\u7684 shell\u3002"
        show_current
        return
    }
    # Keep the selected source shell visibly highlighted while the engineer
    # performs the second, opposing-body selection.
    catch {eval [linsert $source_selected 0 *createmark elems 1]; hm_highlightmark elems 1 highlight; *numbersmark elems 1 1}
    catch {*clearmark elems 1}
    *createmarkpanel elems 1 "\u7b2c 2 \u6b65\uff1a\u5728\u53e6\u4e00\u4e2a\u5b9e\u4f53\u6784\u4ef6\u4e0a\uff0c\u53ea\u9009 1 \u4e2a shell\u3002\u4e0d\u8981\u9009\u7b2c 1 \u6b65\u9ad8\u4eae\u7684\u6784\u4ef6\u3002"
    set target_selected [hm_getmark elems 1]
    restore_review_after_selection $review_window
    if {[llength $target_selected] != 1} {
        set status_label "\u4eba\u5de5\u5173\u8054\u53d6\u6d88\uff1a\u7b2c 2 \u6b65\u5fc5\u987b\u53ea\u9009 1 \u4e2a\u5bf9\u4fa7\u5b9e\u4f53\u4e0a\u7684 shell\u3002"
        show_current
        return
    }
    set selected [concat $source_selected $target_selected]
    set owners {}
    foreach eid $selected {
        set config [hm_getvalue elems id=$eid dataname=config]
        set owner [hm_getentityvalue elems $eid collector.id 0]
        if {!($config == 103 || $config == 104) || $owner <= 0 || [is_glue_marker_component $owner]} {
            set status_label "\u4eba\u5de5\u5173\u8054\u53d6\u6d88\uff1a\u53ea\u80fd\u9009\u62e9\u4e24\u4e2a\u4e0d\u540c\u5b9e\u4f53\u6784\u4ef6\u4e0a\u7684 shell \u7f51\u683c\u3002"
            show_current
            return
        }
        lappend owners $owner
    }
    if {[lindex $owners 0] == [lindex $owners 1]} {
        set status_label "\u4eba\u5de5\u5173\u8054\u53d6\u6d88\uff1a\u4e24\u4e2a shell \u5fc5\u987b\u6765\u81ea\u4e0d\u540c\u6784\u4ef6\u3002"
        show_current
        return
    }
    # Selection order is meaningful: first shell is the white-patch/source
    # side, second shell is the opposing glue target.
    set source_component_id [lindex $owners 0]
    set target_component_id [lindex $owners 1]
    set auto_patch [projected_patch_elements $source_component_id [dict get $candidate surface_ids] [dict get $candidate marker_box]]
    dict set candidate component_ids [list $source_component_id $target_component_id]
    dict set candidate component_distances {}
    dict set candidate source_component_id $source_component_id
    dict set candidate auto_element_ids $auto_patch
    dict set candidate element_ids $auto_patch
    dict set candidate added_element_ids {}
    dict set candidate removed_element_ids {}
    dict set candidate association_method manual_two_shell_elements
    dict set candidate reason manual_two_shell_elements
    dict set candidate status manual
    dict set candidate decision pending
    lset candidates $current_index $candidate
    set status_label "\u5df2\u4eba\u5de5\u5173\u8054\u4e24\u4e2a shell \u6784\u4ef6\uff1b\u8bf7\u68c0\u67e5\u767d\u8272\u7f51\u683c\u8303\u56f4\uff0c\u5fc5\u8981\u65f6\u518d\u589e\u51cf\u3002"
    show_current
}

proc ::mcp_glue_review::edit_patch {mode} {
    variable candidates
    variable current_index
    variable status_label
    if {[llength $candidates] == 0} {return}
    set candidate [lindex $candidates $current_index]
    if {[dict get $candidate source_component_id] <= 0} {
        set status_label "\u5f53\u524d\u5019\u9009\u6ca1\u6709\u6070\u597d\u4e24\u4e2a\u5173\u8054 shell \u6784\u4ef6\uff0c\u4e0d\u5141\u8bb8\u7f16\u8f91\u7f51\u683c\u3002"
        return
    }
    show_editable_mesh $candidate
    # *createmarkpanel is a HyperMesh modal selector.  A topmost review window
    # can cover it in HM 2017 and make the session appear frozen.
    set review_window [hide_review_for_selection]
    if {$mode eq "add"} {
        *createmarkpanel elems 1 "\u9009\u62e9\u8981\u589e\u52a0\u7684\u80f6\u7c98 shell \u7f51\u683c"
    } else {
        *createmarkpanel elems 1 "\u9009\u62e9\u8981\u51cf\u5c11\u7684\u80f6\u7c98 shell \u7f51\u683c"
    }
    set selected [hm_getmark elems 1]
    restore_review_after_selection $review_window
    if {[llength $selected] == 0} {set status_label "\u672a\u9009\u62e9\u4efb\u4f55\u7f51\u683c\uff0c\u5f53\u524d\u8d34\u7247\u672a\u6539\u53d8\u3002"; return}
    set current [dict get $candidate element_ids]
    if {$mode eq "add"} {set proposed [list_unique [concat $current $selected]]} else {set proposed [list_difference $current $selected]}
    foreach {valid message} [validate_patch $candidate $proposed] {}
    if {!$valid} {set status_label "\u672a\u4fdd\u5b58\u7f51\u683c\u4fee\u6539\uff1a$message"; return}
    set candidate [store_patch $candidate $proposed]
    lset candidates $current_index $candidate
    set status_label "\u5df2\u4fdd\u5b58\u4eba\u5de5\u7f51\u683c\u4fee\u6539\uff1b\u672a\u521b\u5efa\u4efb\u4f55 connector\u3002"
    show_current
}

proc ::mcp_glue_review::save_current_parameters {} {
    variable candidates
    variable current_index
    variable tolerance_var
    variable mesh_size_var
    variable status_label
    if {[llength $candidates] == 0} {return 1}
    if {[catch {set tolerance [positive_number $tolerance_var "\u80f6\u7c98\u8fde\u63a5\u5bb9\u5dee"]} err]} {set status_label $err; return 0}
    if {[catch {set mesh_size [positive_number $mesh_size_var "\u80f6\u7c98\u533a\u57df\u7f51\u683c\u5c3a\u5bf8"]} err]} {set status_label $err; return 0}
    set candidate [lindex $candidates $current_index]
    dict set candidate link_tolerance $tolerance
    dict set candidate mesh_size $mesh_size
    lset candidates $current_index $candidate
    set tolerance_var [format %.6g $tolerance]
    set mesh_size_var [format %.6g $mesh_size]
    return 1
}

proc ::mcp_glue_review::relink_current_with_tolerance {} {
    variable candidates
    variable current_index
    variable tolerance_var
    variable mesh_size_var
    variable default_tolerance
    variable status_label
    if {[llength $candidates] == 0} {return}
    if {[catch {set tolerance [positive_number $tolerance_var "\u80f6\u7c98\u8fde\u63a5\u5bb9\u5dee"]} err]} {set status_label $err; return}
    if {[catch {set mesh_size [positive_number $mesh_size_var "\u80f6\u7c98\u533a\u57df\u7f51\u683c\u5c3a\u5bf8"]} err]} {set status_label $err; return}
    set existing [lindex $candidates $current_index]
    set old_method [expr {[dict exists $existing association_method] ? [dict get $existing association_method] : ""}]
    if {[string match "manual_*" $old_method]} {
        dict set existing link_tolerance $tolerance
        dict set existing mesh_size $mesh_size
        lset candidates $current_index $existing
        set status_label "\u672c\u6761\u5df2\u4eba\u5de5\u5173\u8054\uff0c\u4e0d\u8986\u76d6\u6784\u4ef6\uff1b\u5df2\u53ea\u66f4\u65b0\u5bb9\u5dee\u53c2\u6570\u3002"
        show_current
        return
    }
    # candidate_from_pair uses the namespace default during discovery.  Change
    # it only for this one rebuild, then restore it immediately.
    set original_default_tolerance $default_tolerance
    set default_tolerance $tolerance
    set rc [catch {set rebuilt [candidate_from_pair [dict get $existing surface_ids]]} rebuild_error]
    set default_tolerance $original_default_tolerance
    if {$rc} {set status_label "\u6309\u65b0\u5bb9\u5dee\u91cd\u5173\u8054\u5931\u8d25\uff1a$rebuild_error"; return}
    dict set rebuilt link_tolerance $tolerance
    dict set rebuilt mesh_size $mesh_size
    dict set rebuilt decision pending
    # Retain an engineer-edited patch only if the source side did not change.
    if {[dict get $rebuilt source_component_id] == [dict get $existing source_component_id] && [dict get $existing source_component_id] > 0} {
        set rebuilt [store_patch $rebuilt [dict get $existing element_ids]]
    }
    lset candidates $current_index $rebuilt
    set status_label "\u5df2\u4f7f\u7528 $tolerance mm \u91cd\u65b0\u5173\u8054\u672c\u6761\uff1b\u7ed3\u679c\u5df2\u91cd\u7f6e\u4e3a\u5f85\u5ba1\u6838\uff0c\u8bf7\u786e\u8ba4\u6e90\u4fa7\u4e0e\u5bf9\u4fa7\u6784\u4ef6\u3002"
    show_current
}

proc ::mcp_glue_review::show_current {} {
    variable candidates
    variable current_index
    variable candidate_label
    variable detail_label
    variable tolerance_var
    variable mesh_size_var
    if {[llength $candidates] == 0} {
        set candidate_label "\u6ca1\u6709\u53ef\u5ba1\u6838\u7684\u80f6\u7c98\u5019\u9009\u3002"
        set detail_label "\u672a\u521b\u5efa\u4efb\u4f55 connector\u3002"
        return
    }
    if {$current_index < 0} {set current_index 0}
    if {$current_index >= [llength $candidates]} {set current_index [expr {[llength $candidates]-1}]}
    set candidate [lindex $candidates $current_index]
    if {[dict exists $candidate marker_component_id]} {
        set ::mcp_glue_review::marker_component_id [dict get $candidate marker_component_id]
    }
    update_review_counts
    set candidate_label "\u80f6\u7c98\u5019\u9009 [expr {$current_index+1}]/[llength $candidates]"
    set detail_label [candidate_summary $candidate]
    update_mesh_count $candidate
    set tolerance_var [dict get $candidate link_tolerance]
    set mesh_size_var [dict get $candidate mesh_size]
    foreach {valid message} [validate_patch $candidate [dict get $candidate element_ids]] {}
    if {$valid} {
        set ::mcp_glue_review::status_label "\u8bf7\u5ba1\u6838\u4e24\u5f20\u5f00\u53e3\u5706\u67f1\u9762\u4e0e\u767d\u8272\u80f6\u7c98\u7f51\u683c\uff1b\u7f51\u683c\u8303\u56f4\u6b63\u786e\u540e\u53ef\u786e\u8ba4\u3002"
    } else {
        set ::mcp_glue_review::status_label "\u672c\u6761\u4e0d\u53ef\u786e\u8ba4\uff1a$message"
    }
    isolate_current $candidate
}

proc ::mcp_glue_review::next_candidate {step} {
    variable candidates
    variable current_index
    if {![save_current_parameters] || [llength $candidates] == 0} {return}
    set current_index [expr {max(0, min([llength $candidates]-1, $current_index+$step))}]
    show_current
}

proc ::mcp_glue_review::set_current_decision {decision} {
    variable candidates
    variable current_index
    variable status_label
    if {[llength $candidates] == 0 || ![save_current_parameters]} {return}
    set candidate [lindex $candidates $current_index]
    if {$decision eq "approved"} {
        foreach {valid message} [validate_patch $candidate [dict get $candidate element_ids]] {}
        if {!$valid} {set status_label "\u4e0d\u80fd\u786e\u8ba4\uff1a$message"; return}
    }
    dict set candidate decision $decision
    lset candidates $current_index $candidate
    update_review_counts
    if {$current_index < [expr {[llength $candidates]-1}]} {
        set status_label [expr {$decision eq "approved" ? "\u5df2\u786e\u8ba4\uff1a\u5df2\u4fdd\u7559\u5f53\u524d\u7f51\u683c\u8d34\u7247\uff0c\u81ea\u52a8\u5207\u6362\u5230\u4e0b\u4e00\u6761\u3002" : "\u5df2\u6392\u9664\uff1a\u6b64\u6761\u4e0d\u4f1a\u521b\u5efa\uff0c\u81ea\u52a8\u5207\u6362\u5230\u4e0b\u4e00\u6761\u3002"}]
        next_candidate 1
    } else {
        set status_label [expr {$decision eq "approved" ? "\u5df2\u786e\u8ba4\u6700\u540e\u4e00\u6761\uff1b\u53ef\u5728\u6700\u7ec8\u6309\u94ae\u4e8c\u6b21\u786e\u8ba4\u540e\u521b\u5efa\u3002" : "\u5df2\u6392\u9664\u6700\u540e\u4e00\u6761\u3002"}]
        show_current
    }
}

proc ::mcp_glue_review::json_quote {value} {
    return "\"[string map [list "\\" "\\\\" "\"" "\\\"" "\n" "\\n" "\r" "\\r" "\t" "\\t"] $value]\""
}

proc ::mcp_glue_review::json_number_array {values} {return "\[[join $values ,]\]"}

proc ::mcp_glue_review::candidate_json {candidate} {
    return "{\"surface_ids\":[json_number_array [dict get $candidate surface_ids]],\"decision\":[json_quote [dict get $candidate decision]],\"status\":[json_quote [dict get $candidate status]],\"reason\":[json_quote [dict get $candidate reason]],\"component_ids\":[json_number_array [dict get $candidate component_ids]],\"source_component_id\":[dict get $candidate source_component_id],\"auto_element_ids\":[json_number_array [dict get $candidate auto_element_ids]],\"element_ids\":[json_number_array [dict get $candidate element_ids]],\"added_element_ids\":[json_number_array [dict get $candidate added_element_ids]],\"removed_element_ids\":[json_number_array [dict get $candidate removed_element_ids]],\"link_tolerance\":[dict get $candidate link_tolerance],\"mesh_size\":[dict get $candidate mesh_size]}"
}

proc ::mcp_glue_review::write_audit {event success message created_count} {
    variable audit_path
    variable session_id
    variable model_path
    variable output_path
    variable marker_component_id
    variable candidates
    set rows {}
    foreach candidate $candidates {lappend rows [candidate_json $candidate]}
    set f [open $audit_path w]
    puts $f "{\"schema_version\":\"1.0\",\"session_id\":[json_quote $session_id],\"event\":[json_quote $event],\"success\":$success,\"message\":[json_quote $message],\"model_path\":[json_quote $model_path],\"output_model_path\":[json_quote $output_path],\"marker_component_id\":$marker_component_id,\"created_count\":$created_count,\"candidates\":[join $rows ,]}"
    close $f
}

proc ::mcp_glue_review::create_connector {candidate} {
    set elements [dict get $candidate element_ids]
    set component_ids [dict get $candidate component_ids]
    set tolerance [dict get $candidate link_tolerance]
    set mesh_size [dict get $candidate mesh_size]
    set details [list "link_elems_geom=elems" "link_rule=now" "relink_rule=none" "tol_flag=1" "tol=[format %.6f $tolerance]" "seam_area_group=0" "area_mesh_type=1" "area_mesh_size=[format %.6f $mesh_size]" "ce_nonnormal=0" "ce_systems=0" "ce_connectivity=2" "ce_dir_assign=0" "ce_prop_opt=0" "ce_areathicknesstype=1" "ce_jacobian_flag=0" "ce_jacobian=0.000000" "ce_aspect_flag=0" "ce_aspect=0.000000" "ce_areastacksize=1" "ce_hexaoffsetcheck=1"]
    eval [linsert $elements 0 *createmark elems 1]
    eval [linsert $component_ids 0 *createmark components 2]
    *createstringarray 20 {*}$details
    *CE_ConnectorCreateByMarkAndRealizeWithDetails elements 1 "area" 2 components 2 "nastran" 1001 127 $tolerance 1 20
}

proc ::mcp_glue_review::apply_approved {} {
    variable candidates
    variable applied
    variable backup_path
    variable model_path
    variable output_path
    variable status_label
    if {$applied} {set status_label "\u672c\u4f1a\u8bdd\u5df2\u6267\u884c\u8fc7\u80f6\u7c98\u521b\u5efa\uff0c\u5df2\u9501\u5b9a\u4ee5\u9632\u6b62\u91cd\u590d\u521b\u5efa\u3002"; return}
    if {![save_current_parameters]} {return}
    set approved {}
    foreach candidate $candidates {if {[dict get $candidate decision] eq "approved"} {lappend approved $candidate}}
    if {[llength $approved] == 0} {set status_label "\u6ca1\u6709\u5df2\u786e\u8ba4\u7684\u80f6\u7c98\u5019\u9009\uff0c\u672a\u521b\u5efa\u3002"; write_audit apply_skipped false "no approved glue candidates" 0; return}
    set answer [tk_messageBox -type yesno -icon warning -title "\u786e\u8ba4\u521b\u5efa\u80f6\u7c98" -message "\u5c06\u6309\u5f53\u524d\u4eba\u5de5\u7f16\u8f91\u540e\u7684\u7f51\u683c\u521b\u5efa [llength $approved] \u4e2a area connector\uff0c\u5e76\u4fdd\u5b58\u5f53\u524d\u6a21\u578b\u3002\n\u7b2c\u4e00\u6b21\u786e\u8ba4\uff1a\u662f\u5426\u7ee7\u7eed\uff1f"]
    if {$answer ne "yes"} {return}
    set answer [tk_messageBox -type yesno -icon warning -title "\u4e8c\u6b21\u786e\u8ba4\u521b\u5efa" -message "\u8bf7\u518d\u6b21\u786e\u8ba4\uff1a\u73b0\u5728\u521b\u5efa [llength $approved] \u4e2a\u5df2\u786e\u8ba4\u80f6\u7c98\u5e76\u4fdd\u5b58\u3002\n\u70b9\u51fb\u201c\u5426\u201d\u4e0d\u4f1a\u521b\u5efa\u3001\u4e0d\u4f1a\u4fdd\u5b58\u3002"]
    if {$answer ne "yes"} {return}
    if {[catch {*writefile "$backup_path" 1} backup_error]} {set status_label "\u6062\u590d\u5feb\u7167\u4fdd\u5b58\u5931\u8d25\uff0c\u672a\u521b\u5efa\uff1a$backup_error"; write_audit apply_failed false $backup_error 0; return}
    set created 0; set create_error ""
    catch {*beginhistorystate "MCP glue review"}
    foreach candidate $approved {if {[catch {create_connector $candidate} create_error]} {break}; incr created}
    catch {*endhistorystate "MCP glue review"}
    set applied 1
    if {$create_error ne ""} {set status_label "\u521b\u5efa\u5728\u7b2c [expr {$created+1}] \u6761\u5931\u8d25\uff1a$create_error\u3002\u6a21\u578b\u672a\u4fdd\u5b58\u3002"; write_audit apply_failed false $create_error $created; return}
    if {[catch {*writefile "$output_path" 1} save_error]} {set status_label "connector \u5df2\u521b\u5efa\u4f46\u7ed3\u679c\u6a21\u578b\u4fdd\u5b58\u5931\u8d25\uff1a$save_error"; write_audit apply_failed false $save_error $created; return}
    write_audit apply_saved true "glue area connectors created and result model saved" $created
    restore_full_display
    set status_label "\u5df2\u521b\u5efa $created \u4e2a\u80f6\u7c98 area connector\uff0c\u5e76\u53e6\u5b58\u4e3a\u7ed3\u679c\u6a21\u578b\uff1a$output_path"
    tk_messageBox -type ok -icon info -title "\u80f6\u7c98\u521b\u5efa\u5b8c\u6210" -message $status_label
}

proc ::mcp_glue_review::build_ui {page} {
    ttk::label $page.title -text "\u80f6\u7c98\u8bc6\u522b\u4e0e\u7f51\u683c\u5ba1\u6838" -font {{Microsoft YaHei UI} 14 bold}
    ttk::label $page.candidate -textvariable ::mcp_glue_review::candidate_label -font {{Microsoft YaHei UI} 12 bold}
    ttk::label $page.counts -textvariable ::mcp_glue_review::review_counts_label -font {{Microsoft YaHei UI} 11 bold}
    ttk::label $page.detail -textvariable ::mcp_glue_review::detail_label -justify left -wraplength 700 -font {{Microsoft YaHei UI} 12}
    ttk::label $page.mesh_count -textvariable ::mcp_glue_review::mesh_count_label -font {{Microsoft YaHei UI} 12 bold}
    ttk::frame $page.parameters
    ttk::label $page.parameters.tolerance_label -text "\u80f6\u7c98\u8fde\u63a5\u5bb9\u5dee (mm)\uff1a" -font {{Microsoft YaHei UI} 11}
    ttk::entry $page.parameters.tolerance_value -textvariable ::mcp_glue_review::tolerance_var -width 8 -font {{Microsoft YaHei UI} 11}
    ttk::label $page.parameters.size_label -text "\u533a\u57df\u7f51\u683c\u5c3a\u5bf8 (mm)\uff1a" -font {{Microsoft YaHei UI} 11}
    ttk::entry $page.parameters.size_value -textvariable ::mcp_glue_review::mesh_size_var -width 8 -font {{Microsoft YaHei UI} 11}
    ttk::button $page.parameters.relink -text "\u6309\u5f53\u524d\u5bb9\u5dee\u91cd\u65b0\u5173\u8054\u672c\u6761" -command ::mcp_glue_review::relink_current_with_tolerance
    ttk::label $page.parameters.hint -text "\u4ec5\u91cd\u5173\u8054\u672c\u6761\uff1b\u5df2\u4eba\u5de5\u5173\u8054\u7684\u6784\u4ef6\u4e0d\u4f1a\u88ab\u8986\u76d6\u3002" -font {{Microsoft YaHei UI} 10}
    pack $page.parameters.tolerance_label $page.parameters.tolerance_value $page.parameters.size_label $page.parameters.size_value $page.parameters.relink $page.parameters.hint -side left -padx 4
    ttk::frame $page.navigation
    ttk::button $page.navigation.prev -text "\u4e0a\u4e00\u4e2a" -command {::mcp_glue_review::next_candidate -1}
    ttk::button $page.navigation.next -text "\u4e0b\u4e00\u4e2a\uff08\u4e0d\u786e\u8ba4\u3001\u4e0d\u6392\u9664\uff09" -command {::mcp_glue_review::next_candidate 1}
    ttk::button $page.navigation.approve -text "\u786e\u8ba4\uff08\u5f85\u521b\u5efa\uff09" -command {::mcp_glue_review::set_current_decision approved}
    ttk::button $page.navigation.reject -text "\u6392\u9664" -command {::mcp_glue_review::set_current_decision rejected}
    pack $page.navigation.prev $page.navigation.next $page.navigation.approve $page.navigation.reject -side left -padx 4
    ttk::labelframe $page.mesh -text "\u80f6\u7c98\u7f51\u683c\u4eba\u5de5\u7f16\u8f91" -padding 8
    ttk::label $page.mesh.hint -text "\u7f51\u683c\u4fee\u6539\u4ec5\u5141\u8bb8\u5f53\u524d\u7f51\u683c\u6e90\u4fa7\u7684 shell\uff1b\u4fdd\u5b58\u65f6\u6821\u9a8c\u8fde\u901a\u6027\u3002" -font {{Microsoft YaHei UI} 10}
    ttk::checkbutton $page.mesh.ring -text "\u663e\u793a\u80f6\u7c98\u5706\u73af\u53c2\u7167" -variable ::mcp_glue_review::show_marker_ring -command ::mcp_glue_review::show_current
    ttk::button $page.mesh.associate -text "\u5206\u4e24\u6b65\u70b9\u9009\u4e24\u4fa7\u7f51\u683c\u91cd\u65b0\u5173\u8054" -command ::mcp_glue_review::manual_associate_from_elements
    ttk::button $page.mesh.add -text "\u589e\u52a0\u80f6\u7c98\u7f51\u683c" -command {::mcp_glue_review::edit_patch add}
    ttk::button $page.mesh.remove -text "\u51cf\u5c11\u80f6\u7c98\u7f51\u683c" -command {::mcp_glue_review::edit_patch remove}
    pack $page.mesh.hint $page.mesh.ring $page.mesh.associate $page.mesh.add $page.mesh.remove -side left -padx 5
    ttk::button $page.apply -text "\u521b\u5efa\u6240\u6709\u5df2\u786e\u8ba4\u80f6\u7c98\u5e76\u4fdd\u5b58" -command ::mcp_glue_review::apply_approved
    ttk::label $page.status -textvariable ::mcp_glue_review::status_label -justify left -wraplength 700 -font {{Microsoft YaHei UI} 11}
    pack $page.title -anchor w -pady {0 10}
    pack $page.candidate -anchor w -pady 3
    pack $page.counts -anchor w -pady 3
    pack $page.detail -anchor w -fill x -pady 4
    pack $page.mesh_count -anchor w -pady {3 6}
    pack $page.parameters -anchor w -pady 7
    pack $page.navigation -anchor w -pady 5
    pack $page.mesh -anchor w -fill x -pady 6
    pack $page.apply -anchor w -pady {8 5}
    pack $page.status -anchor w -fill x -pady 5
}

proc ::mcp_glue_review::restore_candidates_from_removed_duplicate_filter {} {
    # Older in-memory sessions may contain the short-lived automatic
    # "existing_connector" state.  Restore only those entries to ordinary
    # engineer review; no connector is inferred or filtered any more.
    variable candidates
    for {set index 0} {$index < [llength $candidates]} {incr index} {
        set candidate [lindex $candidates $index]
        if {[dict get $candidate status] ne "existing_connector" && [dict get $candidate decision] ne "existing"} {continue}
        set method [expr {[dict exists $candidate association_method] ? [dict get $candidate association_method] : ""}]
        if {[string match "manual_*" $method]} {
            dict set candidate status manual
            dict set candidate reason manual_two_shell_elements
        } else {
            dict set candidate status review
            if {[llength [dict get $candidate component_ids]] != 2} {
                dict set candidate reason "linked_shell_component_count_[llength [dict get $candidate component_ids]]"
            } elseif {[llength [dict get $candidate element_ids]] == 0} {
                dict set candidate reason no_source_mesh_in_projected_marker_region
            } else {
                dict set candidate reason open_cylinder_two_side_faces
            }
        }
        dict set candidate decision pending
        lset candidates $index $candidate
    }
    update_review_counts
}

proc ::mcp_glue_review::start {} {
    variable candidates
    variable marker_component_id
    if {[llength $candidates] == 0 && $marker_component_id <= 0} {scan_candidates} else {restore_candidates_from_removed_duplicate_filter}
    apply_triage
    show_current
}

proc ::mcp_spot_weld_review::d3 {x1 y1 z1 x2 y2 z2} {
    return [expr {sqrt(($x1-$x2)*($x1-$x2)+($y1-$y2)*($y1-$y2)+($z1-$z2)*($z1-$z2))}]
}

proc ::mcp_spot_weld_review::boxdist {x y z xmin ymin zmin xmax ymax zmax} {
    set dx 0.0
    if {$x < $xmin} {set dx [expr {$xmin-$x}]} elseif {$x > $xmax} {set dx [expr {$x-$xmax}]}
    set dy 0.0
    if {$y < $ymin} {set dy [expr {$ymin-$y}]} elseif {$y > $ymax} {set dy [expr {$y-$ymax}]}
    set dz 0.0
    if {$z < $zmin} {set dz [expr {$zmin-$z}]} elseif {$z > $zmax} {set dz [expr {$z-$zmax}]}
    return [expr {sqrt($dx*$dx+$dy*$dy+$dz*$dz)}]
}

proc ::mcp_spot_weld_review::marker_shape {solid} {
    variable marker_max_size
    set surfs [hm_getsurfacesfromsolid $solid]
    set xmin 1e99
    set ymin 1e99
    set zmin 1e99
    set xmax -1e99
    set ymax -1e99
    set zmax -1e99
    set edge_counts {}
    foreach surf $surfs {
        foreach {x0 y0 z0 x1 y1 z1} [join [hm_getgeometrybox surfs $surf]] {}
        if {$x0 < $xmin} {set xmin $x0}
        if {$y0 < $ymin} {set ymin $y0}
        if {$z0 < $zmin} {set zmin $z0}
        if {$x1 > $xmax} {set xmax $x1}
        if {$y1 > $ymax} {set ymax $y1}
        if {$z1 > $zmax} {set zmax $z1}
        lappend edge_counts [llength [join [hm_getsurfaceedges $surf]]]
    }
    set sx [expr {$xmax-$xmin}]
    set sy [expr {$ymax-$ymin}]
    set sz [expr {$zmax-$zmin}]
    if {$sx > $marker_max_size || $sy > $marker_max_size || $sz > $marker_max_size} {return {}}
    set signature [lsort -integer $edge_counts]
    if {[llength $surfs] == 4 && $signature eq {2 2 4 4}} {
        return [dict create kind cylinder required_component_count 2 point_tolerance $::mcp_spot_weld_review::center_tolerance marker_size [list $sx $sy $sz]]
    }
    if {[llength $surfs] == 5 && $signature eq {3 3 4 4 4}} {
        return [dict create kind triangular_prism required_component_count 3 point_tolerance $::mcp_spot_weld_review::triangular_center_tolerance marker_size [list $sx $sy $sz]]
    }
    return {}
}

proc ::mcp_spot_weld_review::component_name {cid} {
    if {[catch {set name [hm_getvalue comps id=$cid dataname=name]}]} {return "component-$cid"}
    return $name
}

proc ::mcp_spot_weld_review::component_is_excluded {cid} {
    variable marker_component_ids
    variable excluded_component_names
    if {[lsearch -exact $marker_component_ids $cid] >= 0} {return 1}
    set name [component_name $cid]
    foreach excluded $excluded_component_names {
        if {[string equal -nocase $name $excluded]} {return 1}
    }
    return 0
}

proc ::mcp_spot_weld_review::positive_number {value field_name} {
    if {[catch {set number [expr {double($value)}]}] || $number <= 0.0} {
        return -code error "$field_name\u5fc5\u987b\u662f\u5927\u4e8e 0 \u7684\u6570\u5b57\u3002"
    }
    return $number
}

proc ::mcp_spot_weld_review::ensure_nastran_connector_template {} {
    # Visible HM sessions may already have a solver profile, while hmbatch
    # starts empty.  Make the Nastran template explicit before realization.
    set template_candidates {}
    if {![catch {set executable [info nameofexecutable]}] && $executable ne ""} {
        set install_root [file dirname [file dirname [file dirname [file dirname $executable]]]]
        lappend template_candidates [file join $install_root templates feoutput nastran general]
    }
    if {[info exists ::env(HYPERMESH_NASTRAN_TEMPLATE_DIR)] && $::env(HYPERMESH_NASTRAN_TEMPLATE_DIR) ne ""} {
        lappend template_candidates $::env(HYPERMESH_NASTRAN_TEMPLATE_DIR)
    }
    foreach template [lsort -unique $template_candidates] {
        if {![file exists $template]} {continue}
        if {![catch {*templatefileset "$template"}]} {return}
    }
    return -code error "Unable to load the Nastran FE template required for spot-weld realization."
}

proc ::mcp_spot_weld_review::refresh_fe_components {} {
    variable fe_components
    set fe_components {}
    *createmark components 1 "all"
    foreach fe_cid [hm_getmark components 1] {
        if {[component_is_excluded $fe_cid]} {continue}
        set elems [hm_getvalue comps id=$fe_cid dataname=elements]
        if {[llength $elems] == 0} {continue}
        if {[catch {foreach {xmax ymax zmax xmin ymin zmin xc yc zc} [hm_ce_entitycoordinatesget comps $fe_cid] {}}]} {continue}
        lappend fe_components [list $fe_cid $xmin $ymin $zmin $xmax $ymax $zmax]
    }
}

proc ::mcp_spot_weld_review::linked_components {center tolerance} {
    variable fe_components
    if {[llength $fe_components] == 0} {refresh_fe_components}
    foreach {x y z} $center {}
    set links {}
    foreach entry $fe_components {
        foreach {fe_cid bx0 by0 bz0 bx1 by1 bz1} $entry {}
        if {[boxdist $x $y $z $bx0 $by0 $bz0 $bx1 $by1 $bz1] > $tolerance} {continue}
        *createmark elems 1 "by comp id" $fe_cid
        if {[catch {set node [hm_getclosestnode $x $y $z 1]}] || $node == 0} {continue}
        foreach {nx ny nz} [lindex [hm_nodevalue $node] 0] {}
        set distance [d3 $x $y $z $nx $ny $nz]
        if {$distance <= $tolerance} {lappend links [list $distance $fe_cid]}
    }
    return [lsort -real -index 0 $links]
}

proc ::mcp_spot_weld_review::relink_candidate {candidate tolerance} {
    # Manual additions have no marker center; keep their human-selected parts.
    if {[dict get $candidate marker_solid_id] <= 0 || [llength [dict get $candidate center]] != 3} {return $candidate}
    set links [linked_components [dict get $candidate center] $tolerance]
    set component_ids {}
    set component_distances {}
    foreach link $links {
        foreach {distance fe_cid} $link {}
        lappend component_ids $fe_cid
        lappend component_distances $distance
    }
    dict set candidate component_ids $component_ids
    dict set candidate component_distances $component_distances
    set required [dict get $candidate required_component_count]
    set confirmed_multiface 0
    if {[dict exists $candidate single_entity_multiface]} {
        set confirmed_multiface [dict get $candidate single_entity_multiface]
    }
    if {[llength $component_ids] == $required || $confirmed_multiface} {
        dict set candidate status high
        if {$confirmed_multiface} {
            dict set candidate reason single_entity_multiface_confirmed
        } else {
            dict set candidate reason "exactly_${required}_fe_components"
        }
    } else {
        dict set candidate status review
        dict set candidate reason "fe_component_count_[llength $component_ids]"
        if {[dict get $candidate decision] eq "approved"} {dict set candidate decision pending}
    }
    return $candidate
}

proc ::mcp_spot_weld_review::find_marker_components {} {
    variable marker_aliases
    array set point_counts {}
    array set shape_counts {}
    array set component_names {}
    *createmark components 1 "all"
    foreach cid [hm_getmark components 1] {
        set component_names($cid) [component_name $cid]
    }
    *createmark points 1 "all"
    foreach pid [hm_getmark points 1] {
        set cid [hm_getentityvalue points $pid collector.id 0]
        if {$cid > 0} {incr point_counts($cid)}
    }
    *createmark solids 1 "all"
    foreach solid [hm_getmark solids 1] {
        set cid [hm_getentityvalue solids $solid collector.id 0]
        if {$cid <= 0} {continue}
        if {[marker_shape $solid] ne {}} {incr shape_counts($cid)}
    }
    set all_options {}
    set alias_options {}
    foreach cid [array names component_names] {
        set shapes [expr {[info exists shape_counts($cid)] ? $shape_counts($cid) : 0}]
        set points [expr {[info exists point_counts($cid)] ? $point_counts($cid) : 0}]
        if {$shapes <= 0 || $points <= 0} {continue}
        set entry [dict create component_id $cid component_name $component_names($cid) shape_markers $shapes reference_points $points]
        lappend all_options $entry
        foreach alias $marker_aliases {
            if {[string equal -nocase $component_names($cid) $alias]} {
                lappend alias_options $entry
                break
            }
        }
    }
    if {[llength $alias_options] > 0} {return $alias_options}
    return $all_options
}

proc ::mcp_spot_weld_review::candidate_priority {candidate} {
    if {[dict get $candidate status] eq "high"} {return 0}
    if {[candidate_is_complete $candidate]} {return 1}
    if {[llength [dict get $candidate component_ids]] > 0} {return 2}
    return 3
}

proc ::mcp_spot_weld_review::compare_candidates {first second} {
    set first_priority [candidate_priority $first]
    set second_priority [candidate_priority $second]
    if {$first_priority != $second_priority} {return [expr {$first_priority - $second_priority}]}
    return [expr {[dict get $first marker_solid_id] - [dict get $second marker_solid_id]}]
}

proc ::mcp_spot_weld_review::candidate_is_complete {candidate} {
    set component_count [llength [dict get $candidate component_ids]]
    if {$component_count == [dict get $candidate required_component_count]} {return 1}
    if {$component_count != 1 || ![dict exists $candidate single_entity_multiface]} {return 0}
    return [expr {[dict get $candidate single_entity_multiface] ? 1 : 0}]
}

proc ::mcp_spot_weld_review::scan_marker {cid} {
    scan_markers [list $cid]
}

proc ::mcp_spot_weld_review::scan_markers {cids} {
    variable marker_component_id
    variable marker_component_ids
    variable candidates
    variable current_index
    variable default_tolerance
    variable default_diameter
    variable status_label
    set marker_component_ids [lsort -integer -unique $cids]
    if {[llength $marker_component_ids] == 0} {return}
    set marker_component_id [lindex $marker_component_ids 0]
    set candidates {}
    set current_index 0
    catch {destroy .mcp_spot_marker_selector}
    refresh_fe_components
    foreach scan_marker_id $marker_component_ids {
    set marker_component_id $scan_marker_id
    set ref_points {}
    *createmark points 1 "all"
    foreach pid [hm_getmark points 1] {
        if {[hm_getentityvalue points $pid collector.id 0] != $marker_component_id} {continue}
        lappend ref_points [list $pid [hm_getvalue points id=$pid dataname=x] [hm_getvalue points id=$pid dataname=y] [hm_getvalue points id=$pid dataname=z]]
    }
    *createmark solids 1 "all"
    foreach solid [hm_getmark solids 1] {
        if {[hm_getentityvalue solids $solid collector.id 0] != $marker_component_id} {continue}
        set shape [marker_shape $solid]
        if {$shape eq {}} {continue}
        set marker_size [dict get $shape marker_size]
        foreach {sx sy sz} $marker_size {}
        foreach surf [hm_getsurfacesfromsolid $solid] {
            foreach {x0 y0 z0 x1 y1 z1} [join [hm_getgeometrybox surfs $surf]] {}
            if {![info exists xmin] || $x0 < $xmin} {set xmin $x0}
            if {![info exists ymin] || $y0 < $ymin} {set ymin $y0}
            if {![info exists zmin] || $z0 < $zmin} {set zmin $z0}
            if {![info exists xmax] || $x1 > $xmax} {set xmax $x1}
            if {![info exists ymax] || $y1 > $ymax} {set ymax $y1}
            if {![info exists zmax] || $z1 > $zmax} {set zmax $z1}
        }
        set x [expr {($xmin+$xmax)/2.0}]
        set y [expr {($ymin+$ymax)/2.0}]
        set z [expr {($zmin+$zmax)/2.0}]
        unset -nocomplain xmin ymin zmin xmax ymax zmax
        set best_id -1
        set best_distance 1e99
        foreach point $ref_points {
            foreach {pid px py pz} $point {}
            set distance [d3 $x $y $z $px $py $pz]
            if {$distance < $best_distance} {set best_distance $distance; set best_id $pid}
        }
        set kind [dict get $shape kind]
        set required [dict get $shape required_component_count]
        if {$best_distance > [dict get $shape point_tolerance]} {
            lappend candidates [dict create kind $kind required_component_count $required status review reason no_center_point marker_solid_id $solid point_id $best_id component_ids {} component_distances {} center [list $x $y $z] marker_size $marker_size center_point_distance $best_distance link_tolerance $default_tolerance diameter $default_diameter single_entity_multiface 0 decision pending]
            continue
        }
        set links [linked_components [list $x $y $z] $default_tolerance]
        set component_ids {}
        set component_distances {}
        foreach link $links {
            foreach {distance fe_cid} $link {}
            lappend component_ids $fe_cid
            lappend component_distances $distance
        }
        set within_default_tolerance 1
        foreach distance $component_distances {
            if {$distance > $default_tolerance} {set within_default_tolerance 0; break}
        }
        set single_entity_multiface 0
        if {[llength $component_ids] == $required && $within_default_tolerance} {
            set status high
            set reason "exactly_${required}_fe_components"
        } elseif {[llength $component_ids] == $required} {
            set status review
            set reason outside_default_tolerance
        } else {
            set status review
            set reason "fe_component_count_[llength $component_ids]"
        }
        lappend candidates [dict create kind $kind required_component_count $required status $status reason $reason marker_solid_id $solid point_id $best_id component_ids $component_ids component_distances $component_distances center [list $x $y $z] marker_size $marker_size center_point_distance $best_distance link_tolerance $default_tolerance diameter $default_diameter single_entity_multiface $single_entity_multiface decision pending]
    }
    }
    set marker_component_id [lindex $marker_component_ids 0]
    set candidates [lsort -command ::mcp_spot_weld_review::compare_candidates $candidates]
    update_review_counts
    apply_triage
    set marker_names {}
    foreach scan_marker_id $marker_component_ids {lappend marker_names [component_name $scan_marker_id]}
    set status_label "\u5df2\u4ece [join $marker_names {, }] \u626b\u63cf\u5230 [llength $candidates] \u4e2a\u5019\u9009\uff1b\u9010\u6761\u786e\u8ba4\u540e\u624d\u4f1a\u521b\u5efa\u3002"
    show_current
}

proc ::mcp_spot_weld_review::candidate_key {candidate} {
    return "[dict get $candidate point_id]|[join [lsort -integer [dict get $candidate component_ids]] ,]"
}

proc ::mcp_spot_weld_review::candidate_triage_id {candidate} {
    return "spot:[dict get $candidate kind]:[dict get $candidate point_id]:[join [lsort -integer [dict get $candidate component_ids]] ,]"
}

proc ::mcp_spot_weld_review::apply_triage {} {
    variable candidates
    variable triage_rows
    if {[llength $triage_rows] == 0} {return}
    array set triage_by_id {}
    foreach row $triage_rows {
        foreach {candidate_id state confidence reason ai_reasons} $row {}
        set triage_by_id($candidate_id) [list $state $confidence $reason $ai_reasons]
    }
    set updated {}
    foreach candidate $candidates {
        set candidate_id [candidate_triage_id $candidate]
        if {[info exists triage_by_id($candidate_id)]} {
            foreach {state confidence reason ai_reasons} $triage_by_id($candidate_id) {}
            dict set candidate triage_state $state
            dict set candidate triage_reason $reason
            dict set candidate ai_confidence $confidence
            dict set candidate ai_reasons $ai_reasons
            dict set candidate decision [expr {$state eq "green_pending_submit" ? "approved" : "pending"}]
        }
        lappend updated $candidate
    }
    set candidates $updated
    update_review_counts
}

proc ::mcp_spot_weld_review::update_review_counts {} {
    variable candidates
    variable review_counts_label
    set approved 0
    set rejected 0
    set pending 0
    set created 0
    foreach candidate $candidates {
        switch -- [dict get $candidate decision] {
            approved {incr approved}
            rejected {incr rejected}
            default {incr pending}
        }
    }
    set review_counts_label "\u5df2\u786e\u8ba4\uff1a$approved    \u5df2\u6392\u9664\uff1a$rejected    \u5f85\u5ba1\u6838\uff1a$pending"
}

proc ::mcp_spot_weld_review::normalize_candidate {candidate} {
    variable default_diameter
    if {![dict exists $candidate diameter]} {dict set candidate diameter $default_diameter}
    if {![dict exists $candidate single_entity_multiface]} {dict set candidate single_entity_multiface 0}
    return $candidate
}

proc ::mcp_spot_weld_review::candidate_summary {candidate} {
    set ids [dict get $candidate component_ids]
    set names {}
    foreach cid $ids {lappend names "[component_name $cid] (#$cid)"}
    set triage ""
    # AI 置信度 is evidence only; apply_approved remains the only write path.
    if {[dict exists $candidate triage_state]} {
        set triage "\nAI 置信度：[format %.3f [dict get $candidate ai_confidence]]    \u5206\u6d41：[dict get $candidate triage_state]\nAI \u7406\u7531：[join [dict get $candidate ai_reasons] {; }]\n\u5206\u6d41\u539f\u56e0：[dict get $candidate triage_reason]"
    }
    return "\u7c7b\u578b：[dict get $candidate kind]\n\u710a\u70b9：[dict get $candidate point_id]  \u6807\u8bb0\u5b9e\u4f53：[dict get $candidate marker_solid_id]\n\u9ad8\u4eae\u76ee\u6807\u6784\u4ef6：[join $names {, }]\n\u8ddd\u79bb：[join [dict get $candidate component_distances] {, }]\n\u8fde\u63a5\u5bb9\u5dee：[format %.3f [dict get $candidate link_tolerance]] mm    \u710a\u70b9\u76f4\u5f84：[format %.3f [dict get $candidate diameter]] mm\n\u5224\u5b9a：[dict get $candidate status] / [dict get $candidate reason]\n\u5f53\u524d\u51b3\u5b9a：[dict get $candidate decision]$triage"
}

proc ::mcp_spot_weld_review::highlight_current {candidate} {
    # Keep the current review point unmistakable: one highlighted point plus
    # its red HyperMesh ID, never a cloud of labels from other candidates.
    catch {*numbersclear}
    catch {
        set solid [dict get $candidate marker_solid_id]
        if {$solid > 0} {*createmark solids 1 $solid; hm_highlightmark solids 1 highlight}
    }
    catch {
        set point [dict get $candidate point_id]
        if {$point > 0} {
            *createmark points 1 $point
            hm_highlightmark points 1 highlight
            *numbersmark points 1 1
        }
    }
    catch {
        set ids [dict get $candidate component_ids]
        if {[llength $ids] > 0} {
            *createmark components 1 {*}$ids
            hm_highlightmark components 1 highlight
            *numbersmark components 1 1
        }
    }
}

proc ::mcp_spot_weld_review::focus_current {candidate} {
    # Fit around the marker rather than the full vehicle-sized components, so
    # the highlighted weld point remains visible while it is reviewed.
    set center [dict get $candidate center]
    if {[llength $center] != 3} {return}
    set radius 40.0
    foreach dimension [dict get $candidate marker_size] {
        set candidate_radius [expr {double($dimension) * 5.0}]
        if {$candidate_radius > $radius} {set radius $candidate_radius}
    }
    catch {*graphuserwindow_byXYZandR {*}$center $radius}
}

proc ::mcp_spot_weld_review::keep_window_on_top {w} {
    if {[catch {winfo exists $w} exists] || !$exists} {return}
    catch {wm attributes $w -topmost 1}
    catch {raise $w}
}

proc ::mcp_spot_weld_review::restore_full_display {} {
    catch {*unmaskall}
    catch {*displayall}
    catch {*displayallgeometry}
    catch {*window 0 0 0 0 0}
}

proc ::mcp_spot_weld_review::isolate_current {candidate} {
    set ids [dict get $candidate component_ids]
    # Component-display flags do not isolate every geometry class in HM 2017.
    # A graphics mask does: mask everything, then reveal only the target FE
    # components, the one current marker solid, and its one weld point.
    catch {*unmaskall}
    catch {*maskall}
    if {[llength $ids] > 0} {
        catch {
            *createmark components 1 {*}$ids
            *unmaskentitymark components 1
        }
    }
    # The marker component may contain hundreds of weld markers, so reveal its
    # current solid only -- never the whole marker component.
    catch {
        set solid [dict get $candidate marker_solid_id]
        if {$solid > 0} {
            *createmark solids 1 $solid
            *unmaskentitymark solids 1
        }
    }
    catch {
        set point [dict get $candidate point_id]
        if {$point > 0} {
            *createmark points 1 $point
            *unmaskentitymark points 1
        }
    }
    catch {*window 0 0 0 0 0}
}

proc ::mcp_spot_weld_review::close_panel {} {
    variable window
    restore_full_display
    catch {destroy $window}
}

proc ::mcp_spot_weld_review::on_page_changed {notebook} {
    set page [$notebook select]
    if {[string match "*.glue" $page]} {
        ::mcp_glue_review::show_current
    } elseif {[string match "*.rbe2" $page] && [llength [info procs ::mcp_circular_rbe2_review::show_current]] > 0} {
        ::mcp_circular_rbe2_review::show_current
    } else {
        ::mcp_spot_weld_review::show_current
    }
}

proc ::mcp_spot_weld_review::save_current_parameters {} {
    variable candidates
    variable current_index
    variable tolerance_var
    variable diameter_var
    variable status_label
    if {[llength $candidates] == 0 || $current_index < 0 || $current_index >= [llength $candidates]} {return 1}
    if {[catch {set tolerance [positive_number $tolerance_var "\u8fde\u63a5\u5bb9\u5dee"]} parameter_error]} {
        set status_label $parameter_error
        return 0
    }
    if {[catch {set diameter [positive_number $diameter_var "\u710a\u70b9\u76f4\u5f84"]} parameter_error]} {
        set status_label $parameter_error
        return 0
    }
    set candidate [normalize_candidate [lindex $candidates $current_index]]
    set candidate [relink_candidate $candidate $tolerance]
    dict set candidate link_tolerance $tolerance
    dict set candidate diameter $diameter
    lset candidates $current_index $candidate
    set tolerance_var [format %.6g $tolerance]
    set diameter_var [format %.6g $diameter]
    return 1
}

proc ::mcp_spot_weld_review::show_current {} {
    variable candidates
    variable current_index
    variable candidate_label
    variable detail_label
    variable tolerance_var
    variable diameter_var
    if {[llength $candidates] == 0} {
        set candidate_label "\u6ca1\u6709\u53ef\u5ba1\u6838\u7684\u710a\u63a5\u5019\u9009\u3002"
        set detail_label "\u8bf7\u68c0\u67e5\u6807\u8bb0\u7ec4\u4ef6\u6216\u7528\u201c\u4eba\u5de5\u8865\u52a0\u201d\u9009\u62e9\u710a\u70b9\u548c\u6784\u4ef6\u3002"
        return
    }
    if {$current_index < 0} {set current_index 0}
    if {$current_index >= [llength $candidates]} {set current_index [expr {[llength $candidates] - 1}]}
    set candidate [normalize_candidate [lindex $candidates $current_index]]
    lset candidates $current_index $candidate
    update_review_counts
    set candidate_label "\u5019\u9009 [expr {$current_index + 1}]/[llength $candidates]"
    set detail_label [candidate_summary $candidate]
    set tolerance_var [dict get $candidate link_tolerance]
    set diameter_var [dict get $candidate diameter]
    isolate_current $candidate
    highlight_current $candidate
    focus_current $candidate
}

proc ::mcp_spot_weld_review::next_candidate {step} {
    variable candidates
    variable current_index
    if {![save_current_parameters]} {return}
    if {[llength $candidates] == 0} {return}
    set current_index [expr {$current_index + $step}]
    if {$current_index < 0} {set current_index 0}
    if {$current_index >= [llength $candidates]} {set current_index [expr {[llength $candidates] - 1}]}
    show_current
}

proc ::mcp_spot_weld_review::set_current_decision {decision} {
    variable candidates
    variable current_index
    variable status_label
    if {[llength $candidates] == 0} {return}
    if {![save_current_parameters]} {return}
    set candidate [lindex $candidates $current_index]
    set requested_tolerance [dict get $candidate link_tolerance]
    if {$decision eq "approved" && ([dict get $candidate point_id] <= 0 || ![candidate_is_complete $candidate])} {
        set status_label "\u6b64\u6761\u6ca1\u6709\u5b8c\u6574\u7684\u710a\u70b9\u6216\u6784\u4ef6\u6570\u4e0d\u6b63\u786e\uff1b\u8bf7\u6392\u9664\u540e\u4f7f\u7528\u4eba\u5de5\u8865\u52a0\u3002"
        return
    }
    if {$decision eq "approved"} {
        foreach distance [dict get $candidate component_distances] {
            if {$distance > $requested_tolerance} {
                set status_label "\u76ee\u6807\u6784\u4ef6\u8ddd\u79bb\u8d85\u8fc7\u5f53\u524d $requested_tolerance mm \u5bb9\u5dee\uff1b\u8bf7\u6539\u4e3a 10 mm \u6216\u4eba\u5de5\u8865\u52a0\u3002"
                return
            }
        }
    }
    dict set candidate decision $decision
    lset candidates $current_index $candidate
    update_review_counts
    if {$decision eq "approved"} {
        if {$current_index < [expr {[llength $candidates] - 1}]} {
            set status_label "\u5df2\u786e\u8ba4\uff1a\u6b64\u6761\u5f85\u6700\u7ec8\u521b\u5efa\uff1b\u5df2\u81ea\u52a8\u5207\u6362\u5230\u4e0b\u4e00\u6761\u3002"
            next_candidate 1
        } else {
            set status_label "\u5df2\u786e\u8ba4\u6700\u540e\u4e00\u6761\uff1b\u8bf7\u70b9\u51fb\u201c\u521b\u5efa\u6240\u6709\u5df2\u786e\u8ba4\u710a\u70b9\u5e76\u4fdd\u5b58\u201d\u3002"
            show_current
        }
    } else {
        if {$current_index < [expr {[llength $candidates] - 1}]} {
            set status_label "\u5df2\u6392\u9664\uff1a\u6b64\u6761\u4e0d\u4f1a\u521b\u5efa\u710a\u70b9\uff1b\u5df2\u81ea\u52a8\u5207\u6362\u5230\u4e0b\u4e00\u6761\u3002"
            next_candidate 1
        } else {
            set status_label "\u5df2\u6392\u9664\u6700\u540e\u4e00\u6761\uff1b\u8bf7\u6838\u5bf9\u5df2\u786e\u8ba4\u7684\u710a\u70b9\u540e\u518d\u521b\u5efa\u3002"
            show_current
        }
    }
}

proc ::mcp_spot_weld_review::confirm_single_entity_multiface {} {
    # This review-only confirmation is allowed only after the engineer has
    # checked a located marker with one continuous FE component.
    variable candidates
    variable current_index
    variable status_label
    if {[llength $candidates] == 0} {return}
    if {![save_current_parameters]} {return}
    set candidate [normalize_candidate [lindex $candidates $current_index]]
    if {[dict get $candidate point_id] <= 0 || [llength [dict get $candidate component_ids]] != 1} {
        set status_label "\u5355\u5b9e\u4f53\u591a\u9762\u786e\u8ba4\u53ea\u9002\u7528\u4e8e\u5df2\u5b9a\u4f4d\u710a\u70b9\u4e14\u4ec5\u5173\u8054 1 \u4e2a\u6784\u4ef6\u7684\u5019\u9009\u3002"
        return
    }
    dict set candidate single_entity_multiface 1
    dict set candidate status high
    dict set candidate reason single_entity_multiface_confirmed
    lset candidates $current_index $candidate
    set_current_decision approved
}

proc ::mcp_spot_weld_review::manual_add {} {
    variable candidates
    variable manual_kind
    variable default_tolerance
    variable default_diameter
    variable status_label
    if {$manual_kind eq "cylinder"} {set required 2} else {set required 3}
    restore_full_display
    *createmarkpanel points 1 "\u9009\u62e9\u4e00\u4e2a\u710a\u70b9"
    set points [hm_getmark points 1]
    if {[llength $points] != 1} {
        set status_label "\u4eba\u5de5\u8865\u52a0\u53d6\u6d88\uff1a\u5fc5\u987b\u9009\u62e9\u4e00\u4e2a\u710a\u70b9\u3002"
        return
    }
    *createmarkpanel components 2 "\u9009\u62e9\u88ab\u710a\u63a5\u6784\u4ef6"
    set selected_components [hm_getmark components 2]
    if {[llength $selected_components] != $required || [llength [lsort -unique $selected_components]] != $required} {
        set status_label "\u4eba\u5de5\u8865\u52a0\u53d6\u6d88\uff1a$manual_kind \u5fc5\u987b\u9009\u62e9 $required \u4e2a\u4e0d\u540c\u6784\u4ef6\u3002"
        return
    }
    foreach cid $selected_components {
        if {[component_is_excluded $cid]} {
            set status_label "\u4eba\u5de5\u8865\u52a0\u53d6\u6d88\uff1a\u4e0d\u80fd\u9009\u62e9\u710a\u70b9\u6807\u8bb0\u6216\u8fde\u63a5\u5668\u7ed3\u679c\u7ec4\u4ef6\u3002"
            return
        }
    }
    set candidate [dict create kind $manual_kind required_component_count $required status manual reason human_added marker_solid_id 0 point_id [lindex $points 0] component_ids $selected_components component_distances {} center {} marker_size {} center_point_distance 0.0 link_tolerance $default_tolerance diameter $default_diameter single_entity_multiface 0 decision approved]
    set key [candidate_key $candidate]
    foreach existing $candidates {
        if {[candidate_key $existing] eq $key} {
            set status_label "\u4eba\u5de5\u8865\u52a0\u53d6\u6d88\uff1a\u8be5\u710a\u70b9\u548c\u6784\u4ef6\u7ec4\u5408\u5df2\u7ecf\u5728\u5019\u9009\u5217\u8868\u4e2d\u3002"
            return
        }
    }
    lappend candidates $candidate
    set ::mcp_spot_weld_review::current_index [expr {[llength $candidates] - 1}]
    update_review_counts
    set status_label "\u5df2\u4eba\u5de5\u8865\u52a0\u5e76\u6279\u51c6\uff1b\u8bf7\u6838\u5bf9\u540e\u5e94\u7528\u3002"
    show_current
}

proc ::mcp_spot_weld_review::json_quote {value} {
    return "\"[string map [list "\\" "\\\\" "\"" "\\\"" "\n" "\\n" "\r" "\\r" "\t" "\\t"] $value]\""
}

proc ::mcp_spot_weld_review::json_number_array {values} {
    return "\[[join $values ,]\]"
}

proc ::mcp_spot_weld_review::candidate_json {candidate} {
    set candidate [normalize_candidate $candidate]
    set decision [dict get $candidate decision]
    set single_entity_multiface false
    if {[dict get $candidate single_entity_multiface]} {set single_entity_multiface true}
    return "{\"kind\":[json_quote [dict get $candidate kind]],\"decision\":[json_quote $decision],\"status\":[json_quote [dict get $candidate status]],\"reason\":[json_quote [dict get $candidate reason]],\"point_id\":[dict get $candidate point_id],\"marker_solid_id\":[dict get $candidate marker_solid_id],\"component_ids\":[json_number_array [dict get $candidate component_ids]],\"single_entity_multiface\":$single_entity_multiface,\"link_tolerance\":[dict get $candidate link_tolerance],\"diameter\":[dict get $candidate diameter]}"
}

proc ::mcp_spot_weld_review::write_audit {event success message created_count} {
    variable audit_path
    variable session_id
    variable model_path
    variable output_path
    variable backup_path
    variable marker_component_id
    variable candidates
    set rows {}
    foreach candidate $candidates {lappend rows [candidate_json $candidate]}
    set f [open $audit_path w]
    puts $f "{\"schema_version\":\"1.0\",\"session_id\":[json_quote $session_id],\"event\":[json_quote $event],\"success\":$success,\"message\":[json_quote $message],\"model_path\":[json_quote $model_path],\"output_model_path\":[json_quote $output_path],\"backup_path\":[json_quote $backup_path],\"marker_component_id\":$marker_component_id,\"created_count\":$created_count,\"candidates\":[join $rows ,]}"
    close $f
}

proc ::mcp_spot_weld_review::append_rule_history {created_count} {
    variable rule_history_path
    variable marker_component_id
    variable default_tolerance
    variable session_id
    set f [open $rule_history_path a]
    puts $f "{\"event\":\"spot_weld_accepted\",\"session_id\":[json_quote $session_id],\"marker_component\":[json_quote [component_name $marker_component_id]],\"default_link_tolerance\":$default_tolerance,\"created_count\":$created_count}"
    close $f
}

proc ::mcp_spot_weld_review::create_connector {candidate} {
    set candidate [normalize_candidate $candidate]
    set point [dict get $candidate point_id]
    set component_ids [dict get $candidate component_ids]
    set component_count [llength $component_ids]
    if {$point <= 0 || ![candidate_is_complete $candidate]} {
        return -code error "candidate is not a complete point-weld association"
    }
    set tolerance [dict get $candidate link_tolerance]
    set diameter [dict get $candidate diameter]
    set details [list "link_elems_geom=elems" "link_rule=now" "link_rule=now" "relink_rule=none" "tol_flag=1" "tol=[format %.6f $tolerance]" "ce_normal_link=0" "ce_nonnormal=0" "ce_fedepth=1.000000" "ce_fewidth=1.000000" "ce_systems=0" "num_node_flag=0" "num_node=3" "ce_fe_vector=0" "ce_coarse_mesh=3" "ce_connectivity=2" "ce_dir_assign=0" "ce_prop_opt=0" "ce_fe_density=1" "ce_fe_thck_flag=3" "ce_fe_acm_numhexa=1" "ce_fe_proj_hexa_face=0" "ce_fe_hexa_ensure_projection=0" "ce_diameter=[format %.6f $diameter]" "ce_quad_size=0.000000" "ce_cwelds=0" "ce_extralinknum=0" "ce_hexaoffsetcheck=1" "ce_bl_connection_ang=10.000000" "ce_lt_connection_ang=60.000000"]
    *createmark points 1 $point
    if {[dict get $candidate single_entity_multiface]} {
        set face_count [dict get $candidate required_component_count]
        if {$face_count ni {2 3}} {
            return -code error "single-entity multi-face weld requires a two- or three-face marker"
        }
        *createmark elems 1 "by comp id" [lindex $component_ids 0]
        *createstringarray 30 {*}$details
        *CE_ConnectorCreateByMarkAndRealizeWithDetails points 1 "spot" $face_count elems 1 "nastran" 1001 74 $tolerance 1 30
        return
    }
    *createmark components 2 {*}$component_ids
    *createstringarray 30 {*}$details
    *CE_ConnectorCreateByMarkAndRealizeWithDetails points 1 "spot" $component_count components 2 "nastran" 1001 74 $tolerance 1 30
}

proc ::mcp_spot_weld_review::apply_approved {} {
    variable candidates
    variable applied
    variable backup_path
    variable model_path
    variable output_path
    variable status_label
    if {$applied} {
        set status_label "\u672c\u4f1a\u8bdd\u5df2\u7ecf\u6267\u884c\u8fc7\u521b\u5efa\uff1b\u4e3a\u9632\u6b62\u91cd\u590d\u521b\u5efa\uff0c\u5df2\u9501\u5b9a\u3002"
        return
    }
    if {![save_current_parameters]} {return}
    set approved {}
    foreach candidate $candidates {
        if {[dict get $candidate decision] eq "approved"} {lappend approved $candidate}
    }
    if {[llength $approved] == 0} {
        set status_label "\u6ca1\u6709\u5df2\u786e\u8ba4\u5019\u9009\uff0c\u672a\u521b\u5efa\u8fde\u63a5\u5668\u3002"
        write_audit apply_skipped false "no approved candidates" 0
        return
    }
    set answer [tk_messageBox -type yesno -icon warning -title "\u786e\u8ba4\u521b\u5efa\u70b9\u710a" -message "\u5c06\u521b\u5efa [llength $approved] \u4e2a spot connector\u3002\n\u6b64\u64cd\u4f5c\u5c06\u5148\u5199\u5165\u6062\u590d\u5feb\u7167\uff0c\u7136\u540e\u521b\u5efa connector \u5e76\u4fdd\u5b58\u5f53\u524d HM \u6587\u4ef6\u3002\n\u8fd9\u662f\u7b2c\u4e00\u6b21\u786e\u8ba4\uff1a\u662f\u5426\u7ee7\u7eed\uff1f"]
    if {$answer ne "yes"} {return}
    set answer [tk_messageBox -type yesno -icon warning -title "\u4e8c\u6b21\u786e\u8ba4\u521b\u5efa" -message "\u8bf7\u518d\u6b21\u786e\u8ba4\uff1a\u73b0\u5728\u521b\u5efa [llength $approved] \u4e2a\u5df2\u6279\u51c6\u70b9\u710a\u5e76\u4fdd\u5b58\u6a21\u578b\u3002\n\u70b9\u51fb\u201c\u5426\u201d\u4e0d\u4f1a\u521b\u5efa\u3001\u4e0d\u4f1a\u4fdd\u5b58\u3002"]
    if {$answer ne "yes"} {return}
    if {[catch {ensure_nastran_connector_template} template_error]} {
        set status_label "\u65e0\u6cd5\u52a0\u8f7d Nastran FE \u6a21\u677f\uff0c\u672a\u521b\u5efa\uff1a$template_error"
        write_audit apply_failed false $template_error 0
        return
    }
    if {[catch {*writefile "$backup_path" 1} backup_error]} {
        set status_label "\u6062\u590d\u5feb\u7167\u4fdd\u5b58\u5931\u8d25\uff0c\u672a\u521b\u5efa\uff1a$backup_error"
        write_audit apply_failed false $backup_error 0
        return
    }
    set created 0
    set create_error ""
    catch {*beginhistorystate "MCP spot weld review"}
    foreach candidate $approved {
        if {[catch {create_connector $candidate} create_error]} {break}
        incr created
    }
    catch {*endhistorystate "MCP spot weld review"}
    set applied 1
    if {$create_error ne ""} {
        set status_label "\u521b\u5efa\u5728\u7b2c [expr {$created + 1}] \u6761\u5931\u8d25\uff1a$create_error\u3002\u6a21\u578b\u672a\u4fdd\u5b58\uff1b\u53ef\u4f7f\u7528\u4e00\u6b21 Undo \u6216\u6062\u590d\u5feb\u7167\u3002"
        write_audit apply_failed false $create_error $created
        return
    }
    if {[catch {*writefile "$output_path" 1} save_error]} {
        set status_label "\u8fde\u63a5\u5668\u5df2\u521b\u5efa\u4f46\u7ed3\u679c\u6a21\u578b\u4fdd\u5b58\u5931\u8d25\uff1a$save_error\u3002\u8bf7\u4e0d\u8981\u518d\u6b21\u5e94\u7528\uff0c\u53ef\u4ece\u6062\u590d\u5feb\u7167\u56de\u9000\u3002"
        write_audit apply_failed false $save_error $created
        return
    }
    append_rule_history $created
    write_audit apply_saved true "spot weld connectors created and result model saved" $created
    restore_full_display
    set status_label "\u5df2\u521b\u5efa $created \u4e2a connector\uff0c\u5e76\u53e6\u5b58\u4e3a\u7ed3\u679c\u6a21\u578b\uff1a$output_path\u3002\u6062\u590d\u5feb\u7167\uff1a$backup_path"
    tk_messageBox -type ok -icon info -title "\u70b9\u710a\u521b\u5efa\u5b8c\u6210" -message $status_label
}

proc ::mcp_spot_weld_review::show_marker_selector {} {
    variable marker_options
    variable marker_selector_ids
    set w .mcp_spot_marker_selector
    catch {destroy $w}
    toplevel $w
    wm title $w "\u9009\u62e9\u710a\u70b9\u6807\u8bb0\u7ec4\u4ef6"
    keep_window_on_top $w
    ttk::label $w.hint -text "\u68c0\u6d4b\u5230\u591a\u4e2a\u53ef\u80fd\u7684\u710a\u70b9\u6807\u8bb0\u7ec4\u4ef6\uff0c\u8bf7\u9009\u62e9\u4e00\u4e2a\u540e\u518d\u5ba1\u6838\u3002"
    listbox $w.list -height 10 -width 60 -exportselection 0
    set marker_selector_ids {}
    foreach entry $marker_options {
        set cid [dict get $entry component_id]
        lappend marker_selector_ids $cid
        $w.list insert end "[dict get $entry component_name]  (#$cid\uff0c\u6807\u8bb0=[dict get $entry shape_markers]\uff0c\u70b9=[dict get $entry reference_points])"
    }
    $w.list selection set 0
    ttk::button $w.ok -text "\u4f7f\u7528\u9009\u4e2d\u7ec4\u4ef6" -command [list ::mcp_spot_weld_review::select_marker_from_dialog $w]
    pack $w.hint -padx 12 -pady {12 6}
    pack $w.list -padx 12 -pady 6
    pack $w.ok -padx 12 -pady {6 12}
}

proc ::mcp_spot_weld_review::select_marker_from_dialog {w} {
    variable marker_selector_ids
    set selection [$w.list curselection]
    if {[llength $selection] != 1} {return}
    set cid [lindex $marker_selector_ids [lindex $selection 0]]
    destroy $w
    scan_marker $cid
}

proc ::mcp_spot_weld_review::build_ui {} {
    variable window
    # The dedicated RBE2-only entry point and the unified notebook share one
    # state namespace. Do not leave an older standalone window interactive
    # while its variables are repointed to the notebook's RBE2 tab.
    catch {destroy .mcpCircularRbe2Review}
    catch {destroy $window}
    toplevel $window
    wm title $window "HyperMesh \u70b9\u710a / \u80f6\u7c98\u4eba\u5de5\u5ba1\u6838"
    wm minsize $window 760 500
    keep_window_on_top $window
    wm protocol $window WM_DELETE_WINDOW ::mcp_spot_weld_review::close_panel
    ttk::notebook $window.pages
    ttk::frame $window.pages.spot -padding 16
    ttk::frame $window.pages.glue -padding 16
    ttk::frame $window.pages.rbe2 -padding 16
    $window.pages add $window.pages.spot -text "\u70b9\u710a\u5ba1\u6838"
    $window.pages add $window.pages.glue -text "\u80f6\u7c98\u5ba1\u6838"
    $window.pages add $window.pages.rbe2 -text "RBE2 \u5ba1\u6838"
    pack $window.pages -fill both -expand 1
    bind $window.pages <<NotebookTabChanged>> [list ::mcp_spot_weld_review::on_page_changed $window.pages]
    set page $window.pages.spot
    ttk::label $page.title -text "\u70b9\u710a\u8bc6\u522b\u4e0e\u4eba\u5de5\u786e\u8ba4" -font {{Microsoft YaHei UI} 14 bold}
    ttk::label $page.candidate -textvariable ::mcp_spot_weld_review::candidate_label -font {{Microsoft YaHei UI} 12 bold}
    ttk::label $page.counts -textvariable ::mcp_spot_weld_review::review_counts_label -font {{Microsoft YaHei UI} 11 bold}
    ttk::label $page.detail -textvariable ::mcp_spot_weld_review::detail_label -justify left -wraplength 700 -font {{Microsoft YaHei UI} 13}
    ttk::frame $page.parameters
    ttk::label $page.parameters.tolerance_label -text "\u672c\u6761\u8fde\u63a5\u5bb9\u5dee (mm)\uff1a" -font {{Microsoft YaHei UI} 11}
    ttk::entry $page.parameters.tolerance_value -textvariable ::mcp_spot_weld_review::tolerance_var -width 10 -font {{Microsoft YaHei UI} 11}
    ttk::label $page.parameters.diameter_label -text "\u710a\u70b9\u76f4\u5f84 (mm)\uff1a" -font {{Microsoft YaHei UI} 11}
    ttk::entry $page.parameters.diameter_value -textvariable ::mcp_spot_weld_review::diameter_var -width 10 -font {{Microsoft YaHei UI} 11}
    ttk::label $page.parameters.hint -text "\u586b\u5199\u540e\u5207\u6362\u5019\u9009\u6216\u70b9\u51fb\u786e\u8ba4\u65f6\u4f1a\u91cd\u65b0\u6821\u9a8c\u5173\u8054\u6784\u4ef6\u6570\u91cf\u3002" -font {{Microsoft YaHei UI} 10}
    pack $page.parameters.tolerance_label $page.parameters.tolerance_value $page.parameters.diameter_label $page.parameters.diameter_value $page.parameters.hint -side left -padx 4
    ttk::frame $page.navigation
    ttk::button $page.navigation.prev -text "\u4e0a\u4e00\u4e2a" -command {::mcp_spot_weld_review::next_candidate -1}
    ttk::button $page.navigation.approve -text "\u786e\u8ba4\uff08\u5f85\u521b\u5efa\uff09" -command {::mcp_spot_weld_review::set_current_decision approved}
    ttk::button $page.navigation.reject -text "\u6392\u9664" -command {::mcp_spot_weld_review::set_current_decision rejected}
    ttk::button $page.navigation.single_multiface -text "\u786e\u8ba4\uff1a\u5355\u5b9e\u4f53\u591a\u9762\u710a\u63a5" -command ::mcp_spot_weld_review::confirm_single_entity_multiface
    pack $page.navigation.prev $page.navigation.approve $page.navigation.reject $page.navigation.single_multiface -side left -padx 4
    ttk::labelframe $page.manual -text "\u4eba\u5de5\u8865\u52a0" -padding 8
    ttk::radiobutton $page.manual.cylinder -text "\u5706\u67f1\uff1a2 \u4e2a\u6784\u4ef6" -variable ::mcp_spot_weld_review::manual_kind -value cylinder
    ttk::radiobutton $page.manual.prism -text "\u4e09\u68f1\u67f1\uff1a3 \u4e2a\u6784\u4ef6" -variable ::mcp_spot_weld_review::manual_kind -value triangular_prism
    ttk::button $page.manual.add -text "\u9009\u62e9\u710a\u70b9\u548c\u6784\u4ef6\u5e76\u8865\u52a0" -command ::mcp_spot_weld_review::manual_add
    pack $page.manual.cylinder $page.manual.prism $page.manual.add -side left -padx 5
    ttk::button $page.apply -text "\u521b\u5efa\u6240\u6709\u5df2\u786e\u8ba4\u710a\u70b9\u5e76\u4fdd\u5b58" -command ::mcp_spot_weld_review::apply_approved
    ttk::label $page.status -textvariable ::mcp_spot_weld_review::status_label -justify left -wraplength 700 -font {{Microsoft YaHei UI} 11}
    pack $page.title -anchor w -pady {0 10}
    pack $page.candidate -anchor w -pady 3
    pack $page.counts -anchor w -pady 3
    pack $page.detail -anchor w -fill x -pady 4
    pack $page.parameters -anchor w -pady 7
    pack $page.navigation -anchor w -pady 5
    pack $page.manual -anchor w -fill x -pady 6
    pack $page.apply -anchor w -pady {8 5}
    pack $page.status -anchor w -fill x -pady 5
    ::mcp_glue_review::build_ui $window.pages.glue
    if {[llength [info procs ::mcp_circular_rbe2_review::build_ui]] > 0} {
        ::mcp_circular_rbe2_review::build_ui $window.pages.rbe2
    }
}

proc ::mcp_spot_weld_review::start {} {
    variable marker_options
    variable candidates
    variable marker_component_id
    build_ui
    # Glue scan is independent of point-weld markers.  It runs even when the
    # model has no cankao/hanjie data, but it only prepares candidates and never
    # creates connectors or saves the model.
    ::mcp_glue_review::start
    if {[llength $candidates] > 0 || $marker_component_id > 0} {
        set ::mcp_spot_weld_review::status_label "\u5df2\u6062\u590d\u672c\u4f1a\u8bdd\u7684\u5019\u9009\u548c\u4eba\u5de5\u5ba1\u6838\u72b6\u6001\uff1b\u672a\u521b\u5efa\u3001\u672a\u4fdd\u5b58\u4efb\u4f55\u6a21\u578b\u3002"
        show_current
        return
    }
    set marker_options [find_marker_components]
    if {[llength $marker_options] == 0} {
        set ::mcp_spot_weld_review::candidate_label "\u672a\u53d1\u73b0\u710a\u70b9\u6807\u8bb0\u7ec4\u4ef6"
        set ::mcp_spot_weld_review::detail_label "\u672a\u627e\u5230\u540c\u65f6\u5305\u542b\u5c0f\u578b\u5706\u67f1/\u4e09\u68f1\u67f1\u5b9e\u4f53\u548c\u53c2\u8003\u70b9\u7684\u7ec4\u4ef6\uff1b\u53ef\u4f7f\u7528\u4eba\u5de5\u8865\u52a0\u3002"
        set ::mcp_spot_weld_review::status_label "\u6ca1\u6709\u81ea\u52a8\u521b\u5efa\u4efb\u4f55\u8fde\u63a5\u5668\u3002"
        return
    }
    if {[llength $marker_options] == 1} {
        scan_marker [dict get [lindex $marker_options 0] component_id]
    } else {
        set marker_ids {}
        foreach entry $marker_options {lappend marker_ids [dict get $entry component_id]}
        # No manual component selection is needed: scan every component that
        # contains both valid marker geometry and reference points.
        scan_markers $marker_ids
    }
}
# Defer startup until the generated script selects its mode.  A dedicated RBE2
# panel sets rbe2 before idle; the unified point-weld/glue/RBE2 workflow sets
# unified and starts the notebook exactly once.
after idle {
    if {![info exists ::mcp_connector_review_mode] || $::mcp_connector_review_mode eq "unified"} {
        ::mcp_spot_weld_review::start
    }
}
