// Main control unit
// Decodes standard RV32I instructions and the custom MAC extension.
//
// Custom-0 opcode:
//     7'b0001011
//
// funct3:
//     3'b000 -> MAC
//     3'b001 -> MACLO
//     3'b010 -> MACHI
//     3'b011 -> CLR
`timescale 1ns / 1ps
module control_unit (
    input  [6:0] opcode,
    input  [2:0] funct3,

    output reg Branch,
    output reg MemRead,
    output reg MemtoReg,
    output reg MemWrite,
    output reg ALUSrc,
    output reg RegWrite,
    output reg LUI_en,
    output reg AUIPC_en,
    output reg JAL_en,
    output reg JALr_en,

    // Custom MAC control signals
    output reg MAC_Enable,
    output reg MAC_Clear,
    output reg MACLO_Enable,
    output reg MACHI_Enable,

    output reg [1:0] ALUOp
);

    // ---------------------------------------------------------
    // Control signals
    //
    // ALUOp:
    // 00 = ADD / default
    // 01 = SUB / branch comparison
    // 10 = R-type
    // 11 = I-type ALU
    // ---------------------------------------------------------

    always @(*) begin

        // -----------------------------------------------------
        // Default values
        // -----------------------------------------------------
        Branch     = 1'b0;
        MemRead    = 1'b0;
        MemtoReg   = 1'b0;
        MemWrite   = 1'b0;
        ALUSrc     = 1'b0;
        RegWrite   = 1'b0;
        LUI_en     = 1'b0;
        AUIPC_en   = 1'b0;
        JAL_en     = 1'b0;
        JALr_en    = 1'b0;

        MAC_Enable   = 1'b0;
        MAC_Clear    = 1'b0;
        MACLO_Enable = 1'b0;
        MACHI_Enable = 1'b0;

        ALUOp      = 2'b00;


        // -----------------------------------------------------
        // Instruction decoding
        // -----------------------------------------------------
        case (opcode)

            // -------------------------------------------------
            // R-type
            // -------------------------------------------------
            7'b0110011: begin
                ALUSrc   = 1'b0;
                RegWrite = 1'b1;
                ALUOp    = 2'b10;
            end


            // -------------------------------------------------
            // I-type ALU
            // -------------------------------------------------
            7'b0010011: begin
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                ALUOp    = 2'b11;
            end


            // -------------------------------------------------
            // Load
            // -------------------------------------------------
            7'b0000011: begin
                ALUSrc   = 1'b1;
                RegWrite = 1'b1;
                MemRead  = 1'b1;
                MemtoReg = 1'b1;
                ALUOp    = 2'b00;
            end


            // -------------------------------------------------
            // Store
            // -------------------------------------------------
            7'b0100011: begin
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
                ALUOp    = 2'b00;
            end


            // -------------------------------------------------
            // Branch
            // -------------------------------------------------
            7'b1100011: begin
                Branch = 1'b1;
                ALUOp  = 2'b01;
            end


            // -------------------------------------------------
            // LUI
            // -------------------------------------------------
            7'b0110111: begin
                RegWrite = 1'b1;
                LUI_en   = 1'b1;
                ALUOp    = 2'b00;
            end


            // -------------------------------------------------
            // AUIPC
            // -------------------------------------------------
            7'b0010111: begin
                RegWrite = 1'b1;
                AUIPC_en = 1'b1;
                ALUSrc   = 1'b1;   // AUIPC uses PC + immediate
                ALUOp    = 2'b00;
            end


            // -------------------------------------------------
            // JAL
            // -------------------------------------------------
            7'b1101111: begin
                RegWrite = 1'b1;
                JAL_en   = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 2'b00;
            end


            // -------------------------------------------------
            // JALR
            // -------------------------------------------------
            7'b1100111: begin
                RegWrite = 1'b1;
                JALr_en  = 1'b1;
                ALUSrc   = 1'b1;
                ALUOp    = 2'b00;
            end


            // =================================================
            // CUSTOM-0
            // =================================================
            // Opcode = 0001011
            //
            // funct3 = 000 -> MAC
            // funct3 = 001 -> MACLO
            // funct3 = 010 -> MACHI
            // funct3 = 011 -> CLR
            // =================================================
            7'b0001011: begin

                case (funct3)

                    // -----------------------------------------
                    // MAC rd, rs1, rs2
                    // -----------------------------------------
                    3'b000: begin
                        MAC_Enable = 1'b1;
                        RegWrite   = 1'b1;
                    end


                    // -----------------------------------------
                    // MACLO rd
                    // -----------------------------------------
                    3'b001: begin
                        MACLO_Enable = 1'b1;
                        RegWrite     = 1'b1;
                    end


                    // -----------------------------------------
                    // MACHI rd
                    // -----------------------------------------
                    3'b010: begin
                        MACHI_Enable = 1'b1;
                        RegWrite     = 1'b1;
                    end


                    // -----------------------------------------
                    // CLR
                    // -----------------------------------------
                    3'b011: begin
                        MAC_Clear = 1'b1;
                        RegWrite  = 1'b0;
                    end


                    // -----------------------------------------
                    // Other Custom-0 instructions
                    // -----------------------------------------
                    default: begin
                        MAC_Enable   = 1'b0;
                        MAC_Clear    = 1'b0;
                        MACLO_Enable = 1'b0;
                        MACHI_Enable = 1'b0;
                        RegWrite     = 1'b0;
                    end

                endcase

            end


            // -------------------------------------------------
            // Unknown instruction
            // -------------------------------------------------
            default: begin
                // All control signals remain at default 0
            end

        endcase
    end

endmodule
