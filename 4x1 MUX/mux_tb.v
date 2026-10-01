`timescale 1ns/1ps

module mux_tb;
    reg i0, i1, i2, i3;
    reg s0, s1;

    wire out;
    mux uut (
        .out(out),
        .i0(i0),
        .i1(i1),
        .i2(i2),
        .i3(i3),
        .s1(s1),
        .s0(s0)
    );
    initial begin
        $dumpfile("mux_tb.vcd");
        $dumpvars(0, mux_tb);

        $monitor("Time=%0t | s1 s0 = %b %b | Selected out = %b (Inputs: i0=%b, i1=%b, i2=%b, i3=%b)", 
                 $time, s1, s0, out, i0, i1, i2, i3);

        // Set fixed unique inputs: i0=0, i1=1, i2=0, i3=1
        i0 = 1'b0; i1 = 1'b1; i2 = 1'b0; i3 = 1'b1;

        // Test selection: s1 s0 = 00 -> should select i0 (0)
        s1 = 1'b0; s0 = 1'b0; #10;

        // Test selection: s1 s0 = 01 -> should select i1 (1)
        s1 = 1'b0; s0 = 1'b1; #10;

        // Test selection: s1 s0 = 10 -> should select i2 (0)
        s1 = 1'b1; s0 = 1'b0; #10;

        // Test selection: s1 s0 = 11 -> should select i3 (1)
        s1 = 1'b1; s0 = 1'b1; #10;

        // Change inputs to test dynamic switching
        i2 = 1'b1;
        s1 = 1'b1; s0 = 1'b0; #10; // should now output 1

        $finish;
    end
endmodule