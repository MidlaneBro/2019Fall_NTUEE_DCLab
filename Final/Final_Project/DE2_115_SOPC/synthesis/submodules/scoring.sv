//this module will evaluate whether the signal_test is compatible to signal_base or not
//signal_base and signal_test are both on the spectral domain
//x-axis range:0Hz ~ 4000Hz(0~511), the frequency resolution is 16hz.
//y-axis range:-32768 ~ 32767
//the signal will be sent into this module one by one for 256 iterations
//this module will record that on which iteration(which freqency), the signal has maximum value.
//judgement standard:
//only when the maximal freqency of signal_test is 1/2,1,2 times of the maximal frequency of signal_base, the result is true.

module evaluate(
    input i_clk,
    input i_rst_n,
    input i_start,  // correspond to  
    input [15:0] i_voice_freq_imag,
	input [15:0] i_voice_freq_real,
	input [15:0] i_sd_freq_imag,
	input [15:0] i_sd_freq_real,
    output o_start_scoring,
    output o_result
);

// ===== States =====
parameter S_IDLE = 2'b00;
parameter S_EVALUATE = 2'b01;
parameter S_COMPARE = 2'b11;
// ===== Output Buffer =====
reg start_scoring;
reg result;
// ===== Register & Wire =====
reg [1:0] state;
reg [32:0] signal_base;
reg [32:0] signal_test;
reg [32:0] max_value_base;
reg [32:0] max_value_test;
reg [10:0] max_frequency_base;
reg [10:0] max_frequency_test;
reg [10:0] counter;
// ===== Output Assignment =====
assign o_start_scoring = start_scoring;
assign o_result = result;
// ===== Combinational Circuit =====
always@(*) begin
	signal_test = i_voice_freq_imag * i_voice_freq_imag + i_voice_freq_real * i_voice_freq_real;
	signal_base = i_sd_freq_imag * i_sd_freq_imag + i_sd_freq_real * i_sd_freq_real;
end
// ===== Sequential Circuit =====
always@(posedge i_clk or negedge i_rst_n) begin
    if(!i_rst_n) begin 
		start_scoring <= 0;
        result <= 0;
        state <= 0;
        max_value_base <= 0;
        max_value_test <= 0;
        max_frequency_base <= 0;
        max_frequency_test <= 0;
        counter <= 0;
	end
	else begin
		case(state)
        S_IDLE:
        begin
            start_scoring <= 0;
            if(i_start)
            begin
                start_scoring <= 0;
                result <= 0;
                state <= S_EVALUATE;
                max_value_base <= 0;
                max_value_test <= 0;
                max_frequency_base <= 0;
                max_frequency_test <= 0;
                counter <= 0;
            end
        end
        S_EVALUATE:
        begin
            if(counter == 255)
            begin
                state <= S_COMPARE;
            end
            else
                counter <= counter + 1;
            if(signal_base > max_value_base)
            begin
                max_value_base <= signal_base;
                max_frequency_base <= counter;
            end
            if(signal_test > max_value_test)
            begin
                max_value_test <= signal_test;
                max_frequency_test <= counter;
            end
        end
        S_COMPARE:
        begin
            if(((max_frequency_test <= max_frequency_base + max_frequency_base[9:5]) && (max_frequency_test >= max_frequency_base - max_frequency_base[9:5]))
			||((max_frequency_test <= max_frequency_base * 2 + max_frequency_base[9:5] * 2) && (max_frequency_test >= max_frequency_base * 2- max_frequency_base[9:5] * 2))
			||((max_frequency_test <= max_frequency_base * 4 + max_frequency_base[9:5] * 4) && (max_frequency_test >= max_frequency_base * 4- max_frequency_base[9:5] * 4))
			||((max_frequency_test * 2 <= max_frequency_base + max_frequency_base[9:5]) && (max_frequency_test * 2 >= max_frequency_base - max_frequency_base[9:5]))
			||((max_frequency_test * 4 <= max_frequency_base + max_frequency_base[9:5]) && (max_frequency_test * 4 >= max_frequency_base - max_frequency_base[9:5])))
                result <= 1;
			else
				result <= 0;
            state <= S_IDLE;
            start_scoring <= 1;
        end
        endcase
	end
end
endmodule

module scoring(
	input i_clk,
    input i_rst_n,
    input i_receiving,
    input i_correct,
	input[2:0] i_control,
	output[15:0] o_score, 
	output[9:0] o_percent, // between 0 to 1000, represents 0%, 0.1%, 0.2%, etc.
	output o_finished
); 
reg[15:0] score_r, score_w;
reg[15:0] data_num_r, data_num_w;
reg finished_r, finished_w;
reg[9:0] percent_r, percent_w;
wire[25:0] score_ext, data_num_ext;

assign o_score = score_r;
assign o_percent = percent_r;
assign o_finished = finished_r;
assign score_ext = score_r * 1000;
assign data_num_ext = {10'b0, data_num_r};
always_comb begin
	data_num_w = data_num_r;
	score_w = score_r;
	finished_w = finished_r; 
	percent_w = score_ext / data_num_ext;
	if (i_receiving)
	begin
		finished_w = 0;
		data_num_w = data_num_r + 1;
		if (i_correct)
		begin
			score_w = score_r + 1;
		end		
	end
	else if(i_control == 3'b011)
	begin
		finished_w = 1;
		score_w = 0;		
	end
end

always@(posedge i_clk or negedge i_rst_n) begin
	 if(!i_rst_n) 
	 begin 
		data_num_r <= 0;
		score_r <= 0;
		finished_r <= 0; 
		percent_r <= 0;
	end
	else
	begin
		data_num_r <= data_num_w;
		score_r <= score_w;
		finished_r <= finished_w; 
		percent_r <= percent_w;
	end
end 
endmodule
/*
module DSP(
	input i_reset_n,
	input i_clk, // using bit clock as the main clock
	input i_start,
	input i_finished,
	input [15:0] i_data_left,
	input [15:0] i_data_right,
	output [15:0] o_data_left,
	output [15:0] o_data_right,
	output [19:0] o_sram_addr,
	output dsp_finished
);
reg[15:0] orig_data_l_r[0:4], orig_data_l_w[0:4];
reg[15:0] orig_data_r_r[0:4], orig_data_r_w[0:4];
reg[2:0] data_counter_r, data_counter_w;
reg[19:0] o_addr_r, o_addr_w;
reg[15:0] o_data_r, o_data_w;

always@(*) begin
	if(data_counter_r == 3'd4)
		data_counter_w = 0;
	else
		data_counter_w = data_counter_r + 1;
	case(data_counter_r)
	3'd0: 
	begin
		orig_data_l_w = i_data_left;
	end
	3'd1: 
	begin
		
	end
	3'd2: 
	begin
		
	end
	3'd3: 
	begin
		
	end
	3'd4: 
	begin
		
	end
	endcase
	if()
	begin
		this_data_w = $signed(i_sram_data);
		prev_data_w = $signed(this_data_r);
		o_data_w = $signed(this_data_r);
		o_addr_w = o_addr_r + 1;
		data_counter_w = data_counter_r + 1; 
	end
	else 
	begin
		o_data_w = $signed(prev_data_r) * (i_speed - data_counter_r) / i_speed + $signed(this_data_r) * (data_counter_r)/ i_speed;
		if (data_counter_r == i_speed - 1) // finish interpolation
			data_counter_w = 0;
		else
			data_counter_w = data_counter_r + 1;
	end
end

always @(posedge i_clk or negedge i_reset_n)
begin
	if(!i_reset_n)
	begin
		
	end
	else 
	begin
	
	end
end
endmodule
*/