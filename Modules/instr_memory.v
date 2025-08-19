`timescale 1ns / 1ps

module instr_memory(
input [7:0] addr,       // supports up to 256 words
output [31:0] instr
    );

reg [31:0] memory [0:255];  // Memory array: 256 x 32-bit words, 8-bit address -> 256 instructions

assign instr = memory[addr];

initial begin
    $readmemh("program.mem", memory);  // Load hex values into 'memory'
end

endmodule
