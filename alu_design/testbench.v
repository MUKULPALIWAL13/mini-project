module tb_arithmetic_unit;

    reg  [3:0] opcode;
    reg  [7:0] a, b;
    wire [15:0] result;

    arithmetic_unit uut (
        .opcode(opcode),
        .a(a),
        .b(b),
        .result(result)
    );

    initial begin
        a = 8'd15;
        b = 8'd3;

        $display("Opcode |   A   |   B   |   Result");
        $display("-------------------------------");

        opcode = 4'b0000; #10 $display(" ADD   |  %d  |  %d  |  %d", a, b, result);
        opcode = 4'b0001; #10 $display(" SUB   |  %d  |  %d  |  %d", a, b, result);
        opcode = 4'b0010; #10 $display(" MUL   |  %d  |  %d  |  %d", a, b, result);
        opcode = 4'b0011; #10 $display(" DIV   |  %d  |  %d  |  %d", a, b, result);
        opcode = 4'b0100; #10 $display(" LSH   |  %d  |  %d  |  %d", a, b, result);
        opcode = 4'b0101; #10 $display(" RSH   |  %d  |  %d  |  %d", a, b, result);
        opcode = 4'b0110; #10 $display(" AND   |  %d  |  %d  |  %d", a, b, result);
        opcode = 4'b0111; #10 $display("  OR   |  %d  |  %d  |  %d", a, b, result);
        opcode = 4'b1000; #10 $display(" XOR   |  %d  |  %d  |  %d", a, b, result);
        opcode = 4'b1001; #10 $display(" XNOR  |  %d  |  %d  |  %d", a, b, result);

        $finish;
    end

endmodule
