`timescale 1ns / 1ps

module pc_adder(
input  [31:0] pc_current,   
input  [31:0] imm,          // Immediate (from immediate_gen)
output [31:0] pc_plus_4,    // PC + 4
output [31:0] pc_branch     // PC + Immediate (branch target)
   );

assign pc_plus_4 = pc_current + 32'd4;
assign pc_branch = pc_current + imm;

endmodule