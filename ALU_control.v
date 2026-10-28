`timescale 1ns / 1ps
module ALU_control
(
    input [1:0]ALUOp,
    input fun7,        // funct7 bit 5 of the instruction (instr[30]) - only meaningful for R-type and for SRLI/SRAI
    input [2:0]fun3,
    output reg [3:0]control_out
);

// control_out encoding
localparam AND_OP = 4'b0000;
localparam OR_OP  = 4'b0001;
localparam ADD_OP = 4'b0010;
localparam XOR_OP = 4'b0011;
localparam SLL_OP = 4'b0100;
localparam SRL_OP = 4'b0101;
localparam SUB_OP = 4'b0110;
localparam SRA_OP = 4'b0111;
localparam SLT_OP = 4'b1000;
localparam SLTU_OP= 4'b1001;

always @(*) begin
    casez({ALUOp, fun7, fun3})
        // ALUOp=00: loads/stores/JALR/AUIPC address calc -> always ADD, fun7 don't-care
        6'b00_?_???: control_out = ADD_OP;

        // ALUOp=01: branch comparison -> always SUB (zero flag used for BEQ), fun7/fun3 don't-care
        6'b01_?_???: control_out = SUB_OP;

        // ALUOp=10: R-type -> decode via funct3, funct7[5] only distinguishes ADD/SUB and SRL/SRA
        6'b10_0_000: control_out = ADD_OP;  // ADD
        6'b10_1_000: control_out = SUB_OP;  // SUB
        6'b10_?_001: control_out = SLL_OP;  // SLL
        6'b10_?_010: control_out = SLT_OP;  // SLT
        6'b10_?_011: control_out = SLTU_OP; // SLTU
        6'b10_?_100: control_out = XOR_OP;  // XOR
        6'b10_0_101: control_out = SRL_OP;  // SRL
        6'b10_1_101: control_out = SRA_OP;  // SRA
        6'b10_?_110: control_out = OR_OP;   // OR
        6'b10_?_111: control_out = AND_OP;  // AND

        // ALUOp=11: I-type ALU (ADDI/SLTI/.../ANDI) -> decode via funct3 only.
        // funct7 is NOT a real instruction field here (bit 30 is just part of the
        // immediate), so it must be ignored EXCEPT for SRLI/SRAI where the ISA
        // reuses that bit exactly like R-type SRL/SRA.
        6'b11_?_000: control_out = ADD_OP;  // ADDI  (never SUB - there is no SUBI)
        6'b11_?_001: control_out = SLL_OP;  // SLLI
        6'b11_?_010: control_out = SLT_OP;  // SLTI
        6'b11_?_011: control_out = SLTU_OP; // SLTIU
        6'b11_?_100: control_out = XOR_OP;  // XORI
        6'b11_0_101: control_out = SRL_OP;  // SRLI
        6'b11_1_101: control_out = SRA_OP;  // SRAI
        6'b11_?_110: control_out = OR_OP;   // ORI
        6'b11_?_111: control_out = AND_OP;  // ANDI

        default:     control_out = ADD_OP;
    endcase
end
endmodule
