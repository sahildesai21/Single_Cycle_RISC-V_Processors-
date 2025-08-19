`timescale 1ns / 1ps

module cpu_top_tb;
reg clk;
reg rst;

// Instantiate the CPU
cpu_top DUT (
    .clk(clk),
    .rst(rst)
    );

// Clock generation
initial clk = 0;
always #5 clk = ~clk;  // 10ns period, 100MHz

// Monitor - display key signals every clock
initial begin
$display("Time  Ph  PC        Instr     ALUres    MemRData  WB_rd  WB_data");
$monitor("%4t  %0d  %h  %h  %h  %h  %0d   %h",$time,DUT.phase,DUT.pc_out,DUT.instr,DUT.saved_alu_result,DUT.MemReadData_wire,DUT.wb_rd,DUT.wb_write_data);
end

// Test stimulus
initial begin
// Reset for a few cycles
rst = 1;
#20;
rst = 0;

// Run for a certain number of cycles, then stop
#300;
$display("Simulation complete.");
$finish;
end

// Optional: dump waveform for GTKWave or Vivado
initial begin
$dumpfile("cpu_top_tb.vcd");
$dumpvars(0, cpu_top_tb);
end

endmodule
