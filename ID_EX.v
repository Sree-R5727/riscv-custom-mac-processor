`timescale 1ns / 1ps
module ID_EX (
    input wire        clk,
    input wire        rst,
    input wire        flush,
    input wire        enable,

    // ------------------------------------------------
    // DATA
    // ------------------------------------------------
    input wire [31:0] pc_in,
    input wire [31:0] pc_plus4_in,
    input wire [31:0] rs1_data_in,
    input wire [31:0] rs2_data_in,
    input wire [31:0] immediate_in,

    // ------------------------------------------------
    // REGISTER ADDRESSES
    // ------------------------------------------------
    input wire [4:0]  rs1_in,
    input wire [4:0]  rs2_in,
    input wire [4:0]  rd_in,

    // ------------------------------------------------
    // INSTRUCTION FIELDS
    // ------------------------------------------------
    input wire [2:0]  funct3_in,
    input wire        funct7_in,

    // ------------------------------------------------
    // NORMAL CONTROL
    // ------------------------------------------------
    input wire        RegWrite_in,
    input wire        ALUSrc_in,
    input wire [1:0]  ALUOp_in,

    input wire        MemRead_in,
    input wire        MemWrite_in,
    input wire        MemToReg_in,

    input wire        Branch_in,

    // ------------------------------------------------
    // JUMP / U-TYPE CONTROL
    // ------------------------------------------------
    input wire        JAL_en_in,
    input wire        JALR_en_in,
    input wire        AUIPC_en_in,
    input wire        LUI_en_in,

    // ------------------------------------------------
    // CUSTOM MAC CONTROL
    // ------------------------------------------------
    input wire        MAC_Enable_in,
    input wire        MAC_Clear_in,
    input wire        MACLO_Enable_in,
    input wire        MACHI_Enable_in,

    // ------------------------------------------------
    // OUTPUTS
    // ------------------------------------------------
    output reg [31:0] pc_out,
    output reg [31:0] pc_plus4_out,
    output reg [31:0] rs1_data_out,
    output reg [31:0] rs2_data_out,
    output reg [31:0] immediate_out,

    output reg [4:0]  rs1_out,
    output reg [4:0]  rs2_out,
    output reg [4:0]  rd_out,

    output reg [2:0]  funct3_out,
    output reg        funct7_out,

    // Normal control
    output reg        RegWrite_out,
    output reg        ALUSrc_out,
    output reg [1:0]  ALUOp_out,

    output reg        MemRead_out,
    output reg        MemWrite_out,
    output reg        MemToReg_out,

    output reg        Branch_out,

    // Jump / U-type
    output reg        JAL_en_out,
    output reg        JALR_en_out,
    output reg        AUIPC_en_out,
    output reg        LUI_en_out,

    // Custom MAC
    output reg        MAC_Enable_out,
    output reg        MAC_Clear_out,
    output reg        MACLO_Enable_out,
    output reg        MACHI_Enable_out
);

always @(posedge clk or posedge rst) begin

    if (rst) begin

        // DATA
        pc_out        <= 32'd0;
        pc_plus4_out  <= 32'd0;
        rs1_data_out  <= 32'd0;
        rs2_data_out  <= 32'd0;
        immediate_out <= 32'd0;

        // REGISTERS
        rs1_out <= 5'd0;
        rs2_out <= 5'd0;
        rd_out  <= 5'd0;

        // INSTRUCTION
        funct3_out <= 3'd0;
        funct7_out <= 1'b0;

        // NORMAL CONTROL
        RegWrite_out <= 1'b0;
        ALUSrc_out   <= 1'b0;
        ALUOp_out    <= 2'b00;
        MemRead_out  <= 1'b0;
        MemWrite_out <= 1'b0;
        MemToReg_out <= 1'b0;
        Branch_out   <= 1'b0;

        // JUMP / U-TYPE
        JAL_en_out   <= 1'b0;
        JALR_en_out  <= 1'b0;
        AUIPC_en_out <= 1'b0;
        LUI_en_out   <= 1'b0;

        // MAC
        MAC_Enable_out  <= 1'b0;
        MAC_Clear_out   <= 1'b0;
        MACLO_Enable_out <= 1'b0;
        MACHI_Enable_out <= 1'b0;

    end

    else if (flush) begin

        RegWrite_out <= 1'b0;
        ALUSrc_out   <= 1'b0;
        ALUOp_out    <= 2'b00;
        MemRead_out  <= 1'b0;
        MemWrite_out <= 1'b0;
        MemToReg_out <= 1'b0;
        Branch_out   <= 1'b0;

        JAL_en_out   <= 1'b0;
        JALR_en_out  <= 1'b0;
        AUIPC_en_out <= 1'b0;
        LUI_en_out   <= 1'b0;

        MAC_Enable_out   <= 1'b0;
        MAC_Clear_out    <= 1'b0;
        MACLO_Enable_out <= 1'b0;
        MACHI_Enable_out <= 1'b0;

        pc_out        <= 32'd0;
        pc_plus4_out  <= 32'd0;
        rs1_data_out  <= 32'd0;
        rs2_data_out  <= 32'd0;
        immediate_out <= 32'd0;

        rs1_out <= 5'd0;
        rs2_out <= 5'd0;
        rd_out  <= 5'd0;

        funct3_out <= 3'd0;
        funct7_out <= 1'b0;

    end

    else if (enable) begin

        pc_out        <= pc_in;
        pc_plus4_out  <= pc_plus4_in;
        rs1_data_out  <= rs1_data_in;
        rs2_data_out  <= rs2_data_in;
        immediate_out <= immediate_in;

        rs1_out <= rs1_in;
        rs2_out <= rs2_in;
        rd_out  <= rd_in;

        funct3_out <= funct3_in;
        funct7_out <= funct7_in;

        RegWrite_out <= RegWrite_in;
        ALUSrc_out   <= ALUSrc_in;
        ALUOp_out    <= ALUOp_in;
        MemRead_out  <= MemRead_in;
        MemWrite_out <= MemWrite_in;
        MemToReg_out <= MemToReg_in;
        Branch_out   <= Branch_in;

        JAL_en_out   <= JAL_en_in;
        JALR_en_out  <= JALR_en_in;
        AUIPC_en_out <= AUIPC_en_in;
        LUI_en_out   <= LUI_en_in;

        MAC_Enable_out   <= MAC_Enable_in;
        MAC_Clear_out    <= MAC_Clear_in;
        MACLO_Enable_out <= MACLO_Enable_in;
        MACHI_Enable_out <= MACHI_Enable_in;

    end

end

endmodule
