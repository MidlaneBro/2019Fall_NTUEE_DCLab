module Rsa256Wrapper (
    input         avm_rst,
    input         avm_clk,
    output  [4:0] avm_address,
    output        avm_read,
    input  [31:0] avm_readdata,
    output        avm_write,
    output [31:0] avm_writedata,
    input         avm_waitrequest
);

localparam RX_BASE     = 0*4;
localparam TX_BASE     = 1*4;
localparam STATUS_BASE = 2*4;
localparam TX_OK_BIT   = 6;
localparam RX_OK_BIT   = 7;

// Feel free to design your own FSM!
localparam S_IDLE = 0;
localparam S_GET_KEY = 1;
localparam S_GET_DATA = 2;
localparam S_WAIT_CALCULATE = 3;
localparam S_SEND_DATA = 4;

logic [255:0] n_r, n_w, e_r, e_w, enc_r, enc_w, dec_r, dec_w;
logic [2:0] state_r, state_w;
logic [6:0] bytes_counter_r, bytes_counter_w;
logic [4:0] avm_address_r, avm_address_w;
logic [4:0] sel_r, sel_w;
logic [31:0] avm_writedata_r, avm_writedata_w;
logic avm_read_r, avm_read_w, avm_write_r, avm_write_w;

logic rsa_start_r, rsa_start_w;
logic rsa_finished;
logic [255:0] rsa_dec;

assign avm_address = avm_address_r;
assign avm_read = avm_read_r;
assign avm_write = avm_write_r;
assign avm_writedata = avm_writedata_r;

Rsa256Core rsa256_core(
    .i_clk(avm_clk),
    .i_rst(avm_rst),
    .i_start(rsa_start_r),
    .i_a(enc_r),
    .i_d(e_r),
    .i_n(n_r),
    .o_a_pow_d(rsa_dec),
    .o_finished(rsa_finished)
);

task StartRead;
    input [4:0] addr;
    begin
        avm_read_w = 1;
        avm_write_w = 0;
        avm_address_w = addr;
    end
endtask
task StartWrite;
    input [4:0] addr;
    begin
        avm_read_w = 0;
        avm_write_w = 1;
        avm_address_w = addr;
    end
endtask

