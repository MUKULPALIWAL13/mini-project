`timescale 1ns / 1ps
`include "fp.v"   // includes fp_unit, fpadd, multiplier modules

module ALU (
    input  [4:0]  ALUCtl,     // Control signal from ALUCtrl
    input  [31:0] A, B,       // Operands (can be int or float)
    input         clk,
    input         rst,
    output reg [31:0] ALUOut, // Result
    output        zero,       // Zero or comparison result
    output        overflow,   // Overflow flag (for FP or INT)
    output        underflow,  // Underflow flag (for FP)
    output        exception   // FP exception flag
);

    // --------------------------------------------------------
    // Floating-point unit connection
    // --------------------------------------------------------
    reg  [1:0] fp_op;           // 00 = ADD, 01 = SUB, 10 = MUL, 11 = DIV/FNEG
    reg        fp_i_vld;        // Operation valid flag
    wire [31:0] fp_res;
    wire        fp_res_vld;
    wire        fp_exception;
    wire        fp_overflow;
    wire        fp_underflow;

    fp_unit fpu (
        .clk(clk),
        .rst(rst),
        .op(fp_op),
        .i_vld(fp_i_vld),
        .i_a(A),
        .i_b(B),
        .o_res(fp_res),
        .o_res_vld(fp_res_vld),
        .exception(fp_exception),
        .overflow(fp_overflow),
        .underflow(fp_underflow)
    );

    // --------------------------------------------------------
    // Integer operations
    // --------------------------------------------------------
    wire [31:0] add_res  = A + B;
    wire [31:0] sub_res  = A - B;
    wire [31:0] and_res  = A & B;
    wire [31:0] or_res   = A | B;
    wire [31:0] xor_res  = A ^ B;
    wire [31:0] sll_res  = A << B[4:0];
    wire [31:0] srl_res  = A >> B[4:0];
    wire [31:0] sra_res  = $signed(A) >>> B[4:0];
    wire [31:0] slt_res  = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
    wire [31:0] sltu_res = (A < B) ? 32'd1 : 32'd0;

    // --------------------------------------------------------
    // Control mapping
    // --------------------------------------------------------
    always @(*) begin
        // Default
        fp_op     = 2'b00;
        fp_i_vld  = 1'b0;
        ALUOut    = 32'b0;

        case (ALUCtl)
            5'b00000: ALUOut = add_res;  // ADD
            5'b00010: ALUOut = sub_res;  // SUB
            5'b00001: ALUOut = and_res;  // AND
            5'b00011: ALUOut = or_res;   // OR
            5'b00100: ALUOut = xor_res;  // XOR
            5'b00101: ALUOut = sll_res;  // SLL
            5'b00110: ALUOut = srl_res;  // SRL
            5'b00111: ALUOut = sra_res;  // SRA
            5'b01000: ALUOut = slt_res;  // SLT
            5'b01001: ALUOut = sltu_res; // SLTU
            5'b01010: ALUOut = sub_res;  // For BEQ, BNE comparisons

            // ------------------------------------------------
            // Floating-point operations (from fp_unit)
            // ------------------------------------------------
            5'b10000: begin  // FADD.S
                fp_op    = 2'b00;
                fp_i_vld = 1'b1;
                ALUOut   = fp_res;
            end

            5'b10001: begin  // FSUB.S
                fp_op    = 2'b01;
                fp_i_vld = 1'b1;
                ALUOut   = fp_res;
            end

            5'b10010: begin  // FMUL.S
                fp_op    = 2'b10;
                fp_i_vld = 1'b1;
                ALUOut   = fp_res;
            end

            5'b10011: begin  // FDIV.S (not implemented yet, future)
                fp_op    = 2'b11;
                fp_i_vld = 1'b1;
                ALUOut   = 32'h7FC00000; // Return NaN placeholder for now
            end

            5'b10100: begin  // FNEG.S
                fp_op    = 2'b01; // Reuse subtraction logic by flipping sign
                fp_i_vld = 1'b1;
                ALUOut   = {~A[31], A[30:0]}; // Negate sign bit
            end

            default: ALUOut = 32'b0;
        endcase
    end

    // --------------------------------------------------------
    // Status Flags
    // --------------------------------------------------------
    assign zero      = (ALUOut == 32'b0);
    assign overflow  = fp_overflow;
    assign underflow = fp_underflow;
    assign exception = fp_exception;

endmodule
