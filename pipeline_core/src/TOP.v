`timescale 1ns / 1ps

module TOP(
    input reset, 
    input clk_signal,  // 50 MHz input clock
    input btn,
    output [3:0] out_1
);
    wire clk;
   // assign clk1 = clk;

    // Instantiate clock divider
    toggle_Clock ck(.reset(reset),.clk_signal(clk_signal), .clk(clk));

    // Instantiate main module with toggled clock
    CompleteCPU m1(.clk(clk) ,.start(reset),.out_1(out_1));
endmodule