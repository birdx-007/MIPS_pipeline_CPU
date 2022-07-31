module DataMemory
#(parameter RAM_SIZE = 256, parameter RAM_SIZE_BIT = 8)
(reset, clk, Address, Write_data, Read_data, MemRead, MemWrite, DeviceAccess);
	input reset, clk;
	input [RAM_SIZE_BIT-1:0] Address;
	input [31:0] Write_data;
	input MemRead, MemWrite, DeviceAccess;
	output reg	[31:0] Read_data;
	
	reg [31:0] RAM_data[RAM_SIZE - 1: 0];
	//assign Read_data = (MemRead)? RAM_data[Address]: 32'h00000000;
	always @(*)begin
		if(MemRead) Read_data <= RAM_data[Address];
		else Read_data <= 32'b0;
	end
	
	integer i;
	always @(posedge reset or posedge clk)begin
		if(reset)begin
			for (i = 0; i < RAM_SIZE; i = i + 1)begin
				/*case(i)
					//str:eaeaeaeaea
					0:			RAM_data[i] <= 32'h61656165;
					1:			RAM_data[i] <= 32'h61656165;
					2:			RAM_data[i] <= 32'h00006165;
					//pattern:a(61)e(65)
					128:		RAM_data[i] <= 32'h00006561;
					default:	RAM_data[i] <= 32'h00000000;
				endcase*/
				RAM_data[i] <= 32'h00000000;
			end
		end
		else if(MemWrite & !DeviceAccess)begin
			RAM_data[Address] <= Write_data;
		end
	end		
endmodule