module ALUCtrl (
    input  [1:0] ALUOp,       // From main Control
    input  [6:0] funct7,      // Full funct7 from instruction
    input  [2:0] funct3,      // funct3 from instruction
    output reg [4:0] ALUCtl   // Expanded width for more ops
);

always @(*) begin
    case (ALUOp)
        // --------------------------------------------------
        // 00: Load, Store, Immediate-type (ADDI, etc.)
        // --------------------------------------------------
        2'b00: begin
            case (funct3)
                3'b000: ALUCtl = 5'b00000; // ADD
                3'b010: ALUCtl = 5'b00001; // SLTI
                default: ALUCtl = 5'b11111; // NOP
            endcase
        end

        // --------------------------------------------------
        // 01: Branches (BEQ, BNE)
        // --------------------------------------------------
        2'b01: ALUCtl = 5'b01010; // Branch comparison

        // --------------------------------------------------
        // 10: Integer R-type (ADD, SUB, OR, SLL, AND, etc.)
        // --------------------------------------------------
        2'b10: begin
            case (funct3)
                3'b000: ALUCtl = (funct7[5]) ? 5'b00010 : 5'b00000; // SUB or ADD
                3'b001: ALUCtl = 5'b00101; // SLL
                3'b010: ALUCtl = 5'b01000; // SLT
                3'b011: ALUCtl = 5'b01001; // SLTU
                3'b100: ALUCtl = 5'b00100; // XOR
                3'b101: ALUCtl = (funct7[5]) ? 5'b00111 : 5'b00110; // SRA or SRL
                3'b110: ALUCtl = 5'b00011; // OR
                3'b111: ALUCtl = 5'b00001; // AND
                default: ALUCtl = 5'b11111; // NOP
            endcase
        end

        // --------------------------------------------------
        // 11: Floating-Point Arithmetic (RV32F)
        // --------------------------------------------------
        2'b11: begin
            /*
             funct7 field encodes FP operation in RV32F:
             0000000 -> FADD.S
             0000100 -> FSUB.S
             0001000 -> FMUL.S
             0001100 -> FDIV.S
             0101100 -> FSQRT.S
             0010000 -> FSGNJ.S/FSGNJN.S/FSGNJX.S (funct3 selects variant)
            */
            case (funct7)
                7'b0000000: ALUCtl = 5'b10000; // FADD.S
                7'b0000100: ALUCtl = 5'b10001; // FSUB.S
                7'b0001000: ALUCtl = 5'b10010; // FMUL.S
                7'b0001100: ALUCtl = 5'b10011; // FDIV.S
                7'b0101100: ALUCtl = 5'b10100; // FSQRT.S
                7'b0010000: begin
                    case (funct3)
                        3'b000: ALUCtl = 5'b10101; // FSGNJ.S
                        3'b001: ALUCtl = 5'b10110; // FSGNJN.S
                        3'b010: ALUCtl = 5'b10111; // FSGNJX.S
                        default: ALUCtl = 5'b11111;
                    endcase
                end
                default: ALUCtl = 5'b11111; // Default (NOP)
            endcase
        end

        // --------------------------------------------------
        // Default (Unknown opcode)
        // --------------------------------------------------
        default: ALUCtl = 5'b11111;
    endcase
end

endmodule
