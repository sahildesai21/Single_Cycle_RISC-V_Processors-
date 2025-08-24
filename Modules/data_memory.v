`timescale 1ns / 1ps

module data_memory (
input         clk,
input         rst,        
input         MemRead,    
input         MemWrite,   
input  [31:0] addr,       
input  [31:0] write_data, 
input  [2:0]  funct3,
output reg [31:0] read_data 
);

    
reg [7:0] mem [0:1023];     // Byte-addressable memory (1024 bytes = 256 words)
reg [9:0] addr_reg;         // registered address for synchronous read
integer i;

initial begin
$readmemh("data.mem", mem);
end

always @(posedge clk) begin
if (rst) begin
for (i = 0; i < 1024; i = i + 1)
    mem[i] <= 8'b0;
    read_data <= 32'b0;
    addr_reg <= 10'b0;
end else begin
if (MemWrite) begin
    case (funct3)
    3'b000: mem[addr[9:0]] <= write_data[7:0]; // SB
    3'b001: begin // SH
    mem[addr[9:0]]     <= write_data[7:0];
    mem[addr[9:0] + 1] <= write_data[15:8];
    end
    3'b010: begin // SW
    mem[addr[9:0]]     <= write_data[7:0];
    mem[addr[9:0] + 1] <= write_data[15:8];
    mem[addr[9:0] + 2] <= write_data[23:16];
    mem[addr[9:0] + 3] <= write_data[31:24];
    end
    endcase
    end
    addr_reg <= addr[9:0];
    if (MemRead) begin
    case (funct3)
    3'b000: read_data <= {{24{mem[addr_reg][7]}},   // LB
            mem[addr_reg]};
    3'b001: read_data <= {{16{mem[addr_reg + 1][7]}},   // LH
            mem[addr_reg + 1], mem[addr_reg]};
    3'b010: read_data <= {mem[addr_reg + 3], mem[addr_reg + 2], // LW
            mem[addr_reg + 1], mem[addr_reg]};
     3'b100: read_data <= {24'b0, mem[addr_reg]};               // LBU
     3'b101: read_data <= {16'b0, mem[addr_reg + 1], mem[addr_reg]};    // LHU
     default: read_data <= 32'b0;
     endcase
     end else begin
     read_data <= 32'b0;
     end
   end
end

endmodule
