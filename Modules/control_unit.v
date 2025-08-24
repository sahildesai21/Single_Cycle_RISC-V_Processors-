`timescale 1ns / 1ps

module control_unit(
input [6:0] opcode,         // instr[6:0]
input [2:0] funct3,          // instr[14:12]
input funct7_5,              // instr[30]
output reg RegWrite,
output reg MemRead,
output reg MemWrite,
output reg Jump,
output reg Branch,
output reg ALUSrc,
output reg MemToReg,
output reg [2:0] ImmSel,    // 000: I-type, 001: S-type, 010: B-type, 011: U-type, 100: J-type
output reg [3:0] ALUCtrl    // Custom encoding to drive the ALU    
    );
    
    
always @ (*) begin 

RegWrite = 0;
MemRead = 0;
MemWrite = 0;
Jump = 0;
Branch = 0;
ALUSrc = 0;
MemToReg = 0;
ImmSel = 3'b000;
ALUCtrl = 4'b0000;


case(opcode)

7'b0110011: begin           // R-Type: add, sub, sll, sra, slt, etc.
    RegWrite = 1;
    ALUSrc = 0;
    case({funct7_5,funct3})
    4'b0000: ALUCtrl = 4'b0000; // ADD
    4'b1000: ALUCtrl = 4'b0001; // SUB
    4'b0001: ALUCtrl = 4'b0101; // SLL
    4'b0101: ALUCtrl = 4'b0110; // SRL
    4'b1101: ALUCtrl = 4'b0111; // SRA
    4'b0010: ALUCtrl = 4'b1000; // SLT
    4'b0011: ALUCtrl = 4'b1001; // SLTU
    4'b0111: ALUCtrl = 4'b0010; // AND
    4'b0110: ALUCtrl = 4'b0011; // OR
    endcase
    end 

7'b0010011 : begin       // I-Type: addi, lw, jalr, andi, ori
    RegWrite = 1;       // Arithmetic immediate
    ALUSrc = 1;
    ImmSel = 3'b000;     // I-type
    case(funct3)
    3'b000 : ALUCtrl = 4'b0000;     // ADDI
    3'b111 : ALUCtrl = 4'b0111;     // ANDI
    3'b110 : ALUCtrl = 4'b1000;     // ORI
    endcase
    end
    
7'b0000011 : begin         // lw (Load Word – loads a 32-bit word from memory)
    RegWrite = 1;
    MemRead = 1;
    MemToReg = 1;
    ALUSrc = 1;
    ImmSel = 3'b000;
    ALUCtrl = 4'b0000;      //ADD
    end
    
7'b0100011 : begin          // sw (Store Word – stores a 32-bit word to memory)
    ALUSrc = 1;
    MemWrite = 1;
    ImmSel = 3'b001;     // S-type (Store)
    ALUCtrl = 4'b0000;   // ADD
    end
    
7'b1100011 : begin      // Branch (beq)
     Branch = 1;
    ALUSrc = 0;
    ImmSel = 3'b010;        // B-type (Branch)
    case(funct3)
        3'b000 : ALUCtrl = 4'b0001; // BEQ (uses SUB)
        3'b001 : ALUCtrl = 4'b0001; // BNE (uses SUB)
        3'b100 : ALUCtrl = 4'b1000; // BLT (signed compare)
        3'b101 : ALUCtrl = 4'b1000; // BGE (signed compare)
        3'b110 : ALUCtrl = 4'b1001; // BLTU (unsigned compare)
        3'b111 : ALUCtrl = 4'b1001; // BGEU (unsigned compare)
        default: ALUCtrl = 4'b0000; // NOP / Safe default
    endcase
    end
    
7'b1101111 : begin      // jal (Jump and Link – jump to address and save PC+4)
    RegWrite = 1;
    Jump = 1;
    ImmSel = 3'b100;    // J-type (Jump)
    end
    
7'b1100111 : begin      // jalr (Jump and Link Register – indirect jump using register	)
    RegWrite = 1;
    Jump = 1;
    ALUSrc = 1;
    ImmSel = 3'b000;    // I-type
    end
    
7'b0110111 : begin      // lui (Load Upper Immediate – loads constant into upper bits)
    RegWrite = 1;
    ImmSel = 3'b011;    // U-type
    end
    
7'b0010111 : begin      // auipc (Add Upper Immediate to PC – PC-relative addressing)
    RegWrite = 1;
    ImmSel = 3'b011;
    end
    
default : begin
    RegWrite  = 0;
    ALUSrc    = 0;
    MemRead   = 0;
    MemWrite  = 0;
    MemToReg  = 0;
    Branch    = 0;
    Jump      = 0;
    ALUCtrl   = 4'b0000; 
    ImmSel    = 3'b000;  
    end
endcase

end    
endmodule
