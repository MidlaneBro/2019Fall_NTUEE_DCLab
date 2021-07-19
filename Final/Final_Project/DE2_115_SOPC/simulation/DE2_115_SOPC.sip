set_global_assignment -entity "DE2_115_SOPC" -library "lib_DE2_115_SOPC" -name IP_TOOL_NAME "Qsys"
set_global_assignment -entity "DE2_115_SOPC" -library "lib_DE2_115_SOPC" -name IP_TOOL_VERSION "15.0"
set_global_assignment -entity "DE2_115_SOPC" -library "lib_DE2_115_SOPC" -name IP_TOOL_ENV "Qsys"
set_global_assignment -library "lib_DE2_115_SOPC" -name SPD_FILE [file join $::quartus(sip_path) "../DE2_115_SOPC.spd"]
set_global_assignment -library "lib_DE2_115_SOPC" -name MISC_FILE [file join $::quartus(sip_path) "../../DE2_115_SOPC.qsys"]

set_global_assignment -library "lib_DE2_115_SOPC" -name MISC_FILE [file join $::quartus(sip_path) "DE2_115_SOPC.v"]
set_global_assignment -library "lib_DE2_115_SOPC" -name MISC_FILE [file join $::quartus(sip_path) "submodules/DE2_115_SOPC_altpll_audio.vo"]
set_global_assignment -library "lib_DE2_115_SOPC" -name MISC_FILE [file join $::quartus(sip_path) "submodules/DE2_115_SOPC_altpll.vo"]
set_global_assignment -library "lib_DE2_115_SOPC" -name MISC_FILE [file join $::quartus(sip_path) "submodules/TERASIC_IRM.v"]
set_global_assignment -library "lib_DE2_115_SOPC" -name MISC_FILE [file join $::quartus(sip_path) "submodules/irda_receive_terasic.v"]
