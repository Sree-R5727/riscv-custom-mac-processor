`timescale 1ns / 1ps
module HazardDetectionUnit (
    input  wire        MemRead_ID_EX,
    input  wire [4:0]  rd_ID_EX,
    input  wire [4:0]  rs1_IF_ID,
    input  wire [4:0]  rs2_IF_ID,

    output reg         Stall_PC,
    output reg         Stall_IF_ID,
    output reg         Flush_ID_EX
);

always @(*) begin

    // Default: no hazard
    Stall_PC    = 1'b0;
    Stall_IF_ID = 1'b0;
    Flush_ID_EX = 1'b0;

    // Load-use hazard detection
    if (MemRead_ID_EX &&
        (rd_ID_EX != 5'd0) &&
        ((rd_ID_EX == rs1_IF_ID) ||
         (rd_ID_EX == rs2_IF_ID))) begin

        Stall_PC    = 1'b1;
        Stall_IF_ID = 1'b1;
        Flush_ID_EX = 1'b1;

    end

end

endmodule
