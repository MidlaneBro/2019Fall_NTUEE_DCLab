module I2cInitializer(
	input i_rst_n,
	input i_clk,
	input i_start,
	output o_finished,
	output o_sclk, 
	output o_sdat, 
	output o_oen // you are outputing (you are not outputing only when you are acknowledging.) 
); 
localparam S_START = 0;
localparam S_WRITE= 1;
localparam S_TRANSMIT=2;
localparam S_ACK=3;
localparam S_FINISH=4;
localparam S_IDLE=5;

logic [23:0] reset_r, reset_w, aapc_r, aapc_w, dapc_r, dapc_w, pdc_r, pdc_w, daif_r, daif_w, samcon_r, samcon_w, actcon_r, actcon_w;  
//constants. Should not change thruout the entire procedure
//analog audio path control, digital audio path control, power down control, digital audio interface format, sampling control, active control
logic [2:0] state_r, state_w; 
logic finished_r, finished_w, sclk_r, sclk_w, sdat_r, sdat_w, oen_r, oen_w; //outputs
logic [4:0] bitcounter_r, bitcounter_w;  // only when state_r == S_TRANSMIT do counter+=1, reset when == 23 in state_r == ACK (complete a word transmission)
logic [2:0] datcounter_w, datcounter_r; // choose data which we should transmit.


assign o_finished = finished_r;
assign o_sclk = sclk_r;
assign o_sdat = sdat_r;
assign o_oen = oen_r;

always_comb begin 
	reset_w   = reset_r; 
	aapc_w    = aapc_r; 
	dapc_w    = dapc_r;
	pdc_w     = pdc_r; 
	daif_w    = daif_r; 
	samcon_w  = samcon_r;
	actcon_w  = actcon_r;
	state_w   = state_r;
	finished_w = finished_r;
	sclk_w = sclk_r; 
	sdat_w = sdat_r; 
	oen_w = oen_r;
	bitcounter_w = bitcounter_r;
	datcounter_w = datcounter_r;
	case(state_r)
		S_START:
		begin 
			sclk_w = 1'b1;
			sdat_w = 1'b1;
			finished_w = 1'b0;
			oen_w = 1'b1;
			bitcounter_w = 5'b0;
			datcounter_w = 3'b0;
			state_w = S_WRITE;
		end
		S_WRITE:
		begin
			sclk_w = 1'b0;
			finished_w = 1'b0;
			oen_w = 1'b1;
			state_w = S_TRANSMIT;
			case (datcounter_r)
				3'd0: begin
					sdat_w = reset_r[5'd23-bitcounter_r];
				end
				3'd1: begin
					sdat_w = aapc_r[5'd23-bitcounter_r];
				end	
				3'd2: begin
					sdat_w = dapc_r[5'd23-bitcounter_r];
				end	
				3'd3: begin
					sdat_w = pdc_r[5'd23-bitcounter_r];
				end	
				3'd4: begin
					sdat_w = daif_r[5'd23-bitcounter_r];
				end	
				3'd5: begin
					sdat_w = samcon_r[5'd23-bitcounter_r];
				end	
				3'd6: begin
					sdat_w = actcon_r[5'd23-bitcounter_r];
				end	
			endcase
		end
		S_TRANSMIT:
		begin 
			if ((bitcounter_r + 5'd1) % 8 == 0 ) 
			begin
				if ((bitcounter_r + 5'd1) % 24 == 0)
				begin 
					datcounter_w = datcounter_r + 3'd1;
					bitcounter_w = 0;
				end
				else 
				begin
					bitcounter_w = bitcounter_r + 5'd1;
				end
				state_w = S_ACK;
				finished_w = 1'b0;
				oen_w = 1'b1;
				sclk_w = 1'b1;
			end
			else 
			begin
				state_w = S_WRITE;
				finished_w = 1'b0;
				oen_w = 1'b1;
				sclk_w = 1'b1;
				bitcounter_w = bitcounter_r + 5'd1;
			end
		end
		S_ACK:
		begin
			sdat_w = 1'bz;
			sclk_w=1'b1;
			finished_w = 1'b0;
			oen_w = 1'b0;
			if (datcounter_r == 3'd7) 
				state_w = S_FINISH;
			else
				state_w = S_WRITE;
		end
		S_FINISH:
		begin
			sdat_w=1'b1;
			sclk_w=1'b1;
			finished_w = 1'b1;
			oen_w = 1'b1;
			state_w = S_IDLE;
		end
		S_IDLE:
		begin
			finished_w = 1'b0;
			if (i_start)
				state_w = S_START;
		end
	endcase
end

always_ff @(negedge i_clk or negedge i_rst_n) begin

	if (!i_rst_n)
	begin 
		reset_r <= 24'b001101000001111000000000;
		aapc_r  <= 24'b001101000000100000010101;
		dapc_r  <= 24'b001101000000101000000000;
		pdc_r   <= 24'b001101000000110000000000;
		daif_r  <= 24'b001101000000111001000010;
		samcon_r<= 24'b001101000001000000011001;
		actcon_r<= 24'b001101000001001000000001;
		state_r <= S_START;
		bitcounter_r <= 5'd0;
		datcounter_r <= 3'd0;
		finished_r <= 0;
		sclk_r <= 0; 
		sdat_r <= 0; 
		oen_r <= 0;
	end
	else
	begin
		reset_r   <= reset_w; 
		aapc_r    <= aapc_w; 
		dapc_r    <= dapc_w;
		pdc_r     <= pdc_w; 
		daif_r    <= daif_w; 
		samcon_r  <= samcon_w;
		actcon_r  <= actcon_w;
		state_r   <= state_w;
		bitcounter_r <= bitcounter_w;
		datcounter_r <= datcounter_w;
		finished_r <= finished_w;
		sclk_r <= sclk_w; 
		sdat_r <= sdat_w; 
		oen_r <= oen_w;
	end
end
endmodule