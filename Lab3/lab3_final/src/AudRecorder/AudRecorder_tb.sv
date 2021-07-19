module tb();

reg rst_n,clk,lrc,start,pause,stop,i_data;
wire [19:0] address;
wire [15:0] o_data;

AudRecorder AR(
	.i_rst_n(rst_n),
	.i_clk(clk),
	.i_lrc(lrc),
	.i_start(start),
	.i_pause(pause),
	.i_stop(stop),
	.i_data(i_data),
	.o_address(address),
	.o_data(o_data)
);

always #10 clk=~clk;
always #400 lrc=~lrc;

initial begin

	$dumpfile("AudRecorder.fsdb");
	$dumpvars;

	rst_n=1;
	clk=0;
	lrc=0;
	start=0;
	pause=0;
	stop=0;
	i_data=0;

	#20; rst_n = 0;
	#20; rst_n = 1;
	#20; start = 1;
	#20; start = 0;
	//80
	#340; i_data = 1;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 0; pause = 1;
	#20; i_data = 1;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 0;
	//740
	#80; i_data = 1;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 0;
	//1120
	#80; i_data = 0;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 0;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 0; pause = 0;
	#20; i_data = 0;
	#20; i_data = 0; 
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 0;
	//1520
	#80; i_data = 0;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 0;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 0;
	#20; i_data = 0;
	#20; i_data = 0;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 0;
	//1920
	#80; i_data = 0;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 0;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 0; stop = 1;
	#20; i_data = 0;
	#20; i_data = 0;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 0;
	//2320
	#80; i_data = 0;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 0;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 0;
	#20; i_data = 0;
	#20; i_data = 0;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 0;
	//2720
	#80; i_data = 0;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 0;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 0; stop = 0;
	#20; i_data = 0;
	#20; i_data = 0;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 0;
	//3120
	#80; i_data = 0;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 0;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 0;
	#20; i_data = 0;
	#20; i_data = 0;
	#20; i_data = 0;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 1;
	#20; i_data = 0;

	$finish;

end

endmodule