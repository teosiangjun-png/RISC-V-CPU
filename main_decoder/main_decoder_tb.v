`timescale 1ns / 1ps
 
module tb_main_decoder;
 
    reg  [6:0] opcode;
    wire       reg_write, alu_b_src, alu_a_src, mem_write;
    wire [1:0] result_src, alu_op;
    wire       branch, jump, jalr;
 
    main_decoder dut (
        .opcode    (opcode),
        .reg_write (reg_write),
        .alu_b_src   (alu_b_src),
        .alu_a_src (alu_a_src),
        .mem_write (mem_write),
        .result_src(result_src),
        .branch    (branch),
        .jump      (jump),
        .jalr      (jalr),
        .alu_op    (alu_op)
    );
 
    // Packed order: {reg_write, alu_src, alu_a_src, mem_write,
    //                result_src[1:0], branch, jump, jalr, alu_op[1:0]}
    wire [10:0] actual = {reg_write, alu_b_src, alu_a_src, mem_write,
                          result_src, branch, jump, jalr, alu_op};
 
    integer errors = 0;
    integer tests  = 0;
 
    task check;
        input [6:0]  op;
        input [10:0] expected;
        input [127:0] name;   // up to 16 chars
        begin
            opcode = op;
            #1;
            tests = tests + 1;
            if (actual !== expected) begin
                errors = errors + 1;
                $display("FAIL %-8s opcode=%b", name, op);
                $display("     expected rw=%b as=%b aa=%b mw=%b rs=%b br=%b j=%b jalr=%b aop=%b",
                         expected[10], expected[9], expected[8], expected[7],
                         expected[6:5], expected[4], expected[3], expected[2], expected[1:0]);
                $display("     actual   rw=%b as=%b aa=%b mw=%b rs=%b br=%b j=%b jalr=%b aop=%b",
                         reg_write, alu_b_src, alu_a_src, mem_write,
                         result_src, branch, jump, jalr, alu_op);
            end 
            else
                $display("PASS %-8s opcode=%b", name, op);
        end
    endtask
 
    initial begin
        $dumpfile("tb_main_decoder.vcd");
        $dumpvars(0, tb_main_decoder);
 
        //     opcode       expected       name
        check(7'b0110011, 11'b10000000010, "R-type");
        check(7'b0010011, 11'b11000000010, "I-type");
        check(7'b0000011, 11'b11000100000, "LOAD");
        check(7'b0100011, 11'b01010000000, "STORE");
        check(7'b1100011, 11'b00000010001, "BRANCH");
        check(7'b1101111, 11'b10001001000, "JAL");
        check(7'b1100111, 11'b11001001100, "JALR");
        check(7'b0110111, 11'b11000000011, "LUI");
        check(7'b0010111, 11'b11100000000, "AUIPC");
 
        // Unsupported opcodes must leave everything off
        check(7'b0001111, 11'b0, "FENCE");
        check(7'b1110011, 11'b0, "ECALL");
        check(7'b0100111, 11'b0, "FP-STORE");
        check(7'b0000000, 11'b0, "ZEROS");
        check(7'b1111111, 11'b0, "ONES");
 
        $display("----------------------------------------");
        if (errors == 0)
            $display("ALL %0d TESTS PASSED", tests);
        else
            $display("%0d of %0d TESTS FAILED", errors, tests);
        $finish;
    end
 
endmodule
 