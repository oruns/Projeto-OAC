`timescale 1ns / 1ps

module ALUController (
    //Inputs
    input logic [2:0] ALUOp,  // 2-bit opcode field from the Controller--000: LW/SW/AUIPC; 001:Branch; 010: Rtype; 011: Itype; 100: JAL/JALR;
    input logic [6:0] Funct7,  // bits 25 to 31 of the instruction
    input logic [2:0] Funct3,  // bits 12 to 14 of the instruction

    //Output
    output logic [3:0] Operation  // operation selection for ALU
);
  assign Operation[0] = ((ALUOp == 3'b010) && (Funct3 == 3'b110)) ||  // R\I->> or
      ((ALUOp == 3'b011) && (Funct3 == 3'b000)) ||  // ADDI
      ((ALUOp == 3'b010) && (Funct3 == 3'b100) && (Funct7 == 7'b0000000)) ||  // R\I->> xor
      ((ALUOp == 3'b011) && (Funct3 == 3'b101) && (Funct7 == 7'b0000000)) ||  // R\I->>> srli
      ((ALUOp == 3'b011) && (Funct3 == 3'b101) && (Funct7 == 7'b0100000)) ||  // R\I->>> srai
      ((ALUOp == 3'b001) && (Funct3 == 3'b001)) || // BNE (1001)
      ((ALUOp == 3'b001) && (Funct3 == 3'b100));   // BLT (1011) 

  assign Operation[1] = (ALUOp == 3'b000) ||  // LW\SW
    ((ALUOp == 3'b010) && (Funct3 == 3'b000)) ||  // R\I-add
    ((ALUOp == 3'b010) && (Funct3 == 3'b000) && (Funct7 == 3'b0100000)) ||  // R\I-sub
    ((ALUOp == 3'b010) && (Funct3 == 3'b100) && (Funct7 == 7'b0000000)) ||  // R\I->> xor
    ((ALUOp == 3'b011) && (Funct3 == 3'b101) && (Funct7 == 7'b0100000)) ||  // R\I->>> srai
    ((ALUOp == 3'b011) && (Funct3 == 3'b010)) ||  // R\I-< slti
    ((ALUOp == 3'b001) && (Funct3 == 3'b101)) || // BGE (1010)
    ((ALUOp == 3'b001) && (Funct3 == 3'b100));   // BLT (1011) 

  assign Operation[2] =  ((ALUOp == 3'b010) && (Funct3 == 3'b000) && (Funct7 == 3'b0100000)) ||  // R\I-sub
      ((ALUOp == 3'b011) && (Funct3 == 3'b000)) ||  // ADDI
      ((ALUOp == 3'b011) && (Funct3 == 3'b101) && (Funct7 == 7'b0000000)) ||  // R\I->>> srli
      ((ALUOp == 3'b011) && (Funct3 == 3'b101) && (Funct7 == 7'b0100000)) ||  // R\I->>> srai
      ((ALUOp == 3'b011) && (Funct3 == 3'b001)) ||  // R\I-<< slli
      ((ALUOp == 3'b010) && (Funct3 == 3'b010)) ||  // R\I-< slt
      ((ALUOp == 3'b011) && (Funct3 == 3'b010));  // R\I-< slti

  assign Operation[3] = (ALUOp == 3'b001) ||  // BEQ 
      ((ALUOp == 3'b001) && (Funct3 == 3'b001)) ||  // BNE (1001)
      ((ALUOp == 3'b001) && (Funct3 == 3'b101)) ||  // BGE (1010) 
      ((ALUOp == 3'b001) && (Funct3 == 3'b100)) ||  // BLT (1011)
      ((ALUOp == 3'b011) && (Funct3 == 3'b000)) ||  // ADDI
      ((ALUOp == 3'b010) && (Funct3 == 3'b010)) ||  // R\I-< slt
      ((ALUOp == 3'b011) && (Funct3 == 3'b010));  // R\I-< slti
endmodule