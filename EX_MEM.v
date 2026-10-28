`timescale 1ns / 1ps
module EX_MEM (
    input wire        clk,
    input wire        rst,
    input wire        flush,
    input wire        enable,

    // ------------------------------------------------
    // NORMAL EX DATA
    // ------------------------------------------------
    input wire [31:0] alu_result_in,
    input wire [31:0] rs2_data_in,
    input wire [31:0] branch_target_in,

    // Branch condition
    input wire        zero_in,

    // Destination register
    input wire [4:0]  rd_in,

    // ------------------------------------------------
    // JUMP LINK
    // PC + 4 for JAL / JALR
    // ------------------------------------------------
    input wire [31:0] pc_plus4_in,

    // ------------------------------------------------
    // CUSTOM MAC RESULTS
    // ------------------------------------------------
    input wire [31:0] mac_result_in,
    input wire [31:0] mac_low_in,
    input wire [31:0] mac_high_in,

    // ------------------------------------------------
    // NORMAL CONTROL
    // ------------------------------------------------
    input wire        RegWrite_in,
    input wire        MemRead_in,
    input wire        MemWrite_in,
    input wire        MemToReg_in,
    input wire        Branch_in,

    // ------------------------------------------------
    // JUMP / U-TYPE CONTROL
    // ------------------------------------------------
    input wire        JAL_en_in,
    input wire        JALR_en_in,
    input wire        LUI_en_in,

    // ------------------------------------------------
    // CUSTOM MAC CONTROL
    // ------------------------------------------------
    input wire        MAC_Enable_in,
    input wire        MACLO_Enable_in,
    input wire        MACHI_Enable_in,

    // ------------------------------------------------
    // OUTPUTS
    // ------------------------------------------------
    output reg [31:0] alu_result_out,
    output reg [31:0] rs2_data_out,
    output reg [31:0] branch_target_out,

    output reg        zero_out,

    output reg [4:0]  rd_out,

    // PC + 4
    output reg [31:0] pc_plus4_out,

    // MAC results
    output reg [31:0] mac_result_out,
    output reg [31:0] mac_low_out,
    output reg [31:0] mac_high_out,

    // Normal control
    output reg        RegWrite_out,
    output reg        MemRead_out,
    output reg        MemWrite_out,
    output reg        MemToReg_out,
    output reg        Branch_out,

    // Jump / U-type
    output reg        JAL_en_out,
    output reg        JALR_en_out,
    output reg        LUI_en_out,

    // MAC control
    output reg        MAC_Enable_out,
    output reg        MACLO_Enable_out,
    output reg        MACHI_Enable_out
);

always @(posedge clk or posedge rst) begin

    if (rst) begin

        alu_result_out    <= 32'd0;
        rs2_data_out      <= 32'd0;
        branch_target_out <= 32'd0;
        zero_out          <= 1'b0;
        rd_out            <= 5'd0;
        pc_plus4_out      <= 32'd0;
        mac_result_out    <= 32'd0;
        mac_low_out       <= 32'd0;
        mac_high_out      <= 32'd0;
        RegWrite_out      <= 1'b0;
        MemRead_out       <= 1'b0;
        MemWrite_out      <= 1'b0;
        MemToReg_out      <= 1'b0;
        Branch_out        <= 1'b0;
        JAL_en_out        <= 1'b0;
        JALR_en_out       <= 1'b0;
        LUI_en_out        <= 1'b0;
        MAC_Enable_out    <= 1'b0;
        MACLO_Enable_out  <= 1'b0;
        MACHI_Enable_out  <= 1'b0;

    end

    else if (flush) begin

        RegWrite_out      <= 1'b0;
        MemRead_out       <= 1'b0;
        MemWrite_out      <= 1'b0;
        MemToReg_out      <= 1'b0;
        Branch_out        <= 1'b0;
        JAL_en_out        <= 1'b0;
        JALR_en_out       <= 1'b0;
        LUI_en_out        <= 1'b0;
        MAC_Enable_out    <= 1'b0;
        MACLO_Enable_out  <= 1'b0;
        MACHI_Enable_out  <= 1'b0;
        alu_result_out    <= 32'd0;
        rs2_data_out      <= 32'd0;
        branch_target_out <= 32'd0;
        zero_out          <= 1'b0;
        rd_out            <= 5'd0;
        pc_plus4_out      <= 32'd0;
        mac_result_out    <= 32'd0;
        mac_low_out       <= 32'd0;
        mac_high_out      <= 32'd0;

    end

    else if (enable) begin

        alu_result_out    <= alu_result_in;
        rs2_data_out      <= rs2_data_in;
        branch_target_out <= branch_target_in;
        zero_out          <= zero_in;
        rd_out            <= rd_in;
        pc_plus4_out      <= pc_plus4_in;
        mac_result_out    <= mac_result_in;
        mac_low_out       <= mac_low_in;
        mac_high_out      <= mac_high_in;
        RegWrite_out      <= RegWrite_in;
        MemRead_out       <= MemRead_in;
        MemWrite_out      <= MemWrite_in;
        MemToReg_out      <= MemToReg_in;
        Branch_out        <= Branch_in;
        JAL_en_out        <= JAL_en_in;
        JALR_en_out       <= JALR_en_in;
        LUI_en_out        <= LUI_en_in;
        MAC_Enable_out    <= MAC_Enable_in;
        MACLO_Enable_out  <= MACLO_Enable_in;
        MACHI_Enable_out  <= MACHI_Enable_in;

    end

end

endmodule`timescale 1ns / 1ps
module EX_MEM (
    input wire        clk,
    input wire        rst,
    input wire        flush,
    input wire        enable,

    // ------------------------------------------------
    // NORMAL EX DATA
    // ------------------------------------------------
    input wire [31:0] alu_result_in,
    input wire [31:0] rs2_data_in,
    input wire [31:0] branch_target_in,

    // Branch condition
    input wire        zero_in,

    // Destination register
    input wire [4:0]  rd_in,

    // ------------------------------------------------
    // JUMP LINK
    // PC + 4 for JAL / JALR
    // ------------------------------------------------
    input wire [31:0] pc_plus4_in,

    // ------------------------------------------------
    // CUSTOM MAC RESULTS
    // ------------------------------------------------
    input wire [31:0] mac_result_in,
    input wire [31:0] mac_low_in,
    input wire [31:0] mac_high_in,

    // ------------------------------------------------
    // NORMAL CONTROL
    // ------------------------------------------------
    input wire        RegWrite_in,
    input wire        MemRead_in,
    input wire        MemWrite_in,
    input wire        MemToReg_in,
    input wire        Branch_in,

    // ------------------------------------------------
    // JUMP / U-TYPE CONTROL
    // ------------------------------------------------
    input wire        JAL_en_in,
    input wire        JALR_en_in,
    input wire        LUI_en_in,

    // ------------------------------------------------
    // CUSTOM MAC CONTROL
    // ------------------------------------------------
    input wire        MAC_Enable_in,
    input wire        MACLO_Enable_in,
    input wire        MACHI_Enable_in,

    // ------------------------------------------------
    // OUTPUTS
    // ------------------------------------------------
    output reg [31:0] alu_result_out,
    output reg [31:0] rs2_data_out,
    output reg [31:0] branch_target_out,

    output reg        zero_out,

    output reg [4:0]  rd_out,

    // PC + 4
    output reg [31:0] pc_plus4_out,

    // MAC results
    output reg [31:0] mac_result_out,
    output reg [31:0] mac_low_out,
    output reg [31:0] mac_high_out,

    // Normal control
    output reg        RegWrite_out,
    output reg        MemRead_out,
    output reg        MemWrite_out,
    output reg        MemToReg_out,
    output reg        Branch_out,

    // Jump / U-type
    output reg        JAL_en_out,
    output reg        JALR_en_out,
    output reg        LUI_en_out,

    // MAC control
    output reg        MAC_Enable_out,
    output reg        MACLO_Enable_out,
    output reg        MACHI_Enable_out
);

