`timescale 1ns / 1ps

module data_memory_tb;
reg clk;
reg rst;
reg MemRead;
reg MemWrite;
reg [31:0] addr;
reg [31:0] write_data;
reg [2:0] funct3;
wire [31:0] read_data;

data_memory DUT (
.clk(clk),
.rst(rst),
.MemRead(MemRead),
.MemWrite(MemWrite),
.addr(addr),
.write_data(write_data),
.funct3(funct3),
.read_data(read_data)
    );

always #5 clk = ~clk;

initial begin
$dumpfile("data_memory_tb.vcd");
$dumpvars(0, data_memory_tb);
rst = 1;
#10;
clk = 0;
rst = 0;
MemRead = 0;
MemWrite = 0;
addr = 0;
write_data = 0;
funct3 = 3'b000;
#10;

MemRead = 1; 
funct3 = 3'b000; 
addr = 32'd0; 
#10;
        
funct3 = 3'b001;    //LH 
addr = 32'd1; 
#10;
        
funct3 = 3'b010;    //LW 
addr = 32'd0; 
#10;
        
funct3 = 3'b100;    // LBU 
addr = 32'd0; 
#10;
        
funct3 = 3'b101;    //LHU 
addr = 32'd1; 
#10;

MemRead = 0;
$finish;
end

endmodule
