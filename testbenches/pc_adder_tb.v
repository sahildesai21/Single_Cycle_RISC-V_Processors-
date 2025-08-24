`timescale 1ns / 1ps

module pc_adder_tb;
reg [31:0] pc_current;
reg [31:0] imm;
wire [31:0] pc_plus_4;
wire [31:0] pc_branch;

pc_adder DUT (
    .pc_current(pc_current),
    .imm(imm),
    .pc_plus_4(pc_plus_4),
    .pc_branch(pc_branch)
    );


initial begin
$display("Time\tPC\t\tImm\t\tPC+4\t\tPC+Imm");
$monitor("%0t\t%h\t%h\t%h\t%h",$time, pc_current, imm, pc_plus_4, pc_branch);

pc_current = 32'h00000000;  // Test 1: Seuential execution
imm = 32'h00000010;   // +16
#10;

pc_current = 32'h00000020;  // Test 2: Branch backward
imm = 32'hFFFFFFF0;   // -16
#10;

pc_current = 32'h00000040; // Test 3: No offset
imm = 32'h00000000;
#10;

pc_current = 32'h10000000;  // Test 4: Large jump forward
imm = 32'h00001000;   // +4096
#10;

$finish;
end

endmodule
