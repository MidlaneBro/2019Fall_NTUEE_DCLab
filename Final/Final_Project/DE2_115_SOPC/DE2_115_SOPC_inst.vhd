	component DE2_115_SOPC is
		port (
			Terasic_IrDA_0_conduit_end_export                                                 : in    std_logic                     := 'X';             -- export
			altpll_audio_locked_conduit_export                                                : out   std_logic;                                        -- export
			altpll_audio_phasedone_conduit_export                                             : out   std_logic;                                        -- export
			altpll_c1_clk                                                                     : out   std_logic;                                        -- clk
			altpll_c2_clk                                                                     : out   std_logic;                                        -- clk
			altpll_c3_clk                                                                     : out   std_logic;                                        -- clk
			altpll_locked_conduit_export                                                      : out   std_logic;                                        -- export
			altpll_phasedone_conduit_export                                                   : out   std_logic;                                        -- export
			audio_conduit_end_XCK                                                             : out   std_logic;                                        -- XCK
			audio_conduit_end_ADCDAT                                                          : in    std_logic                     := 'X';             -- ADCDAT
			audio_conduit_end_ADCLRC                                                          : in    std_logic                     := 'X';             -- ADCLRC
			audio_conduit_end_DACDAT                                                          : out   std_logic;                                        -- DACDAT
			audio_conduit_end_DACLRC                                                          : in    std_logic                     := 'X';             -- DACLRC
			audio_conduit_end_BCLK                                                            : in    std_logic                     := 'X';             -- BCLK
			clk_50_clk_in_clk                                                                 : in    std_logic                     := 'X';             -- clk
			clk_50_clk_in_reset_reset_n                                                       : in    std_logic                     := 'X';             -- reset_n
			eep_i2c_scl_external_connection_export                                            : out   std_logic;                                        -- export
			eep_i2c_sda_external_connection_export                                            : inout std_logic                     := 'X';             -- export
			i2c_scl_external_connection_export                                                : out   std_logic;                                        -- export
			i2c_sda_external_connection_export                                                : inout std_logic                     := 'X';             -- export
			key_external_connection_export                                                    : in    std_logic_vector(3 downto 0)  := (others => 'X'); -- export
			lcd_external_RS                                                                   : out   std_logic;                                        -- RS
			lcd_external_RW                                                                   : out   std_logic;                                        -- RW
			lcd_external_data                                                                 : inout std_logic_vector(7 downto 0)  := (others => 'X'); -- data
			lcd_external_E                                                                    : out   std_logic;                                        -- E
			ledg_external_connection_export                                                   : out   std_logic_vector(8 downto 0);                     -- export
			ledr_external_connection_export                                                   : out   std_logic_vector(17 downto 0);                    -- export
			rs232_external_connection_rxd                                                     : in    std_logic                     := 'X';             -- rxd
			rs232_external_connection_txd                                                     : out   std_logic;                                        -- txd
			rs232_external_connection_cts_n                                                   : in    std_logic                     := 'X';             -- cts_n
			rs232_external_connection_rts_n                                                   : out   std_logic;                                        -- rts_n
			sd_clk_external_connection_export                                                 : out   std_logic;                                        -- export
			sd_cmd_external_connection_export                                                 : inout std_logic                     := 'X';             -- export
			sd_dat_external_connection_export                                                 : inout std_logic_vector(3 downto 0)  := (others => 'X'); -- export
			sd_wp_n_external_connection_export                                                : in    std_logic                     := 'X';             -- export
			seg7_conduit_end_export                                                           : out   std_logic_vector(63 downto 0);                    -- export
			sma_in_external_connection_export                                                 : in    std_logic                     := 'X';             -- export
			sma_out_external_connection_export                                                : out   std_logic;                                        -- export
			sw_external_connection_export                                                     : in    std_logic_vector(17 downto 0) := (others => 'X'); -- export
			tri_state_bridge_flash_bridge_0_export_av_tri_s1_cfi_flash_0_tcm_address_out      : out   std_logic_vector(22 downto 0);                    -- av_tri_s1_cfi_flash_0_tcm_address_out
			tri_state_bridge_flash_bridge_0_export_av_tri_s1_cfi_flash_0_tcm_write_n_out      : out   std_logic_vector(0 downto 0);                     -- av_tri_s1_cfi_flash_0_tcm_write_n_out
			tri_state_bridge_flash_bridge_0_export_av_tri_s1_cfi_flash_0_tcm_chipselect_n_out : out   std_logic_vector(0 downto 0);                     -- av_tri_s1_cfi_flash_0_tcm_chipselect_n_out
			tri_state_bridge_flash_bridge_0_export_av_tri_s1_cfi_flash_0_tcm_read_n_out       : out   std_logic_vector(0 downto 0);                     -- av_tri_s1_cfi_flash_0_tcm_read_n_out
			tri_state_bridge_flash_bridge_0_export_av_tri_s1_cfi_flash_0_tcm_data_out         : inout std_logic_vector(7 downto 0)  := (others => 'X')  -- av_tri_s1_cfi_flash_0_tcm_data_out
		);
	end component DE2_115_SOPC;

	u0 : component DE2_115_SOPC
		port map (
			Terasic_IrDA_0_conduit_end_export                                                 => CONNECTED_TO_Terasic_IrDA_0_conduit_end_export,                                                 --             Terasic_IrDA_0_conduit_end.export
			altpll_audio_locked_conduit_export                                                => CONNECTED_TO_altpll_audio_locked_conduit_export,                                                --            altpll_audio_locked_conduit.export
			altpll_audio_phasedone_conduit_export                                             => CONNECTED_TO_altpll_audio_phasedone_conduit_export,                                             --         altpll_audio_phasedone_conduit.export
			altpll_c1_clk                                                                     => CONNECTED_TO_altpll_c1_clk,                                                                     --                              altpll_c1.clk
			altpll_c2_clk                                                                     => CONNECTED_TO_altpll_c2_clk,                                                                     --                              altpll_c2.clk
			altpll_c3_clk                                                                     => CONNECTED_TO_altpll_c3_clk,                                                                     --                              altpll_c3.clk
			altpll_locked_conduit_export                                                      => CONNECTED_TO_altpll_locked_conduit_export,                                                      --                  altpll_locked_conduit.export
			altpll_phasedone_conduit_export                                                   => CONNECTED_TO_altpll_phasedone_conduit_export,                                                   --               altpll_phasedone_conduit.export
			audio_conduit_end_XCK                                                             => CONNECTED_TO_audio_conduit_end_XCK,                                                             --                      audio_conduit_end.XCK
			audio_conduit_end_ADCDAT                                                          => CONNECTED_TO_audio_conduit_end_ADCDAT,                                                          --                                       .ADCDAT
			audio_conduit_end_ADCLRC                                                          => CONNECTED_TO_audio_conduit_end_ADCLRC,                                                          --                                       .ADCLRC
			audio_conduit_end_DACDAT                                                          => CONNECTED_TO_audio_conduit_end_DACDAT,                                                          --                                       .DACDAT
			audio_conduit_end_DACLRC                                                          => CONNECTED_TO_audio_conduit_end_DACLRC,                                                          --                                       .DACLRC
			audio_conduit_end_BCLK                                                            => CONNECTED_TO_audio_conduit_end_BCLK,                                                            --                                       .BCLK
			clk_50_clk_in_clk                                                                 => CONNECTED_TO_clk_50_clk_in_clk,                                                                 --                          clk_50_clk_in.clk
			clk_50_clk_in_reset_reset_n                                                       => CONNECTED_TO_clk_50_clk_in_reset_reset_n,                                                       --                    clk_50_clk_in_reset.reset_n
			eep_i2c_scl_external_connection_export                                            => CONNECTED_TO_eep_i2c_scl_external_connection_export,                                            --        eep_i2c_scl_external_connection.export
			eep_i2c_sda_external_connection_export                                            => CONNECTED_TO_eep_i2c_sda_external_connection_export,                                            --        eep_i2c_sda_external_connection.export
			i2c_scl_external_connection_export                                                => CONNECTED_TO_i2c_scl_external_connection_export,                                                --            i2c_scl_external_connection.export
			i2c_sda_external_connection_export                                                => CONNECTED_TO_i2c_sda_external_connection_export,                                                --            i2c_sda_external_connection.export
			key_external_connection_export                                                    => CONNECTED_TO_key_external_connection_export,                                                    --                key_external_connection.export
			lcd_external_RS                                                                   => CONNECTED_TO_lcd_external_RS,                                                                   --                           lcd_external.RS
			lcd_external_RW                                                                   => CONNECTED_TO_lcd_external_RW,                                                                   --                                       .RW
			lcd_external_data                                                                 => CONNECTED_TO_lcd_external_data,                                                                 --                                       .data
			lcd_external_E                                                                    => CONNECTED_TO_lcd_external_E,                                                                    --                                       .E
			ledg_external_connection_export                                                   => CONNECTED_TO_ledg_external_connection_export,                                                   --               ledg_external_connection.export
			ledr_external_connection_export                                                   => CONNECTED_TO_ledr_external_connection_export,                                                   --               ledr_external_connection.export
			rs232_external_connection_rxd                                                     => CONNECTED_TO_rs232_external_connection_rxd,                                                     --              rs232_external_connection.rxd
			rs232_external_connection_txd                                                     => CONNECTED_TO_rs232_external_connection_txd,                                                     --                                       .txd
			rs232_external_connection_cts_n                                                   => CONNECTED_TO_rs232_external_connection_cts_n,                                                   --                                       .cts_n
			rs232_external_connection_rts_n                                                   => CONNECTED_TO_rs232_external_connection_rts_n,                                                   --                                       .rts_n
			sd_clk_external_connection_export                                                 => CONNECTED_TO_sd_clk_external_connection_export,                                                 --             sd_clk_external_connection.export
			sd_cmd_external_connection_export                                                 => CONNECTED_TO_sd_cmd_external_connection_export,                                                 --             sd_cmd_external_connection.export
			sd_dat_external_connection_export                                                 => CONNECTED_TO_sd_dat_external_connection_export,                                                 --             sd_dat_external_connection.export
			sd_wp_n_external_connection_export                                                => CONNECTED_TO_sd_wp_n_external_connection_export,                                                --            sd_wp_n_external_connection.export
			seg7_conduit_end_export                                                           => CONNECTED_TO_seg7_conduit_end_export,                                                           --                       seg7_conduit_end.export
			sma_in_external_connection_export                                                 => CONNECTED_TO_sma_in_external_connection_export,                                                 --             sma_in_external_connection.export
			sma_out_external_connection_export                                                => CONNECTED_TO_sma_out_external_connection_export,                                                --            sma_out_external_connection.export
			sw_external_connection_export                                                     => CONNECTED_TO_sw_external_connection_export,                                                     --                 sw_external_connection.export
			tri_state_bridge_flash_bridge_0_export_av_tri_s1_cfi_flash_0_tcm_address_out      => CONNECTED_TO_tri_state_bridge_flash_bridge_0_export_av_tri_s1_cfi_flash_0_tcm_address_out,      -- tri_state_bridge_flash_bridge_0_export.av_tri_s1_cfi_flash_0_tcm_address_out
			tri_state_bridge_flash_bridge_0_export_av_tri_s1_cfi_flash_0_tcm_write_n_out      => CONNECTED_TO_tri_state_bridge_flash_bridge_0_export_av_tri_s1_cfi_flash_0_tcm_write_n_out,      --                                       .av_tri_s1_cfi_flash_0_tcm_write_n_out
			tri_state_bridge_flash_bridge_0_export_av_tri_s1_cfi_flash_0_tcm_chipselect_n_out => CONNECTED_TO_tri_state_bridge_flash_bridge_0_export_av_tri_s1_cfi_flash_0_tcm_chipselect_n_out, --                                       .av_tri_s1_cfi_flash_0_tcm_chipselect_n_out
			tri_state_bridge_flash_bridge_0_export_av_tri_s1_cfi_flash_0_tcm_read_n_out       => CONNECTED_TO_tri_state_bridge_flash_bridge_0_export_av_tri_s1_cfi_flash_0_tcm_read_n_out,       --                                       .av_tri_s1_cfi_flash_0_tcm_read_n_out
			tri_state_bridge_flash_bridge_0_export_av_tri_s1_cfi_flash_0_tcm_data_out         => CONNECTED_TO_tri_state_bridge_flash_bridge_0_export_av_tri_s1_cfi_flash_0_tcm_data_out          --                                       .av_tri_s1_cfi_flash_0_tcm_data_out
		);

