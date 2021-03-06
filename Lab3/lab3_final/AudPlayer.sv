module AudPlayer(
	input 			i_rst_n,
	input 			i_bclk,
	input 			i_daclrck,
	input 			i_en, // enable AudPlayer only when playing audio, work with AudDSP
	input 	[15:0]	i_dac_data, //dac_data
	output 			o_aud_dacdat
);

// ===== States =====
parameter S_IDLE = 2'b00;
parameter S_PLAY = 2'b01;
parameter S_PLAY_FINISH = 2'b10;


// ===== Input Buffer =====
logic [15:0] dac_data_r;
logic [15:0] dac_data_w;
logic [4:0] counter_r;
logic [4:0] counter_w;
logic Ispre_r;
logic Ispre_w;

// ===== Output Buffer =====
logic aud_dacdat_r;
logic aud_dacdat_w;


// ===== Register & Wire =====
logic [1:0] state_r;
logic [1:0] state_w;



// ===== Output Assignment =====
assign o_aud_dacdat = aud_dacdat_r;

// ===== Submodule =====

// ===== Combinational Circuit =====
always_comb begin
	//default value
	dac_data_w = dac_data_r;
	aud_dacdat_w = aud_dacdat_r;
	state_w = state_r;
	counter_w = counter_r;
	Ispre_w = Ispre_r;
	//FSM
	case(state_r)
		S_IDLE:
		begin
			if(i_en)
			begin
				Ispre_w = 0;
				state_w = S_PLAY;
			end
		end
		S_PLAY:
		begin
			if(Ispre_r && i_daclrck)
			begin
				if(counter_r <= 5'd15)
				begin
					aud_dacdat_w = dac_data_r[5'd15-counter_r];
					counter_w = counter_r+5'd1;
				end
				else
				begin
					aud_dacdat_w = 0;
					state_w = S_PLAY_FINISH;
					counter_w = 0;
				end
			end
			else
			begin
				aud_dacdat_w = 0;
				counter_w = 0;
			end
		end
		S_PLAY_FINISH:
		begin
			if(!i_daclrck)
			begin
				state_w = S_PLAY;
			end
		end
	endcase
end
// ===== Sequential Circuit =====
always_ff @(negedge i_bclk or negedge i_rst_n) begin	
	if(!i_rst_n)
	begin
		aud_dacdat_r <= 0;
		state_r <= S_IDLE;
		counter_r <= 0;
	end
	else
	begin
		aud_dacdat_r <= aud_dacdat_w;
		state_r <= state_w;
		counter_r <= counter_w;
	end
end

always_ff @(posedge i_daclrck or negedge i_rst_n) begin	
	if(!i_rst_n)
	begin
		Ispre_r <= 0;
		dac_data_r <= 16'b0000000000000000;
	end
	else if(i_daclrck)
	begin
		Ispre_r <= i_en;
		dac_data_r <= i_dac_data;
	end
	else
	begin
		Ispre_r <= 0;
		dac_data_r <= dac_data_w;
	end
end

endmodule