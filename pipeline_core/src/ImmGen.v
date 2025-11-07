module ImmGen#(parameter Width = 32) (
    input [Width-1:0] inst,
    output reg signed [Width-1:0] imm
);
    // ImmGen generate imm value based on opcode

    wire [6:0] opcode = inst[6:0];
    always @(*) 
    begin
    case(opcode)
        7'b1100011: imm = {{(Width-13){inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0}; // B
        7'b0000011: imm = {{(Width-12){inst[31]}},inst[31:20]}; // lw
        7'b0100011: imm = {{(Width-12){inst[31]}}, inst[31:25], inst[11:7]}; // sw
        7'b0010011: imm = {{(Width-12){inst[31]}},inst[31:20]}; // I-type
        7'b1101111: imm = {{(Width-20){inst[31]}},inst[31],inst[19:12],inst[20],inst[30:21],1'b0}; // J
        default: imm = {(Width-1){1'b0}};
	endcase
    end
            
endmodule
