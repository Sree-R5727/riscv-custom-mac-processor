`timescale 1ns / 1ps
module mux(
    input [31:0] A, B,
    input sel,
    output [31:0] mux_out
);
assign mux_out = (sel == 1'b0) ? A : B;
endmodule
