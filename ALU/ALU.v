`timescale 1ns/1ps
module alu(A,B, C_alu, out, c_out, c_in);
    input [3:0] A, B;
    input [2:0] C_alu;
    input c_in;

    output [3:0] out;
    output c_out;

    localparam OP_ADD = 3'b000; // a + b
    localparam OP_ADC = 3'b001; // a + b + c_in (Add with Carry)
    localparam OP_SUB = 3'b010; // a - b
    localparam OP_AND = 3'b011; // a & b
    localparam OP_OR  = 3'b100; // a | b
    localparam OP_XOR = 3'b101; // a ^ b
    localparam OP_SHL = 3'b110; // a << 1 (Logical Shift Left)
    localparam OP_SHR = 3'b111; // a >> 1 (Logical Shift Right)

    always @(*) begin
        c_out = 1'b0;
        out = 4'b0000;

        case (C_alu)
            OP_ADD: {c_out, out} = A + B;  //{c_out, out} --> 1bit from cout + 4 bit out -->5 bit
            OP_ADC: {c_out, out} = A + B + c_in;
            OP_SUB: {c_out, out} = A - B;
            OP_AND: out = A & B;
            OP_OR:  out = A | B;
            OP_XOR: out = A ^ B;

            OP_SHL: begin
                c_out = A[3];      // MSB shifts out into carry
                out   = A << 1;
            end

            OP_SHR: begin
                c_out = A[0];      // LSB shifts out into carry
                out   = A >> 1;
            end

            default: begin
                out   = 4'b0000;
                c_out = 1'b0;
            end
        endcase
        
    end
endmodule