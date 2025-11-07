`timescale 1ns / 1ps

module EX_MEM_Pipeline(
    input clk,reset,
    input [31:0] pc_in, alu_in,read_data2_in,
    input [4:0] wr_in,
    input branch_in,memread_in,memreg_in,memwrite_in,regwrite_in,zero_in,
    output reg [31:0] pc_out, alu_out,read_data2_out,
    output reg [4:0] wr_out,
    output reg branch_out,memread_out,memreg_out,memwrite_out,regwrite_out,zero_out
    );
    
    always @(posedge clk or posedge reset)
    begin
        if(reset)
        begin
            pc_out<=0;
            alu_out<=0;
            read_data2_out<=0;
            wr_out<=0;
            branch_out<=0;
            memread_out<=0;
            memreg_out<=0;
            memwrite_out<=0;
            regwrite_out<=0;
            zero_out<=0;
        end
        else
        begin
            pc_out<=pc_in;
            alu_out<=alu_in;
            read_data2_out<=read_data2_in;
            wr_out<=wr_in;
            branch_out<=branch_in;
            memread_out<=memread_in;
            memreg_out<=memreg_in;
            memwrite_out<=memwrite_in;
            regwrite_out<=regwrite_in;
            zero_out<=zero_in;
        end
    end
endmodule
