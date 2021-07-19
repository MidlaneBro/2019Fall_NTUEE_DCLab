// Record only Right Channel
module AudRecorder (
	input 	i_rst_n,
	input 	i_clk,
	input 	i_lrc,
	input 	i_start,
	input 	i_pause,
	input 	i_stop,
	input	i_data,
	output [19:0] o_address,
	output [15:0] o_data
);

enum{
	IDLE,
	RIGHT,
	REC,
	WAIT,
	PAUSE,
	STOP,
	DONE
} state_w, state_r;

logic [19:0] addr_r, addr_w;
logic [15:0] data_r, data_w;
logic [5:0] bit_counter_r, bit_counter_w;
logic lrc_r, lrc_w;

assign lrc_w = i_lrc;
assign o_address	= addr_r;
assign o_data	= data_r;

always_comb begin
	state_w	= state_r;
	addr_w	= addr_r;
	data_w	= data_r;
	bit_counter_w	= bit_counter_r;

	case(state_r)
		IDLE: begin
			if (i_start) begin
				state_w	= RIGHT;
				addr_w	= 0;
			end
		end
		RIGHT: begin
			if ((!lrc_r) && i_lrc) begin
				state_w	= REC;
			end
		end
		REC: begin
			if (i_pause)
				state_w	= PAUSE;
			else if (i_stop)
				state_w = STOP;
			else begin
				data_w[15 - bit_counter_r]	= i_data;
				if (bit_counter_r == 15) begin
					state_w	= WAIT;
					bit_counter_w	= 0;
				end
				else begin
					bit_counter_w	= bit_counter_r + 1;
				end
			end
		end
		WAIT: begin
			if (addr_r == 20'HFFFFF) begin
				state_w	= DONE;
				addr_w	= 0;
			end
			else begin
				state_w	= RIGHT;
				addr_w	= addr_r + 1;
			end
			//data_w	= 0;
		end
		PAUSE: begin
			state_w	= IDLE;
			bit_counter_w 	= 0;
		end
		STOP: begin
			state_w	= IDLE;
			bit_counter_w	= 0;
		end
		DONE: begin
			state_w	= IDLE;
		end
	endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (~i_rst_n) begin
		addr_r	<= 0;
		data_r	<= 0;
		state_r	<= IDLE;
		lrc_r	<= 0;
		bit_counter_r	<= 0;
	end
	else begin
		state_r	<= state_w;
		addr_r	<= addr_w;
		data_r	<= data_w;
		lrc_r	<= lrc_w;
		bit_counter_r	<= bit_counter_w;
	end
end

endmodule
