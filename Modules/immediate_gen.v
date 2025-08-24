`timescale 1ns / 1ps

module immediate_gen(
    input [31:0] instr,
    input [2:0] ImmSel,         // 000=I, 001=S, 010=B, 011=U, 100=J
    output reg [31:0] imm_out
);
    
always @ (*) begin
    case(ImmSel)
        // I-type: addi, lw, etc.
        3'b000: imm_out = {{20{instr[31]}}, instr[31:20]};
        
        // S-type: sw, etc.
        3'b001: imm_out = {{20{instr[31]}}, instr[31:25], instr[11:7]};
        
        // B-type: beq, bne, etc.
        3'b010: imm_out = {{19{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8], 1'b0};
        
        // U-type: lui, auipc
        3'b011: imm_out = {instr[31:12], 12'b0};
        
        // J-type: jal
        3'b100: imm_out = {{11{instr[31]}}, instr[31], instr[19:12], instr[20], instr[30:21], 1'b0};
        
        default: imm_out = 32'b0;
    endcase
end

endmodule
