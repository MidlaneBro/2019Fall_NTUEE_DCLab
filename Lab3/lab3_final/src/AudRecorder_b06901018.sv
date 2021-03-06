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
parameter S_RECORD_FINISHED = 2'b11;
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
logic flag_r; //when lrc changes from 0 to 1, pause value will be assigned to this reg
logic flag_w; //when lrc changes from 0 to 1, pause value will be assigned to this reg
logic stop_r, stop_w;
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
	flag_w = i_pause;
	stop_w = stop_r;
	//FSM
	case(state_r)
		S_IDLE:
		begin
			o_address_w = 20'b11111111111111111111;
			o_data_w = 0;
			counter_w = 0;
			if(i_start)
			begin
				if(i_lrc)
				begin
					state_w = S_RECORD;
					o_address_w = o_address_r + 1'b1;
				end
				else
					state_w = S_NOT_RECORD;
			end
		end
		S_NOT_RECORD: //lrc=0
		begin
			if(stop_r)
			begin
				state_w = S_IDLE;
				stop_w = 0;
			end
			else if(i_lrc && !flag_r)
			begin
				o_address_w = o_address_r + 1'b1;
				o_data_w = 0;
				counter_w = 4'd15;
				state_w = S_RECORD;
			end
		end
		S_RECORD: //lrc=1 and data input. At this moment, data and address are right.
		begin
			o_data_w[counter_r] = i_data;
			counter_w = counter_r - 4'd1;
			if(counter_r == 0)
				state_w = S_RECORD_FINISHED;
			
		end
		S_RECORD_FINISHED: //lrc=1 but data not input
		begin
			if(!i_lrc)
			begin
				state_w = S_NOT_RECORD;
			end
		end
	endcase
end
// ===== Sequential Circuit =====
always_ff @(posedge i_clk or negedge i_rst_n) begin
	if(!i_rst_n) begin 
		o_address_r <= 0;
		o_data_r <= 0;
		state_r <= 0;
		counter_r <= 0;
		stop_r <= 0;
	end
	else begin
		o_address_r <= o_address_w;
		o_data_r <= o_data_w;
		state_r <= state_w;
		counter_r <= counter_w;
		stop_r <= stop_w;
	end
end

always_ff @(posedge i_lrc or negedge i_rst_n  or posedge i_stop) begin
	if(!i_rst_n)
		flag_r <= 0;
	else if(i_stop) begin
		o_address_r <= o_address_w;
		o_data_r <= o_data_w;
		state_r <= state_w;
		counter_r <= counter_w;
		stop_r <= 1;
	end
	else 
		flag_r <= flag_w;
end

endmodule
