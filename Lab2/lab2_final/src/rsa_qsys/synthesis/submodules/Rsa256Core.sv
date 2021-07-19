//`include "ModuloProduct.sv"
//`include "Montgomery_Algorithm.sv"

module Rsa256Core (
	input          i_clk,
	input          i_rst,
	input          i_start, 
	input  [255:0] i_a, // cipher text y
	input  [255:0] i_d,
	input  [255:0] i_n,
	output [255:0] o_a_pow_d, // plain text x
	output         o_finished
);

// operations for RSA256 decryption
// namely, the Montgomery algorithm

// ===== States =====
parameter S_IDLE = 3'b000;
parameter S_PREP_1 = 3'b001;
parameter S_PREP_2 = 3'b010;
parameter S_MONT_1 = 3'b011;
parameter S_MONT_2 = 3'b100;
parameter S_CALC = 3'b101;

// ===== Input Buffer =====
logic [255:0] encryptdata_r;
logic [255:0] encryptdata_w;

// ===== Output Buffer =====
logic [255:0] o_a_pow_d_r;
logic [255:0] o_a_pow_d_w;
logic o_finished_r;
logic o_finished_w;

// ===== Register & Wire =====
logic [2:0] state_r;
logic [2:0] state_w;
logic [255:0] t_r;
logic [255:0] t_w;
logic [255:0] m_r;
logic [255:0] m_w;
logic [8:0] counter_r;
logic [8:0] counter_w;
logic RsaPrep_start_r;
logic RsaPrep_start_w;
logic RsaMont_t_start_r;
logic RsaMont_t_start_w;
logic RsaMont_m_start_r;
logic RsaMont_m_start_w;
logic [255:0] RsaMont_t_input_a_r;
logic [255:0] RsaMont_t_input_a_w;
logic [255:0] RsaMont_t_input_b_r;
logic [255:0] RsaMont_t_input_b_w;
logic [255:0] RsaMont_m_input_a_r;
logic [255:0] RsaMont_m_input_a_w;
logic [255:0] RsaMont_m_input_b_r;
logic [255:0] RsaMont_m_input_b_w;
logic [255:0] RsaPrep_output;
logic [255:0] RsaMont_t_output;
logic [255:0] RsaMont_m_output;
logic RsaPrep_finished;
logic RsaMont_t_finished;
logic RsaMont_m_finished;
logic t_finished_r;
logic t_finished_w;
logic m_finished_r;
logic m_finished_w;

// ===== Output Assignment =====
assign o_a_pow_d = o_a_pow_d_r;
assign o_finished = o_finished_r;

