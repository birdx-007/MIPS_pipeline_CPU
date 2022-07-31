`timescale 1ns / 1ps

// 解决Read after Write冒险
module RAW_Forwarding(IDEX_Rs, IDEX_Rt, EXMEM_RegWr, EXMEM_RegWrAddr, MEMWB_RegWr, MEMWB_RegWrAddr, ForwardA, ForwardB);
	input [4:0] IDEX_Rs;
	input [4:0] IDEX_Rt;
	input EXMEM_RegWr;
	input [4:0] EXMEM_RegWrAddr;
	input MEMWB_RegWr;
	input [4:0] MEMWB_RegWrAddr;
	output [1:0] ForwardA;
	output [1:0] ForwardB;
	
	// EX/MEM->EX
	wire conditionA1=IDEX_Rs != 0 && EXMEM_RegWr && EXMEM_RegWrAddr==IDEX_Rs;
	wire conditionB1=IDEX_Rt != 0 && EXMEM_RegWr && EXMEM_RegWrAddr==IDEX_Rt;
	// MEM/WB->EX
	wire conditionA2=IDEX_Rs != 0 && MEMWB_RegWr && MEMWB_RegWrAddr == IDEX_Rs;
	wire conditionB2=IDEX_Rt != 0 && MEMWB_RegWr && MEMWB_RegWrAddr == IDEX_Rt;
	assign ForwardA=conditionA1?2'b01:
					conditionA2?2'b10:
					2'b00;
	assign ForwardB=conditionB1?2'b01:
					conditionB2?2'b10:
					2'b00;
endmodule

// 解决Save after Load冒险
module SAL_Forwarding(EXMEM_MemWr, EXMEM_Rt, MEMWB_MemRead, MEMWB_RegWrAddr, Forward);
	input EXMEM_MemWr;
	input [4:0] EXMEM_Rt;
	input MEMWB_MemRead;
	input [4:0] MEMWB_RegWrAddr;
	output Forward;
	
	wire condition=EXMEM_Rt != 0 && EXMEM_MemWr && MEMWB_MemRead && MEMWB_RegWrAddr == EXMEM_Rt;
	assign Forward=condition?1'b1:1'b0;
endmodule

// 解决jr/jalr after Write冒险
module JAW_Forwarding(ID_OpCode, ID_Funct, ID_Rs, IDEX_RegWr, IDEX_RegWrAddr, EXMEM_MemtoReg, EXMEM_RegWr, EXMEM_RegWrAddr, Forward);
	input [5:0] ID_OpCode;
	input [5:0] ID_Funct;
	input [4:0] ID_Rs;
	input IDEX_RegWr;
	input [4:0] IDEX_RegWrAddr;
	input [1:0] EXMEM_MemtoReg;
	input EXMEM_RegWr;
	input [4:0] EXMEM_RegWrAddr;
	output [1:0] Forward;
	
	// jr/jalr
	wire conditionjr=ID_OpCode == 6'b0 && (ID_Funct == 6'b001000 || ID_Funct == 6'b001001);
	// jal/jalr-nop-jr/jalr
	wire condition1=(EXMEM_MemtoReg == 2'b10);
	// use-x-jr/jalr
	wire condition2=(ID_Rs != 0 && EXMEM_RegWr && EXMEM_RegWrAddr == ID_Rs);
	// use-jr/jalr
	wire condition3=(ID_Rs != 0 && IDEX_RegWr && IDEX_RegWrAddr == ID_Rs);
	assign Forward=!conditionjr?2'b00:
					(condition1?2'b01:
					condition2?2'b11:
					condition3?2'b10:2'b00);
endmodule