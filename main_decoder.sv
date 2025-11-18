module maindec (input logic [6:0] op,
                output logic [1:0] ResultSrc,
                output logic MemWrite,
                output logic Branch, ALUSrc,
                output logic RegWrite, Jump,
                output logic [2:0] ImmSrc,
                output logic [1:0] ALUOp);

    logic [11:0] controls;

    assign {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump} = controls;

    always_comb begin
        case(op)
            // RegWrite_ImmSrc_ALUSrc_MemWrite_ResultSrc_Branch_ALUOp_Jump
            7'b0000011: controls = 12'b1_000_1_0_01_0_00_0; // LOAD
            7'b0100011: controls = 12'b0_001_1_1_00_0_00_0; // STORE
            7'b0010011: controls = 12'b1_000_1_0_00_0_10_0; // OP-IMM
            7'b0110011: controls = 12'b1_000_0_0_00_0_10_0; // OP
            7'b1100011: controls = 12'b0_010_0_0_00_1_01_0; // BRANCH
            7'b0110111: controls = 12'b1_011_1_0_11_0_00_0; // LUI
            7'b0010111: controls = 12'b1_011_1_0_00_0_00_0; // AUIPC
            7'b1101111: controls = 12'b1_100_1_0_10_0_00_1; // JAL
            7'b1100111: controls = 12'b1_000_1_0_10_0_00_1; // JALR
            default:    controls = 12'b0_000_0_0_00_0_00_0;
        endcase
    end

endmodule

// Encodings to keep in minds
// IMM Src
// 000: I-type
// 001: S-type
// 010: B-type 
// 011: U-type
// 100: J-type

// ALU Op
// 00: Force ADD
// 01: Force SUB
// 10: Use funct3/funct7 fields (R-type and I-type ALU ops)

// Result Src
// 00: ALU result
// 01: Memory read data
// 10: PC + 4 (for JAL/JALR)
// 11: Immediate value (for LUI)

