module CPU(reset, clk, pc, v0);
	input reset, clk;
	output [31:0] pc;
	output [31:0] v0;
	
	parameter USE_DELAY_SLOT = 0;
	parameter Inst_Num = 256;
	parameter Inst_Num_BIT = 8;
	parameter RAM_SIZE = 256;
	parameter RAM_SIZE_BIT = 8;
	
    //--------------Your code below-----------------------

	wire [9:0] RegChoice;
	wire [1:0] PC_willgo;
	wire [31:0] PCnew_plus4;
	wire [31:0] PCnew_Branch;
	wire [31:0] PCnew_Jump;
	wire [31:0] PCnew_JumpReg;
	wire [31:0] PCnew;
	wire [31:0] IF_PC;
	wire [31:0] IF_Instruction;
	wire [31:0] ID_PCnew_plus4;
	wire [31:0] ID_Instruction;
	wire [5:0] OpCode;
	wire [5:0] Funct;
	wire LbOp;
	wire EqualOp;
	wire [1:0] PCSrc;
	wire Branch;
	wire RegWrite;
	wire [1:0] RegDst;
	wire MemRead;
	wire MemWrite;
	wire [1:0] MemtoReg;
	wire ALUSrc1;
	wire ALUSrc2;
	wire ExtOp;
	wire LuOp;
	wire [1:0] ID_Forward;
	wire [4:0] RF_Read_register1;
	wire [4:0] RF_Read_register2;
	wire [4:0] RF_Write_register;
	wire [31:0] RF_Write_data;
	wire [31:0] RF_Read_data1;
	wire [31:0] RF_Read_data2;
	wire [4:0] ID_Shamt;
	wire [31:0] ID_Op1;
	wire [15:0] Imm;
	wire [31:0] Imm_Result;
	wire [4:0] ALU_Ctrl;
	wire ALU_Sign;
	wire [4:0] ID_Rt;
	wire [4:0] ID_Rd;
	wire [4:0] ID_Rs;
	wire [31:0] EX_PCnew_plus4;
	wire [31:0] EX_PCnew_jal;
	wire EX_LbOp;
	wire EX_EqualOp;
	wire [1:0] EX_RegDst;
	wire EX_Branch;
	wire EX_MemRead;
	wire [1:0] EX_MemtoReg;
	wire EX_MemWrite;
	wire EX_ALUSrc1;
	wire EX_ALUSrc2;
	wire EX_RegWrite;
	wire EX_willbranch;
	wire [1:0] EX_ForwardA;
	wire [1:0] EX_ForwardB;
	wire [4:0] EX_Shamt;
	wire [31:0] EX_Op1;
	wire [31:0] EX_Op2;
	wire [31:0] EX_ALU_in1_0;
	wire [31:0] EX_ALU_in2_0;
	wire [4:0] EX_RegWrAddr;
	wire [4:0] EX_Rt;
	wire [4:0] EX_Rd;
	wire [4:0] EX_Rs;
	wire [31:0] ALU_in1;
	wire [31:0] ALU_in2;
	wire [31:0] EX_Imm_Result;
	wire [31:0] ALU_OUT_COPY;
	wire [31:0] ALU_OUT;
	wire Zero;
	wire EX_BranchOn;
	wire [4:0] EX_ALU_Ctrl;
	wire EX_ALU_Sign;
	wire Device_Access;
	wire [31:0] MEM_PCnew_jal;
	wire [31:0] MEM_ALU_OUT;
	wire MEM_LbOp;
	wire MEM_MemRead;
	wire [1:0] MEM_MemtoReg;
	wire MEM_MemWrite;
	wire MEM_RegWrite;
	wire MEM_Forward;
	wire [31:0] MEM_ALU_in2_0;
	wire [4:0] MEM_RegWrAddr;
	wire [4:0] MEM_Rt;
	wire [31:0] MEM_Write_data;
	wire [31:0] MEM_Read_data;
	wire [31:0] MEM_Device_data;
	wire [31:0] MEM_Address;
	wire [RAM_SIZE_BIT-1:0] RAM_Address;
	wire MEM_Device_Access;
	wire [4:0] WB_RegWrAddr;
	wire WB_LbOp;
	wire WB_MemRead;
	wire [1:0] WB_MemtoReg;
	wire WB_RegWrite;
	wire [31:0] WB_PCnew_jal;
	wire [31:0] WB_ALU_OUT;
	wire [31:0] WB_Read_data;
	wire [31:0] WB_Device_data;
	wire [31:0] WB_Word;
	wire [7:0] WB_Byte;
	wire [31:0] WB_LoadData;
	wire [31:0] WB_RegWrData;
	wire WB_Device_Access;
	wire [1:0] LU_IFIDchoice;
	wire [1:0] J_IFIDchoice;
	wire [1:0] B_IFIDchoice;
	wire [1:0] LU_IDEXchoice;
	wire [1:0] B_IDEXchoice;
	
	// IF
	assign PC_willgo=(EX_willbranch)?2'b0:PCSrc;
	assign PCnew_plus4=IF_PC+32'h4;
	assign PCnew_Branch=(EX_willbranch)?(EX_PCnew_plus4+(EX_Imm_Result<<2)):PCnew_plus4;//MUX
	assign PCnew_Jump={ID_PCnew_plus4[31:28],ID_Instruction[25:0],2'b00};
	assign PCnew_JumpReg=ID_Op1;
	assign PCnew=(PC_willgo==2'h2)?PCnew_JumpReg:((PC_willgo==2'h1)?PCnew_Jump:PCnew_Branch);//MUX;
	RegTemp #(.SIZE(32)) PC(
		.reset(reset),
		.clk(clk),
		.choice(RegChoice[1:0]),
		.Data_i(PCnew),
		.Data_o(IF_PC)
	);
	
	InstructionMemory #(.Inst_Num(Inst_Num),.Inst_Num_BIT(Inst_Num_BIT)) instmem(
		.Inst_Address(IF_PC[Inst_Num_BIT+1:2]),
		.Instruction(IF_Instruction)
	);
	RegTemp #(.SIZE(32+32)) IF_ID(
		.reset(reset),
		.clk(clk),
		.choice(RegChoice[3:2]),
		.Data_i({PCnew_plus4,
				IF_Instruction}),
		.Data_o({ID_PCnew_plus4,
				ID_Instruction})
	);
	
	// ID
	assign OpCode=ID_Instruction[31:26];
	assign Funct=ID_Instruction[5:0];
	assign RF_Read_register1=ID_Instruction[25:21];
	assign RF_Read_register2=ID_Instruction[20:16];
	assign RF_Write_register=WB_RegWrAddr;
	assign RF_Write_data=WB_RegWrData;
	assign ID_Shamt=ID_Instruction[10:6];
	assign ID_Op1=(ID_Forward==2'h3)?MEM_ALU_OUT:
						(ID_Forward==2'h2)?ALU_OUT:
						(ID_Forward==2'h1)?MEM_PCnew_jal:
						RF_Read_data1;//MUX
	assign Imm=ID_Instruction[15:0];
	assign ID_Rt=ID_Instruction[20:16];
	assign ID_Rd=ID_Instruction[15:11];
	assign ID_Rs=ID_Instruction[25:21];
	Control ctr(
		.OpCode(OpCode),
		.Funct(Funct),
		.LbOp(LbOp),
		.EqualOp(EqualOp),
		.PCSrc(PCSrc),
		.Branch(Branch),
		.RegWrite(RegWrite),
		.RegDst(RegDst),
		.MemRead(MemRead),
		.MemWrite(MemWrite),
		.MemtoReg(MemtoReg),
		.ALUSrc1(ALUSrc1),
		.ALUSrc2(ALUSrc2),
		.ExtOp(ExtOp),
		.LuOp(LuOp)
	);
    RegisterFile rf(
		.reset(reset),
		.clk(clk),
		.RegWrite(WB_RegWrite),
		.Read_register1(RF_Read_register1),
		.Read_register2(RF_Read_register2),
		.Write_register(RF_Write_register),
		.Write_data(RF_Write_data),
		.Read_data1(RF_Read_data1),
		.Read_data2(RF_Read_data2)
	);
	ImmProcess immprocess(
		.ExtOp(ExtOp),
		.LuiOp(LuOp),
		.Immediate(Imm),
		.ImmOut(Imm_Result)
	); 
	ALUControl aluctr(
		.OpCode(OpCode),
		.Funct(Funct),
		.ALUCtrl(ALU_Ctrl),
		.Sign(ALU_Sign)
	);
	RegTemp #(.SIZE(32+12+5+32+32+32+6+5+5+5)) ID_EX(
		.reset(reset),
		.clk(clk),
		.choice(RegChoice[5:4]),
		.Data_i({ID_PCnew_plus4,
				LbOp,EqualOp,RegDst,Branch,MemRead,MemtoReg,MemWrite,ALUSrc1,ALUSrc2,RegWrite,
				ID_Shamt,
				ID_Op1,
				RF_Read_data2,
				Imm_Result,
				ALU_Ctrl,ALU_Sign,
				ID_Rt,
				ID_Rd,
				ID_Rs}),
		.Data_o({EX_PCnew_plus4,
				EX_LbOp,EX_EqualOp,EX_RegDst,EX_Branch,EX_MemRead,EX_MemtoReg,EX_MemWrite,EX_ALUSrc1,EX_ALUSrc2,EX_RegWrite,
				EX_Shamt,
				EX_Op1,
				EX_Op2,
				EX_Imm_Result,
				EX_ALU_Ctrl,EX_ALU_Sign,
				EX_Rt,
				EX_Rd,
				EX_Rs})
	);
	
	// EX
	assign EX_PCnew_jal=(USE_DELAY_SLOT)?(EX_PCnew_plus4+32'h4):EX_PCnew_plus4;//MUX
	assign EX_willbranch=EX_Branch&&EX_BranchOn;
	assign EX_ALU_in1_0=(EX_ForwardA==2'h2)?WB_RegWrData:
							(EX_ForwardA==2'h1)?MEM_ALU_OUT:
							EX_Op1;//MUX
	assign EX_ALU_in2_0=(EX_ForwardB==2'h2)?WB_RegWrData:
							(EX_ForwardB==2'h1)?MEM_ALU_OUT:
							EX_Op2;//MUX
	assign EX_RegWrAddr=(EX_RegDst==2'h2)?(5'd31):
							(EX_RegDst==2'h1)?EX_Rd:
							EX_Rt;//MUX
	assign ALU_in1=(EX_ALUSrc1==1)?EX_Shamt:EX_ALU_in1_0;//MUX
	assign ALU_in2=(EX_ALUSrc2==1)?EX_Imm_Result:EX_ALU_in2_0;//MUX
	assign ALU_OUT_COPY=ALU_OUT;
	assign Device_Access=ALU_OUT[30];
	assign EX_BranchOn=(EX_EqualOp==1)?Zero:!Zero;//MUX
	ALU alu(
		.in1(ALU_in1),
		.in2(ALU_in2),
		.ALUCtrl(EX_ALU_Ctrl),
		.Sign(EX_ALU_Sign),
		.out(ALU_OUT),
		.zero(Zero)
	);
	RegTemp #(.SIZE(32+(7)+(32)+32+32+5+5)) EX_MEM(
		.reset(reset),
		.clk(clk),
		.choice(RegChoice[7:6]),
		.Data_i({EX_PCnew_jal,
				Device_Access,EX_LbOp,EX_MemRead,EX_MemtoReg,EX_MemWrite,EX_RegWrite,
				ALU_OUT_COPY,
				ALU_OUT,
				EX_ALU_in2_0,
				EX_RegWrAddr,
				EX_Rt}),
		.Data_o({MEM_PCnew_jal,
				MEM_Device_Access,MEM_LbOp,MEM_MemRead,MEM_MemtoReg,MEM_MemWrite,MEM_RegWrite,
				MEM_Address,
				MEM_ALU_OUT,
				MEM_ALU_in2_0,
				MEM_RegWrAddr,
				MEM_Rt})
	);
	
	//MEM
	assign MEM_Write_data=(MEM_Forward)?WB_RegWrData:MEM_ALU_in2_0;//MUX
	assign RAM_Address=(EX_MemRead)?ALU_OUT_COPY[RAM_SIZE_BIT+1:2]:MEM_Address[RAM_SIZE_BIT+1:2];
	blk_mem_gen_0 RAM(
		.clka(clk),
		.ena(EX_MemRead|MEM_MemWrite),
		.wea(MEM_MemWrite & !MEM_Device_Access & !EX_MemRead),
		.addra(RAM_Address),
		.dina(MEM_Write_data),
		.douta(MEM_Read_data)
	);
	DeviceControl devicectr(
		.reset(reset),
		.clk(clk),
		.Address(MEM_ALU_OUT),
		.Write_data(MEM_Write_data[11:0]),
		.Read_data(MEM_Device_data),
		.MemRead(MEM_MemRead),
		.MemWrite(MEM_MemWrite)
	);
	RegTemp #(.SIZE(32+32+(64)+(6)+5)) MEM_WB(
		.reset(reset),
		.clk(clk),
		.choice(RegChoice[9:8]),
		.Data_i({MEM_PCnew_jal,
				MEM_ALU_OUT,
				MEM_Read_data,MEM_Device_data,
				MEM_Device_Access,MEM_LbOp,MEM_MemRead,MEM_MemtoReg,MEM_RegWrite,
				MEM_RegWrAddr}),
		.Data_o({WB_PCnew_jal,
				WB_ALU_OUT,
				WB_Read_data,WB_Device_data,
				WB_Device_Access,WB_LbOp,WB_MemRead,WB_MemtoReg,WB_RegWrite,
				WB_RegWrAddr})
	);

	// WB
	assign WB_Word=(WB_Device_Access)?WB_Device_data:WB_Read_data;
	assign WB_LoadData=(WB_LbOp)?{24'b0,WB_Byte}:WB_Word;
	assign WB_RegWrData=(WB_MemtoReg==2'h2)?(WB_PCnew_jal):((WB_MemtoReg==2'h1)?WB_LoadData:WB_ALU_OUT);//MUX
	ByteProcess byteprocess(
		.Byte_Address(WB_ALU_OUT[1:0]),
		.Word(WB_Word),
		.Byte(WB_Byte)
	);

	// 解决冒险
	assign RegChoice[3:2]={LU_IFIDchoice[1]|J_IFIDchoice[1]|B_IFIDchoice[1],
							LU_IFIDchoice[0]&J_IFIDchoice[0]&B_IFIDchoice[0]};
	assign RegChoice[5:4]={LU_IDEXchoice[1]|B_IDEXchoice[1],
							LU_IDEXchoice[0]&B_IDEXchoice[0]};
	assign RegChoice[7:6]=2'b01;
	assign RegChoice[9:8]=2'b01;
	RAW_Forwarding raw(
		.IDEX_Rs(EX_Rs),
		.IDEX_Rt(EX_Rt),
		.EXMEM_RegWr(MEM_RegWrite),
		.EXMEM_RegWrAddr(MEM_RegWrAddr),
		.MEMWB_RegWr(WB_RegWrite),
		.MEMWB_RegWrAddr(WB_RegWrAddr),
		.ForwardA(EX_ForwardA),
		.ForwardB(EX_ForwardB)
	);
	SAL_Forwarding sal(
		.EXMEM_MemWr(MEM_MemWrite),
		.EXMEM_Rt(MEM_Rt),
		.MEMWB_MemRead(WB_MemRead),
		.MEMWB_RegWrAddr(WB_RegWrAddr),
		.Forward(MEM_Forward)
	);
	JAW_Forwarding jaw(
		.ID_OpCode(OpCode),
		.ID_Funct(Funct),
		.ID_Rs(ID_Rs),
		.IDEX_RegWr(EX_RegWrite),
		.IDEX_RegWrAddr(EX_RegWrAddr),
		.EXMEM_MemtoReg(MEM_MemtoReg),
		.EXMEM_RegWr(MEM_RegWrite),
		.EXMEM_RegWrAddr(MEM_RegWrAddr),
		.Forward(ID_Forward)
	);
	LU_Hazard lu(
		.IFID_MemWr(MemWrite),
		.IFID_Rs(ID_Rs),
		.IFID_Rt(ID_Rt),
		.IDEX_MemRead(EX_MemRead),
		.IDEX_Rt(EX_Rt),
		.PC_choice(RegChoice[1:0]),
		.IFID_choice(LU_IFIDchoice),
		.IDEX_choice(LU_IDEXchoice)
	);
	J_Hazard #(.USE_DELAY_SLOT(USE_DELAY_SLOT)) j(
		.ID_willjump(PC_willgo),
		.IFID_choice(J_IFIDchoice)
	);
	B_Hazard b(
		.EX_willbranch(EX_willbranch),
		.IFID_choice(B_IFIDchoice),
		.IDEX_choice(B_IDEXchoice)
	);
	
	assign pc=IF_PC;
	assign v0=rf.RF_data[2];
    //--------------Your code above-----------------------

endmodule
	