`timescale 1ns / 1ps

module Forward_unit(
    input reset, regwrite_mem, regwrite_wb,
    input [4:0] rs1, rs2, rd_mem, rd_wb,
    output reg [1:0] FA, FB
);
    
    always @(*) begin
        if (reset) begin  // Assuming reset is active-low
            FA = 2'b00;
            FB = 2'b00;
        end else begin
            // Forwarding for FA
            if (regwrite_mem && (rd_mem != 5'b0) && (rd_mem == rs1))
                FA = 2'b10;
            else if (regwrite_wb && (rd_wb != 5'b0) && (rd_wb == rs1))
                FA = 2'b01;
            else 
                FA = 2'b00;

            // Forwarding for FB
            if (regwrite_mem && (rd_mem != 5'b0) && (rd_mem == rs2))
                FB = 2'b10;
            else if (regwrite_wb && (rd_wb != 5'b0) && (rd_wb == rs2))
                FB = 2'b01;
            else 
                FB = 2'b00;
        end
    end

endmodule
