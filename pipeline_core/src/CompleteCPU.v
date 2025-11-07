module CompleteCPU (
    input clk,
    input start,
    output [3:0]out_1
);

    wire [31:0] next_pc,pc,pc4,inst;
    
    wire [31:0] inst_IFID,pc_IFID,readData1_IFID,readData2_IFID,imm_IFID;
    wire branch_IFID,memRead_IFID,memtoReg_IFID,memWrite_IFID,ALUSrc_IFID,regWrite_IFID;
    wire [1:0] ALUOp_IFID;
    
    wire [31:0] pc_IDEX,readData1_IDEX,readData2_IDEX,imm_IDEX,pcb_IDEX,ALUOut_IDEX,ALUI2_IDEX,inst_IDEX;
    wire branch_IDEX,memRead_IDEX,memtoReg_IDEX,memWrite_IDEX,ALUSrc_IDEX,regWrite_IDEX,zero_IDEX;
    wire [1:0] ALUOp_IDEX;
    wire [3:0] funct_IDEX,ALUCtl_IDEX;
    wire [4:0] writereg_IDEX;
    
    wire [31:0] pcb_EXMEM,ALUOut_EXMEM,readData2_EXMEM,readData_EXMEM;
    wire branch_EXMEM,zero_EXMEM,memWrite_EXMEM,memRead_EXMEM,regWrite_EXMEM,memtoReg_EXMEM;
    wire [4:0] writereg_EXMEM;
    
    wire [31:0] readData_MEMWB,ALUOut_MEMWB,writeData_MEMWB;
    wire regWrite_MEMWB,memtoReg_MEMWB;
    wire [4:0] writereg_MEMWB;
    
    wire branch,memRead,memtoReg,memWrite,ALUSrc,regWrite;
    wire [1:0]ALUOp;
    
    wire PCSrc,PCWrite,IFIDWrite,stall,IF_Flush;
    wire [1:0] FA,FB;

PC m_PC(
    .clk(clk),
    .rst(start),
    .PCWrite(PCWrite),
    .pc_i(next_pc),
    .pc_o(pc)
);

Adder m_Adder_1(
    .a(pc),
    .b(32'd4),
    .sum(pc4)
);

InstructionMemory m_InstMem(
    .readAddr(pc),
    .inst(inst)
);

wire [31:0] pc1;

assign pc1 = pcb_IDEX - 32'd4;

Mux2to1 #(.size(32)) m_Mux_PC(
    .sel(PCSrc),
    .s0(pc4),
    .s1(pc1),
    .out(next_pc)
);

IF_ID_Pipeline FDP (
        .clk(clk),
        .reset(~start),
        .IF_IDWrite(IFIDWrite),
        .IF_Flush(IF_Flush),
        .pc_in(pc),
        .instruction_in(inst),
        .pc_out(pc_IFID),
        .instruction_out(inst_IFID)
    );


Control m_Control(
    .opcode(inst_IFID[6:0]),
    .branch(branch),
    .memRead(memRead),
    .memtoReg(memtoReg),
    .ALUOp(ALUOp),
    .memWrite(memWrite),
    .ALUSrc(ALUSrc),
    .regWrite(regWrite)
);


Register m_Register(
    .clk(clk),
    .rst(start),
    .regWrite(regWrite_MEMWB),
    .readReg1(inst_IFID[19:15]),
    .readReg2(inst_IFID[24:20]),
    .writeReg(writereg_MEMWB),
    .writeData(writeData_MEMWB),
    .readData1(readData1_IFID),
    .readData2(readData2_IFID)
);


ImmGen #(.Width(32)) m_ImmGen(
    .inst(inst_IFID),
    .imm(imm_IFID)
);

//ShiftLeftOne m_ShiftLeftOne(
//    .i(),
//    .o()
//);

ID_EX_Pipeline IEP (
        .clk(clk),
        .reset(~start),
        .pc_in(pc),
        .read_data1_in(readData1_IFID),
        .read_data2_in(readData2_IFID),
        .imm_in(imm_IFID),
        .funct_in({inst_IFID[30], inst_IFID[14:12]}),
        .wr_in(inst_IFID[11:7]),
        .aluop_in(ALUOp_IFID),
        .branch_in(branch_IFID),
        .memread_in(memRead_IFID),
        .memreg_in(memtoReg_IFID), 
        .memwrite_in(memWrite_IFID),
        .alusrc_in(ALUSrc_IFID),
        .regwrite_in(regWrite_IFID),
        .instruction_in(inst_IFID),
        .pc_out(pc_IDEX),
        .read_data1_out(readData1_IDEX),
        .read_data2_out(readData2_IDEX),
        .imm_out(imm_IDEX),
        .funct_out(funct_IDEX),
        .wr_out(writereg_IDEX),
        .aluop_out(ALUOp_IDEX),
        .branch_out(branch_IDEX),
        .memread_out(memRead_IDEX),
        .memreg_out(memtoReg_IDEX), 
        .memwrite_out(memWrite_IDEX),
        .alusrc_out(ALUSrc_IDEX),
        .regwrite_out(regWrite_IDEX),
        .instruction_out(inst_IDEX)
    );

//wire [31:0] imm_IDEX_shift;

//ShiftLeftOne slo(
//        .i(imm_IDEX),
//        .o(imm_IDEX_shift)
//    );

