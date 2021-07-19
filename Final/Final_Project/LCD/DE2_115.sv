module DE2_115_Default (
    //////// CLOCK //////////
	input CLOCK_50,
	input CLOCK2_50,
	input CLOCK3_50,
	input ENETCLK_25,
    //////// Sma //////////
	input SMA_CLKIN,
	output SMA_CLKOUT,
    //////// LED //////////
	output [8:0] LEDG,
	output [17:0] LEDR,
    //////// KEY //////////
	input [3:0] KEY,
    //////// SW //////////
	input [17:0] SW,
    //////// SEG7 //////////
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [6:0] HEX6,
	output [6:0] HEX7,
    //////// LCD //////////
	output LCD_BLON,
	inout [7:0] LCD_DATA,
	output LCD_EN,
	output LCD_ON,
	output LCD_RS,
	output LCD_RW,
    //////// RS232 //////////
	output UART_CTS,
	input UART_RTS,
	input UART_RXD,
	output UART_TXD,
    //////// PS2 //////////
	inout PS2_CLK,
	inout PS2_DAT,
	inout PS2_CLK2,
	inout PS2_DAT2,
    //////// SDCARD //////////
	output SD_CLK,
	inout SD_CMD,
	inout [3:0] SD_DAT,
	input SD_WP_N,
    //////// VGA //////////
	output [7:0] VGA_B,
	output VGA_BLANK_N,
	output VGA_CLK,
	output [7:0] VGA_G,
	output VGA_HS,
	output [7:0] VGA_R,
	output VGA_SYNC_N,
	output VGA_VS,
    //////// Audio //////////
	input AUD_ADCDAT,
	inout AUD_ADCLRCK,
	inout AUD_BCLK,
	output AUD_DACDAT,
	inout AUD_DACLRCK,
	output AUD_XCK,
    //////// I2C for EEPROM //////////
	output EEP_I2C_SCLK,
	inout EEP_I2C_SDAT,
    //////// I2C for Audio and Tv-Decode //////////
	output I2C_SCLK,
	inout I2C_SDAT,
    //////// Ethernet 0 //////////
	output ENET0_GTX_CLK,
	input ENET0_INT_N,
	output ENET0_MDC,
	input ENET0_MDIO,
	output ENET0_RST_N,
	input ENET0_RX_CLK,
	input ENET0_RX_COL,
	input ENET0_RX_CRS,
	input [3:0] ENET0_RX_DATA,
	input ENET0_RX_DV,
	input ENET0_RX_ER,
	input ENET0_TX_CLK,
	output [3:0] ENET0_TX_DATA,
	output ENET0_TX_EN,
	output ENET0_TX_ER,
	input ENET0_LINK100,
    //////// Ethernet 1 //////////
	output ENET1_GTX_CLK,
	input ENET1_INT_N,
	output ENET1_MDC,
	input ENET1_MDIO,
	output ENET1_RST_N,
	input ENET1_RX_CLK,
	input ENET1_RX_COL,
	input ENET1_RX_CRS,
	input [3:0] ENET1_RX_DATA,
	input ENET1_RX_DV,
	input ENET1_RX_ER,
	input ENET1_TX_CLK,
	output [3:0] ENET1_TX_DATA,
	output ENET1_TX_EN,
	output ENET1_TX_ER,
	input ENET1_LINK100,
    //////// TV Decoder //////////
	input TD_CLK27,
	input [7:0] TD_DATA,
	input TD_HS,
	output TD_RESET_N,
	input TD_VS,
    /////// USB OTG controller
	inout [15:0] OTG_DATA,
	output [1:0] OTG_ADDR,
	output OTG_CS_N,
	output OTG_WR_N,
	output OTG_RD_N,
	input OTG_INT,
	output OTG_RST_N,
    //////// IR Receiver //////////
	input IRDA_RXD,
    //////// SDRAM //////////
	output [12:0] DRAM_ADDR,
	output [1:0] DRAM_BA,
	output DRAM_CAS_N,
	output DRAM_CKE,
	output DRAM_CLK,
	output DRAM_CS_N,
	inout [31:0] DRAM_DQ,
	output [3:0] DRAM_DQM,
	output DRAM_RAS_N,
	output DRAM_WE_N,
    //////// SRAM //////////
	output [19:0] SRAM_ADDR,
	output SRAM_CE_N,
	inout [15:0] SRAM_DQ,
	output SRAM_LB_N,
	output SRAM_OE_N,
	output SRAM_UB_N,
	output SRAM_WE_N,
    //////// Flash //////////
	output [22:0] FL_ADDR,
	output FL_CE_N,
	inout [7:0] FL_DQ,
	output FL_OE_N,
	output FL_RST_N,
	input FL_RY,
	output FL_WE_N,
	output FL_WP_N,
    //////// GPIO //////////
	inout [35:0] GPIO,
    //////// HSMC (LVDS) //////////
	input HSMC_CLKIN_P1,
	input HSMC_CLKIN_P2,
	input HSMC_CLKIN0,
	output HSMC_CLKOUT_P1,
	output HSMC_CLKOUT_P2,
	output HSMC_CLKOUT0,
	inout [3:0] HSMC_D,
	input [16:0] HSMC_RX_D_P,
	output [16:0] HSMC_TX_D_P,
    //////// EXTEND IO //////////
	inout [6:0] EX_IO
);

//=======================================================
//  PARAMETER declarations
//=======================================================

//=============================================================================
// REG/WIRE declarations
//=============================================================================

wire [7:0]  LCD_D_1;
wire        LCD_RW_1;
wire        LCD_EN_1;
wire        LCD_RS_1;
reg  [9:0]  percent_r,percent_w;
reg  [11:0] score_r,score_w;
reg         counter2_r,counter2_w;
reg  [29:0] counter_r,counter_w;

//=============================================================================
// Structural coding
//=============================================================================

assign LCD_DATA = LCD_D_1;
assign LCD_RW   = LCD_RW_1;
assign LCD_EN   = LCD_EN_1;
assign LCD_RS   = LCD_RS_1; 
assign LCD_ON   = 1'b1;
assign LCD_BLON = 1'b0; //not supported;

always@(*) begin
	if(counter_r == 30'd20000000)
	begin
		counter_w = 0;
		counter2_w = counter2_r + 1;
		if(counter2_r == 1)
		begin
			percent_w = percent_r + 1;
			score_w = score_r + 1;
		end
		else
		begin
			percent_w = percent_r;
			score_w = score_r;
		end
	end
	else
	begin
		counter_w = counter_r + 1;
		counter2_w = counter2_r;
		percent_w = percent_r;
		score_w = score_r;
	end
end

always@(posedge CLOCK_50 or negedge KEY[0]) begin
    if(!KEY[0])
	begin
			counter_r <= 0;
			counter2_r <= 0;
			percent_r <= 0;
			score_r <= 0;
	end
	else
	begin
			counter_r <= counter_w;
			counter2_r <= counter2_w;
			percent_r <= percent_w;
			score_r <= score_w;
	end
end

LCD_TEST u5	(
	//	Host Side
	.iCLK(CLOCK_50),
	.iRST_N(KEY[0]),
	.Percent(percent_r),
	.Score(score_r),
	//	LCD Side
	.LCD_DATA(LCD_D_1),
	.LCD_RW(LCD_RW_1),
	.LCD_EN(LCD_EN_1),
	.LCD_RS(LCD_RS_1)
);

endmodule
