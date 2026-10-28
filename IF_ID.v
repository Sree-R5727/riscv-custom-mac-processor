`timescale 1ns / 1ps
module IF_ID (
    input wire        clk,
    input wire        rst,
    input wire        stall,
    input wire        flush,

    input wire [31:0] pc_in,
    input wire [31:0] pc_plus4_in,
    input wire [31:0] instruction_in,

    output reg [31:0] pc_out,
    output reg [31:0] pc_plus4_out,
    output reg [31:0] instruction_out
);

always @(posedge clk or posedge rst) begin

    if (rst) begin
        pc_out          <= 32'd0;
        pc_plus4_out    <= 32'd0;
        instruction_out <= 32'd0;
    end

    else if (flush) begin
        pc_out          <= 32'd0;
        pc_plus4_out    <= 32'd0;
        instruction_out <= 32'd0;
    end

    else if (!stall) begin
        pc_out          <= pc_in;
        pc_plus4_out    <= pc_plus4_in;
        instruction_out <= instruction_in;
    end

end

endmodule
