module ByteProcess(Byte_Address,Word,Byte);
	input [1:0] Byte_Address;
	input [31:0] Word;
	output reg [7:0] Byte;
	
	always @(*)begin
		if(Byte_Address==2'b11)			Byte = Word[31:24];
		else if(Byte_Address==2'b10)	Byte = Word[23:16];
		else if(Byte_Address==2'b01)	Byte = Word[15:8];
		else Byte = Word[7:0];
	end
endmodule