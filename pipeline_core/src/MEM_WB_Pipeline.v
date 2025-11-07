`timescale 1ns / 1ps

module MEM_WB_Pipeline(
    input clk,reset,
    input [31:0] read_data_in,alu_in,
    input [4:0] wr_in,
    input reg_write_in,
    input mem_reg_in,
    output reg [31:0] read_data_out,alu_out,
    output reg [4:0] wr_out,
    output reg reg_write_out,mem_reg_out
    );
    
    always @(posedge clk or posedge reset)
    begin
        if(reset)
        begin
            read_data_out<=0;
            alu_out<=0;
            wr_out<=0;
            reg_write_out<=0;
            mem_reg_out<=0;
        end
        else
        begin
            read_data_out<=read_data_in;
            alu_out<=alu_in;
            wr_out<=wr_in;
            reg_write_out<=reg_write_in;
            mem_reg_out<=mem_reg_in;
        end
    end
    
endmodule
