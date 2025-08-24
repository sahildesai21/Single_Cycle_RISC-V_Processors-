`timescale 1ns / 1ps

module instr_memory(
  input  [31:0] addr,
  output [31:0] instr
);
  reg [31:0] memory [0:255];
  wire [7:0] word_index = addr[9:2];
  assign instr = memory[word_index];
  initial begin
    $readmemh("program.mem", memory);
  end
endmodule
