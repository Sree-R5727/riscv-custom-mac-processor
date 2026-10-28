`timescale 1ns / 1ps
module data_mem(
    input wire        clk,
    input wire        rst,
    input wire        MemRead,
    input wire        MemWrite,
    input wire [31:0] address,
    input wire [31:0] write_data,
    output wire [31:0] read_data
);

    reg [31:0] D_mem [0:63];
    integer k;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (k = 0; k < 64; k = k + 1)
                D_mem[k] <= 32'b0;
        end
        else if (MemWrite) begin
            D_mem[address >> 2] <= write_data;
        end
    end

    assign read_data = MemRead ? D_mem[address >> 2] : 32'b0;

endmodule
