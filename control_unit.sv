`include "main_decoder.sv"
`include "alu_decoder.sv"

module controller (input logic [6:0] op,
                   input logic [2:0] funct3,
                   input logic funct7,
                   input logic Zero,
                   output logic [1:0] ResultSrc,
                   output logic MemWrite,
                   output logic PCSrc,
                   output logic ALUSrc,
                   output logic RegWrite,
                   output logic Jump,
                   output logic [1:0] ImmSrc,
                   output logic [2:0] ALUControl);
    logic [1:0] ALUOp;
    logic Branch;

    maindec md(op, ResultSrc, MemWrite, Branch, ALUSrc, RegWrite, Jump, ImmSrc, ALUOp);
    aludec ad(op[5], funct3, funct7, ALUOp, ALUControl);

    assign PCSrc = Branch & Zero | Jump;
endmodule
