`timescale 1ns / 1ps

module cpu_top(
    input clk,
    input rst
);

// ---------------- PC ----------------
wire [31:0] pc_out;
reg  [31:0] pc_in;
reg         pc_write;

pc u_pc (
    .clk(clk),
    .rst(rst),
    .pc_write(pc_write),
    .pc_in(pc_in),
    .pc_out(pc_out)
);

// ---------------- Instruction Memory ----------------
wire [31:0] instr;
instr_memory u_imem (
    .addr(pc_out),
    .instr(instr)
);

// ---------------- Instruction Fields ----------------
wire [6:0] opcode   = instr[6:0];
wire [2:0] funct3   = instr[14:12];
wire       funct7_5 = instr[30];
wire [4:0] rs1      = instr[19:15];
wire [4:0] rs2      = instr[24:20];
wire [4:0] rd       = instr[11:7];

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
wire [31:0] rs1_data, rs2_data;

reg         wb_RegWrite;
reg  [4:0]  wb_rd;
reg  [31:0] wb_write_data;

register_file u_rf (
    .clk(clk),
    .rst(rst),
    .RegWrite(wb_RegWrite),
    .rs1(rs1),
    .rs2(rs2),
    .rd(wb_rd),
    .write_data(wb_write_data),
    .read_data1(rs1_data),
    .read_data2(rs2_data)
);

// ---------------- ALU input mux ----------------
wire [31:0] alu_b;
mux2 #(.WIDTH(32)) u_alu_src_mux (
    .in0(rs2_data),
    .in1(imm),
    .sel(ALUSrc_ctrl),
    .out(alu_b)
);

// ---------------- ALU ----------------
wire [31:0] alu_result;
wire        alu_zero;

alu u_alu (
    .a(rs1_data),
    .b(alu_b),
    .ALUctrl(ALUCtrl_ctrl),
    .result(alu_result),
    .zero(alu_zero)
);

// ---------------- Branch Unit ----------------
wire branch_taken_raw;
branch_unit u_branch (
    .rs1(rs1_data),
    .rs2(rs2_data),
    .funct3(funct3),
    .BranchTaken(branch_taken_raw)
);
wire branch_taken = Branch_ctrl & branch_taken_raw;

// ---------------- PC Adders / Targets ----------------
wire [31:0] pc_plus_4;
wire [31:0] pc_branch;       // PC + B/J immediate (B or J already LSB=0 in imm)
assign pc_plus_4 = pc_out + 32'd4;
assign pc_branch = pc_out + imm;

wire is_jal  = (opcode == 7'b1101111);
wire is_jalr = (opcode == 7'b1100111);

// RISC-V JALR target: (rs1 + imm) & ~1
wire [31:0] jalr_target = (rs1_data + imm) & 32'hFFFF_FFFE;

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

// ---------------- 2-phase FSM (phase 0: Execute, phase 1: Writeback) ----------------
reg phase;

// Saved pipeline registers for WB
reg [31:0] saved_alu_result;
reg [4:0]  saved_rd;
reg        saved_RegWrite;
reg        saved_MemToReg;
reg        saved_Jump;
reg [31:0] saved_pc_plus4;

reg [31:0] next_pc_calc;   // compute in phase 0, use in phase 1

// ---------------- Debug (kept for TB visibility) ----------------
wire [31:0] dbg_pc        = pc_out;
wire [31:0] dbg_instr     = instr;
wire [31:0] dbg_alu_res   = alu_result;
wire [31:0] dbg_mem_rdata = MemReadData_wire;
wire [4:0]  dbg_wb_rd     = wb_rd;
wire [31:0] dbg_wb_data   = wb_write_data;

always @(posedge clk) begin
    if (rst) begin
        phase <= 1'b0;

        pc_write <= 1'b0;
        pc_in    <= 32'b0;

        MemRead_sig      <= 1'b0;
        MemWrite_sig     <= 1'b0;
        MemAddr_sig      <= 32'b0;
        MemWriteData_sig <= 32'b0;
        MemFunct3_sig    <= 3'b010;

        saved_alu_result <= 32'b0;
        saved_rd         <= 5'b0;
        saved_RegWrite   <= 1'b0;
        saved_MemToReg   <= 1'b0;
        saved_Jump       <= 1'b0;
        saved_pc_plus4   <= 32'b0;

        wb_RegWrite      <= 1'b0;
        wb_rd            <= 5'b0;
        wb_write_data    <= 32'b0;

        next_pc_calc     <= 32'b0;

    end else begin
        if (phase == 1'b0) begin
            // ---------------- Phase 0: Execute & Memory address setup ----------------
            // Drive memory interface
            MemAddr_sig      <= alu_result;
            MemWriteData_sig <= rs2_data;
            MemFunct3_sig    <= funct3;
            MemRead_sig      <= MemRead_ctrl;
            MemWrite_sig     <= MemWrite_ctrl;

            // Save for WB stage
            saved_alu_result <= alu_result;
            saved_rd         <= rd;
            saved_RegWrite   <= RegWrite_ctrl;
            saved_MemToReg   <= MemToReg_ctrl;
            saved_Jump       <= Jump_ctrl;
            saved_pc_plus4   <= pc_plus_4;

            // Next PC calculation (priority: JALR > JAL > BranchTaken > +4)
            if (is_jalr)         next_pc_calc <= jalr_target;
            else if (is_jal)     next_pc_calc <= pc_branch;
            else if (branch_taken) next_pc_calc <= pc_branch;
            else                  next_pc_calc <= pc_plus_4;

            // Hold PC write until WB phase
            pc_write    <= 1'b0;

            // No reg write during execute
            wb_RegWrite   <= 1'b0;
            wb_rd         <= 5'b0;
            wb_write_data <= 32'b0;

            phase <= 1'b1;

        end else begin
            // ---------------- Phase 1: Writeback & PC update ----------------
            // Write-back mux: Jump writes PC+4 (link), Loads write MemReadData, else ALU result
            if (saved_Jump)          wb_write_data <= saved_pc_plus4;
            else if (saved_MemToReg) wb_write_data <= MemReadData_wire;
            else                     wb_write_data <= saved_alu_result;

            wb_RegWrite <= saved_RegWrite;
            wb_rd       <= saved_rd;

            // Commit next PC
            pc_in    <= next_pc_calc;
            pc_write <= 1'b1;

            // Deassert mem controls after use
            MemRead_sig  <= 1'b0;
            MemWrite_sig <= 1'b0;

            phase <= 1'b0;
        end
    end
end

endmodule
