`timescale 1ns / 1ps

module control_unit_tb;
reg [6:0] opcode;
reg [2:0] funct3;  
reg funct7_5; 

wire RegWrite;
wire MemRead;
wire MemWrite;
wire Jump;
wire Branch;
wire ALUSrc;
wire MemToReg;
wire [2:0] ImmSel;
wire [3:0] ALUCtrl;

control_unit DUT (
    .opcode(opcode),
    .funct3(funct3),
    .funct7_5(funct7_5),
    .RegWrite(RegWrite),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .Jump(Jump),
    .Branch(Branch),
    .ALUSrc(ALUSrc),
    .MemToReg(MemToReg),
    .ImmSel(ImmSel),
    .ALUCtrl(ALUCtrl)
);

initial begin
    $display("Time\tOpcode\t\tFunct3\tF7_5\tRegWrite MemRead MemWrite Jump Branch ALUSrc MemToReg ImmSel ALUCtrl");
    $monitor("%0t\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%b\t%03b\t%04b", 
             $time, opcode, funct3, funct7_5, RegWrite, MemRead, MemWrite, Jump, Branch, ALUSrc, MemToReg, ImmSel, ALUCtrl);

opcode = 7'b0110011; // R-type: ADD
funct3 = 3'b000;
funct7_5 = 1'b0;
#10;

funct7_5 = 1'b1;  // R-type: SUB
#10;

opcode = 7'b0010011;     // I-type: ADDI
funct3 = 3'b000;
funct7_5 = 1'b0;
#10;

funct3 = 3'b110;        // I-type: ORI
#10;

opcode = 7'b0000011;     // lw (Load Word)
funct3 = 3'b010;  // don't care here
#10;

opcode = 7'b0100011;    // sw (Store Word)
#10;

opcode = 7'b1100011;    // Branch (BEQ)
funct3 = 3'b000;
#10;

opcode = 7'b1101111;    // jal
#10;

opcode = 7'b1100111;    // jalr
funct3 = 3'b000;
#10;

opcode = 7'b0110111;    // lui
#10;

opcode = 7'b0010111;    // auipc
#10;
 
opcode = 7'b1111111;    // Unknown opcode (default case)
#10;

$finish;
end
endmodule
