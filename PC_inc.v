`timescale 1ns / 1ps
module PC_inc(
    input [31:0] fromPC,
    output [31:0] toPC
);
assign toPC = fromPC + 4;
endmodule
