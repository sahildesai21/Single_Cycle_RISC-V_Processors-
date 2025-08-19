`timescale 1ns / 1ps

module pc(
input rst,
input clk,
input pc_write,
input [31:0] pc_in,
output reg [31:0] pc_out
    );
    
parameter reset_addr = 32'h00000000;

always @ (posedge clk) begin
if (rst) begin
    pc_out <= reset_addr;
    end
    else if (pc_write) begin
        pc_out <= pc_in;
        end
    else
        pc_out <= pc_out;   // Hold
end
endmodule
