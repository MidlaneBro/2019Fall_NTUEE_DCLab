// the top module for the fft and scoring system

module fft_n_ifft (
	input i_clk,       //   dac_clock one data for a cycle
	input i_reset_n,  // reset
	input [31:0] i_write_data,
	input [2:0] i_addr, // 000: vocal, 001: sd, 010: refresh score, 011: i_finished, 
	input i_chip_sel,
	input i_write_en, // after start, write_en = 1, 
	output [31:0] o_read_data, // control score and percent send left/right 
	output o_scoring_finished  // scoring is complete
);
reg[15:0] voice_data_r, voice_data_w;
reg[15:0] sd_data_r, sd_data_w;
reg sink_valid_vl_r, sink_valid_vl_w; //When the final sample loads, the source asserts sink_eop and sink_valid for the last data transfer.
reg sink_sop_vl_r, sink_sop_vl_w;
reg sink_eop_vl_r, sink_eop_vl_w;
reg source_ready_vl_r, source_ready_vl_w;
reg sink_valid_sdl_r, sink_valid_sdl_w; //When the final sample loads, the source asserts sink_eop and sink_valid for the last data transfer.
reg sink_sop_sdl_r, sink_sop_sdl_w;
reg sink_eop_sdl_r, sink_eop_sdl_w;
reg source_ready_sdl_r, source_ready_sdl_w;
reg[10:0] counter_r, counter_w;
reg[2:0] state_r, state_w;
reg start_evaluate_r, start_evaluate_w;
reg vocal_exist_r, vocal_exist_w;
reg[31:0] read_data_r, read_data_w;

wire sink_ready_vl, sink_ready_sdl;
wire source_valid_vl, source_valid_sdl;
wire source_sop_vl, source_sop_sdl;
wire source_eop_vl, source_eop_sdl;
wire[1:0] source_error_vl, source_error_sdl;

// fft to evaluate
wire[15:0] voice_freq_imag;
wire[15:0] voice_freq_real;
wire[15:0] sd_freq_imag;
wire[15:0] sd_freq_real;
// evaluate to scoring
wire start_scoring;
wire correctness;
wire[15:0] score;
wire[9:0] percent;

integer i;

localparam S_IDLE = 0;
localparam S_VOICE = 1;
localparam S_SD = 2;
localparam S_SCORING = 3;
localparam S_PAUSE = 4;
assign o_start_evaluate = start_evaluate_r;
assign o_read_data = read_data_r;
//assign o_read_data = {score, 4'b0, percent, 6'b0};

evaluate evaluate_0(
    .i_clk(i_clk),
    .i_rst_n(i_reset_n),
    .i_start(start_evaluate_r),  
    .i_voice_freq_imag(voice_freq_imag),
	.i_voice_freq_real(voice_freq_real),
	.i_sd_freq_imag(sd_freq_imag),
	.i_sd_freq_real(sd_freq_real),
    .o_start_scoring(start_scoring),
    .o_result(1)
);

scoring scoring_0(
	.i_clk(i_clk),
    .i_rst_n(i_reset_n),
    .i_receiving(start_scoring),
    .i_correct(1),
	.i_control(i_addr),
	.o_score(score),
	.o_percent(percent), // between 0 to 1000, represents 0%, 0.1%, 0.2%, etc.
	.o_finished(o_scoring_finished)
); 

fft_n_ifft_fft_ii_0 fft_voice(
	.clk(i_clk), 
	.reset_n(i_reset_n),
	.inverse(0),
	// sink part (inputs except sink_ready)
	.sink_ready(sink_ready_vl),
	.fftpts_in(2048),
	.sink_valid(sink_valid_vl_r),
	.sink_sop(sink_sop_vl_r),
	.sink_eop(sink_eop_vl_r),
	.sink_real(voice_data_r),  // buffer 1 clock cycle
	.sink_imag(0), //fed-in signal nust be REAL!
	.sink_error(0),
	// source part (outputs except source_ready)
	.source_ready(source_ready_vl_r),
	.fftpts_out(2048),
	.source_valid(source_valid_vl),
	.source_sop(source_sop_vl),
	.source_eop(source_eop_vl),
	.source_real(voice_freq_real),  // the 2 outputs
	.source_imag(voice_freq_imag),
	.source_error(source_error_vl)
);

fft_n_ifft_fft_ii_0 fft_sd(
	.clk(i_clk),
	.reset_n(i_reset_n),
	.inverse(0),
	// sink part (inputs except sink_ready)	
	.sink_ready(sink_ready_sdl),
	.fftpts_in(2048),
	.sink_valid(sink_valid_sdl_r),
	.sink_sop(sink_sop_sdl_r),
	.sink_eop(sink_eop_sdl_r),
	.sink_real(sd_data_r),  // no buffer
	.sink_imag(0),
	.sink_error(0),
	// source part (outputs except source_ready)	
	.source_ready(source_ready_sdl_r),
	.fftpts_out(2048),
	.source_error(source_error_sdl),
	.source_sop(source_sop_sdl),
	.source_eop(source_eop_sdl),
	.source_valid(source_valid_sdl),
	.source_real(sd_freq_real),  // the 2 outputs
	.source_imag(sd_freq_imag)
);

