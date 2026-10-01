`timescale 1ns/1ps

module riscv_alu_tb;

    reg [31:0] a, b;
    reg [3:0] c_alu;
    wire [31:0] out;
    wire zero;

    integer errors = 0;

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

    alu uut(
        .a(a),
        .b(b),
        .c_alu(c_alu),
        .out(out),
        .zero(zero));

        
        task check_result;
            input [31:0] expected_out;
            input        expected_zero;
            input [63:0] test_name;
            begin
                #1;
                if ((out === expected_out) && (zero === expected_zero)) begin
                    $display("[PASS] %0s | out: %h, zero: %b", test_name, out, zero);
                end else begin
                    $display("[FAIL] %0s | Expected: out = %h, zero = %b | Got: out = %h, zero = %b", 
                        test_name, expected_out, expected_zero, out, zero);
                errors = errors + 1;
                end
            end
        endtask

            initial begin
        $display("-------------------------------------------");
        $display("Starting RISC-V RV32I ALU Testbench...");
        $display("-------------------------------------------");

        // Test 1: ADD (Normal)
        a = 32'd25; b = 32'd17; c_alu = ALU_ADD;
        check_result(32'd42, 1'b0, "ADD Norm");

        // Test 2: ADD (Overflow wrap-around to 0 -> tests zero flag)
        a = 32'hFFFF_FFFF; b = 32'd1; c_alu = ALU_ADD;
        check_result(32'h0000_0000, 1'b1, "ADD Wrap");

        // Test 3: SUB (Normal)
        a = 32'd50; b = 32'd20; c_alu = ALU_SUB;
        check_result(32'd30, 1'b0, "SUB Norm");

        // Test 4: SUB (Equal values -> zero flag active for BEQ)
        a = 32'hA5A5_1234; b = 32'hA5A5_1234; c_alu = ALU_SUB;
        check_result(32'h0000_0000, 1'b1, "SUB Zero");

        // Test 5: SLL (Shift Left Logical)
        a = 32'h0000_000F; b = 32'd4; c_alu = ALU_SLL;
        check_result(32'h0000_00F0, 1'b0, "SLL by 4");

        // Test 6: SLT (Signed comparison: -5 < 3 should be 1)
        a = -32'd5; b = 32'd3; c_alu = ALU_SLT;
        check_result(32'd1, 1'b0, "SLT Neg ");

        // Test 7: SLTU (Unsigned comparison: 0xFFFFFFFB < 3 should be 0)
        a = 32'hFFFF_FFFB; b = 32'd3; c_alu = ALU_SLTU;
        check_result(32'd0, 1'b1, "SLTU Big");

        // Test 8: XOR
        a = 32'hAAAA_5555; b = 32'hFFFF_FFFF; c_alu = ALU_XOR;
        check_result(32'h5555_AAAA, 1'b0, "XOR Test");

        // Test 9: SRL (Shift Right Logical: inserts 0s at MSB)
        a = 32'h8000_0000; b = 32'd2; c_alu = ALU_SRL;
        check_result(32'h2000_0000, 1'b0, "SRL Test");

        // Test 10: SRA (Shift Right Arithmetic: preserves sign bit)
        a = 32'h8000_0000; b = 32'd2; c_alu = ALU_SRA;
        check_result(32'hE000_0000, 1'b0, "SRA Test");

        // Test 11: OR
        a = 32'hF0F0_0000; b = 32'h0000_0F0F; c_alu = ALU_OR;
        check_result(32'hF0F0_0F0F, 1'b0, "OR  Test");

        // Test 12: AND
        a = 32'hFFFF_0000; b = 32'h00FF_FF00; c_alu = ALU_AND;
        check_result(32'h00FF_0000, 1'b0, "AND Test");

        // Summary
        $display("-------------------------------------------");
        if (errors == 0) begin
            $display("ALL TESTS PASSED SUCCESSFULLY! (0 errors)");
        end else begin
            $display("TESTBENCH FINISHED WITH %0d ERRORS!", errors);
        end
        $display("-------------------------------------------");
        $finish;
    end

endmodule