`timescale 1ns / 1ps

module branch_unit (
input  [31:0] rs1,
input  [31:0] rs2,
input  [2:0] funct3,
output reg BranchTaken
);

always @(*) begin
case (funct3)
3'b000: BranchTaken = (rs1 == rs2);                     // BEQ
3'b001: BranchTaken = (rs1 != rs2);                     // BNE
3'b100: BranchTaken = ($signed(rs1) < $signed(rs2));    // BLT (signed)
3'b101: BranchTaken = ($signed(rs1) >= $signed(rs2));   // BGE (signed)
3'b110: BranchTaken = (rs1 < rs2);                      // BLTU (unsigned)
3'b111: BranchTaken = (rs1 >= rs2);                     // BGEU (unsigned)
default: BranchTaken = 0;
endcase
end

endmodule
