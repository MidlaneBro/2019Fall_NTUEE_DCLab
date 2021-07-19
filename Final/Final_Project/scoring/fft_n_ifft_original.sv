// the top module for the fft and scoring system
`timescale 1 ps / 1 ps
module fft_n_ifft (
	input i_clk,       //   dac_clock one data for a cycle
	input i_reset_n,  // reset
	input i_start_fft,  // when this signal comes, sink_valid, sink_sop & sink_ready should all = 1.
	input i_finished, //audio finished
	input [15:0] i_voice_data_left,  // split to left & right
	input [15:0] i_voice_data_right,
	input [15:0] i_sd_data_left,
	input [15:0] i_sd_data_right,
	output[11:0] score,
	output[9:0] percent, // between 0 to 1000, represents 0%, 0.1%, 0.2%, etc.
	output scoring_finished  // scoring is complete
);

wire[15:0] i_voice_data;
wire[15:0] i_sd_data;

reg inverse_r, inverse_w;
reg sink_valid_r, sink_valid_w; //When the final sample loads, the source asserts sink_eop and sink_valid for the last data transfer.
reg sink_sop_r, sink_sop_w;
reg sink_eop_r, sink_eop_w;
reg[1:0] sink_error_r, sink_error_w;
reg source_ready_r, source_ready_w;
reg sink_ready_vl, sink_ready_sdl;
reg source_valid_vl, source_valid_sdl;
reg source_sop_vl, source_sop_sdl;
reg source_eop_vl, source_eop_sdl;
reg[1:0] source_error_vl, source_error_sdl;
reg[10:0] counter_r, counter_w;
reg state_r, state_w;

// fft to evaluate
reg start_evaluate_r, start_evaluate_w;
wire[15:0] voice_freq_imag;
wire[15:0] voice_freq_real;
wire[15:0] sd_freq_imag;
wire[15:0] sd_freq_real;
// evaluate to scoring
wire start_scoring;
wire correctness;

localparam S_IDLE = 0;
localparam S_PROC = 1;

assign i_voice_data = i_voice_data_left + i_voice_data_right;
assign i_sd_data = i_sd_data_left + i_sd_data_right;
assign o_start_evaluate = start_evaluate_r;

evaluate evaluate_0(
    .i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_start(start_evaluate_r),  // correspond to  
    .i_voice_freq_imag(voice_freq_imag),
	.i_voice_freq_real(voice_freq_real),
	.i_sd_freq_imag(sd_freq_imag),
	.i_sd_freq_real(sd_freq_real),
    .o_start_scoring(start_scoring),
    .o_result(correctness)
);

scoring scoring_0(
	.i_clk(i_clk),
    .i_rst_n(i_rst_n),
    .i_receiving(start_scoring),
    .i_correct(correctness),
	.i_aud_end(i_finished),
	.o_score(score),
	.o_percent(percent), // between 0 to 1000, represents 0%, 0.1%, 0.2%, etc.
	.o_finished(fft_finished)
); 

fft_n_ifft_fft_ii_0 fft_voice(
	.clk(i_clk), 
	.reset_n(i_reset_n),
	.inverse(inverse_r),
	// sink part (inputs except sink_ready)
	.sink_ready(sink_ready_vl),
	.fftpts_in(2048),
	.sink_valid(sink_valid_r),
	.sink_sop(sink_sop_r),
	.sink_eop(sink_eop_r),
	.sink_real(i_voice_data),  // only this port is fed with input
	.sink_imag(0), //fed-in signal nust be REAL!
	.sink_error(sink_error_r),
	// source part (outputs except source_ready)
	.source_ready(source_ready_r),
	.fftpts_out(2048),
	.source_valid(source_valid_vl),
	.source_sop(source_sop_vl),
	.source_eop(source_eop_vl),
	.source_real(voice_freq_imag),  // the 2 outputs
	.source_imag(voice_freq_real),
	.source_error(source_error_vl)
);

fft_n_ifft_fft_ii_0 fft_sd(
	.clk(i_clk),
	.reset_n(i_reset_n),
	.inverse(inverse_r),
	// sink part (inputs except sink_ready)	
	.sink_ready(sink_ready_r),
	.fftpts_in(2048),
	.sink_valid(sink_valid_sdl),
	.sink_sop(sink_sop_r),
	.sink_eop(sink_eop_r),
	.sink_real(i_sd_data),  // only this port is fed with input
	.sink_imag(0),
	.sink_error(sink_error_r),
	// source part (outputs except source_ready)	
	.source_ready(source_ready_r),
	.fftpts_out(2048),
	.source_error(source_error_sdl),
	.source_sop(source_sop_sdl),
	.source_eop(source_eop_sdl),
	.source_valid(source_valid_sdl),
	.source_real(sd_freq_imag),  // the 2 outputs
	.source_imag(sd_freq_real)
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

always_comb begin
	inverse_w = 0;
	sink_valid_w = sink_valid_r; //When the final sample loads, the source asserts sink_eop and sink_valid for the last data transfer.
	sink_sop_w = sink_sop_r;
	sink_eop_w = sink_eop_r;
	sink_error_w = 0;
	source_ready_w = source_ready_r;
	start_evaluate_w = start_evaluate_r;
	counter_w = counter_r;
	state_w = state_r;
	case(state_r)
		S_IDLE:
		begin
			if(i_start_fft)
			begin
				sink_valid_w = 1;
				sink_sop_w = 1;
				sink_eop_w = 0;
				source_ready_w = 1;
				start_evaluate_w = 0;
				state_w = S_PROC;
			end
			else 
			begin
				sink_valid_w = 0;
				sink_sop_w = 0;
				sink_eop_w = 0;
				source_ready_w = 0;	
				start_evaluate_w = 0;				
			end
		end
		S_PROC:
		begin
			if(i_finished)
			begin
				counter_w = 0;
				sink_valid_w = 0;
				sink_eop_w = 1;
				sink_sop_w = 0;
				source_ready_w = 0;
				start_evaluate_w = 0;
				state_w = S_IDLE;
			end
			else
			begin
				if(counter_r == 12'd2047)
				begin
					counter_w = 0;
					sink_valid_w = 1; 
					sink_sop_w = 0;
					sink_eop_w = 1;
					source_ready_w = 1;
					start_evaluate_w = 1;  //only last 1 cycle
				end
				else if (counter_r == 12'd0)
				begin
					counter_w = counter_r + 1;
					sink_valid_w = 1; 
					sink_sop_w = 1;
					sink_eop_w = 0;
					source_ready_w = 1;
					start_evaluate_w = 0;
				end
				else
				begin
					counter_w = counter_r + 1;
					sink_valid_w = 1; 
					sink_sop_w = 0;
					sink_eop_w = 0;
					source_ready_w = 1;
				end
			end
		end
	endcase
end

always_ff @(posedge i_clk or negedge i_reset_n)
begin
	if(!i_reset_n)
	begin
		inverse_r <= 0;
		sink_valid_r <= 0; 
		sink_sop_r <= 0;
		sink_eop_r <= 0;
		sink_error_r <= 0;
		source_ready_r <= 0;
		start_evaluate_r <= 0;
		counter_r <= 0;
		state_r <= S_IDLE;		
	end
	else 
	begin
		inverse_r <= inverse_w;
		sink_valid_r <= sink_valid_w; 
		sink_sop_r <= sink_sop_w;
		sink_eop_r <= sink_eop_w;
		sink_error_r <= sink_error_w;
		source_ready_r <= source_ready_w;
		start_evaluate_r <= start_evaluate_w;
		counter_r <= counter_w;
		state_r <= state_w;		
	end
end
endmodule
