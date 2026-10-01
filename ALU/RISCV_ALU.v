`timescale 1ns/1ps
module alu (
    input [31:0] a,
    input [31:0] b,
    input [3:0] c_alu,
    output reg [31:0] out,
    output zero
);
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_SLL  = 4'b0010;
    localparam ALU_SLT  = 4'b0011;
    localparam ALU_SLTU = 4'b0100;
    localparam ALU_XOR  = 4'b0101;
    localparam ALU_SRL  = 4'b0110;
    localparam ALU_SRA  = 4'b0111;
    localparam ALU_OR   = 4'b1000;
    localparam ALU_AND  = 4'b1001;

    wire[4:0] shamt = b[4:0];

    always @(*) begin
        out = 32'b00000000000000000000000000000000;
        case (c_alu)
            ALU_ADD: out = a + b;
            ALU_SUB: out = a- b;
            ALU_SLL: out = a << shamt;
            ALU_SLT: out = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            ALU_SLTU: out = (a < b) ? 32'd1 : 32'd0;
            ALU_XOR:  out = a ^ b;
            ALU_SRL:  out = a >> shamt;
            ALU_SRA:  out = $signed(a) >>> shamt;
            ALU_OR:   out = a | b;
            ALU_AND:  out = a & b;
            default:  out = 32'd0; 
        endcase 
    end

    assign zero = (out == 32'd0);
    
endmodule