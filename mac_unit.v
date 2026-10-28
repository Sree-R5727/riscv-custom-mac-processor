`timescale 1ns / 1ps
module mac_unit (
    input  wire        clk,
    input  wire        reset,
    input  wire        enable,
    input  wire        clear_acc,
    input  wire [31:0] A,
    input  wire [31:0] B,
    output wire [31:0] result,
    output wire [31:0] acc_low,
    output wire [31:0] acc_high
);
    reg  [63:0] accumulator;
    wire [31:0] A_iso;
    wire [31:0] B_iso;
    wire [63:0] product;
    wire [63:0] next_accumulator;

    // Operand isolation: suppress multiplier input activity when MAC is idle.
    assign A_iso = enable ? A : 32'b0;
    assign B_iso = enable ? B : 32'b0;

    assign product = A_iso * B_iso;
    assign next_accumulator = accumulator + product;

    // Preserve the existing result semantics.
    assign result   = next_accumulator[31:0];
    assign acc_low  = accumulator[31:0];
    assign acc_high = accumulator[63:32];

    // Clock-enable style: synthesis can infer clock gating if configured
    // before elaboration and supported by the selected Genus flow.
    always @(posedge clk or posedge reset) begin
        if (reset)
            accumulator <= 64'd0;
        else if (clear_acc)
            accumulator <= 64'd0;
        else if (enable)
            accumulator <= next_accumulator;
    end
endmodule
