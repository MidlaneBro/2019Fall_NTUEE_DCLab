module AudDSP(
	input i_rst_n,
	input i_clk, // using bit clock as the main clock
	input i_start,
	input i_pause,
	input i_stop,
	input [3:0] i_speed,
	input [1:0] i_mode, //0: original, 1: fast, 2: slow_0, 3: slow_1
	input i_daclrck, // one cycle of daclrck process one data point. Slowest calculation takes 8 bclk cycles.
	input [15:0] i_sram_data,
	output [15:0] o_dac_data,
	output [19:0] o_sram_addr
);
// ===== States =====
parameter S_IDLE = 3'b000;
parameter S_MODE0 = 3'b001;
parameter S_MODE1 = 3'b010;
parameter S_MODE2 = 3'b011;
parameter S_MODE3 = 3'b100;
parameter S_FINISH = 3'b101;
// ===== Output Buffer =====
logic [15:0] o_data_r, o_data_w;
logic [19:0] o_addr_r, o_addr_w;
// ===== Register & Wire =====
logic [2:0] state_r,state_w;
// ===== Output Assignment =====
assign o_dac_data = o_data_r;
assign o_sram_addr = o_addr_r;
// ===== Combinational Circuit =====
always_comb begin
	//default
	o_data_w = o_data_r;
	o_addr_w = o_addr_r;
	state_w = state_r;
	//FSM
	case(state_r)
		S_IDLE:
		begin
			o_data_w = 0;
			o_addr_w = 0;
			if(i_start)
			begin
				if(i_mode == 0)
					state_w = S_MODE0;
				if(i_mode == 1)
					state_w = S_MODE1;
				if(i_mode == 2)
					state_w = S_MODE2;
				if(i_mode == 3)
					state_w = S_MODE3;
			end
		end
		S_MODE0:
			o_data_w = i_sram_data;
			state_w = S_FINISH;
		S_MODE1:
		S_MODE2:
		S_MODE3:
		S_FININSH:
			
	endcase
end 
// ===== Sequential Circuit =====
always_ff @(negedge i_daclrck or negedge i_rst_n) begin
	if (!i_rst_n)
	begin 
		o_data_r <= 0;
		o_addr_r <= 0;
		state_r <= 0;
	end
	else
	begin
		o_data_r <= o_data_w;
		o_addr_r <= o_addr_w;
		state_r <= state_w;
	end
end

endmodule 