altera_reset_controller #(
	.NUM_RESET_INPUTS          (1),
	.OUTPUT_RESET_SYNC_EDGES   ("deassert"),
	.SYNC_DEPTH                (2),
	.RESET_REQUEST_PRESENT     (0),
	.RESET_REQ_WAIT_TIME       (1),
	.MIN_RST_ASSERTION_TIME    (3),
	.RESET_REQ_EARLY_DSRT_TIME (1),
	.USE_RESET_REQUEST_IN0     (0),
	.USE_RESET_REQUEST_IN1     (0),
	.USE_RESET_REQUEST_IN2     (0),
	.USE_RESET_REQUEST_IN3     (0),
	.USE_RESET_REQUEST_IN4     (0),
	.USE_RESET_REQUEST_IN5     (0),
	.USE_RESET_REQUEST_IN6     (0),
	.USE_RESET_REQUEST_IN7     (0),
	.USE_RESET_REQUEST_IN8     (0),
	.USE_RESET_REQUEST_IN9     (0),
	.USE_RESET_REQUEST_IN10    (0),
	.USE_RESET_REQUEST_IN11    (0),
	.USE_RESET_REQUEST_IN12    (0),
	.USE_RESET_REQUEST_IN13    (0),
	.USE_RESET_REQUEST_IN14    (0),
	.USE_RESET_REQUEST_IN15    (0),
	.ADAPT_RESET_REQUEST       (0)
) rst_controller (
	.reset_in0      (~reset_reset_n),                 // reset_in0.reset
	.clk            (clk_clk),                        //       clk.clk
	.reset_out      (rst_controller_reset_out_reset), // reset_out.reset
	.reset_req      (),                               // (terminated)
	.reset_req_in0  (1'b0),                           // (terminated)
	.reset_in1      (1'b0),                           // (terminated)
	.reset_req_in1  (1'b0),                           // (terminated)
	.reset_in2      (1'b0),                           // (terminated)
	.reset_req_in2  (1'b0),                           // (terminated)
	.reset_in3      (1'b0),                           // (terminated)
	.reset_req_in3  (1'b0),                           // (terminated)
	.reset_in4      (1'b0),                           // (terminated)
	.reset_req_in4  (1'b0),                           // (terminated)
	.reset_in5      (1'b0),                           // (terminated)
	.reset_req_in5  (1'b0),                           // (terminated)
	.reset_in6      (1'b0),                           // (terminated)
	.reset_req_in6  (1'b0),                           // (terminated)
	.reset_in7      (1'b0),                           // (terminated)
	.reset_req_in7  (1'b0),                           // (terminated)
	.reset_in8      (1'b0),                           // (terminated)
	.reset_req_in8  (1'b0),                           // (terminated)
	.reset_in9      (1'b0),                           // (terminated)
	.reset_req_in9  (1'b0),                           // (terminated)
	.reset_in10     (1'b0),                           // (terminated)
	.reset_req_in10 (1'b0),                           // (terminated)
	.reset_in11     (1'b0),                           // (terminated)
	.reset_req_in11 (1'b0),                           // (terminated)
	.reset_in12     (1'b0),                           // (terminated)
	.reset_req_in12 (1'b0),                           // (terminated)
	.reset_in13     (1'b0),                           // (terminated)
	.reset_req_in13 (1'b0),                           // (terminated)
	.reset_in14     (1'b0),                           // (terminated)
	.reset_req_in14 (1'b0),                           // (terminated)
	.reset_in15     (1'b0),                           // (terminated)
	.reset_req_in15 (1'b0)                            // (terminated)
);

always@(*) begin
	voice_data_w = voice_data_r;
	sd_data_w = sd_data_r;
	sink_valid_vl_w = sink_valid_vl_r; 
	sink_sop_vl_w = sink_sop_vl_r;
	sink_eop_vl_w = sink_eop_vl_r;
	source_ready_vl_w = source_ready_vl_r;
	sink_valid_sdl_w = sink_valid_sdl_r;
	sink_sop_sdl_w = sink_sop_sdl_r;
	sink_eop_sdl_w = sink_eop_sdl_r;
	source_ready_sdl_w = source_ready_sdl_r;
	counter_w = counter_r;
	state_w = state_r;
	start_evaluate_w = start_evaluate_r;
	vocal_exist_w = vocal_exist_r;
	case(i_addr)
		3'b000:
			read_data_w = {16'b0, voice_data_r};
		3'b001:
			read_data_w = {16'b0, sd_data_r};
		3'b010:
			read_data_w = {score, percent, 6'b0};	
	endcase
	case(state_r)
		S_IDLE:
		begin
			if (i_write_en)
			begin
				counter_w = 0;
				source_ready_vl_w = 1;
				source_ready_sdl_w = 1;
				vocal_exist_w = 0;
				voice_data_w = i_write_data[31:16] + i_write_data[15:0];
				state_w = S_VOICE;
			end
			else 
			begin
				sink_valid_vl_w = 0; 
				sink_sop_vl_w = 0;
				sink_eop_vl_w = 0;
				source_ready_vl_w = 0;
				sink_valid_sdl_w = 0;
				sink_sop_sdl_w = 0;
				sink_eop_sdl_w = 0;
				source_ready_sdl_w = 0;
				start_evaluate_w = 0;			
			end
		end
		S_VOICE:
		begin
			if(i_write_en)
			begin
				sink_valid_vl_w = 1;
				sink_valid_sdl_w = 1;
				sd_data_w = i_write_data[31:16] + i_write_data[15:0];
				if(i_write_data[31:16] + i_write_data[15:0] > 2000)
				begin
					vocal_exist_w = 1;
				end
				state_w = S_SD;
				if(counter_r == 12'b0)
				begin
					sink_sop_vl_w = 1;
					sink_sop_sdl_w = 1;				
				end
				else if (counter_r == 12'd2047)
				begin				
					sink_eop_vl_w = 1;
					sink_eop_sdl_w = 1;
				end
			end
		end
		S_SD:
		begin
			if(i_write_en)
			begin
				sink_valid_vl_w = 0;
				sink_valid_sdl_w = 0;
				if (counter_r == 12'd2047)
				begin		
					counter_w = 0;	
					sink_eop_vl_w = 0;
					sink_eop_sdl_w = 0;
					if(vocal_exist_r)
					begin
						start_evaluate_w = 1;
						state_w = S_SCORING;
					end
					else 
					begin
						state_w = S_IDLE;
					end
				end		
				else
				begin
					counter_w = counter_r + 1;
					source_ready_vl_w = 0;				
					source_ready_sdl_w = 0;
					state_w = S_PAUSE;
					if(counter_r == 12'd0)
					begin
						sink_sop_vl_w = 0;
						sink_sop_sdl_w = 0;
					end
				end
			end
		end
		S_SCORING:
		begin
			start_evaluate_w = 0;
			if(counter_r == 255)
			begin
				state_w = S_IDLE;
				counter_w = 0;
				source_ready_vl_w = 0;				
				source_ready_sdl_w = 0;				
			end
			else
			begin
				counter_w = counter_r + 1;			
			end
		end
		S_PAUSE:
		begin
			if (i_addr == 3'b011)
				state_w = S_IDLE;			
			if (i_write_en)
			begin
				source_ready_vl_w = 1;
				source_ready_sdl_w = 1;
				voice_data_w = i_write_data[31:16] + i_write_data[15:0];
				state_w = S_VOICE;
			end
		end
	endcase
end

always_ff @(posedge i_clk or negedge i_reset_n)
begin
	if(!i_reset_n)
	begin
		voice_data_r <= 0;
		sd_data_r <= 0;
		sink_valid_vl_r <= 0; 
		sink_sop_vl_r <= 0;
		sink_eop_vl_r <= 0;
		source_ready_vl_r <= 0;
		sink_valid_sdl_r <= 0;
		sink_sop_sdl_r <= 0;
		sink_eop_sdl_r <= 0;
		source_ready_sdl_r <= 0;
		counter_r <= 0;
		state_r <= S_IDLE;
		start_evaluate_r <= 0;	
		vocal_exist_r <= 0;	
		read_data_r	<= 0;
	end
	else 
	begin
		voice_data_r <= voice_data_w;
		sd_data_r <= sd_data_w;
		sink_valid_vl_r <= sink_valid_vl_w; 
		sink_sop_vl_r <= sink_sop_vl_w;
		sink_eop_vl_r <= sink_eop_vl_w;
		source_ready_vl_r <= source_ready_vl_w;
		sink_valid_sdl_r <= sink_valid_sdl_w;
		sink_sop_sdl_r <= sink_sop_sdl_w;
		sink_eop_sdl_r <= sink_eop_sdl_w;
		source_ready_sdl_r <= source_ready_sdl_w;
		counter_r <= counter_w;
		state_r <= state_w;
		start_evaluate_r <= start_evaluate_w;
		vocal_exist_r <= vocal_exist_w;	
		read_data_r <= read_data_w;
	end
end
endmodule
