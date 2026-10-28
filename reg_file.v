`timescale 1ns / 1ps
module reg_file (
    input clk, rst, reg_write,
    input [4:0] rs1, rs2, rd,
    input [31:0] write_data,
    output [31:0] read_data_1, read_data_2
);

reg [31:0] registers [0:31];
integer k;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        for (k=0; k<32; k=k+1)
            registers[k] <= 32'b0;
    end
    else if (reg_write && (rd != 5'd0)) begin
        registers[rd] <= write_data;
    end
end

// Asynchronous reads with same-cycle WB write-through.
// This removes the read-after-write ambiguity between WB and ID.
assign read_data_1 =
    (reg_write && (rd != 5'd0) && (rd == rs1)) ?
    write_data :
    ((rs1 == 5'd0) ? 32'b0 : registers[rs1]);

assign read_data_2 =
    (reg_write && (rd != 5'd0) && (rd == rs2)) ?
    write_data :
    ((rs2 == 5'd0) ? 32'b0 : registers[rs2]);

endmodule
