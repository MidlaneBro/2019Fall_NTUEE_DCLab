module Top (
	input i_rst_n,
	input i_clk,
	input i_key_0,
	input i_key_1,
	input i_key_2,
	input [3:0] i_speed, // design how user can decide mode on your own
	
	// AudDSP and SRAM
	output [19:0] o_SRAM_ADDR,
	inout  [15:0] io_SRAM_DQ,
	output        o_SRAM_WE_N,
	output        o_SRAM_CE_N,
	output        o_SRAM_OE_N,
	output        o_SRAM_LB_N,
	output        o_SRAM_UB_N,
	
	// I2C
	input  i_clk_100k,
	output o_I2C_SCLK,
	inout  io_I2C_SDAT,
	
	// AudPlayer
	input  i_AUD_ADCDAT,
	inout  i_AUD_ADCLRCK,
	inout  i_AUD_BCLK,
	inout  i_AUD_DACLRCK,
	output o_AUD_DACDAT,

	// SEVENDECODER (optional display)
	// output [5:0] o_record_time,
	// output [5:0] o_play_time,

	// LCD (optional display)
	// input        i_clk_800k,
	// inout  [7:0] o_LCD_DATA,
	// output       o_LCD_EN,
	// output       o_LCD_RS,
	// output       o_LCD_RW,
	// output       o_LCD_ON,
	// output       o_LCD_BLON,

	// LED
	output [8:0] o_ledg,
	output [17:0] o_ledr

);

// design the FSM and states as you like
parameter S_IDLE       = 0;
parameter S_I2C        = 1;
parameter S_RECD       = 2;
parameter S_RECD_PAUSE = 3;
parameter S_PLAY       = 4;
parameter S_PLAY_PAUSE = 5;

wire i2c_sdat;
logic i2c_oen;
logic [19:0] addr_record, addr_play;
logic [15:0] data_record, data_play, dac_data;
logic [2:0] state_r, state_w;
logic ini_start_r, ini_start_w;
logic ini_finish_r, ini_finish_w;
logic rec_start_r, rec_start_w;
logic rec_pause_r, rec_pause_w;
logic rec_stop_r, rec_stop_w;
logic play_start_r, play_start_w;
logic play_pause_r, play_pause_w;
logic play_stop_r, play_stop_w;
logic [19:0] data_end_address_r, data_end_address_w;
logic [1:0] mode_r, mode_w; // 0:orginal 1:fast 2:constant interpolation 3:linear interpolation
logic test_record_r, test_record_w;
logic test_play_r, test_play_w;

assign io_I2C_SDAT = (i2c_oen) ? i2c_sdat : 1'bz;

assign o_SRAM_ADDR = (state_r == S_RECD) ? addr_record : addr_play[19:0];
assign io_SRAM_DQ  = (state_r == S_RECD) ? data_record : 16'dz; // sram_dq as output
assign data_play   = (state_r != S_RECD) ? io_SRAM_DQ : 16'd0; // sram_dq as input

assign o_SRAM_WE_N = (state_r == S_RECD) ? 1'b0 : 1'b1;
assign o_SRAM_CE_N = 1'b0;
assign o_SRAM_OE_N = 1'b0;
assign o_SRAM_LB_N = 1'b0;
assign o_SRAM_UB_N = 1'b0;

assign o_ledg[3:0] = state_r;
assign o_ledg[5:4] = mode_r;
assign o_ledr[17] = i_AUD_ADCDAT;
assign o_ledr[16] = !i_AUD_ADCDAT;
assign o_ledr[15] = o_AUD_DACDAT;
assign o_ledr[14] = test_record_r;
assign o_ledr[13] = test_play_r;
assign o_ledr[8:5] = data_record[3:0];
assign o_ledr[12:9] = io_SRAM_DQ[3:0];
assign o_ledr[3:0] = i_speed;

// below is a simple example for module division
// you can design these as you like

// === I2cInitializer ===
// sequentially sent out settings to initialize WM8731 with I2C protocal
I2cInitializer init0(
	.i_rst_n(i_rst_n),
	.i_clk(i_clk_100k),
	.i_start(ini_start_r),
	.o_finished(ini_finish_r),
	.o_sclk(o_I2C_SCLK),
	.io_sdat(i2c_sdat),
	.o_oen(i2c_oen) // you are outputing (you are not outputing only when you are "ack"ing.)
);

// === AudDSP ===
// responsible for DSP operations including fast play and slow play at different speed
// in other words, determine which data addr to be fetch for player 
AudDSP dsp0(
	.i_rst_n(i_rst_n),
	.i_clk(i_clk),
	.i_start(play_start_r),
	.i_pause(play_pause_r),
	.i_stop(play_stop_r),
	.i_speed(i_speed),
	.i_mode(mode_r), // 0:orginal 1:fast 2:constant interpolation 3:linear interpolation
	.i_daclrck(i_AUD_DACLRCK),
	.i_sram_data(data_play),
	.o_dac_data(dac_data),
	.o_sram_addr(addr_play),
	.o_dsp_state(o_ledg[7:6])
);

