`timescale 1ns / 1ps

// 解决Load-Use冒险
module LU_Hazard(IFID_MemWr, IFID_Rs, IFID_Rt, IDEX_MemRead, IDEX_Rt, PC_choice, IFID_choice, IDEX_choice);
	input IFID_MemWr;
	input [4:0] IFID_Rs;
	input [4:0] IFID_Rt;
	input IDEX_MemRead;
	input [4:0] IDEX_Rt;
	output [1:0] PC_choice;
	output [1:0] IFID_choice;
	output [1:0] IDEX_choice;
	
	wire condition=IDEX_MemRead && (IDEX_Rt==IFID_Rs || (!IFID_MemWr && IDEX_Rt==IFID_Rt));
	assign PC_choice=condition?2'b10:// Keep PC;
					2'b01;
	assign IFID_choice=condition?2'b10:// Keep IF/ID;
						2'b01;
	assign IDEX_choice=condition?2'b00:// Flush ID/EX;
						2'b01;
endmodule

// 解决Jump控制冒险
module J_Hazard
#(parameter USE_DELAY_SLOT = 0)
(ID_willjump, IFID_choice);
	input [1:0] ID_willjump;
	output [1:0] IFID_choice;
	
	wire condition=(USE_DELAY_SLOT == 0 && ID_willjump != 2'b00);
	assign IFID_choice=condition?2'b00:// Flush IF/ID;
						2'b01;
endmodule

// 解决Branch控制冒险
module B_Hazard
(EX_willbranch,  IFID_choice, IDEX_choice);
	input EX_willbranch;
	output [1:0] IFID_choice;
	output [1:0] IDEX_choice;
	
	wire condition=(EX_willbranch != 0);
	assign IFID_choice=condition?2'b00:// Flush IF/ID;
						2'b01;
	assign IDEX_choice=condition?2'b00:// Flush ID/EX;
						2'b01;
endmodule