always_comb begin
	//DEFAULT VALUES
	n_w = n_r;
	e_w = e_r;
	enc_w = enc_r;
	dec_w = dec_r;
	state_w =state_r;
	bytes_counter_w = bytes_counter_r;
	avm_address_w = avm_address_r;
	sel_w = sel_r;
	avm_read_w = avm_read_r;
	avm_write_w = avm_write_r;
	rsa_start_w = rsa_start_r;
	avm_writedata_w = avm_writedata_r;
	//FSM
	case(state_r)
		S_IDLE:
		begin
			n_w = 0;
			e_w = 0;
			enc_w = 0;
			dec_w = 0;
			StartRead(STATUS_BASE);
			state_w = S_GET_KEY;
			bytes_counter_w = 63;
			rsa_start_w = 0;
			sel_w = 1;
			avm_writedata_w = 0;
		end
		S_GET_KEY:
		begin
			if(!avm_read_r)
			begin
				avm_read_w = 1;
			end
    		if((avm_address_r == STATUS_BASE) && avm_read_r)
			begin
				//$display(avm_readdata);
				if(!avm_waitrequest)
				begin
					if(avm_readdata[RX_OK_BIT]==1)
					begin
						StartRead(RX_BASE);
					end
					else
						avm_read_w = 0;
				end
			end
			else if(avm_address_r == RX_BASE)
			begin
				if(bytes_counter_r>=32)
				begin
					if(!avm_waitrequest)
					begin
						//$display(n_w);
						//$display(avm_readdata);
						n_w[(bytes_counter_r-7'd32)*8+:8]=avm_readdata[7:0];
						avm_address_w = STATUS_BASE;
						avm_read_w = 0;
						bytes_counter_w = bytes_counter_r-1;
					end
				end
				else if(bytes_counter_r>=0)
				begin
					if(!avm_waitrequest)
					begin
						e_w[(bytes_counter_r)*8+:8]=avm_readdata[7:0];
						avm_address_w = STATUS_BASE;
						avm_read_w = 0;
						if(bytes_counter_r==0)
						begin
							bytes_counter_w = 31;
							state_w = S_GET_DATA;
						end
						else
						begin
							bytes_counter_w = bytes_counter_r-1;
						end
					end
						
				end
			end
			//$display(bytes_counter_r);
		end
		S_GET_DATA:
		begin
			//$display("S_GET_DATA");
			if(!avm_read_r)
			begin
				avm_read_w = 1;
			end
			if((avm_address_r == STATUS_BASE) && avm_read_r)
			begin
				if(!avm_waitrequest)
				begin
					if(avm_readdata[RX_OK_BIT]==1)
					begin
						StartRead(RX_BASE);
					end
					else
						avm_read_w = 0;
				end
			end
			else if(avm_address_r == RX_BASE)
			begin
				if(!avm_waitrequest)
				begin
					enc_w[(bytes_counter_r)*8+:8]=avm_readdata[7:0];
					avm_address_w = STATUS_BASE;
					avm_read_w = 0;
					if(bytes_counter_r!=0)
					begin
						bytes_counter_w = bytes_counter_r-1;
					end
					else
					begin
						bytes_counter_w = 31;
						state_w = S_WAIT_CALCULATE;
						rsa_start_w = 1;
					end
				end
			end
		end
		S_WAIT_CALCULATE:
		begin
			//$display("S_WAIT_CALCULATE");
			if(rsa_start_r==1)
			begin
				rsa_start_w = 0;
			end
			if(rsa_finished==1)
			begin
				dec_w = rsa_dec;
				state_w = S_SEND_DATA;
				avm_writedata_w[7:0] = rsa_dec[247+:8];
			end
		end
		S_SEND_DATA:
		begin
			//$display("S_SEND_DATA");
			if(!avm_read_r && !avm_write_r)
			begin
				avm_read_w = 1;
			end
			avm_writedata_w[7:0] = dec_r[(255-8*sel_r)-:8];
			if((avm_address_r == STATUS_BASE) && avm_read_r)
			begin
				if(!avm_waitrequest)
				begin
					if(avm_readdata[TX_OK_BIT]==1)
					begin
						StartWrite(TX_BASE);
					end
					else
						avm_read_w = 0;
				end
			end
			else if(avm_address_r == TX_BASE)
			begin
				if(!avm_waitrequest)
				begin
					avm_address_w = STATUS_BASE;
					avm_write_w = 0;
					sel_w = sel_r + 1;
					if(sel_r==31)
					begin
						state_w = S_GET_DATA;
						sel_w = 1;
					end
				end
			end
		end
	endcase
	
end

always_ff @(posedge avm_clk or posedge avm_rst) begin
    if (avm_rst) begin
        n_r <= 0;
        e_r <= 0;
        enc_r <= 0;
        dec_r <= 0;
        avm_address_r <= STATUS_BASE;
        avm_read_r <= 0;
        avm_write_r <= 0;
        state_r <= S_IDLE;
        bytes_counter_r <= 63;
        rsa_start_r <= 0;
		sel_r <= 1;
		avm_writedata_r <= 0;
    end else begin
        n_r <= n_w;
        e_r <= e_w;
        enc_r <= enc_w;
        dec_r <= dec_w;
        avm_address_r <= avm_address_w;
        avm_read_r <= avm_read_w;
        avm_write_r <= avm_write_w;
        state_r <= state_w;
        bytes_counter_r <= bytes_counter_w;
        rsa_start_r <= rsa_start_w;
		sel_r <= sel_w;
		avm_writedata_r <= avm_writedata_w;
    end
end

endmodule
