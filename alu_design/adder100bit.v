module top_module( 
    input [99:0] a, b,
    input cin,
    output cout,
    output [99:0] sum );
    wire [100:0] sum1;
    assign sum = {a+b+cin};//automatically concatenate to show just 100 bit sum not cout
    assign sum1 = a+b+cin;//total sum with 101th bit as cout 
    assign cout = sum1[100];

endmodule
