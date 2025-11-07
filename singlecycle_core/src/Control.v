module Control (
    input  [6:0] opcode,
    output reg   branch,
    output reg   memRead,
    output reg   memtoReg,
    output reg   memWrite,
    output reg   ALUSrc,
    output reg   regWrite,
    output reg [1:0] ALUOp
);

always @(*) begin
    // Default values for all control signals
    branch   = 0;
    memRead  = 0;
    memtoReg = 0;
    memWrite = 0;
    ALUSrc   = 0;
    regWrite = 0;
    ALUOp    = 2'b00;

    case (opcode)
        7'b0110011: begin  
            // Integer R-type (ADD, SUB, OR, AND, etc.)
            regWrite = 1;
            ALUOp    = 2'b10;
        end

        7'b0010011: begin  
            // Integer I-type (ADDI, ORI, SLLI, etc.)
            regWrite = 1;
            ALUSrc   = 1;
            ALUOp    = 2'b00;
        end

        7'b0000011: begin  
            // Load (LW)
            regWrite = 1;
            memRead  = 1;
            memtoReg = 1;
            ALUSrc   = 1;
            ALUOp    = 2'b00;
        end

        7'b0100011: begin  
            // Store (SW)
            memWrite = 1;
            ALUSrc   = 1;
            ALUOp    = 2'b00;
        end

        7'b1100011: begin  
            // Branch (BEQ, BNE, etc.)
            branch = 1;
            ALUOp  = 2'b01;
        end

        // --- FLOATING POINT EXTENSION (RV32F) ---
        7'b0000111: begin  
            // FLW (floating-point load)
            regWrite = 1;
            memRead  = 1;
            memtoReg = 1;
            ALUSrc   = 1;
            ALUOp    = 2'b00;
        end

        7'b0100111: begin  
            // FSW (floating-point store)
            memWrite = 1;
            ALUSrc   = 1;
            ALUOp    = 2'b00;
        end

        7'b1010011: begin  
            // Floating-point arithmetic (FADD.S, FSUB.S, FMUL.S, FDIV.S, FNEG.S, etc.)
            regWrite = 1;
            ALUOp    = 2'b11;   // Distinct ALUOp for FP unit
        end

        default: begin  
            // Safe defaults (NOP)
            branch   = 0;
            memRead  = 0;
            memtoReg = 0;
            memWrite = 0;
            ALUSrc   = 0;
            regWrite = 0;
            ALUOp    = 2'b00;
        end
    endcase
end

endmodule
