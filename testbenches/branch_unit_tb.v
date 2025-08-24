`timescale 1ns / 1ps

module branch_unit_tb;

reg  [31:0] rs1, rs2;
reg  [2:0]  funct3;
wire       BranchTaken;

branch_unit DUT (
    .rs1(rs1),
    .rs2(rs2),
    .funct3(funct3),
    .BranchTaken(BranchTaken)
);

initial begin
    $display("Time\tfunct3\t\trs1\t\trs2\t\tBranchTaken");
    $monitor("%0t\t%b\t%h\t%h\t%b", $time, funct3, rs1, rs2, BranchTaken);

    // BEQ
    rs1 = 32'd10; rs2 = 32'd10; funct3 = 3'b000; #10;
    rs1 = 32'd10; rs2 = 32'd5;  funct3 = 3'b000; #10;

    // BNE
    rs1 = 32'd10; rs2 = 32'd5;  funct3 = 3'b001; #10;
    rs1 = 32'd20; rs2 = 32'd20; funct3 = 3'b001; #10;

    // BLT (signed)
    rs1 = -5;     rs2 = 3;      funct3 = 3'b100; #10;
    rs1 = 5;      rs2 = -3;     funct3 = 3'b100; #10;

    // BGE (signed)
    rs1 = 10;     rs2 = 10;     funct3 = 3'b101; #10;
    rs1 = -1;     rs2 = -2;     funct3 = 3'b101; #10;

    // BLTU (unsigned)
    rs1 = 32'h00000005; rs2 = 32'h0000000A; funct3 = 3'b110; #10;
    rs1 = 32'hFFFFFFF0; rs2 = 32'h0000000A; funct3 = 3'b110; #10;

    // BGEU (unsigned)
    rs1 = 32'h0000000A; rs2 = 32'h0000000A; funct3 = 3'b111; #10;
    rs1 = 32'hFFFFFFFF; rs2 = 32'h00000001; funct3 = 3'b111; #10;

    // Default
    rs1 = 1; rs2 = 2; funct3 = 3'b011; #10;
    $finish;
end

endmodule
