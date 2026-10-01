`timescale 1ns/1ps

module instruction_decoder_tb;

    reg  [31:0] instruction;
    wire [4:0]  rs1_addr, rs2_addr, rd_addr;
    wire [2:0]  funct3;
    wire [6:0]  funct7;
    wire [31:0] imm;

    integer errors = 0;
    integer tests  = 0;

    instruction_decoder dut (
        .instruction(instruction),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),
        .funct3(funct3),
        .funct7(funct7),
        .imm(imm)
    );

    // ------------------------------------------------------------------
    // Reference model: built bit-by-bit straight from the spec's imm[x]
    // labels, deliberately written differently from the DUT's concatenations.
    // ------------------------------------------------------------------
    function [31:0] ref_imm;
        input [31:0] i;
        reg [31:0] e;
        begin
            e = 32'b0;
            case (i[6:0])
                7'b0010011, 7'b0000011, 7'b1100111, 7'b1110011: begin // I
                    e[11:0]  = i[31:20];
                    e[31:12] = {20{i[31]}};
                end
                7'b0100011: begin                                     // S
                    e[11:5]  = i[31:25];
                    e[4:0]   = i[11:7];
                    e[31:12] = {20{i[31]}};
                end
                7'b1100011: begin                                     // B
                    e[12]    = i[31];
                    e[10:5]  = i[30:25];
                    e[4:1]   = i[11:8];
                    e[11]    = i[7];
                    e[31:13] = {19{i[31]}};
                end
                7'b0110111, 7'b0010111: begin                         // U
                    e[31:12] = i[31:12];
                end
                7'b1101111: begin                                     // J
                    e[20]    = i[31];
                    e[10:1]  = i[30:21];
                    e[11]    = i[20];
                    e[19:12] = i[19:12];
                    e[31:21] = {11{i[31]}};
                end
                default: e = 32'b0;   // R-type and unknown opcodes
            endcase
            ref_imm = e;
        end
    endfunction

    // ------------------------------------------------------------------
    // Tasks
    // ------------------------------------------------------------------
    task check_imm;
        input [255:0] name;
        input [31:0]  instr;
        input [31:0]  exp_imm;
        begin
            instruction = instr;
            #1;
            tests = tests + 1;
            if (imm !== exp_imm) begin
                errors = errors + 1;
                $display("FAIL %0s: instr=%h imm=%h expected=%h", name, instr, imm, exp_imm);
            end 
            else
                $display("PASS %0s: instr=%h imm=%h", name, instr, imm);
            end
    endtask

    task check_fields;
        input [255:0] name;
        input [31:0]  instr;
        input [4:0]   e_rs1;
        input [4:0]   e_rs2;
        input [4:0]   e_rd;
        input [2:0]   e_f3;
        input [6:0]   e_f7;
        begin
            instruction = instr;
            #1;
            tests = tests + 1;
            if (rs1_addr !== e_rs1 || rs2_addr !== e_rs2 || rd_addr !== e_rd ||
                funct3 !== e_f3 || funct7 !== e_f7) begin
                errors = errors + 1;
                $display("FAIL %0s fields: rs1=%0d rs2=%0d rd=%0d f3=%b f7=%b",
                         name, rs1_addr, rs2_addr, rd_addr, funct3, funct7);
            end 
            else
                $display("PASS %0s fields", name);
        end
    endtask

    // Compare DUT against the reference for the current instruction
    task check_ref;
        input [31:0] instr;
        begin
            instruction = instr;
            #1;
            tests = tests + 1;
            if (imm !== ref_imm(instr)) begin
                errors = errors + 1;
                $display("FAIL ref: instr=%h imm=%h expected=%h", instr, imm, ref_imm(instr));
            end
        end
    endtask

    // For one opcode: walk a single 1 through bits 31:7, then a single 0,
    // then random fill. Any wrongly routed bit shows up on its own.
    task sweep;
        input [6:0] op;
        integer b, k;
        reg [31:0] mask;
        begin
            mask = 32'hFFFFFF80;                       // bits 31:7
            check_ref({25'b0, op});                    // all zero fields
            check_ref({25'h1FFFFFF, op});              // all one fields
            for (b = 7; b < 32; b = b + 1) begin
                check_ref(({25'b0, op}) | (32'b1 << b));               // walking 1
                check_ref((~(32'b1 << b) & mask) | {25'b0, op});       // walking 0
            end
            for (k = 0; k < 200; k = k + 1)
                check_ref(($random & mask) | {25'b0, op});
        end
    endtask

    // ------------------------------------------------------------------
    // Test sequence
    // ------------------------------------------------------------------
    initial begin
        $display("---- Directed immediate tests (hand-assembled) ----");

        // I-type
        check_imm("addi x2,x0,5",       32'h00500113, 32'h00000005);
        check_imm("addi x1,x1,-1",      32'hFFF08093, 32'hFFFFFFFF);
        check_imm("addi x1,x0,2047",    32'h7FF00093, 32'h000007FF);
        check_imm("addi x1,x0,-2048",   32'h80000093, 32'hFFFFF800);
        check_imm("lw x5,8(x2)",        32'h00812283, 32'h00000008);
        check_imm("jalr x0,0(x1)",      32'h00008067, 32'h00000000);
        check_imm("ecall",              32'h00000073, 32'h00000000);
        // srai: imm field is 0x403 (funct7 bits + shamt); ALU must use only [4:0]
        check_imm("srai x1,x1,3",       32'h4030D093, 32'h00000403);

        // S-type
        check_imm("sw x5,8(x2)",        32'h00512423, 32'h00000008);
        check_imm("sw x5,-4(x2)",       32'hFE512E23, 32'hFFFFFFFC);

        // B-type
        check_imm("beq x1,x2,+16",      32'h00208863, 32'h00000010);
        check_imm("beq x1,x2,-8",       32'hFE208CE3, 32'hFFFFFFF8);

        // U-type
        check_imm("lui x3,0x12345",     32'h123451B7, 32'h12345000);
        check_imm("lui x3,0xFFFFF",     32'hFFFFF1B7, 32'hFFFFF000);
        check_imm("auipc x4,1",         32'h00001217, 32'h00001000);

        // J-type
        check_imm("jal x1,+16",         32'h010000EF, 32'h00000010);
        check_imm("jal x0,-4",          32'hFFDFF06F, 32'hFFFFFFFC);

        // R-type has no immediate
        check_imm("add x3,x1,x2",       32'h002081B3, 32'h00000000);

        // Unknown opcode falls through to default
        check_imm("unknown opcode",     32'hFFFFFFFF, 32'h00000000);

        $display("---- Field tests ----");
        // Only fields that exist in the format are meaningful. For lw, rs2_addr
        // is really imm[4:0]; for sw, rd_addr is really imm[4:0]. The decoder
        // extracts them blindly, so those values are checked here as such.
        //                                             rs1   rs2   rd    f3      f7
        check_fields("add x3,x1,x2",  32'h002081B3, 5'd1, 5'd2, 5'd3,  3'b000, 7'b0000000);
        check_fields("sub x3,x1,x2",  32'h402081B3, 5'd1, 5'd2, 5'd3,  3'b000, 7'b0100000);
        check_fields("lw x5,8(x2)",   32'h00812283, 5'd2, 5'd8, 5'd5,  3'b010, 7'b0000000);
        check_fields("sw x5,-4(x2)",  32'hFE512E23, 5'd2, 5'd5, 5'd28, 3'b010, 7'b1111111);

        $display("---- Bit-sweep tests against reference model ----");
        sweep(7'b0110011);  // R
        sweep(7'b0010011);  // I arith
        sweep(7'b0000011);  // load
        sweep(7'b1100111);  // jalr
        sweep(7'b1110011);  // system
        sweep(7'b0100011);  // S
        sweep(7'b1100011);  // B
        sweep(7'b0110111);  // lui
        sweep(7'b0010111);  // auipc
        sweep(7'b1101111);  // J
        sweep(7'b1111111);  // unknown
        sweep(7'b0001111);  // fence (not handled, falls to default)

        $display("----");
        if (errors == 0)
            $display("ALL %0d TESTS PASSED", tests);
        else
            $display("%0d of %0d TESTS FAILED", errors, tests);
        $finish;
    end

endmodule