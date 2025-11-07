`timescale 1ns / 1ps

module ControlReset (
    input stall,  // Stall signal from Hazard Detection Unit
    input regwrite_in, memread_in, memwrite_in, alusrc_in, branch_in,memtoreg_in,
    input [1:0] aluop_in,
    output reg regwrite_out, memread_out, memwrite_out, alusrc_out, branch_out,memtoreg_out,
    output reg [1:0] aluop_out
);

always @(*) begin
    if (stall) begin
        // Set all control signals to NOP (no operation)
        regwrite_out = 0;
        memread_out = 0;
        memwrite_out = 0;
        alusrc_out = 0;
        branch_out = 0;
        memtoreg_out = 0;
        aluop_out = 2'b00;  // Default ALU operation (no computation)
    end else begin
        // Pass original control signals when not stalled
        regwrite_out = regwrite_in;
        memread_out = memread_in;
        memwrite_out = memwrite_in;
        alusrc_out = alusrc_in;
        branch_out = branch_in;
        memtoreg_out = memtoreg_in;
        aluop_out = aluop_in;
    end
end

endmodule
