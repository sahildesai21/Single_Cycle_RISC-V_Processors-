`timescale 1ns / 1ps

module mux2_tb;
reg  [31:0] in0;
reg  [31:0] in1;
reg         sel;
wire [31:0] out;

mux2 #(.WIDTH(32)) DUT (
    .in0(in0),
    .in1(in1),
    .sel(sel),
    .out(out)
    );

initial begin
$display("time\t sel in0        in1        out");
$monitor("%0t\t %b   %h   %h   %h", $time, sel, in0, in1, out);

in0 = 32'hAAAAAAAA;     // Test case 1: Select in0
in1 = 32'hBBBBBBBB; 
sel = 0;
#10;

sel = 1;
#10;

in0 = 32'h12345678; 
in1 = 32'h87654321; 
sel = 0;
#10;

sel = 1;
#10;

$finish;
    
end
endmodule
