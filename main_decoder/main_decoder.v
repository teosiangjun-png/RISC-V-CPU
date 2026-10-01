`timescale 1ns/1ps
module main_decoder (
    input [6:0]opcode,
    output reg reg_write,
    output reg alu_b_src,    
    output reg alu_a_src,  
    output reg mem_write,
    output reg [1:0] result_src,  
    output reg branch,
    output reg jump,
    output reg jalr,
    output reg [1:0]alu_op  
);

    localparam R_arith = 7'b0110011;
    localparam I_arith = 7'b0010011;
    localparam I_load = 7'b0000011;
    localparam S_store = 7'b0100011;
    localparam B_branch = 7'b1100011;
    localparam J_jal = 7'b1101111;  
    localparam I_jalr = 7'b1100111;
    localparam U_lui = 7'b0110111;
    localparam U_auipc = 7'b0010111;

    always @(*) begin
        
      reg_write = 1'b0;
        alu_b_src = 1'b0;
        alu_a_src = 1'b0;
        mem_write = 1'b0;
        result_src = 2'b00;
        branch = 1'b0;
        jump = 1'b0;
        jalr = 1'b0;
        alu_op = 2'b00;
        
    case (opcode)
      
        R_arith : begin
            reg_write = 1'b1;
            alu_op = 2'b10;
        end

        I_arith : begin
            reg_write = 1'b1;
            alu_b_src = 1'b1;
            alu_op = 2'b10;
        end

        I_load : begin
            reg_write = 1'b1;
            alu_b_src = 1'b1;
            result_src = 2'b01;
        end

        S_store: begin
            alu_b_src    = 1'b1;
            mem_write  = 1'b1;
            end

        B_branch: begin
            branch     = 1'b1;
            alu_op     = 2'b01;
        end

        J_jal: begin
            reg_write  = 1'b1;
            result_src = 2'b10;
                jump       = 1'b1;
        end

        I_jalr: begin
            reg_write  = 1'b1;
            alu_b_src    = 1'b1;
            result_src = 2'b10;
            jump       = 1'b1;
            jalr       = 1'b1;
        end

        U_lui: begin
            reg_write  = 1'b1;
            alu_b_src    = 1'b1;
            alu_op     = 2'b11;
        end

        U_auipc: begin
            reg_write  = 1'b1;
            alu_b_src    = 1'b1;
            alu_a_src  = 1'b1;
        end

            default: ;
        
    endcase
    end
    
endmodule