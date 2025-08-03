`timescale 1ns / 1ps

module alu_tb;

  // Testbench signals
  reg [31:0] a, b;
  reg [3:0] ALUctrl;
  wire [31:0] result;
  wire zero;

  // Instantiate the ALU
  alu dut (
    .a(a),
    .b(b),
    .ALUctrl(ALUctrl),
    .result(result),
    .zero(zero)
  );

  initial begin
    $display("Time\tALUctrl\tA\t\tB\t\tResult\t\tZero");
    $monitor("%0t\t%04b\t%h\t%h\t%h\t%b", 
              $time, ALUctrl, a, b, result, zero);

    // ADD
    a = 32'd15; b = 32'd10; ALUctrl = 4'b0000; #10;

    // SUB
    a = 32'd20; b = 32'd20; ALUctrl = 4'b0001; #10;

    // AND
    a = 32'hFF00FF00; b = 32'h0F0F0F0F; ALUctrl = 4'b0010; #10;

    // OR
    a = 32'hAA00AA00; b = 32'h00FF00FF; ALUctrl = 4'b0011; #10;

    // XOR
    a = 32'h12345678; b = 32'h87654321; ALUctrl = 4'b0100; #10;

    // SLL (Shift Left Logical)
    a = 32'h00000001; b = 32'd4; ALUctrl = 4'b0101; #10;

    // SRL (Shift Right Logical)
    a = 32'h00000080; b = 32'd3; ALUctrl = 4'b0110; #10;

    // SRA (Shift Right Arithmetic)
    a = -32'd64; b = 32'd3; ALUctrl = 4'b0111; #10;

    // SLT (Signed Less Than)
    a = -32'd5; b = 32'd1; ALUctrl = 4'b1000; #10;

    // SLTU (Unsigned Less Than)
    a = 32'h00000001; b = 32'hFFFFFFFF; ALUctrl = 4'b1001; #10;

    // Default (Invalid control code)
    ALUctrl = 4'b1111; a = 32'd1; b = 32'd1; #10;

    $finish;
  end

endmodule
