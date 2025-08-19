`timescale 1ns / 1ps

module register_file(
input clk,
input rst,
input RegWrite,
input [4:0] rs1,        // Source registers
input [4:0] rs2,
input [4:0] rd,
input [31:0] write_data,
output [31:0] read_data1,
output [31:0] read_data2
    );

reg [31:0] register [31:0];    // 32 general-purpose registers (x0 to x31), 32-bit each
integer i;

assign read_data1 = register[rs1];    // Asynchronous read
assign read_data2 = register[rs2];


always @ (posedge clk) begin      // Synchronous write on rising edge
if (rst) 
begin
for (i = 0 ; i < 32; i = i+1)
    register[i] <= 32'b0;
end
else if (RegWrite && (rd != 5'bb00000)) begin
    register[rd] <= write_data;
    end
        
end
endmodule
