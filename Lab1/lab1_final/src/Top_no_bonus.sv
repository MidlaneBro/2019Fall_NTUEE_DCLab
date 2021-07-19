module Top (
	input        i_clk,
	input        i_rst_n,
	input        i_start,
	output [3:0] o_random_out
);

// ===== States =====
parameter S_IDLE = 1'b0;
parameter S_RUN  = 1'b1;

// ===== Output Buffer =====
logic [3:0] o_random_out_r;
logic [3:0] o_random_out_w;

// ===== Register & Wires =====
logic state_r;
logic state_w;
logic [16:0] rands_r;
logic [16:0] rands_w;
logic [16:0] rands_tmp_r;
logic [16:0] rands_tmp_w;
logic rands_w5;
logic rands_w3;
logic rands_w2;
logic rands_w0;
logic rands_w20;
logic rands_w320;
logic rands_w5320;
logic [31:0]counter_r;
logic [31:0]counter_w;
logic [31:0]trigger_r;
logic [31:0]trigger_w;
   
// ===== Output Assignments =====
assign o_random_out = o_random_out_r;

// ===== Combinational Circuit =====
always_comb begin
    // Default Values
	rands_w5       = rands_r[5];
	rands_w3       = rands_r[3];
	rands_w2       = rands_r[2];
	rands_w0       = rands_r[0];
	rands_w20      = rands_r[2] ^ rands_r[0];
	rands_w320     = rands_r[3] ^ rands_w20;
	rands_w5320    = rands_w5 ^ rands_w320;
	rands_w        = rands_tmp_r;
	counter_w      = counter_r;
	trigger_w      = trigger_r;
	o_random_out_w = o_random_out_r;
	rands_tmp_w    = rands_tmp_r;
    // FSM
	case(state_r)
		S_IDLE:
		begin
    		if (i_start)
			begin
				counter_w = 32'd0;
				trigger_w = 32'd5000000;
        			state_w = S_RUN;
			end
			else
			begin
				o_random_out_w = o_random_out_r;
				state_w = state_r;
				rands_tmp_w = rands_tmp_r;
			end
		end

		S_RUN:
		begin
			if(trigger_r == 32'd40000000)
			begin
				state_w = S_IDLE; 
			end
			else if(counter_r == trigger_r)
			begin
				counter_w = 32'd0;
				trigger_w = trigger_r + 32'd2500000;
				rands_tmp_w[15:0] = rands_r[16:1];
				rands_tmp_w[16]   = rands_w5320;
				state_w = state_r;
			end
			else
			begin
				o_random_out_w = rands_r[3:0];
				counter_w = counter_r + 32'd1;
				state_w = state_r;
			end
		end
	endcase
end

// ===== Sequential Circuits =====
always_ff @(posedge i_clk or negedge i_rst_n) begin
	// reset
	if (!i_rst_n)
	begin
		o_random_out_r <= 4'd0;
		state_r        <= S_IDLE;
		counter_r      <= 32'd0;
		trigger_r      <= 32'd0;
		rands_tmp_r    <= 17'b11010110011100001;
		
	end
	else
	begin
		trigger_r      <= trigger_w;
		o_random_out_r <= o_random_out_w;
		state_r        <= state_w;
		counter_r      <= counter_w;
		rands_r        <= rands_w;
		rands_tmp_r    <= rands_tmp_w;
	end
end

endmodule
