`timescale 1ns / 1ps

module Hazard_Detection_Unit(
    input memRead_IDEX,         // MemRead signal from ID/EX pipeline register
    input [4:0] rd_IDEX,        // Destination register from ID/EX stage
    input [4:0] rs1_IFID,       // Source register 1 from IF/ID stage
    input [4:0] rs2_IFID,       // Source register 2 from IF/ID stage
    input branch,               // Indicates a branch instruction in IF/ID stage
    output reg stall,           // Stall signal
    output reg PCWrite,         // Control signal to enable/disable PC updates
    output reg IFIDWrite,       // Control signal to enable/disable IF/ID register updates
    output reg IF_Flush         // Flush signal to clear incorrect instructions on branch
);

    always @(*) begin
        // Default values (no stall, allow updates)
        stall = 1'b0;
        PCWrite = 1'b1;
        IFIDWrite = 1'b1;
        IF_Flush = 1'b0;

        // Load-use hazard (stall if EX stage is reading memory and next instruction needs it)
        if (memRead_IDEX && ((rd_IDEX == rs1_IFID) || (rd_IDEX == rs2_IFID))) begin
            stall = 1'b1;
            PCWrite = 1'b0;          // Stop updating PC
            IFIDWrite = 1'b0;        // Stop updating IF/ID register
        end 
        
        // Branch hazard (stall if a BEQ instruction depends on an EX stage register)
        else if (branch && ((rd_IDEX == rs1_IFID) || (rd_IDEX == rs2_IFID))) begin
            stall = 1'b1;
            PCWrite = 1'b0;          // Stop updating PC
            IFIDWrite = 1'b0;        // Stop updating IF/ID register
        end 
        
        // If a branch is taken, flush the IF/ID pipeline register
        if (branch) begin
            IF_Flush = 1'b1;
        end
    end

endmodule
