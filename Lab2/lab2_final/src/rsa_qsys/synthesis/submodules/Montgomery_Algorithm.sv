module Montgomery_Algorithm(
	input i_clk,
	input i_rst,
	input i_start,
	input [255:0] N,
	input [255:0] a,
	input [255:0] b,
	output [255:0] m,
	output o_finished
);

// ===== States =====
parameter S_IDLE = 2'b00;
parameter S_RUN1 = 2'b01;
parameter S_RUN2 = 2'b10;

// ===== Output Buffer =====
logic [257:0] m_r;
logic [257:0] m_w;
logic o_finished_r;
logic o_finished_w;

// ===== Register & wire =====
logic [1:0] state_r;
logic [1:0] state_w;
logic [8:0] counter_r;
logic [8:0] counter_w;

// ===== Output Assignment =====
assign m = m_r[255:0];
assign o_finished = o_finished_r;

// ===== Combinational Circuit =====
always_comb begin
	//default value
	m_w = m_r;
	o_finished_w = o_finished_r;
	state_w = state_r;
	counter_w = counter_r;
	//FSM
	case(state_r)
		S_IDLE:
		begin
			o_finished_w = 0;
			if(i_start)
			begin
				m_w = 0;
				state_w = S_RUN1;
				counter_w = 0;
			end
		end
		S_RUN1:
			if(counter_r <= 9'd255)
			begin
				counter_w = counter_r + 9'd1;
				if(a[counter_r] == 1'b1)
				begin
					if((m_r[0] + b[0])==1'b1)
					begin
						m_w = (m_r + b + N) >> 1;
					end
					else
					begin
						m_w = (m_r + b) >> 1;
					end
				end
				else
				begin
					if(m_r[0]==1'b1)
					begin
						m_w = (m_r + N) >> 1;
					end
					else
					begin
						m_w = m_r >> 1;
					end
				end
			end
			else
				state_w = S_RUN2;

		S_RUN2:
		begin
			if(m_r >= N)
				m_w = m_r - N;
			state_w = S_IDLE;
			o_finished_w = 1'b1;
		end
	endcase
end

// ===== Sequential Circuit =====
always_ff @(posedge i_clk or negedge i_rst) begin
	if(!i_rst)
	begin
		m_r <= 0;
		o_finished_r <= 0;
		state_r <= 0;
		counter_r <= 0;
	end
	else
	begin
		m_r <= m_w;
		o_finished_r <= o_finished_w;
		state_r <= state_w;
		counter_r <= counter_w;
	end
end

endmodule
