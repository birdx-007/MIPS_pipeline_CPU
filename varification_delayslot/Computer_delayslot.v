module Computer(reset,sysclk,led,digi);
	input reset,sysclk;
	output [7:0] led;
	output [11:0] digi;
	
	wire clk;
	
	CPU #(.USE_DELAY_SLOT(1),.Inst_Num(150)) cpu(reset, clk);
	CLK_K #(.K(2),.K_bit(1)) clk_k(sysclk,clk);
	assign led=cpu.devicectr.LED;
	assign digi=cpu.devicectr.DIGI;
endmodule

module CLK_K
#(parameter K=2,parameter K_bit=1)
(clkin,clkout);
	input clkin;
	output clkout;
	reg [K_bit-1:0] cnt;
	reg clkout;
	always @(posedge clkin)begin
		if(cnt==K-1)begin
			cnt<=0;
			clkout<=1;
		end
		else begin
			cnt<=cnt+1;
			clkout<=0;
		end
	end
endmodule