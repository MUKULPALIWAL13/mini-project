module top_module( 
    input [2:0] a, b,
    input cin,
    output [2:0] cout,
    output [2:0] sum );
    wire g0;
    wire g1;
    wire g2;
    wire p0;
    wire p1;
    wire p2;
    assign g0 = a[0]*b[0];
    assign g1 = a[1]*b[1];
    assign g2 = a[2]*b[2];
    assign p0 = a[0]^b[0];
    assign p1 = a[1]^b[1];
    assign p2 = a[2]^b[2];
    assign sum[0] = p0^cin;
    assign cout[0] = p0*cin + g0;
    assign sum[1] = p1^(p0*cin + g0);
    assign cout[1] = p1*(p0*cin + g0) + g1 ;
    assign sum[2] = p2^(p1*(p0*cin + g0) + g1);
    assign cout[2] = p2*(p1*(p0*cin + g0) + g1) + g2;
endmodule
