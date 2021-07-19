
module DE2_115_SOPC (
	Terasic_IrDA_0_conduit_end_export,
	altpll_audio_locked_conduit_export,
	altpll_audio_phasedone_conduit_export,
	altpll_c1_clk,
	altpll_c2_clk,
	altpll_c3_clk,
	altpll_locked_conduit_export,
	altpll_phasedone_conduit_export,
	audio_conduit_end_XCK,
	audio_conduit_end_ADCDAT,
	audio_conduit_end_ADCLRC,
	audio_conduit_end_DACDAT,
	audio_conduit_end_DACLRC,
	audio_conduit_end_BCLK,
	clk_50_clk_in_clk,
	clk_50_clk_in_reset_reset_n,
	eep_i2c_scl_external_connection_export,
	eep_i2c_sda_external_connection_export,
	i2c_scl_external_connection_export,
	i2c_sda_external_connection_export,
	key_external_connection_export,
	lcd_external_RS,
	lcd_external_RW,
	lcd_external_data,
	lcd_external_E,
	ledg_external_connection_export,
	ledr_external_connection_export,
	rs232_external_connection_rxd,
	rs232_external_connection_txd,
	rs232_external_connection_cts_n,
	rs232_external_connection_rts_n,
	sd_clk_external_connection_export,
	sd_cmd_external_connection_export,
	sd_dat_external_connection_export,
	sd_wp_n_external_connection_export,
	seg7_conduit_end_export,
	sma_in_external_connection_export,
	sma_out_external_connection_export,
	sw_external_connection_export,
	tri_state_bridge_flash_bridge_0_export_av_tri_s1_cfi_flash_0_tcm_address_out,
	tri_state_bridge_flash_bridge_0_export_av_tri_s1_cfi_flash_0_tcm_write_n_out,
	tri_state_bridge_flash_bridge_0_export_av_tri_s1_cfi_flash_0_tcm_chipselect_n_out,
	tri_state_bridge_flash_bridge_0_export_av_tri_s1_cfi_flash_0_tcm_read_n_out,
	tri_state_bridge_flash_bridge_0_export_av_tri_s1_cfi_flash_0_tcm_data_out);	

	input		Terasic_IrDA_0_conduit_end_export;
	output		altpll_audio_locked_conduit_export;
	output		altpll_audio_phasedone_conduit_export;
	output		altpll_c1_clk;
	output		altpll_c2_clk;
	output		altpll_c3_clk;
	output		altpll_locked_conduit_export;
	output		altpll_phasedone_conduit_export;
	output		audio_conduit_end_XCK;
	input		audio_conduit_end_ADCDAT;
	input		audio_conduit_end_ADCLRC;
	output		audio_conduit_end_DACDAT;
	input		audio_conduit_end_DACLRC;
	input		audio_conduit_end_BCLK;
	input		clk_50_clk_in_clk;
	input		clk_50_clk_in_reset_reset_n;
	output		eep_i2c_scl_external_connection_export;
	inout		eep_i2c_sda_external_connection_export;
	output		i2c_scl_external_connection_export;
	inout		i2c_sda_external_connection_export;
	input	[3:0]	key_external_connection_export;
	output		lcd_external_RS;
	output		lcd_external_RW;
	inout	[7:0]	lcd_external_data;
	output		lcd_external_E;
	output	[8:0]	ledg_external_connection_export;
	output	[17:0]	ledr_external_connection_export;
	input		rs232_external_connection_rxd;
	output		rs232_external_connection_txd;
	input		rs232_external_connection_cts_n;
	output		rs232_external_connection_rts_n;
	output		sd_clk_external_connection_export;
	inout		sd_cmd_external_connection_export;
	inout	[3:0]	sd_dat_external_connection_export;
	input		sd_wp_n_external_connection_export;
	output	[63:0]	seg7_conduit_end_export;
	input		sma_in_external_connection_export;
	output		sma_out_external_connection_export;
	input	[17:0]	sw_external_connection_export;
	output	[22:0]	tri_state_bridge_flash_bridge_0_export_av_tri_s1_cfi_flash_0_tcm_address_out;
	output	[0:0]	tri_state_bridge_flash_bridge_0_export_av_tri_s1_cfi_flash_0_tcm_write_n_out;
	output	[0:0]	tri_state_bridge_flash_bridge_0_export_av_tri_s1_cfi_flash_0_tcm_chipselect_n_out;
	output	[0:0]	tri_state_bridge_flash_bridge_0_export_av_tri_s1_cfi_flash_0_tcm_read_n_out;
	inout	[7:0]	tri_state_bridge_flash_bridge_0_export_av_tri_s1_cfi_flash_0_tcm_data_out;
endmodule
