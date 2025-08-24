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

    // ---------------- R-type ----------------
    opcode = 7'b0110011; funct3 = 3'b000; funct7_5 = 1'b0; #10; // ADD
    funct7_5 = 1'b1; #10; // SUB

    // ---------------- I-type ----------------
    opcode = 7'b0010011; funct3 = 3'b000; #10; // ADDI
    funct3 = 3'b110; #10; // ORI

    // ---------------- Load ----------------
    opcode = 7'b0000011; funct3 = 3'b010; #10; // LW

    // ---------------- Store ----------------
    opcode = 7'b0100011; funct3 = 3'b010; #10; // SW

    // ---------------- Branches ----------------
    opcode = 7'b1100011;

    funct3 = 3'b000; #10; // BEQ
    funct3 = 3'b001; #10; // BNE
    funct3 = 3'b100; #10; // BLT
    funct3 = 3'b101; #10; // BGE
    funct3 = 3'b110; #10; // BLTU
    funct3 = 3'b111; #10; // BGEU

    // ---------------- Jumps ----------------
    opcode = 7'b1101111; #10; // JAL
    opcode = 7'b1100111; funct3 = 3'b000; #10; // JALR

    // ---------------- Upper Immediate ----------------
    opcode = 7'b0110111; #10; // LUI
    opcode = 7'b0010111; #10; // AUIPC

    // ---------------- Default ----------------
    opcode = 7'b1111111; #10; // Unknown

    $finish;
end
endmodule
