`timescale 1ns / 1ps

module instr_memory_tb;
reg [31:0] addr;
wire [31:0] instr;

instr_memory DUT (
    .addr(addr),
    .instr(instr)   
    );

initial begin
$display("Time\tAddress\tInstruction");
$monitor("%0t\t%h\t%h", $time, addr, instr);

addr = 32'h00000000; #10;
addr = 32'h00000004; #10;
addr = 32'h00000008; #10;
addr = 32'h0000000C; #10;
addr = 32'h00000010; #10;
addr = 32'h00000014; #10;
addr = 32'h00000018; #10;
addr = 32'h0000001C; #10;
addr = 32'h00000020; #10;
$finish;
end
    
endmodule
