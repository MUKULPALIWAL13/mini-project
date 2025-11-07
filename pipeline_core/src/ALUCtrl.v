    module ALUCtrl (
    input [1:0] ALUOp,
    input funct7,
    input [2:0] funct3,
    output reg [3:0] ALUCtl
);

    always@(*)
    begin
        case(ALUOp)
            2'b00: ALUCtl = 4'b0000; // lw,sw
            2'b01:begin //B
                    case(funct3)
                       3'b000: ALUCtl = 4'b1001; //beq
                       3'b001: ALUCtl = 4'b1010; //bne
                       3'b100: ALUCtl = 4'b1011; //blt
                       3'b101: ALUCtl = 4'b1100; //bge
                       3'b010: ALUCtl = 4'b1110; //bgt
                    endcase
                  end
            2'b10: ALUCtl = {funct7,funct3}; // R
            2'b11: ALUCtl = {1'b0,funct3}; // I
        endcase
    end

endmodule

