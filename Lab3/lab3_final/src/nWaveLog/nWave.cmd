wvConvertFile -win $_nWave1 -o "/home/team09/lab3/src/AudDSP.fsdb.fsdb" \
           "/home/team09/lab3/src/AudDSP.fsdb"
wvSetPosition -win $_nWave1 {("G1" 0)}
wvOpenFile -win $_nWave1 {/home/team09/lab3/src/AudDSP.fsdb.fsdb}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/tb"
wvGetSignalClose -win $_nWave1
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/tb"
wvGetSignalSetScope -win $_nWave1 "/tb"
wvSetPosition -win $_nWave1 {("G1" 10)}
wvSetPosition -win $_nWave1 {("G1" 10)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/tb/i_daclrck} \
{/tb/i_rst_n} \
{/tb/i_start} \
{/tb/i_pause} \
{/tb/i_stop} \
{/tb/i_mode\[1:0\]} \
{/tb/i_speed\[3:0\]} \
{/tb/i_sram_data\[15:0\]} \
{/tb/o_dac_data\[15:0\]} \
{/tb/o_sram_addr\[19:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 10 )} 
wvSetPosition -win $_nWave1 {("G1" 10)}
wvGetSignalClose -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 9 )} 
wvSelectSignal -win $_nWave1 {( "G1" 9 )} 
wvSetRadix -win $_nWave1 -format UDec
wvSelectSignal -win $_nWave1 {( "G1" 8 )} 
wvSelectSignal -win $_nWave1 {( "G1" 8 )} 
wvSetRadix -win $_nWave1 -format UDec
wvZoomIn -win $_nWave1
wvZoomIn -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvConvertFile -win $_nWave1 -o "/home/team09/lab3/src/AudDSP.fsdb.fsdb" \
           "/home/team09/lab3/src/AudDSP.fsdb"
wvReloadFile -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomOut -win $_nWave1
wvZoomIn -win $_nWave1
wvSetCursor -win $_nWave1 26341.144040 -snap {("G1" 1)}
wvSetCursor -win $_nWave1 27197.788079 -snap {("G1" 1)}
wvResizeWindow -win $_nWave1 8 31 884 202
wvResizeWindow -win $_nWave1 0 23 1536 801
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvConvertFile -win $_nWave1 -o "/home/team09/lab3/src/AudDSP.fsdb.fsdb" \
           "/home/team09/lab3/src/AudDSP.fsdb"
wvReloadFile -win $_nWave1
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/tb/AudDSP0"
wvSetPosition -win $_nWave1 {("G1" 13)}
wvSetPosition -win $_nWave1 {("G1" 13)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/tb/i_daclrck} \
{/tb/i_rst_n} \
{/tb/i_start} \
{/tb/i_pause} \
{/tb/i_stop} \
{/tb/i_mode\[1:0\]} \
{/tb/i_speed\[3:0\]} \
{/tb/i_sram_data\[15:0\]} \
{/tb/o_dac_data\[15:0\]} \
{/tb/o_sram_addr\[19:0\]} \
{/tb/AudDSP0/prev_data_r\[15:0\]} \
{/tb/AudDSP0/this_data_r\[15:0\]} \
{/tb/AudDSP0/ready_r} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 13 )} 
wvSetPosition -win $_nWave1 {("G1" 13)}
wvGetSignalClose -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 11 )} 
wvSelectSignal -win $_nWave1 {( "G1" 11 )} 
wvSetRadix -win $_nWave1 -format UDec
wvSelectSignal -win $_nWave1 {( "G1" 12 )} 
wvSelectSignal -win $_nWave1 {( "G1" 12 )} 
wvSetRadix -win $_nWave1 -format UDec
wvSetCursor -win $_nWave1 26429.004967 -snap {("G1" 9)}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/tb"
wvGetSignalSetScope -win $_nWave1 "/tb/AudDSP0"
wvGetSignalSetScope -win $_nWave1 "/tb/AudDSP0"
wvSetPosition -win $_nWave1 {("G1" 14)}
wvSetPosition -win $_nWave1 {("G1" 14)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/tb/i_daclrck} \
{/tb/i_rst_n} \
{/tb/i_start} \
{/tb/i_pause} \
{/tb/i_stop} \
{/tb/i_mode\[1:0\]} \
{/tb/i_speed\[3:0\]} \
{/tb/i_sram_data\[15:0\]} \
{/tb/o_dac_data\[15:0\]} \
{/tb/o_sram_addr\[19:0\]} \
{/tb/AudDSP0/prev_data_r\[15:0\]} \
{/tb/AudDSP0/this_data_r\[15:0\]} \
{/tb/AudDSP0/ready_r} \
{/tb/AudDSP0/state_r\[1:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 14 )} 
wvSetPosition -win $_nWave1 {("G1" 14)}
wvGetSignalClose -win $_nWave1
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/tb"
wvGetSignalSetScope -win $_nWave1 "/tb/AudDSP0"
wvGetSignalSetScope -win $_nWave1 "/tb/AudDSP0"
wvSetPosition -win $_nWave1 {("G1" 15)}
wvSetPosition -win $_nWave1 {("G1" 15)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/tb/i_daclrck} \
{/tb/i_rst_n} \
{/tb/i_start} \
{/tb/i_pause} \
{/tb/i_stop} \
{/tb/i_mode\[1:0\]} \
{/tb/i_speed\[3:0\]} \
{/tb/i_sram_data\[15:0\]} \
{/tb/o_dac_data\[15:0\]} \
{/tb/o_sram_addr\[19:0\]} \
{/tb/AudDSP0/prev_data_r\[15:0\]} \
{/tb/AudDSP0/this_data_r\[15:0\]} \
{/tb/AudDSP0/ready_r} \
{/tb/AudDSP0/state_r\[1:0\]} \
{/tb/AudDSP0/counter_r\[3:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 15 )} 
wvSetPosition -win $_nWave1 {("G1" 15)}
wvGetSignalClose -win $_nWave1
wvSetCursor -win $_nWave1 26956.170530 -snap {("G1" 9)}
wvSetCursor -win $_nWave1 28449.806291 -snap {("G1" 9)}
wvSetCursor -win $_nWave1 30931.877483 -snap {("G1" 8)}
wvSetCursor -win $_nWave1 31777.538907 -snap {("G1" 9)}
wvSetCursor -win $_nWave1 29712.807119 -snap {("G1" 7)}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/tb"
wvGetSignalSetScope -win $_nWave1 "/tb/AudDSP0"
wvGetSignalSetScope -win $_nWave1 "/tb/AudDSP0"
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvConvertFile -win $_nWave1 -o "/home/team09/lab3/src/AudDSP.fsdb.fsdb" \
           "/home/team09/lab3/src/AudDSP.fsdb"
wvReloadFile -win $_nWave1
