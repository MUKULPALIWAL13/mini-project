module ALU (
    input [3:0] ALUCtl,
    input [31:0] A,B,
    output reg [31:0] ALUOut,
    output zero
);
    always@(*)
    begin
        case(ALUCtl)
            4'b0000: ALUOut = A+B; // ADD
            4'b1000: ALUOut = A-B; // SUB
            4'b0001: ALUOut = (B<32)?(A<<B):32'b0; // SLL
            4'b0010: ALUOut = ($signed(A) < $signed(B))?1'b1:1'b0; //SLT
            4'b0011: ALUOut = (A<B)?1'b1:1'b0; //SLTU
            4'b0100: ALUOut = A^B; // XOR
            4'b0101: ALUOut =  (B<32)?(A>>B):32'b0; //SRL
            4'b1101: ALUOut = (B<32)?($signed(A) >>> B):((A[31] == 1) ? 32'hFFFFFFFF : 32'b0); //SRA
            4'b0110: ALUOut = A|B; // OR
            4'b0111: ALUOut = A&B; // AND
            4'b1001: ALUOut = (A==B)?1'b0:1'b1; //BEQ
            4'b1010: ALUOut = (A!=B)?1'b0:1'b1; //BNE
            4'b1011: ALUOut = ($signed(A) > $signed(B))?1'b0:1'b1; //BLT
            4'b1100: ALUOut = (A>=B)?1'b0:1'b1; //BGE
            4'b1110: ALUOut = ($signed(A) > $signed(B))?1'b0:1'b1; // BGT
        endcase
    end
    assign zero = (ALUOut==0);
endmodule

