`timescale 1ns / 1ps
module program_counter (
    input clk, rst, enable,
    input [31:0] PC_in,
    output reg [31:0] PC_out
);
always @(posedge clk or posedge rst) begin
    if(rst) 
        PC_out <= 32'b0;
    else if(enable) 
        PC_out <= PC_in;
end
endmodule
