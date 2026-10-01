module tb_Adder;
    reg [4:0] a, b;
    reg       c_in;
    wire [4:0] sum;
    wire      c_out;

    Adder uut(
        .sum(sum), .c_out(c_out),
        .a(a), .b(b), .c_in(c_in));
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_Adder);
        $monitor("Time=%0t | %d +%d +%b =%d (c_out=%b)", $time, a, b, c_in, sum, c_out);
        a = 4'd3; b = 4'd5; c_in = 1'b0; #10;
        a = 4'd12; b = 4'd9; c_in = 1'b0; #10;
        $finish;
    end
endmodule
