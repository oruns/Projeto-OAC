`timescale 1ns / 1ps

module BranchUnit #(
    parameter PC_W = 9
) (
    input logic [PC_W-1:0] Cur_PC,
    input logic [31:0] Imm,
    input logic Branch,
    input logic Jump,
    input logic Jalr,
    input Halt_com,        // Input correto
    input logic [31:0] AluResult,
    output logic [31:0] PC_Imm,
    output logic [31:0] PC_Four,
    output logic [31:0] BrPC,
    output logic PcSel
);

  logic Branch_Sel;
  logic [31:0] PC_Full;

  assign PC_Full = {23'b0, Cur_PC};

  assign PC_Imm = (Jalr) ? AluResult : PC_Full + Imm;
  assign PC_Four = PC_Full + 32'b100;
  
  // Lógica de Branch padrão
  assign Branch_Sel = (Branch && AluResult[0]) || Jump; 


  assign BrPC = (Halt_com == 1) ? (PC_Four - 4) : (Branch_Sel) ? PC_Imm : 32'b0;

  assign PcSel = Branch_Sel || Halt_com; // 1:branch is taken; 0:branch is not taken(choose pc+4)

endmodule