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
logic flag2_r; //when lrc=1, we want to stop, set this flag to 1. Therefore, when lrc=0, we can decide whether to stop by this flag.
logic flag2_w; //when lrc=1, we want to stop, set this flag to 1. Therefore, when lrc=0, we can decide whether to stop by this flag.
logic flag3_r;//used to delay address increment by 1 clk
logic flag3_w;//used to delay address increment by 1 clk
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
	flag2_w = flag2_r;
	flag3_w = flag3_r;
	//FSM
	case(state_r)
		S_IDLE:
		begin
			if(i_start)
			begin
				o_address_w = 0;
				o_data_w = 0;
				counter_w = 0;
				flag_w = 0;
				flag2_w = 0;
				flag3_w = 0;
				if(i_lrc)
				begin
					state_w = S_RECORD;
				end
				else
					state_w = S_NOT_RECORD;
			end
		end
		S_NOT_RECORD: //lrc=0, don't record the data.
		begin
			flag3_w = 0;
			if(i_stop || flag2_r)
				state_w = S_IDLE;
			else if(i_lrc && !flag_r)
			begin
				o_data_w = 0;
				counter_w = 4'd15;
				state_w = S_RECORD;
			end
		end
		S_RECORD: //lrc=1, record the data.
		begin
			if(i_stop)
				flag2_w = 1;

			o_data_w[counter_r] = i_data;
			counter_w = counter_r - 4'd1;
			if(counter_r == 0)
			begin
				state_w = S_RECORD_FINISHED;
			end
		end
		S_RECORD_FINISHED: //lrc=1, record has finished, outside can get correct data and address at this state.
		begin
			if(!flag3_r)
			begin
				o_address_w = o_address_r + 1;
				flag3_w = 1;
			end
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
		flag2_r <= 0;
		flag3_r <= 0;
	end
	else begin
		o_address_r <= o_address_w;
		o_data_r <= o_data_w;
		state_r <= state_w;
		counter_r <= counter_w;
		flag2_r <= flag2_w;
		flag3_r <= flag3_w;
	end
end

always_ff @(posedge i_lrc or negedge i_rst_n) begin
	if(!i_rst_n)
		flag_r <= 0;
	else
		flag_r <= flag_w;
end

endmodule