Adder m_Adder_2(
    .a(pc_IDEX),
    .b(imm_IDEX),
    .sum(pcb_IDEX)
);


wire [31:0] ALUI1,ALUI2;

Mux3to1 Mux_ALU_1(
    .sel(FA),
    .s0(readData1_IDEX),
    .s1(writeData_MEMWB),
    .s2(ALUOut_EXMEM),
    .out(ALUI1)
);

Mux3to1 Mux_ALU_2(
    .sel(FB),
    .s0(readData2_IDEX),
    .s1(writeData_MEMWB),
    .s2(ALUOut_EXMEM),
    .out(ALUI2)
);

Mux2to1 #(.size(32)) m_Mux_ALU(
    .sel(ALUSrc_IDEX),
    .s0(ALUI2),
    .s1(imm_IDEX),
    .out(ALUI2_IDEX)
);


ALUCtrl m_ALUCtrl(
    .ALUOp(ALUOp_IDEX),
    .funct7(funct_IDEX[3]),
    .funct3(funct_IDEX[2:0]),
    .ALUCtl(ALUCtl_IDEX)
);

ALU m_ALU(
    .ALUCtl(ALUCtl_IDEX),
    .A(ALUI1),
    .B(ALUI2_IDEX),
    .ALUOut(ALUOut_IDEX),
    .zero(zero_IDEX)
);

EX_MEM_Pipeline EMP (
        .clk(clk),
        .reset(~start),
        .pc_in(pcb_IDEX),
        .alu_in(ALUOut_IDEX),
        .read_data2_in(readData2_IDEX),
        .wr_in(writereg_IDEX),
        .branch_in(branch_IDEX),
        .memread_in(memRead_IDEX),
        .memreg_in(memtoReg_IDEX), 
        .memwrite_in(memWrite_IDEX),
        .regwrite_in(regWrite_IDEX),
        .zero_in(zero_IDEX),
        .pc_out(pcb_EXMEM),
        .alu_out(ALUOut_EXMEM),
        .read_data2_out(readData2_EXMEM),
        .wr_out(writereg_EXMEM),
        .branch_out(branch_EXMEM),
        .memread_out(memRead_EXMEM),
        .memreg_out(memtoReg_EXMEM), 
        .memwrite_out(memWrite_EXMEM),
        .regwrite_out(regWrite_EXMEM),
        .zero_out(zero_EXMEM)
    );

DataMemory m_DataMemory(
    .rst(start),
    .clk(clk),
    .memWrite(memWrite_EXMEM),
    .memRead(memRead_EXMEM),
    .address(ALUOut_EXMEM),
    .writeData(readData2_EXMEM),
    .readData(readData_EXMEM)
);

MEM_WB_Pipeline MWP (
        .clk(clk),
        .reset(~start),
        .read_data_in(readData_EXMEM),
        .alu_in(ALUOut_EXMEM),
        .wr_in(writereg_EXMEM),
        .mem_reg_in(memtoReg_EXMEM), 
        .reg_write_in(regWrite_EXMEM),
        .read_data_out(readData_MEMWB),
        .alu_out(ALUOut_MEMWB),
        .wr_out(writereg_MEMWB),
        .mem_reg_out(memtoReg_MEMWB), 
        .reg_write_out(regWrite_MEMWB)
    );

Mux2to1 #(.size(32)) m_Mux_WriteData(
    .sel(memtoReg_MEMWB),
    .s0(ALUOut_MEMWB),
    .s1(readData_MEMWB),
    .out(writeData_MEMWB)
);

Forward_unit fu(
        .reset(~start),
        .regwrite_mem(regWrite_EXMEM),
        .regwrite_wb(regWrite_MEMWB),
        .rs1(inst_IDEX[19:15]),
        .rs2(inst_IDEX[24:20]),
        .rd_mem(writereg_EXMEM),
        .rd_wb(writereg_MEMWB),
        .FA(FA),
        .FB(FB)
    );
    
Hazard_Detection_Unit HDU(
        .memRead_IDEX(memWrite_IDEX),
        .rd_IDEX(writereg_IDEX),
        .rs1_IFID(inst_IFID[19:15]),
        .rs2_IFID(inst_IFID[24:20]),
        .branch(PCSrc),
        .stall(stall),
        .PCWrite(PCWrite),
        .IFIDWrite(IFIDWrite),
        .IF_Flush(IF_Flush)
    );
    
ControlReset CR(
        .stall(stall),
        .regwrite_in(regWrite),
        .memread_in(memRead),
        .memwrite_in(memWrite),
        .alusrc_in(ALUSrc),
        .branch_in(branch),
        .memtoreg_in(memtoReg),
        .aluop_in(ALUOp),
        .regwrite_out(regWrite_IFID),
        .memread_out(memRead_IFID),
        .memwrite_out(memWrite_IFID),
        .alusrc_out(ALUSrc_IFID),
        .branch_out(branch_IFID),
        .memtoreg_out(memtoReg_IFID),
        .aluop_out(ALUOp_IFID)
    );
    
    assign PCSrc = zero_IDEX&branch_IDEX;
    assign out_1 = writeData_MEMWB[3:0];
    //assign PCSrc = zero_EXMEM&branch_EXMEM;
endmodule
