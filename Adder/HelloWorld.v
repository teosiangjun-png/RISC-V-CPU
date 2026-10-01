module fulladd(sum, c_out, a, b, c_in);
    output sum, c_out;
    input a, b, c_in;
    assign sum = a^b^c_in;
    assign c_out = (a & b) | (b & c_in) | (a & c_in);
endmodule


module Adder (
    sum,
    c_out,
    a, 
    b, 
    c_in);
    output [4:0] sum;
    output c_out;
    input [4:0] a, b;
    input c_in;
    wire c1, c2, c3, c4;
    fulladd fa0(sum[0], c1, a[0], b[0], c_in);
    fulladd fa1(sum[1], c2, a[1], b[1], c1);
    fulladd fa2(sum[2], c3, a[2], b[2], c2);
    fulladd fa3(sum[3], c4, a[3], b[3], c3);
    fulladd fa4(sum[4], c_out, a[4], b[4], c4);


endmodule