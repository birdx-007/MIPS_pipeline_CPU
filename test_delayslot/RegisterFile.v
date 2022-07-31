module RegisterFile(reset, clk, RegWrite, Read_register1, Read_register2, Write_register, Write_data, Read_data1, Read_data2);
	input reset, clk;
	input RegWrite;
	input [4:0] Read_register1, Read_register2, Write_register;
	input [31:0] Write_data;
	output [31:0] Read_data1, Read_data2;
	
	reg [31:0] RF_data[31:0];
	
	// Write, then read
	assign Read_data1=(Read_register1!=0 && RegWrite && Write_register==Read_register1)?
					Write_data:RF_data[Read_register1];
	assign Read_data2=(Read_register2!=0 && RegWrite && Write_register==Read_register2)?
					Write_data:RF_data[Read_register2];
	
	integer i;
	always @(posedge reset or posedge clk)
		if (reset)
			for (i = 0; i < 32; i = i + 1)begin
				/*if(i==4) RF_data[i] <= 32'd10;//a0
				else if(i==5) RF_data[i] <= 32'h00000000;//a1,&str:0<<2
				else if(i==6) RF_data[i] <= 32'd2;//a2
				else if(i==7) RF_data[i] <= 32'h00000200;//a2,&pattern:128<<2
				else if(i==29) RF_data[i] <= 32'h00000400;//sp,256<<2
				else RF_data[i] <= 32'h00000000;*/
				if(i==29) RF_data[i] <= 32'h00000400;//sp,256<<2
				else RF_data[i] <= 32'h00000000;
			end
		else if (RegWrite && (Write_register != 5'b00000))
			RF_data[Write_register] <= Write_data;

endmodule
			