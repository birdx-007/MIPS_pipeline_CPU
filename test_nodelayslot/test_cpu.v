`timescale 1ns / 1ps
module test_cpu();
	
reg reset;
reg clk;
wire [31:0] PC;
wire [31:0] v0;

CPU #(.USE_DELAY_SLOT(0),.Inst_Num(46),.Inst_Num_BIT(8)) cpu(reset, clk, PC, v0);

initial begin
	reset <= 1;
	clk <= 1;
	#50 reset <= 0;
end

always #50 clk <= ~clk;
		
endmodule
