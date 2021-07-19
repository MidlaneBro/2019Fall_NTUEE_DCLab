module tb();

reg clk,rst_n,start;
reg [15:0] signal_base,signal_test;
wire finish,result;

evaluate a(
    .i_clk(clk),
    .i_rst_n(rst_n),
    .i_start(start),
    .i_signal_base(signal_base),
    .i_signal_test(signal_test),
    .o_finish(finish),
    .o_result(result)
);

always #10 clk=~clk;

initial begin

	$dumpfile("evaluate.fsdb");
	$dumpvars;
    rst_n=1;
	clk=0;
    #20; rst_n=0;
	#20; rst_n=1; start=1; signal_base=16'd100; signal_test=16'd100;
    #20; start=0;
    #5120; $finish;

end

endmodule
