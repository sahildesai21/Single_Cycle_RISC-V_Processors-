`timescale 1ns / 1ps

module data_memory_tb;
reg clk;
reg rst;
reg MemRead;
reg MemWrite;
reg [31:0] addr;
reg [31:0] write_data;
reg [2:0] funct3;
wire [31:0] read_data;

data_memory DUT (
    .clk(clk),
    .rst(rst),
    .MemRead(MemRead),
    .MemWrite(MemWrite),
    .addr(addr),
    .write_data(write_data),
    .funct3(funct3),
    .read_data(read_data)
);

always #5 clk = ~clk;   // 10 ns clock

initial begin
    $dumpfile("data_memory_tb.vcd");
    $dumpvars(0, data_memory_tb);

    // Reset
    clk = 0;
    rst = 1;
    MemRead = 0;
    MemWrite = 0;
    addr = 0;
    write_data = 0;
    funct3 = 3'b000;
    #10;
    rst = 0;

    // -------------------------------
    // Test Case 1: SW (store word) and LW
    // -------------------------------
    MemWrite = 1; MemRead = 0;
    funct3 = 3'b010; // SW
    addr = 32'd0;
    write_data = 32'hDEADBEEF;
    #10;

    MemWrite = 0; MemRead = 1;
    funct3 = 3'b010; // LW
    addr = 32'd0;
    #10;

    // -------------------------------
    // Test Case 2: SH (store halfword) and LH
    // -------------------------------
    MemWrite = 1; MemRead = 0;
    funct3 = 3'b001; // SH
    addr = 32'd4;
    write_data = 32'h0000ABCD;
    #10;

    MemWrite = 0; MemRead = 1;
    funct3 = 3'b001; // LH (signed)
    addr = 32'd4;
    #10;

    funct3 = 3'b101; // LHU (unsigned)
    addr = 32'd4;
    #10;

    // -------------------------------
    // Test Case 3: SB (store byte) and LB/LBU
    // -------------------------------
    MemWrite = 1; MemRead = 0;
    funct3 = 3'b000; // SB
    addr = 32'd8;
    write_data = 32'h000000AA;
    #10;

    MemWrite = 0; MemRead = 1;
    funct3 = 3'b000; // LB (signed)
    addr = 32'd8;
    #10;

    funct3 = 3'b100; // LBU (unsigned)
    addr = 32'd8;
    #10;

    $finish;
end

endmodule
