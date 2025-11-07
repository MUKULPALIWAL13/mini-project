`timescale 1ns / 1ps
module fp_unit(
    input           clk,
    input           rst,
    input  [1:0]    op,
    input           i_vld,
    input  [31:0]   i_a,
    input  [31:0]   i_b,
    output reg [31:0] o_res,
    output reg        o_res_vld,
    output            exception,
    output            overflow,
    output            underflow
);

    wire [31:0] add_res;
    wire [31:0] add_binput;
    wire        add_overflow;

    wire [31:0] mul_res;
    wire        mul_overflow;
    wire        mul_underflow;
    wire        mul_exception;
    wire        mul_res_vld;

    assign add_binput = (op == 2'b01) ? {~i_b[31], i_b[30:0]} : i_b;

    fpadd fpadd_u (
        .clk(clk),
        .rst(rst),
        .i_a(i_a),
        .i_b(add_binput),
        .o_res(add_res),
        .overflow(add_overflow)
    );

    multiplier mul_u(
        .clk(clk),
        .rst(rst),
        .i_a(i_a),
        .i_b(i_b),
        .i_vld(i_vld),
        .exception(mul_exception),
        .overflow(mul_overflow),
        .underflow(mul_underflow),
        .o_res(mul_res),
        .o_res_vld(mul_res_vld)
    );

    assign exception = (op == 2'b10) ? mul_exception : 1'b0;
    assign overflow = (op == 2'b10) ? mul_overflow : (op == 2'b00 || op == 2'b01) ? add_overflow : 1'b0;
    assign underflow = (op == 2'b10) ? mul_underflow : 1'b0;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            o_res <= 32'b0;
            o_res_vld <= 1'b0;
        end else begin
            case (op)
                2'b00: begin
                    o_res <= add_res;
                    o_res_vld <= i_vld;
                end
                2'b01: begin
                    o_res <= add_res;
                    o_res_vld <= i_vld;
                end
                2'b10: begin
                    o_res <= mul_res;
                    o_res_vld <= mul_res_vld;
                end
                default: begin
                    o_res <= i_a;
                    o_res_vld <= i_vld;
                end
            endcase
        end
    end

endmodule


module fpadd(
    input clk, 
    input rst,
    input [31:0] i_a, 
    input [31:0] i_b,
    output reg [31:0] o_res,
    output reg overflow
);
    // Extract components (FP32: 1 sign, 8 exponent, 23 mantissa)
    wire sign_a = i_a[31];
    wire sign_b = i_b[31];
    wire [7:0] exp_a = i_a[30:23];
    wire [7:0] exp_b = i_b[30:23];
    wire [22:0] frac_a = i_a[22:0];
    wire [22:0] frac_b = i_b[22:0];
    
    // Special case detection
    wire is_zero_a = (exp_a == 8'b0) && (frac_a == 23'b0);
    wire is_zero_b = (exp_b == 8'b0) && (frac_b == 23'b0);
    wire is_inf_a = (exp_a == 8'b11111111) && (frac_a == 23'b0);
    wire is_inf_b = (exp_b == 8'b11111111) && (frac_b == 23'b0);
    wire is_nan_a = (exp_a == 8'b11111111) && (frac_a != 23'b0);
    wire is_nan_b = (exp_b == 8'b11111111) && (frac_b != 23'b0);
    
    // Mantissas with implicit leading 1
    wire [23:0] mant_a = (exp_a == 8'b0) ? {1'b0, frac_a} : {1'b1, frac_a};
    wire [23:0] mant_b = (exp_b == 8'b0) ? {1'b0, frac_b} : {1'b1, frac_b};
    
    // Determine larger operand
    wire a_larger = (exp_a > exp_b) || ((exp_a == exp_b) && (mant_a >= mant_b));
    
    // Swap if needed so A is always larger or equal
    wire [7:0] exp_large = a_larger ? exp_a : exp_b;
    wire [7:0] exp_small = a_larger ? exp_b : exp_a;
    wire [23:0] mant_large = a_larger ? mant_a : mant_b;
    wire [23:0] mant_small = a_larger ? mant_b : mant_a;
    wire sign_large = a_larger ? sign_a : sign_b;
    wire sign_small = a_larger ? sign_b : sign_a;
    
    // Alignment
    wire [7:0] exp_diff = exp_large - exp_small;
    wire [23:0] mant_aligned = (exp_diff >= 8'd24) ? 24'b0 : (mant_small >> exp_diff);
    
    // Determine operation: same sign = add, different sign = subtract
    wire same_sign = (sign_large == sign_small);
    
    // Perform addition or subtraction
    wire [24:0] mant_sum = same_sign ? 
                          ({1'b0, mant_large} + {1'b0, mant_aligned}) :
                          ({1'b0, mant_large} - {1'b0, mant_aligned});
    
    // Normalization
    reg [7:0] result_exp;
    reg [23:0] result_mant;
    reg result_sign;
    reg result_overflow;
    
    integer i;
    reg [7:0] leading_zeros;
    
    always @(*) begin
        result_sign = sign_large;
        result_overflow = 1'b0;
        
        if (same_sign) begin
            // Addition - check for carry out
            if (mant_sum[24]) begin
                // Overflow into bit 24, need to shift right
                result_mant = mant_sum[24:1];
                result_exp = exp_large + 1;
                if (exp_large == 8'b11111110) begin
                    // Overflow to infinity
                    result_exp = 8'b11111111;
                    result_mant = 24'b0;
                    result_overflow = 1'b1;
                end
            end else begin
                // No carry, result fits
                result_mant = mant_sum[23:0];
                result_exp = exp_large;
            end
        end else begin
            // Subtraction - need to normalize by shifting left
            if (mant_sum == 25'b0) begin
                // Result is zero
                result_exp = 8'b0;
                result_mant = 24'b0;
                result_sign = 1'b0;
            end else begin
                // Find leading one
                leading_zeros = 8'd0;
                for (i = 23; i >= 0; i = i - 1) begin
                    if (mant_sum[i] && leading_zeros == 8'd0) begin
                        leading_zeros = 23 - i;
                    end
                end
                
                if (leading_zeros >= exp_large) begin
                    // Result is subnormal or zero
                    result_exp = 8'b0;
                    result_mant = mant_sum[23:0] << (exp_large - 1);
                end else begin
                    result_exp = exp_large - leading_zeros;
                    result_mant = mant_sum[23:0] << leading_zeros;
                end
            end
        end
    end
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            o_res <= 32'b0;
            overflow <= 1'b0;
        end else begin
            // Handle special cases
            if (is_nan_a || is_nan_b) begin
                // NaN propagation
                o_res <= 32'b01111111110000000000000000000000; // NaN
                overflow <= 1'b0;
            end else if (is_inf_a && is_inf_b && (sign_a != sign_b)) begin
                // Inf - Inf = NaN
                o_res <= 32'b01111111110000000000000000000000; // NaN
                overflow <= 1'b0;
            end else if (is_inf_a) begin
                // A is infinity
                o_res <= i_a;
                overflow <= 1'b1;
            end else if (is_inf_b) begin
                // B is infinity
                o_res <= i_b;
                overflow <= 1'b1;
            end else if (is_zero_a) begin
                // A is zero
                o_res <= i_b;
                overflow <= 1'b0;
            end else if (is_zero_b) begin
                // B is zero
                o_res <= i_a;
                overflow <= 1'b0;
            end else begin
                // Normal case
                o_res <= {result_sign, result_exp, result_mant[22:0]};
                overflow <= result_overflow;
            end
        end
    end
endmodule


module multiplier(
    input clk,
    input rst,
    input [31:0] i_a,
    input [31:0] i_b,
    input i_vld,
    output exception,
    output overflow,
    output underflow,
    output reg [31:0] o_res,
    output reg o_res_vld
);
    wire sign,round,normalised,zero;
    wire [8:0] exponent,sum_exponent;
    wire [22:0] product_mantissa;
    wire [23:0] op_a,op_b;
    wire [47:0] product,product_normalised,res;
    wire [31:0] a,b;
    
    assign zero = !(|i_a[30:0] && |i_b[30:0]);
    
    always @(posedge clk) begin
        if(rst) begin
            o_res <= 32'd0;
            o_res_vld <= 1'b0;
        end else begin
            o_res <= res[31:0];
            o_res_vld <= i_vld;
        end
    end
    
    assign a = i_a;
    assign b = i_b;
    assign sign = a[31] ^ b[31];
    assign exception = (&a[30:23]) | (&b[30:23]);
    assign op_a = (|(a[30:23]) ? {1'b1,a[22:0]} : {1'b0,a[22:0]});
    assign op_b = (|(b[30:23]) ? {1'b1,b[22:0]} : {1'b0,b[22:0]});
    assign product = op_a * op_b;
    assign round = |product_normalised[22:0]; 
    assign normalised = product[47] ? 1'b1 : 1'b0;
    assign product_normalised = normalised ? product : product << 1;
    assign product_mantissa = product_normalised[46:24] + ((&product_normalised[46:24]) ? 1'b0 : (product_normalised[23] & round)); 
    assign sum_exponent = a[30:23] + b[30:23];
    assign exponent = sum_exponent - 9'd127 + normalised;
    assign overflow = ((exponent[8] & !exponent[7]));
    assign underflow = ((exponent[8] & exponent[7]));
    assign res = (zero ? ({sign,31'd0}) : overflow ? ({sign,8'b11111111,23'b0}) : underflow ? ({sign,31'b0}) : exception ? 32'b0 : {sign,exponent[7:0],product_mantissa});
endmodule