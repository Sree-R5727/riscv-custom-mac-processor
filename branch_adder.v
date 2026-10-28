`timescale 1ns / 1ps
module branch_adder(
    // IMPORTANT: per the RISC-V spec, branch and JAL target addresses are
    // computed as (current instruction's PC) + immediate - NOT (PC+4) + immediate.
    // Wire this to the current PC, never to PCPlus4.
    input [31:0] pc_addr, ImmAddr,
    output [31:0] mux_in_addr
);
assign mux_in_addr = pc_addr + ImmAddr;
endmodule
