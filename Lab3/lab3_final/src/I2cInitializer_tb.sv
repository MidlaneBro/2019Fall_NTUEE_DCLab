module tb();
reg i_rst_n, i_clk, i_start;
wire o_sclk, o_sdat, o_oen, o_finished;

I2cInitializer I2c0(
	.i_rst_n(i_rst_n),
	.i_clk(i_clk),
	.i_start(i_start),
	.o_finished(o_finished),
	.o_sclk(o_sclk), 
	.o_sdat(o_sdat), 
	.o_oen(o_oen) // you are outputing (you are not outputing only when you are acknowledging.) 
); 

always #10 i_clk=~i_clk;

initial begin
	$dumpfile("I2cInitializer.fsdb");
	$dumpvars;
	i_rst_n=0;
	i_start=0;
	i_clk=0;
	#20;
	i_rst_n=1;
	#20
	i_start=1;
	#20
	i_start=0;
	#10000;
	$finish;
end
endmodule