// ===== Submodule =====
ModuloProduct RsaPrep(
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_start(RsaPrep_start_r),
	.N(i_n),
	.a((257'b1<<256)),
	.b(encryptdata_r),
	.k(9'd256),
	.m(RsaPrep_output),
	.o_finished(RsaPrep_finished)
);

Montgomery_Algorithm RsaMont_t(
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_start(RsaMont_t_start_r),
	.N(i_n),
	.a(RsaMont_t_input_a_r),
	.b(RsaMont_t_input_b_r),
	.m(RsaMont_t_output),
	.o_finished(RsaMont_t_finished)
);

Montgomery_Algorithm RsaMont_m(
	.i_clk(i_clk),
	.i_rst(i_rst),
	.i_start(RsaMont_m_start_r),
	.N(i_n),
	.a(RsaMont_m_input_a_r),
	.b(RsaMont_m_input_b_r),
	.m(RsaMont_m_output),
	.o_finished(RsaMont_m_finished)
);

// ===== Combinational Circuit =====
always_comb begin
	//default value
	o_a_pow_d_w = o_a_pow_d_r;
	o_finished_w = o_finished_r;
	state_w = state_r;
	t_w = t_r;
	m_w = m_r;
	counter_w = counter_r;
	RsaPrep_start_w = RsaPrep_start_r;
	RsaMont_t_start_w = RsaMont_t_start_r;
	RsaMont_m_start_w = RsaMont_m_start_r;
	RsaMont_t_input_a_w = RsaMont_t_input_a_r;
	RsaMont_t_input_b_w = RsaMont_t_input_b_r;
	RsaMont_m_input_a_w = RsaMont_m_input_a_r;
	RsaMont_m_input_b_w = RsaMont_m_input_b_r;
	encryptdata_w = encryptdata_r;
	t_finished_w = t_finished_r;
	m_finished_w = m_finished_r;
	//FSM
	case(state_r)
		S_IDLE://0
		begin
			o_finished_w = 0;
			if(i_start)
			begin
				o_a_pow_d_w = 0;
				state_w = S_PREP_1;
				t_w = 0;
				m_w = 0;
				counter_w = 0;
				RsaPrep_start_w = 0;
				RsaMont_t_start_w = 0;
				RsaMont_m_start_w = 0;
				RsaMont_t_input_a_w = 0;
				RsaMont_t_input_b_w = 0;
				RsaMont_m_input_a_w = 0;
				RsaMont_m_input_b_w = 0;
				encryptdata_w = i_a;
				t_finished_w = 0;
				m_finished_w = 0;
			end
		end
		S_PREP_1://1
		begin
			RsaPrep_start_w = 1;
			state_w = S_PREP_2;
		end
		S_PREP_2://2
		begin
			RsaPrep_start_w = 0;
			if(RsaPrep_finished)
			begin
				t_w = RsaPrep_output;
				m_w = 256'd1;
				state_w = S_MONT_1;
			end
		end
		S_MONT_1://3
		begin
			if(i_d[counter_r] == 1'd1)
			begin
				RsaMont_m_start_w = 1;
				RsaMont_m_input_a_w = m_r;
				RsaMont_m_input_b_w = t_r;
			end
			RsaMont_t_start_w = 1;
			RsaMont_t_input_a_w = t_r;
			RsaMont_t_input_b_w = t_r;
			state_w = S_MONT_2;
		end
		S_MONT_2://4
		begin
			//m part
			if(i_d[counter_r] == 1'd1)
			begin
				RsaMont_m_start_w = 0;
				if(RsaMont_m_finished)
				begin
					m_w = RsaMont_m_output;
					m_finished_w = 1;
				end
			end
			
			//t part
			RsaMont_t_start_w = 0;
			if(RsaMont_t_finished)
			begin
				t_w = RsaMont_t_output;
				t_finished_w = 1;
			end

			//state part
			if( ( (i_d[counter_r] == 0) && (t_finished_r) ) || ( (i_d[counter_r]==1) && (m_finished_r) && (t_finished_r) ) )
			begin
				state_w = S_CALC;
				t_finished_w = 0;
				m_finished_w = 0;
			end
		end
		S_CALC://5
		begin
			if(counter_r < 9'd255)
			begin
				state_w = S_MONT_1;
				counter_w = counter_r + 9'd1;
			end
			else
			begin
				o_a_pow_d_w = m_r;
				o_finished_w = 1;
				state_w = S_IDLE;
			end
		end
	endcase
end
// ===== Sequential Circuit =====
always_ff @(posedge i_clk or negedge i_rst) begin	
	if(!i_rst)
	begin
		o_a_pow_d_r <= 0;
		o_finished_r <= 0;
		state_r <= 0;
		t_r <= 0;
		m_r <= 0;
		counter_r <= 0;
		RsaPrep_start_r <= 0;
		RsaMont_t_start_r <= 0;
		RsaMont_m_start_r <= 0;
		RsaMont_t_input_a_r <= 0;
		RsaMont_t_input_b_r <= 0;
		RsaMont_m_input_a_r <= 0;
		RsaMont_m_input_b_r <= 0;
		encryptdata_r <= 0;
		t_finished_r <= 0;
		m_finished_r <= 0;
	end
	else
	begin
		o_a_pow_d_r <= o_a_pow_d_w;
		o_finished_r <= o_finished_w;
		state_r <= state_w;
		t_r <= t_w;
		m_r <= m_w;
		counter_r <= counter_w;
		RsaPrep_start_r <= RsaPrep_start_w;
		RsaMont_t_start_r <= RsaMont_t_start_w;
		RsaMont_m_start_r <= RsaMont_m_start_w;
		RsaMont_t_input_a_r <= RsaMont_t_input_a_w;
		RsaMont_t_input_b_r <= RsaMont_t_input_b_w;
		RsaMont_m_input_a_r <= RsaMont_m_input_a_w;
		RsaMont_m_input_b_r <= RsaMont_m_input_b_w;
		encryptdata_r <= encryptdata_w;
		t_finished_r <= t_finished_w;
		m_finished_r <= m_finished_w;
	end
end

endmodule
