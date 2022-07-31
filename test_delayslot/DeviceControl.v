module DeviceControl(reset, clk, Address, Write_data, Read_data, MemRead, MemWrite);
	input reset, clk;
	input [31:0] Address;
	input [11:0] Write_data;
	input MemRead, MemWrite;
	output reg [31:0] Read_data;
	
	reg [7:0] LED;
	reg [11:0] DIGI;
	
	always @(*)begin
		if(MemRead)begin
			case(Address)
				32'h4000000C: Read_data <= {24'b0,LED};
				32'h40000010: Read_data <= {20'b0,DIGI};
				default: Read_data <= 32'b0;
			endcase
		end
		else Read_data <= 32'b0;
	end
	
	integer i;
	always @(posedge reset or posedge clk)begin
		if(reset)begin
			LED <= 8'b0;
			DIGI <= 12'b0;
		end
		else if(MemWrite)begin
			case(Address)
				32'h4000000C: LED <= Write_data[7:0];
				32'h40000010: DIGI <= Write_data[11:0];
			endcase
		end
	end		
endmodule