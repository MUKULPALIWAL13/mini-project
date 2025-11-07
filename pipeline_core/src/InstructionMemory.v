module InstructionMemory (
    input [31:0] readAddr,
    output [31:0] inst
);
    
    reg [7:0] insts [127:0];
    
    assign inst = (readAddr >= 128) ? 32'b0 : 
                  {insts[readAddr], insts[readAddr + 1], insts[readAddr + 2], insts[readAddr + 3]};

    integer i;
    initial begin
        insts[0]  = 8'b00001010;
        insts[1]  = 8'b00110000;
        insts[2]  = 8'b00000100;
        insts[3]  = 8'b00010011;
        insts[4]  = 8'b11111111;
        insts[5]  = 8'b11000001;
        insts[6]  = 8'b00000001;
        insts[7]  = 8'b00010011;
        insts[8]  = 8'b00000000;
        insts[9]  = 8'b10000001;
        insts[10] = 8'b00100000;
        insts[11] = 8'b00100011;
        insts[12] = 8'b00000000;
        insts[13] = 8'b00000000;
        insts[14] = 8'b00000100;
        insts[15] = 8'b00110011;
        insts[16] = 8'b00000000;
        insts[17] = 8'b00000000;
        insts[18] = 8'b00000010;
        insts[19] = 8'b10010011;
        insts[20] = 8'b00000000;
        insts[21] = 8'b01110010;
        insts[22] = 8'b10100011;
        insts[23] = 8'b00010011;
        insts[24] = 8'b00000000;
        insts[25] = 8'b00000011;
        insts[26] = 8'b00000110;
        insts[27] = 8'b01100011;
        insts[28] = 8'b00000000;
        insts[29] = 8'b00010010;
        insts[30] = 8'b10000010;
        insts[31] = 8'b10010011;
        insts[32] = 8'b11111110;
        insts[33] = 8'b00000000;
        insts[34] = 8'b00001010;
        insts[35] = 8'b11100011;
        insts[36] = 8'b00000000;
        insts[37] = 8'b10100011;
        insts[38] = 8'b01100011;
        insts[39] = 8'b00010011;
        insts[40] = 8'b00000000;
        insts[41] = 8'b00000001;
        insts[42] = 8'b00100100;
        insts[43] = 8'b00000011;
        insts[44] = 8'b00000000;
        insts[45] = 8'b01000001;
        insts[46] = 8'b00000001;
        insts[47] = 8'b00010011;
        insts[48] = 8'b00000000;
        insts[49] = 8'b00000000;
        insts[50] = 8'b00000000;
        insts[51] = 8'b00000000;

        // Zero out the rest (52 to 127)
        for (i = 52; i < 128; i = i + 1) begin
            insts[i] = 8'b0;
        end
    end

endmodule