// === AudPlayer ===
// receive data address from DSP and fetch data to sent to WM8731 with I2S protocal
AudPlayer player0(
	.i_rst_n(i_rst_n),
	.i_bclk(i_AUD_BCLK),
	.i_daclrck(i_AUD_DACLRCK),
	.i_en(!play_pause_r), // enable AudPlayer only when playing audio, work with AudDSP
	.i_dac_data(dac_data), //dac_data
	.o_aud_dacdat(o_AUD_DACDAT)
);

// === AudRecorder ===
// receive data from WM8731 with I2S protocal and save to SRAM
AudRecorder recorder0(
	.i_rst_n(i_rst_n), 
	.i_clk(i_AUD_BCLK),
	.i_lrc(i_AUD_ADCLRCK),
	.i_start(rec_start_r),
	.i_pause(rec_pause_r),
	.i_stop(rec_stop_r),
	.i_data(i_AUD_ADCDAT),
	.o_address(addr_record),
	.o_data(data_record)
);

always_comb begin
	//default value
	state_w = state_r;
	ini_start_w = ini_start_r;
	rec_start_w = rec_start_r;
	play_start_w = play_start_r;
	mode_w = mode_r;
	data_end_address_w = data_end_address_r;
	rec_pause_w = rec_pause_r;
	play_pause_w = play_pause_r;
	rec_stop_w = rec_stop_r;
	play_stop_w = play_stop_r;
	test_record_w = test_record_r;
	test_play_w = test_play_r;
	//FSM
	case (state_r)
		S_IDLE:
		begin
			state_w = S_I2C;
			ini_start_w = 1;
			rec_pause_w = 1;
			play_pause_w = 1;
			rec_stop_w = 0;
			play_stop_w = 0;
		end
		S_I2C:
		begin
			if(ini_finish_r)
				state_w = S_RECD_PAUSE;
			else
				ini_start_w = 0;
		end
		S_RECD:
		begin
			rec_start_w = 0;
			if(!i_AUD_ADCLRCK && rec_pause_r && rec_stop_r) begin
				state_w = S_PLAY_PAUSE;
				rec_stop_w = 0;
			end
			else if(!i_AUD_ADCLRCK && rec_pause_r)
				state_w = S_RECD_PAUSE;
			else if(i_key_0)
			begin
				rec_pause_w = 1;
			end
			else if(i_key_1)
			begin
				data_end_address_w = addr_record;
				rec_pause_w = 1;
				rec_stop_w = 1;
			end
			else if(addr_record == 20'b11111111111111111111)
			begin
				data_end_address_w = addr_record;
				rec_pause_w = 1;
				rec_stop_w = 1;
			end
			else
			begin
			end
		end
		S_RECD_PAUSE:
		begin
			if(i_key_0)
			begin
				state_w = S_RECD;
				rec_pause_w = 0;
				rec_start_w = 1;
			end
			else
			begin
			end
		end
		S_PLAY:
		begin
			if(!i_AUD_DACLRCK && play_pause_r)
			begin
				state_w = S_PLAY_PAUSE;
				play_start_w = 0;
			end
			else
			if(i_key_0)
			begin
				play_pause_w = 1;
			end
			else if(i_key_1)
			begin
				play_pause_w = 1;
				play_stop_w = 1;
			end
			else if(addr_play>data_end_address_r)
			begin
				play_pause_w = 1;
				play_stop_w = 1;
				play_start_w = 0;
			end
			else
			begin
			end
		end
		S_PLAY_PAUSE:
		begin
			play_stop_w = 0;
			if(i_key_0)
			begin
				state_w = S_PLAY;
				play_start_w = 1;
				play_pause_w = 0;
			end
			else if(i_key_1)
			begin
				mode_w = mode_r+1;
			end
			else if(i_key_2)
			begin
				state_w = S_RECD_PAUSE;
			end
			else
			begin
				
			end
		end
	endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		state_r <= S_IDLE;
		ini_start_r <= 0;
		rec_start_r <= 0;
		mode_r <= 0;
		data_end_address_r <= 0;
		rec_pause_r <= 1;
		play_pause_r <= 1;
		rec_stop_r <= 0;
		play_stop_r <= 0;
		test_record_r <= 0;
		play_start_r <= 0;
		//test_play_r <= 0;
	end
	else
	begin
		state_r <= state_w;
		ini_start_r <= ini_start_w;
		rec_start_r <= rec_start_w;
		mode_r <= mode_w;
		data_end_address_r <= data_end_address_w;
		rec_pause_r <= rec_pause_w;
		play_pause_r <= play_pause_w;
		rec_stop_r <= rec_stop_w;
		play_stop_r <= play_stop_w;
		test_record_r <= test_record_w;
		play_start_r <= play_start_w;
		//test_play_r <= test_play_w;
		if(!i_AUD_ADCDAT && (state_r ==S_RECD))
		begin
			test_record_r <= 1;
		end
		if(o_AUD_DACDAT && (state_r ==S_PLAY))
		begin
			//test_play_r <= 1;
		end
	end
end

always_ff @(negedge i_AUD_DACLRCK or negedge i_rst_n) begin
	if (!i_rst_n) begin
		//play_start_r <= 0;
		test_play_r <= 0;
		//play_stop_r <= 0;
	end
	else
	begin
		//play_start_r <= play_start_w;
		test_play_r <= 1;
		//play_stop_r <= play_stop_w;
	end
end

endmodule