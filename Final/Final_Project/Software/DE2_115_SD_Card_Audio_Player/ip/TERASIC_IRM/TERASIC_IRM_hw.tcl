# TCL File Generated by Component Editor 9.1sp2
# Thu Apr 15 13:49:11 CST 2010
# DO NOT MODIFY


# +-----------------------------------
# | 
# | TERASIC_IRM "TERASIC_IRM" v1.0
# | null 2010.04.15.13:49:11
# | 
# | 
# | D:/svn/de2_115_ref/Q_DE2_115/ip/TERASIC_IRM/TERASIC_IRM.v
# | 
# |    ./TERASIC_IRM.v syn, sim
# |    ./irda_receive_terasic.v syn, sim
# | 
# +-----------------------------------

# +-----------------------------------
# | request TCL package from ACDS 9.1
# | 
package require -exact sopc 9.1
# | 
# +-----------------------------------

# +-----------------------------------
# | module TERASIC_IRM
# | 
set_module_property NAME TERASIC_IRM
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property GROUP "Terasic Technologies Inc./DE2_115"
set_module_property DISPLAY_NAME TERASIC_IRM
set_module_property TOP_LEVEL_HDL_FILE TERASIC_IRM.v
set_module_property TOP_LEVEL_HDL_MODULE TERASIC_IRM
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property ANALYZE_HDL TRUE
# | 
# +-----------------------------------

# +-----------------------------------
# | files
# | 
add_file TERASIC_IRM.v {SYNTHESIS SIMULATION}
add_file irda_receive_terasic.v {SYNTHESIS SIMULATION}
# | 
# +-----------------------------------

# +-----------------------------------
# | parameters
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | display items
# | 
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point avalon_slave
# | 
add_interface avalon_slave avalon end
set_interface_property avalon_slave addressAlignment NATIVE
set_interface_property avalon_slave associatedClock clock_sink
set_interface_property avalon_slave burstOnBurstBoundariesOnly false
set_interface_property avalon_slave explicitAddressSpan 0
set_interface_property avalon_slave holdTime 0
set_interface_property avalon_slave isMemoryDevice false
set_interface_property avalon_slave isNonVolatileStorage false
set_interface_property avalon_slave linewrapBursts false
set_interface_property avalon_slave maximumPendingReadTransactions 0
set_interface_property avalon_slave printableDevice false
set_interface_property avalon_slave readLatency 0
set_interface_property avalon_slave readWaitStates 2
set_interface_property avalon_slave readWaitTime 2
set_interface_property avalon_slave setupTime 0
set_interface_property avalon_slave timingUnits Cycles
set_interface_property avalon_slave writeWaitTime 0

set_interface_property avalon_slave ASSOCIATED_CLOCK clock_sink
set_interface_property avalon_slave ENABLED true

add_interface_port avalon_slave s_read read Input 1
add_interface_port avalon_slave s_cs_n chipselect_n Input 1
add_interface_port avalon_slave s_readdata readdata Output 32
add_interface_port avalon_slave s_write write Input 1
add_interface_port avalon_slave s_writedata writedata Input 32
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point clock_sink
# | 
add_interface clock_sink clock end

set_interface_property clock_sink ENABLED true

add_interface_port clock_sink clk clk Input 1
add_interface_port clock_sink reset_n reset_n Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point conduit_end
# | 
add_interface conduit_end conduit end

set_interface_property conduit_end ENABLED true

add_interface_port conduit_end ir export Input 1
# | 
# +-----------------------------------

# +-----------------------------------
# | connection point interrupt_sender
# | 
add_interface interrupt_sender interrupt end
set_interface_property interrupt_sender associatedAddressablePoint avalon_slave

set_interface_property interrupt_sender ASSOCIATED_CLOCK clock_sink
set_interface_property interrupt_sender ENABLED true

add_interface_port interrupt_sender irq irq Output 1
# | 
# +-----------------------------------