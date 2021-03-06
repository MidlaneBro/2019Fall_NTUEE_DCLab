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
	output [19:0] o_sram_addr,
	output [1:0] o_dsp_state
);

localparam S_IDLE = 0;
localparam S_PROC = 1;
localparam S_PAUSE= 2;

logic signed [19:0] prev_data_r, prev_data_w, this_data_r, this_data_w; //previous data point
logic [1:0] state_r, state_w;
logic signed [19:0] o_data_r, o_data_w;
logic [19:0] o_addr_r, o_addr_w;
logic [3:0] counter_r, counter_w;
logic ready_r, ready_w; // ready for interpolation, read next data or continue interpolating.
logic [19:0] pause_time_r, pause_time_w;
assign o_dac_data = o_data_r[15:0];
assign o_sram_addr = o_addr_r;
assign o_dsp_state = state_r;

always_comb begin
	prev_data_w = $signed(prev_data_r); 
	this_data_w = $signed(this_data_r);
	state_w = state_r;
	o_data_w = $signed(o_data_r);
	o_addr_w = o_addr_r;
	counter_w = counter_r;
	ready_w = ready_r;
	pause_time_w = pause_time_r;
	case (state_r)
		S_IDLE:
		begin
			if(i_start)
			begin
				o_addr_w = 0;
				o_data_w = 0;
				counter_w = 0;
				prev_data_w = 0;
				ready_w = 0;
				state_w = S_PROC;
			end
		end
		S_PROC:
		begin
			if(i_stop || o_addr_r == 20'hfffff) 
			begin
				o_addr_w = 0;
				o_data_w = 0;
				counter_w = 0;
				prev_data_w = 0;
				ready_w = 0;
				state_w = S_IDLE;
			end
			else if (i_pause)
			begin
				pause_time_w = 0;
				state_w = S_PAUSE;
			end
			else 
			begin 
				ready_w = 1;
				case(i_mode)
					2'b00:
					begin
						o_data_w = i_sram_data;
						o_addr_w = o_addr_r + 1;
					end
					2'b01:
					begin
						o_data_w = i_sram_data;
						o_addr_w = o_addr_r + i_speed;
					end
					2'b10:
					begin
						if (counter_r == 0)
						begin
							this_data_w = $signed(i_sram_data);
							o_data_w = $signed(i_sram_data);
							o_addr_w = o_addr_r + 1;
							counter_w = counter_r + 1; 
						end
						else 
						begin
							o_data_w = $signed(this_data_r);
							if (counter_r == i_speed - 1) // finish interpolation
								counter_w = 0;
							else
								counter_w = counter_r + 1;
						end
					end
					2'b11:
					begin
						if (!ready_r)
						begin
							this_data_w = $signed(i_sram_data);
							o_addr_w = o_addr_r + 1;
							counter_w = 0;
							ready_w = 1;
						end
						else
						begin
							if (counter_r == 0)
							begin
								this_data_w = $signed(i_sram_data);
								prev_data_w = $signed(this_data_r);
								o_data_w = $signed(this_data_r);
								o_addr_w = o_addr_r + 1;
								counter_w = counter_r + 1; 
							end
							else 
							begin
								o_data_w = $signed(prev_data_r) * (i_speed - counter_r) / i_speed + $signed(this_data_r) * (counter_r)/ i_speed;
								if (counter_r == i_speed - 1) // finish interpolation
									counter_w = 0;
								else
									counter_w = counter_r + 1;
							end
						end
					end
				endcase
			end
		end
		S_PAUSE:
		begin 
			if(i_stop)
				state_w = S_IDLE;
			// FPGA Version
			
			else if(!i_pause)
				state_w = S_PROC;

			// Testbench Version
			/*
			else if(i_pause)
				state_w = S_PROC;
			*/
			pause_time_w = pause_time_r + 1;
		end
	endcase
end 
always_ff @(negedge i_daclrck or negedge i_rst_n) begin
	if (!i_rst_n)
	begin 
		prev_data_r <= 0; 
		this_data_r <= 0;
		state_r <= S_IDLE;
		o_data_r <= 0;
		o_addr_r <= 0;
		counter_r <= 0;
		ready_r <= 0;
		pause_time_r <= 0;
	end
	else
	begin
		prev_data_r <= $signed(prev_data_w);
		this_data_r <= $signed(this_data_w);
		state_r <= state_w;
		o_data_r <= $signed(o_data_w);
		o_addr_r <= o_addr_w;
		counter_r <= counter_w;
		ready_r <= ready_w;
		pause_time_r <= pause_time_w;
	end
end

endmodule 