`timescale 1ns / 1ps

module immediate_gen_tb;
    reg [31:0] instr;
    reg [2:0] ImmSel;
    wire [31:0] imm_out;

    immediate_gen DUT (
        .instr(instr),
        .ImmSel(ImmSel),
        .imm_out(imm_out)
    );

    initial begin
        $display("Time\tImmSel\tInstruction\t\tImmediate");
        $monitor("%0t\t%b\t%h\t%h", $time, ImmSel, instr, imm_out);

        // I-type (ADDI x1, x2, -5)
        instr = 32'b11111111101100010000000010010011;
        ImmSel = 3'b000; // I-type
        #10;

        // S-type (SW x1, -64(x2))
        instr = 32'b11111100000000010010000000100011;
        ImmSel = 3'b001; // S-type
        #10;

        // B-type (BEQ x1, x2, 0)
        instr = 32'b00000000010000010000000001100011;
        ImmSel = 3'b010; // B-type
        #10;

        // U-type (LUI x1, 0xABCD0)
        instr = 32'b10101011110011010000000010110111;
        ImmSel = 3'b011; // U-type
        #10;

        // J-type (JAL x1, -56)
        instr = 32'b11111111110000000000000001101111;
        ImmSel = 3'b100; // J-type
        #10;

        // Default
        instr = 32'b0;
        ImmSel = 3'b111;
        #10;

        $finish;
    end
endmodule
