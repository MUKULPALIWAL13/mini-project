`timescale 1ns / 1ps

module ID_EX_Pipeline(
    input clk,reset,
    input [31:0]pc_in,read_data1_in,read_data2_in,imm_in,instruction_in,
    input [3:0]funct_in,
    input [4:0]wr_in,
    input [1:0]aluop_in,
    input branch_in,memread_in,memreg_in,memwrite_in,alusrc_in,regwrite_in,
    output reg [31:0]pc_out,read_data1_out,read_data2_out,imm_out,instruction_out,
    output reg [3:0]funct_out,
    output reg [4:0]wr_out,
    output reg [1:0]aluop_out,
    output reg branch_out,memread_out,memreg_out,memwrite_out,alusrc_out,regwrite_out
    );
    
    always @(posedge clk or posedge reset)
    begin
        if(reset)
        begin
            pc_out<=0;
            read_data1_out<=0;
            read_data2_out<=0;
            imm_out<=0;
            funct_out<=0;
            wr_out<=0;
            branch_out<=0;
            memread_out<=0;
            memreg_out<=0;
            memwrite_out<=0;
            alusrc_out<=0;
            aluop_out<=0;
            regwrite_out<=0;
            instruction_out<=0;
        end
        else
        begin
            pc_out<=pc_in;
            read_data1_out<=read_data1_in;
            read_data2_out<=read_data2_in;
            imm_out<=imm_in;
            funct_out<=funct_in;
            wr_out<=wr_in;
            branch_out<=branch_in;
            memread_out<=memread_in;
            memreg_out<=memreg_in;
            memwrite_out<=memwrite_in;
            alusrc_out<=alusrc_in;
            aluop_out<=aluop_in;
            regwrite_out<=regwrite_in;
            instruction_out<=instruction_in;
        end
    end
endmodule
