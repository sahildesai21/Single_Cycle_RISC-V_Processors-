`timescale 1ns / 1ps

module register_file_tb;
reg clk;
reg rst;
reg RegWrite;
reg [4:0] rs1;        
reg [4:0] rs2;
reg [4:0] rd;
reg [31:0] write_data;
wire [31:0] read_data1;
wire [31:0] read_data2;

register_file DUT (
.clk(clk),
.rst(rst),
.RegWrite(RegWrite),
.rs1(rs1),
.rs2(rs2),
.rd(rd),
.write_data(write_data),
.read_data1(read_data1),
.read_data2(read_data2)
    );

always #5 clk = ~clk;

initial begin
clk = 0;
rst = 1;
RegWrite = 0;
rs1 = 0;
rs2 = 0;
rd = 0;
write_data = 0;
#10;
rst = 0;

RegWrite = 1;   // Test Case 1: Write to x5
rd = 5;
write_data = 32'hDEADBEEF;
#10;

rd = 10;        // Test Case 2: Write to x10
write_data = 32'hCAFEBABE;
#10;

rd = 0;         // Test Case 3: Attempt to write to x0 (should be ignored)
write_data = 32'hFFFFFFFF;
#10;

// Read from x5 and x10
RegWrite = 0;
rs1 = 5;
rs2 = 10;
#10;
$display("Read x5 = %h (Expected = DEADBEEF)", read_data1);
$display("Read x10 = %h (Expected = CAFEBABE)", read_data2);

// Read from x0
rs1 = 0;
#10;
$display("Read x0 = %h (Expected = 00000000)", read_data1);
$finish;
end
endmodule
