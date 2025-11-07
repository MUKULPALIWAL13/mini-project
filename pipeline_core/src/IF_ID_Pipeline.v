`timescale 1ns / 1ps

module IF_ID_Pipeline(
    input clk,reset,
    input IF_IDWrite,
    input IF_Flush,
    input [31:0] pc_in,instruction_in,
    output reg [31:0] pc_out,instruction_out
    );
    
    always @(posedge clk or posedge reset)
    begin
        if(reset || IF_Flush)
        begin
            pc_out<=0;
            instruction_out<=0;
        end
        else
        begin if(IF_IDWrite)
            pc_out<=pc_in;
            instruction_out<=instruction_in;
        end
    end
endmodule
