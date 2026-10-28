`timescale 1ns / 1ps
module ALU_unit (
    input [31:0] A, B,
    input [3:0] control_in,
    output reg zero,
    output reg [31:0] ALU_out
);

    always @(*) begin
        ALU_out = 32'b0;
        zero = 1'b0;

        case (control_in)
            4'b0000: ALU_out = A & B;                         // AND
            4'b0001: ALU_out = A | B;                         // OR
            4'b0010: ALU_out = A + B;                         // ADD
            4'b0011: ALU_out = A ^ B;                         // XOR
            4'b0100: ALU_out = A << B[4:0];                   // SLL
            4'b0101: ALU_out = A >> B[4:0];                   // SRL
            4'b0110: begin                                    // SUB / BEQ
                ALU_out = A - B;
                zero = (A == B);
            end
            4'b0111: ALU_out = $signed(A) >>> B[4:0];         // SRA
            4'b1000: ALU_out = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0; // SLT
            4'b1001: ALU_out = (A < B) ? 32'd1 : 32'd0;      // SLTU
            default: ALU_out = 32'b0;
        endcase
    end

endmodule