always @(posedge clk or posedge rst) begin

    if (rst) begin

        alu_result_out    <= 32'd0;
        rs2_data_out      <= 32'd0;
        branch_target_out <= 32'd0;
        zero_out          <= 1'b0;
        rd_out            <= 5'd0;
        pc_plus4_out      <= 32'd0;
        mac_result_out    <= 32'd0;
        mac_low_out       <= 32'd0;
        mac_high_out      <= 32'd0;
        RegWrite_out      <= 1'b0;
        MemRead_out       <= 1'b0;
        MemWrite_out      <= 1'b0;
        MemToReg_out      <= 1'b0;
        Branch_out        <= 1'b0;
        JAL_en_out        <= 1'b0;
        JALR_en_out       <= 1'b0;
        LUI_en_out        <= 1'b0;
        MAC_Enable_out    <= 1'b0;
        MACLO_Enable_out  <= 1'b0;
        MACHI_Enable_out  <= 1'b0;

    end

    else if (flush) begin

        RegWrite_out      <= 1'b0;
        MemRead_out       <= 1'b0;
        MemWrite_out      <= 1'b0;
        MemToReg_out      <= 1'b0;
        Branch_out        <= 1'b0;
        JAL_en_out        <= 1'b0;
        JALR_en_out       <= 1'b0;
        LUI_en_out        <= 1'b0;
        MAC_Enable_out    <= 1'b0;
        MACLO_Enable_out  <= 1'b0;
        MACHI_Enable_out  <= 1'b0;
        alu_result_out    <= 32'd0;
        rs2_data_out      <= 32'd0;
        branch_target_out <= 32'd0;
        zero_out          <= 1'b0;
        rd_out            <= 5'd0;
        pc_plus4_out      <= 32'd0;
        mac_result_out    <= 32'd0;
        mac_low_out       <= 32'd0;
        mac_high_out      <= 32'd0;

    end

    else if (enable) begin

        alu_result_out    <= alu_result_in;
        rs2_data_out      <= rs2_data_in;
        branch_target_out <= branch_target_in;
        zero_out          <= zero_in;
        rd_out            <= rd_in;
        pc_plus4_out      <= pc_plus4_in;
        mac_result_out    <= mac_result_in;
        mac_low_out       <= mac_low_in;
        mac_high_out      <= mac_high_in;
        RegWrite_out      <= RegWrite_in;
        MemRead_out       <= MemRead_in;
        MemWrite_out      <= MemWrite_in;
        MemToReg_out      <= MemToReg_in;
        Branch_out        <= Branch_in;
        JAL_en_out        <= JAL_en_in;
        JALR_en_out       <= JALR_en_in;
        LUI_en_out        <= LUI_en_in;
        MAC_Enable_out    <= MAC_Enable_in;
        MACLO_Enable_out  <= MACLO_Enable_in;
        MACHI_Enable_out  <= MACHI_Enable_in;

    end

end

endmodule
