`timescale 1ns/1ps
module instruction_decoder(
    input [31:0] instruction,

    output [4:0]  rs1_addr,    
    output [4:0]  rs2_addr,    
    output [4:0]  rd_addr,        
    output [2:0]  funct3,      
    output [6:0]  funct7,
    output reg [31:0] imm
);
    wire [6:0]opcode = instruction[6:0];
    localparam R_arith = 7'b0110011;
    localparam I_arith = 7'b0010011;
    localparam I_load = 7'b0000011;
    localparam S_store = 7'b0100011;
    localparam B_branch = 7'b1100011;
    localparam J_jal = 7'b1101111;  
    localparam I_jalr = 7'b1100111;
    localparam U_lui = 7'b0110111;
    localparam U_auipc = 7'b0010111;
    localparam I_env = 7'b1110011;  

    assign rs1_addr = instruction[19:15];
    assign rs2_addr = instruction[24:20];
    assign rd_addr = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];

    always @(*) begin
        case (opcode)
            R_arith : begin
                imm = 32'b0;
            end

        I_arith, I_load, I_jalr, I_env : begin
            imm = {{20{instruction[31]}}, instruction[31:20]};
        end

        S_store : begin
            imm = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
        end

        B_branch : begin
            imm = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
        end
        
        U_lui, U_auipc: begin
                // U-type: upper 20 bits shifted to [31:12], low 12 bits zeroed
                imm = {instruction[31:12], 12'b0};
            end

            J_jal: begin
                // J-type: jump target offset, bit 0 is always 1'b0
                imm = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            end

            default: begin
                imm = 32'b0;
            end

        endcase
    end
endmodule