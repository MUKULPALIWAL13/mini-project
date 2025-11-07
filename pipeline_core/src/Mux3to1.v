`timescale 1ns / 1ps
module Mux3to1(
    input [1:0] sel,
    input signed [31:0] s0,
    input signed [31:0] s1,
    input signed [31:0] s2,
    output signed [31:0] out
);

    assign out = (sel == 2'b00) ? s0 :
                 (sel == 2'b01) ? s1 :
                 (sel == 2'b10) ? s2 : 32'b0; // Default case to prevent latching

endmodule
