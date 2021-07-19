module I2cInitializer(
	input i_rst_n,
	input i_clk,
	input i_start,
	output o_finished,
	output o_sclk, 
	inout io_sdat, 
	output o_oen // you are outputing (you are not outputing only when you are acknowledging.) 
); 
localparam S_START = 0;
localparam S_WRITE= 1;
localparam S_TRANSMIT=2;
localparam S_ACK=3;
localparam S_FINISH=4;
localparam S_IDLE=5;

localparam LLINEIN = 24'b0011_0100_000_0000_0_1001_0111;
localparam RLINEIN = 24'b0011_0100_000_0001_0_1001_0111;
localparam LHPOUT = 24'b0011_0100_000_0010_0_0111_1001;
localparam RHPOUT = 24'b0011_0100_000_0011_0_0111_1001;
localparam AAPCTRL = 24'b0011_0100_000_0100_0_0001_0101;
localparam DAPCTRL = 24'b0011_0100_000_0101_0_0000_0000;
localparam PDCTRL = 24'b0011_0100_000_0110_0_0000_0000;
localparam DAIFMT = 24'b0011_0100_000_0111_0_0100_0010;
localparam SCTRL = 24'b0011_0100_000_1000_0_0001_1001;
localparam ACTRL = 24'b0011_0100_000_1001_0_0000_0001;
logic [0:23] config_data[0:9];

assign config_data[9] = LLINEIN;
assign config_data[8] = RLINEIN;
assign config_data[7] = LHPOUT;
assign config_data[6] = RHPOUT;
assign config_data[5] = AAPCTRL;
assign config_data[4] = DAPCTRL;
assign config_data[3] = PDCTRL;
assign config_data[2] = DAIFMT;
assign config_data[1] = SCTRL;
assign config_data[0] = ACTRL;

// logic [23:0] reset_r, reset_w, aapc_r, aapc_w, dapc_r, dapc_w, pdc_r, pdc_w, daif_r, daif_w, samcon_r, samcon_w, actcon_r, actcon_w;  
//constants. Should not change thruout the entire procedure
//analog audio path control, digital audio path control, power down control, digital audio interface format, sampling control, active control
logic [2:0] state_r, state_w; 
logic finished_r, finished_w, sclk_r, sclk_w, sdat_r, sdat_w, oen_r, oen_w; //outputs
logic [4:0] bitcounter_r, bitcounter_w;  // only when state_r == S_TRANSMIT do counter+=1, reset when == 23 in state_r == ACK (complete a word transmission)
logic [3:0] datcounter_w, datcounter_r; // choose data which we should transmit.
logic ack_counter_w, ack_counter_r;

assign o_finished = finished_r;
assign o_sclk = sclk_r;
assign io_sdat = sdat_r;
assign o_oen = oen_r;

always_comb begin
	/*
	reset_w   = reset_r; 
	aapc_w    = aapc_r; 
	dapc_w    = dapc_r;
	pdc_w     = pdc_r; 
	daif_w    = daif_r; 
	samcon_w  = samcon_r;
	actcon_w  = actcon_r;
	*/
	state_w   = state_r;
	finished_w = finished_r;
	sclk_w = sclk_r; 
	sdat_w = sdat_r; 
	oen_w = oen_r;
	bitcounter_w = bitcounter_r;
	datcounter_w = datcounter_r;
	ack_counter_w = ack_counter_r;
	case(state_r)
		S_START:
		begin 
			sclk_w = 1'b0;
			sdat_w = 1'b0;
			finished_w = 1'b0;
			oen_w = 1'b1;
			bitcounter_w = 5'b0;
			ack_counter_w = 0;
			state_w = S_TRANSMIT;
		end
		S_WRITE:
		begin
			sclk_w = 1'b0;
			finished_w = 1'b0;
			oen_w = 1'b1;
			state_w = S_TRANSMIT;
			sdat_w = config_data[datcounter_r][bitcounter_r];
		end
		S_TRANSMIT:
		begin
			sclk_w = 1'b1;
			if ((bitcounter_r + 5'd1) % 8 == 0 ) 
			begin
				state_w = S_ACK;
				if ((bitcounter_r + 5'd1) % 24 == 0)
				begin 
					datcounter_w = datcounter_r + 3'd1;
					bitcounter_w = 5'd24;
				end
				else 
				begin
					bitcounter_w = bitcounter_r + 5'd1;
				end
			end
			else 
			begin
				state_w = S_WRITE;
				bitcounter_w = bitcounter_r + 5'd1;
			end
		end
		S_ACK:
		begin
			sdat_w = 1'bz;
			oen_w = 0;
			if (ack_counter_r == 0)
			begin	
				ack_counter_w = 1;
				sclk_w = 1'b0;
			end
			else 
			begin
				ack_counter_w = 0;
				sclk_w = 1;
				if (bitcounter_r == 5'd24) 
				begin
					bitcounter_w = 0;
					state_w = S_FINISH;
				end
				else
				begin
					state_w = S_WRITE;
				end
			end
		end
		S_FINISH:
		begin
			sclk_w = 1;
			oen_w = 1;
			if(bitcounter_r <= 1)
			begin
				bitcounter_w = bitcounter_r + 1;
				sdat_w = 0;
			end
			else 
			begin
				bitcounter_w = 0;
				sdat_w = 1;
				state_w = S_IDLE;
			end
		end
		S_IDLE:
		begin
			sclk_w = 1;
			if(bitcounter_r == 0)
			begin
				bitcounter_w = 1;
				sdat_w = 1;
				finished_w = 0;
			end
			else if (datcounter_w <= 4'd9)
			begin
				bitcounter_w = 0;
				sdat_w = 0;
				finished_w = 0;
				state_w = S_START;
			end
			else 
				finished_w = 1;
		end
	endcase
end

always_ff @(negedge i_clk or negedge i_rst_n) 
begin
	if (!i_rst_n)
	begin
		/*
		reset_r <= 24'b001101000001111000000000;
		aapc_r  <= 24'b001101000000100000010101;
		dapc_r  <= 24'b001101000000101000000000;
		pdc_r   <= 24'b001101000000110000000000;
		daif_r  <= 24'b001101000000111001000010;
		samcon_r<= 24'b001101000001000000011001;
		actcon_r<= 24'b001101000001001000000001;
		*/
		state_r <= S_IDLE;
		bitcounter_r <= 5'd0;
		datcounter_r <= 3'd0;
		ack_counter_r <= 0;
		finished_r <= 0;
		sclk_r <= 0; 
		sdat_r <= 0; 
		oen_r <= 0;
	end
	else
	begin
		/*
		reset_r   <= reset_w; 
		aapc_r    <= aapc_w; 
		dapc_r    <= dapc_w;
		pdc_r     <= pdc_w; 
		daif_r    <= daif_w; 
		samcon_r  <= samcon_w;
		actcon_r  <= actcon_w;
		*/
		state_r   <= state_w;
		bitcounter_r <= bitcounter_w;
		datcounter_r <= datcounter_w;
		ack_counter_r <= ack_counter_w;
		finished_r <= finished_w;
		sclk_r <= sclk_w; 
		sdat_r <= sdat_w; 
		oen_r <= oen_w;
	end
end
endmodule