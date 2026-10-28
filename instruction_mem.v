`timescale 1ns / 1ps
module instruction_mem (
    input  wire [31:0] read_address,
    output reg  [31:0] instruction_out
);

    localparam [31:0] NOP = 32'h00000013;

    always @* begin
        instruction_out = NOP;
        case (read_address)
            32'd0:  instruction_out = 32'h06400093; // ADDI x1, x0, 100
            32'd4:  instruction_out = 32'h03700113; // ADDI x2, x0, 55
            32'd8:  instruction_out = 32'h0020A023; // SW x2, 0(x1)
            32'd12: instruction_out = 32'h0000A183; // LW x3, 0(x1)
            32'd16: instruction_out = 32'h00218233; // ADD x4, x3, x2
            32'd20: instruction_out = 32'h00500293; // ADDI x5, x0, 5
            32'd24: instruction_out = 32'h00500313; // ADDI x6, x0, 5
            32'd28: instruction_out = 32'h00628463; // BEQ x5, x6, +8
            32'd32: instruction_out = 32'h06F00393; // ADDI x7, x0, 111 (wrong path)
            32'd36: instruction_out = 32'h0DE00393; // ADDI x7, x0, 222 (branch target)
            32'd40: instruction_out = 32'h0080046F; // JAL x8, +8
            32'd44: instruction_out = 32'h06F00493; // ADDI x9, x0, 111 (wrong path)
            32'd48: instruction_out = 32'h0DE00493; // ADDI x9, x0, 222 (JAL target)
            32'd52: instruction_out = 32'h04400513; // ADDI x10, x0, 68
            32'd56: instruction_out = 32'h00A00293; // ADDI x5, x0, 10
            32'd60: instruction_out = 32'h000505E7; // JALR x11, x10, 0 -> address 68
            32'd64: instruction_out = 32'h06F00613; // ADDI x12, x0, 111 (wrong path)
            32'd68: instruction_out = 32'h0062838B; // MAC x7, x5, x6
            default: instruction_out = NOP;
        endcase
    end
endmodule
