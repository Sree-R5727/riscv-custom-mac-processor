`timescale 1ns / 1ps
module MEM_WB (
    input wire        clk,
    input wire        rst,
    input wire        enable,

    // ------------------------------------------------
    // NORMAL DATA
    // ------------------------------------------------
    input wire [31:0] memory_data_in,
    input wire [31:0] alu_result_in,

    // ------------------------------------------------
    // JAL / JALR LINK VALUE
    // ------------------------------------------------
    input wire [31:0] pc_plus4_in,

    // ------------------------------------------------
    // CUSTOM MAC RESULTS
    // ------------------------------------------------
    input wire [31:0] mac_result_in,
    input wire [31:0] mac_low_in,
    input wire [31:0] mac_high_in,

    // ------------------------------------------------
    // DESTINATION REGISTER
    // ------------------------------------------------
    input wire [4:0] rd_in,

    // ------------------------------------------------
    // NORMAL CONTROL
    // ------------------------------------------------
    input wire        RegWrite_in,
    input wire        MemToReg_in,

    // ------------------------------------------------
    // JUMP CONTROL
    // ------------------------------------------------
    input wire        JAL_en_in,
    input wire        JALR_en_in,

    // ------------------------------------------------
    // MAC CONTROL
    // ------------------------------------------------
    input wire        MAC_Enable_in,
    input wire        MACLO_Enable_in,
    input wire        MACHI_Enable_in,

    // ------------------------------------------------
    // OUTPUTS
    // ------------------------------------------------
    output reg [31:0] memory_data_out,
    output reg [31:0] alu_result_out,

    // JAL / JALR
    output reg [31:0] pc_plus4_out,

    // MAC
    output reg [31:0] mac_result_out,
    output reg [31:0] mac_low_out,
    output reg [31:0] mac_high_out,

    // Destination register
    output reg [4:0] rd_out,

    // Normal control
    output reg        RegWrite_out,
    output reg        MemToReg_out,

    // Jump control
    output reg        JAL_en_out,
    output reg        JALR_en_out,

    // MAC control
    output reg        MAC_Enable_out,
    output reg        MACLO_Enable_out,
    output reg        MACHI_Enable_out
);

always @(posedge clk or posedge rst) begin

    if (rst) begin

        memory_data_out <= 32'd0;
        alu_result_out  <= 32'd0;
        pc_plus4_out    <= 32'd0;
        mac_result_out  <= 32'd0;
        mac_low_out     <= 32'd0;
        mac_high_out    <= 32'd0;
        rd_out          <= 5'd0;
        RegWrite_out    <= 1'b0;
        MemToReg_out    <= 1'b0;
        JAL_en_out      <= 1'b0;
        JALR_en_out     <= 1'b0;
        MAC_Enable_out   <= 1'b0;
        MACLO_Enable_out <= 1'b0;
        MACHI_Enable_out <= 1'b0;

    end

    else if (enable) begin

        memory_data_out <= memory_data_in;
        alu_result_out  <= alu_result_in;
        pc_plus4_out    <= pc_plus4_in;
        mac_result_out  <= mac_result_in;
        mac_low_out     <= mac_low_in;
        mac_high_out    <= mac_high_in;
        rd_out          <= rd_in;
        RegWrite_out    <= RegWrite_in;
        MemToReg_out    <= MemToReg_in;
        JAL_en_out      <= JAL_en_in;
        JALR_en_out     <= JALR_en_in;
        MAC_Enable_out   <= MAC_Enable_in;
        MACLO_Enable_out <= MACLO_Enable_in;
        MACHI_Enable_out <= MACHI_Enable_in;

    end

end

endmodule
