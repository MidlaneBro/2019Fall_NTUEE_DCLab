module ModuloProduct(
	input i_clk,
	input i_rst,
	input i_start,
	input [255:0] N,
	input [256:0] a,
	input [255:0] b,
	input [8:0] k,
	output[255:0] m,
	output o_finished
);

// ===== States =====
parameter S_IDLE = 1'b0;
parameter S_RUN = 1'b1;

// ===== Output Buffer =====
logic [257:0] m_r;
logic [257:0] m_w;
logic o_finished_r;
logic o_finished_w;

// ===== Register & wire =====
logic state_r;
logic state_w;
logic [257:0] t_r;
logic [257:0] t_w;
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
	t_w = t_r;
	counter_w = counter_r;
	//FSM
	case(state_r)
		S_IDLE:
		begin
			o_finished_w = 0;
			if(i_start)
			begin
				m_w = 0;
				state_w = S_RUN;
				t_w = b;
				counter_w = 0;
			end
		end
		S_RUN:
		begin
			if(counter_r <= k)
			begin
				if(a[counter_r] == 1'd1)
				begin
					if(m_r + t_r >= N)
						m_w = m_r + t_r - N;
					else
						m_w = m_r+ t_r;
				end
				if(t_r + t_r > N)
					t_w = t_r + t_r - N;
				else
					t_w = t_r + t_r;
				counter_w = counter_r + 9'd1;
			end
			else
			begin
				state_w =S_IDLE;
				o_finished_w = 1'b1;
			end
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
		t_r <= 0;
		counter_r <= 0;
	end
	else
	begin
		m_r <= m_w;
		o_finished_r <= o_finished_w;
		state_r <= state_w;
		t_r <= t_w;
		counter_r <= counter_w;
	end
end

endmodule
