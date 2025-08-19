`timescale 1ns / 1ps

module pc_tb;
reg rst;
reg clk;
reg pc_write;
reg [31:0] pc_in;
wire[31:0] pc_out;

pc DUT (
    .rst(rst),
    .clk(clk),
    .pc_write(pc_write),
    .pc_out(pc_out),
    .pc_in(pc_in)
    );

initial clk = 0;

always #5 clk = ~clk;

initial begin
$display("time\t rst pc_write pc_in      pc_out");
$monitor("%0t\t %b   %b       %h   %h", $time, rst, pc_write, pc_in, pc_out);

rst = 1;
pc_write = 1;
pc_in = 32'h00000000;
#12;                // allow a bit more than one clock edge

rst = 0;
pc_in = 32'h00000004; // normally PC+4 of reset PC
#10;

pc_in = 32'h00000008; #10;  // Advance several sequential PCs
pc_in = 32'h0000000C; #10;

// Stall the PC (pc_write = 0): PC should hold
pc_write = 0;
pc_in = 32'h00000104;   // should NOT update pc_out
#10;

pc_write = 1;   // Release stall
#10;

// Another jump backwards
pc_in = 32'h00000000; #10;

$display("Test complete");
$finish;
end

endmodule
