module tb();
reg i_rst_n, i_clk, i_start, i_pause, i_stop, i_daclrck;
reg [3:0] i_speed;
reg [1:0] i_mode; 
reg [15:0] i_sram_data;
wire [15:0] o_dac_data; 
wire [19:0] o_sram_addr;

AudDSP AudDSP0(
	.i_rst_n(i_rst_n),
	.i_clk(i_clk), 
	.i_start(i_start),
	.i_pause(i_pause),
	.i_stop(i_stop),
	.i_speed(i_speed),
	.i_mode(i_mode), 
	.i_daclrck, 
	.i_sram_data,
	.o_dac_data,
	.o_sram_addr
);

always #10 i_clk=~i_clk; //bit clock_cycle = 20
always #400 i_daclrck=~i_daclrck; //lrc clock cycle = 800

initial begin
	$dumpfile("AudDSP.fsdb");
	$dumpvars;
	i_rst_n=0; i_start=0; i_pause=0; i_stop=0; i_speed=0; i_mode=0;
	i_clk=0; i_daclrck=0;
	// testing normal speed, pause and stop
	#400
	i_sram_data = 16'd8000;
	i_start=1;
	i_rst_n=1;
	#800; // -> S_IDLE
	i_start=0;
	i_sram_data = 16'd7500;
	#800
	i_sram_data = 16'd7000;
	#800
	i_sram_data = 16'd6500;
	#200
	i_pause = 1;
	#400
	i_pause = 0;
	#200
	i_sram_data = 16'd6000;
	#200
	i_pause = 1;
	#400
	i_pause = 0;
	#200
	i_sram_data = 16'd5500;
	#800
	i_sram_data = 16'd5000;
	#800
	i_sram_data = 16'd4500;
	#200
	i_stop = 1;
	#400
	i_stop = 0;
	#200
	// 7 complete clock cycles passed, now test zero order.
	i_sram_data = 16'd2000;
	i_mode = 2;
	i_speed = 4;
	i_start = 1;
	#800
	i_start = 0;
	#3400
	i_sram_data = 16'd4000;
	#3200
	i_sram_data = 16'd600;
	#3200
	// 8 complete clock cycles passed, start testing first order.
	// i_sram_data = 16'd6000;
	i_mode = 3;
	i_speed = 6;
	i_sram_data = 16'd1200;
	#4800
	i_sram_data = 16'd1350;
	#4800
	i_sram_data = 16'd1800;
	#4800
	// 14 complete clock cycles passed.
	$finish;
end
endmodule