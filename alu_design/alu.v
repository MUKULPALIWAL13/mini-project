module arithmetic_unit (
    input      [3:0]  opcode,
    input      [7:0]  a, b,
    output reg [15:0] result
);
// Opcode mapping:
// 0000 : Addition
// 0001 : Subtraction
// 0010 : Multiplication
// 0011 : Division
// 0100 : Left Shift (a << b)
// 0101 : Right Shift (a >> b)
// 0110 : AND
// 0111 : OR
// 1000 : XOR
// 1001 : XNOR
always @(*) begin
    case (opcode)
        4'b0000: result = a + b;
        4'b0001: result = a - b;
        4'b0010: result = a * b;
        4'b0011: result = (b != 0) ? a / b : 16'hXXXX;
        4'b0100: result = a << b;
        4'b0101: result = a >> b;
        4'b0110: result = a & b;
        4'b0111: result = a | b;
        4'b1000: result = a ^ b;
        4'b1001: result = ~(a ^ b);
        default: result = 16'h0000;
    endcase
end

endmodule
