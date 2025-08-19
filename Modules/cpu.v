`timescale 1ns / 1ps

module cpu_top(
    input clk,
    input rst
    );

// ---------------- PC ----------------
wire [31:0] pc_out;
reg [31:0] pc_in;
reg pc_write;

pc pc_integration (
    .clk(clk),
    .rst(rst),
    .pc_write(pc_write),
    .pc_in(pc_in),
    .pc_out(pc_out)
);

// ---------------- Instruction Memory ----------------
wire [31:0] instr;
instr_memory instr_memory (
    .addr(pc_out),
    .instr(instr)
);  

// ---------------- Instruction Decode ----------------
wire [6:0] opcode   = instr[6:0];
wire [2:0] funct3   = instr[14:12];
wire       funct7_5 = instr[30];

// ---------------- Control Unit ----------------
wire RegWrite_ctrl, MemRead_ctrl, MemWrite_ctrl, Jump_ctrl, Branch_ctrl, ALUSrc_ctrl, MemToReg_ctrl;
wire [2:0] ImmSel_ctrl;
wire [3:0] ALUCtrl_ctrl;

control_unit u_ctrl (
    .opcode(opcode),
    .funct3(funct3),
    .funct7_5(funct7_5),
    .RegWrite(RegWrite_ctrl),
    .MemRead(MemRead_ctrl),
    .MemWrite(MemWrite_ctrl),
    .Jump(Jump_ctrl),
    .Branch(Branch_ctrl),
    .ALUSrc(ALUSrc_ctrl),
    .MemToReg(MemToReg_ctrl),
    .ImmSel(ImmSel_ctrl),
    .ALUCtrl(ALUCtrl_ctrl)
);

// ---------------- Immediate Generator ----------------
wire [31:0] imm;
immediate_gen u_imm (
    .instr(instr),
    .ImmSel(ImmSel_ctrl),
    .imm_out(imm)
);   

// ---------------- Register File ----------------
wire [31:0] reg_rs1_data, reg_rs2_data;
wire [4:0] rs1 = instr[19:15];
wire [4:0] rs2 = instr[24:20];
wire [4:0] rd  = instr[11:7];

// Writeback signals
reg wb_RegWrite;
reg [4:0] wb_rd;
reg [31:0] wb_write_data;

register_file u_rf (
    .clk(clk),
    .rst(rst),
    .RegWrite(wb_RegWrite),
    .rs1(rs1),
    .rs2(rs2),
    .rd(wb_rd),
    .write_data(wb_write_data),
    .read_data1(reg_rs1_data),
    .read_data2(reg_rs2_data)
);

// ---------------- ALU input mux ----------------
wire [31:0] alu_b;
wire [31:0] imm_shifted = imm;

mux2 #(.WIDTH(32)) u_alu_src_mux (
    .in0(reg_rs2_data),
    .in1(imm_shifted),
    .sel(ALUSrc_ctrl),
    .out(alu_b)
);

// ---------------- ALU ----------------
wire [31:0] alu_result;
wire        alu_zero;

alu u_alu (
    .a(reg_rs1_data),
    .b(alu_b),
    .ALUctrl(ALUCtrl_ctrl),
    .result(alu_result),
    .zero(alu_zero)
);

// ---------------- PC Adders ----------------
wire [31:0] pc_plus_4;
wire [31:0] pc_branch;

pc_adder u_pc_adder (
    .pc_current(pc_out),
    .imm(imm),
    .pc_plus_4(pc_plus_4),
    .pc_branch(pc_branch)
);

// ---------------- Branch Decision ----------------
wire branch_taken = Branch_ctrl & alu_zero;

// ---------------- Data Memory ----------------
reg        MemRead_sig;
reg        MemWrite_sig;
reg [31:0] MemAddr_sig;
reg [31:0] MemWriteData_sig;
reg [2:0]  MemFunct3_sig;
wire [31:0] MemReadData_wire;

data_memory u_dmem (
    .clk(clk),
    .rst(rst),
    .MemRead(MemRead_sig),
    .MemWrite(MemWrite_sig),
    .addr(MemAddr_sig),
    .write_data(MemWriteData_sig),
    .funct3(MemFunct3_sig),
    .read_data(MemReadData_wire)
);

// ---------------- Pipeline Control (2-phase FSM) ----------------
reg phase;

// Saved pipeline registers
reg [31:0] saved_alu_result;
reg [4:0]  saved_rd;
reg        saved_RegWrite;
reg        saved_MemToReg;
reg [31:0] saved_pc_plus4;

// ---------------- Debug signals ----------------
wire [31:0] dbg_pc        = pc_out;
wire [31:0] dbg_instr     = instr;
wire [31:0] dbg_alu_result= alu_result;
wire [31:0] dbg_mem_rdata = MemReadData_wire;
wire [4:0]  dbg_wb_rd     = wb_rd;
wire [31:0] dbg_wb_data   = wb_write_data;

// ---------------- Main FSM ----------------
always @(posedge clk) begin
    if (rst) begin
        phase <= 1'b0;
        pc_write <= 1'b0;
        pc_in <= 32'b0;

        MemRead_sig <= 1'b0;
        MemWrite_sig <= 1'b0;
        MemAddr_sig <= 32'b0;
        MemWriteData_sig <= 32'b0;
        MemFunct3_sig <= 3'b010;

        saved_alu_result <= 32'b0;
        saved_rd <= 5'b0;
        saved_RegWrite <= 1'b0;
        saved_MemToReg <= 1'b0;
        saved_pc_plus4 <= 32'b0;

        wb_RegWrite <= 1'b0;
        wb_rd <= 5'b0;
        wb_write_data <= 32'b0;
    end else begin
        if (phase == 1'b0) begin
            // ---------------- Phase 0: Execute ----------------
            MemAddr_sig      <= alu_result;
            MemWriteData_sig <= reg_rs2_data;
            MemFunct3_sig    <= funct3;
            MemRead_sig      <= MemRead_ctrl;
            MemWrite_sig     <= MemWrite_ctrl;

            saved_alu_result <= alu_result;
            saved_rd         <= rd;
            saved_RegWrite   <= RegWrite_ctrl;
            saved_MemToReg   <= MemToReg_ctrl;
            saved_pc_plus4   <= pc_plus_4;

            // --- TEMP FIX: disable jumps/jalr ---
            if (branch_taken)
                pc_in <= pc_branch;
            else
                pc_in <= pc_plus_4;

            pc_write   <= 1'b0;
            wb_RegWrite<= 1'b0;
            wb_rd      <= 5'b0;
            wb_write_data <= 32'b0;

            phase <= 1'b1;

        end else begin
            // ---------------- Phase 1: Writeback ----------------
            if (saved_MemToReg)
                wb_write_data <= MemReadData_wire;
            else
                wb_write_data <= saved_alu_result;

            wb_RegWrite <= saved_RegWrite;
            wb_rd       <= saved_rd;

            pc_write <= 1'b1;

            MemRead_sig  <= 1'b0;
            MemWrite_sig <= 1'b0;

            phase <= 1'b0;
        end
    end
end

endmodule
