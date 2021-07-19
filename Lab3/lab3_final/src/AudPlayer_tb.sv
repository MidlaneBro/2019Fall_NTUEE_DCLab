//`include "AudPlayer.sv"

module tb();
reg rst_n,clk,lrc,Isplay;
reg [15:0] dac_data;
wire aud_dacdat;

AudPlayer player0(
	.i_rst_n(rst_n),
	.i_bclk(clk),
	.i_daclrck(lrc),
	.i_en(Isplay), // enable AudPlayer only when playing audio, work with AudDSP
	.i_dac_data(dac_data), //dac_data
	.o_aud_dacdat(aud_dacdat)
);

always #10 clk=~clk;
always #400 lrc=~lrc;

initial begin
	$dumpfile("audplayer.fsdb");
	$dumpvars;
	rst_n=1;
	clk=0;
	lrc=0;
	Isplay=0;
	dac_data = 16'b0000000000000000;
	#20;
	rst_n=0;
	#20;
	rst_n=1;
	#20;
	Isplay=1;
	dac_data = 16'b0101110010110100;
	#600;
	Isplay=0;
	dac_data = 16'b1010101010100101;
	#700;
	Isplay=1;
	#1300;
	Isplay=0;
	$finish;
end
endmodule