`timescale 1ns/1ps
module ALU_decoder (
    input [2:0] funct3,
    input  funct7_bit, //[30]
    input [1:0] alu_op,
    input op_5,
    output reg [2:0] C_alu
);
    localparam ALU_ADD = 3'b000;
    localparam ALU_SUB = 3'b001;
    localparam ALU_AND = 3'b010;
    localparam ALU_OR  = 3'b011;
    localparam ALU_SLT = 3'b101;

    wire is_sub = op_5 & funct7_bit;

always @(*) begin
    
    case (alu_op)
        2'b00: C_alu = ALU_ADD;
        2'b01: C_alu = ALU_SUB;
        2'b10: begin
            case (funct3)
                3'b000: C_alu = is_sub? ALU_SUB : ALU_ADD;
                3'b111 : C_alu = ALU_AND;
                3'b110 : C_alu = ALU_OR;
                3'b010 : C_alu = ALU_SLT;

                default: C_alu = ALU_ADD;
            endcase
        end 
        default: C_alu = ALU_ADD;
    endcase
end
    
endmodule