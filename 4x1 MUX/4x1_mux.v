module mux(out, i0, i1, i2, i3, s1, s0);
    output out;
    input i0, i1, i2, i3, s0, s1;
    wire y0, y1, y2, y3;
    wire s1n, s0n;
    assign out = y0|y1|y2|y3;
    assign y0= i0 & s1n & s0n;
    assign y1= i1 & s1n & s0;
    assign y2= i2 & s1 & s0n;
    assign y3= i3 & s1 & s0;
    assign s1n= ~s1;
    assign s0n= ~s0;
endmodule

