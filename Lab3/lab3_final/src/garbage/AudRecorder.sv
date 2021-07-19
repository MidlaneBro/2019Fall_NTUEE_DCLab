module AudRecorder (
	input i_rst_n,
	input i_clk,
	input i_lrc,
	input i_start,
	input i_pause,
	input i_stop,
	input i_data,
	output [19:0] o_address,
	output [15:0] o_data
);

// ===== States =====
parameter S_IDLE = 2'b00;
parameter S_NOT_RECORD = 2'b01;
parameter S_RECORD = 2'b10;
parameter S_PAUSE = 2'b11;
// ===== Output Buffer =====
logic [19:0] o_address_r;
logic [19:0] o_address_w;
logic [15:0] o_data_r;
logic [15:0] o_data_w;
// ===== Register & Wire =====
logic [1:0] state_r;
logic [1:0] state_w;
logic [3:0] counter_r;
logic [3:0] counter_w;
// ===== Output Assignment =====
assign o_address = o_address_r;
assign o_data = o_data_r;
// ===== Combinational Circuit =====
always_comb begin
	//default value
	o_address_w = o_address_r;
	o_data_w = o_data_r;
	state_w = state_r;
	counter_w = counter_r;
	//FSM
	case(state_r)
		S_IDLE:
		begin
			if(i_start)
			begin
				o_address_w = 0;
				o_data_w = 0;
				counter_w = 0;
				state_w = S_NOT_RECORD;
			end
		end
		S_NOT_RECORD:
		begin
			if(i_stop)
				state_w = S_IDLE;
			else if(i_lrc)
			begin
				o_data_w = 0;
				counter_w = 4'd15;
				state_w = S_RECORD;
			end
		end
		S_RECORD:
		begin
			if(i_stop)
				state_w = S_IDLE;
			else if(i_pause)
				state_w = S_PAUSE;
			else if(counter_r==0)
			begin
				state_w = S_NOT_RECORD;
				o_address_w = o_address_r+1'b1;
			end
			o_data_w[counter_r] = i_data;
			counter_w = counter_r - 4'd1;
		end
		S_PAUSE:
		begin
			if(i_stop)
				state_w = S_IDLE;
			if(i_pause)
				state_w = S_NOT_RECORD;
		end
	endcase
end
// ===== Sequential Circuit =====
always_ff @(negedge i_clk or negedge i_rst_n) begin
	if(!i_rst_n) begin 
		o_address_r <= 0;
		o_data_r <= 0;
		state_r <= 0;
		counter_r <= 0;
	end
	else begin
		o_address_r <= o_address_w;
		o_data_r <= o_data_w;
		state_r <= state_w;
		counter_r <= counter_w;
	end
end

endmodule
