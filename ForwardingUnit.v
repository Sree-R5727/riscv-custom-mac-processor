`timescale 1ns / 1ps
module ForwardingUnit (
    input  wire [4:0] rs1_EX,
    input  wire [4:0] rs2_EX,

    input  wire [4:0] rd_MEM,
    input  wire       RegWrite_MEM,

    input  wire [4:0] rd_WB,
    input  wire       RegWrite_WB,

    output reg  [1:0] ForwardA,
    output reg  [1:0] ForwardB
);

always @(*) begin

    // ------------------------------------------------------------
    // Default
    // 00 = normal value from ID/EX register
    // 10 = value from EX/MEM
    // 01 = value from MEM/WB
    // ------------------------------------------------------------

    ForwardA = 2'b00;
    ForwardB = 2'b00;


    // ============================================================
    // RS1 FORWARDING
    // ============================================================

    if (RegWrite_MEM &&
        (rd_MEM != 5'd0) &&
        (rd_MEM == rs1_EX)) begin

        ForwardA = 2'b10;

    end

    else if (RegWrite_WB &&
             (rd_WB != 5'd0) &&
             (rd_WB == rs1_EX)) begin

        ForwardA = 2'b01;

    end


    // ============================================================
    // RS2 FORWARDING
    // ============================================================

    if (RegWrite_MEM &&
        (rd_MEM != 5'd0) &&
        (rd_MEM == rs2_EX)) begin

        ForwardB = 2'b10;

    end

    else if (RegWrite_WB &&
             (rd_WB != 5'd0) &&
             (rd_WB == rs2_EX)) begin

        ForwardB = 2'b01;

    end

end

endmodule
