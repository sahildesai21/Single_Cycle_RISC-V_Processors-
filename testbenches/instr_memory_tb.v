`timescale 1ns / 1ps

module instr_memory_tb;
reg [7:0] addr;
wire [31:0] instr;

instr_memory DUT (
    .addr(addr),
    .instr(instr)   
    );
    
initial begin
$display("Time\tAddress\t\tInstruction");
$monitor("%0t\t%h\t\t%h", $time, addr, instr);

addr = 8'h00; 
#10;
addr = 8'h01; 
#10;
addr = 8'h02; 
#10;
addr = 8'h03; 
#10;
addr = 8'h04; 
#10;
addr = 8'h05; 
#10;

end
    
endmodule
