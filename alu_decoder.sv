module aludec (input logic opb5, 
               input logic [2:0] funct3,
               input logic funct7b5,
               input logic [1:0] ALUOp,
               output logic [2:0] ALUControl);
    logic RtypeSub;
    assign RtypeSub = funct7b5 & opb5;
    
    always_comb begin
        case (ALUOp)
            2'b00: ALUControl = 3'b010; // add (for loads/stores/AUIPC)
            2'b01: ALUControl = 3'b110; // sub (for branches)
            2'b10: begin
                // R-type and I-type ALU operations: use funct3 and funct7
                case (funct3)
                    3'b000: ALUControl = RtypeSub ? 3'b110 : 3'b010; // SUB / ADD, ADDI
                    3'b001: ALUControl = 3'b011; // SLL, SLLI
                    3'b010: ALUControl = 3'b101; // SLT, SLTI
                    3'b011: ALUControl = 3'b111; // SLTU, SLTIU
                    3'b100: ALUControl = 3'b100; // XOR, XORI
                    3'b101: ALUControl = funct7b5 ? 3'b001 : 3'b000; // SRA/SRAI : SRL/SRLI
                    3'b110: ALUControl = 3'b001; // OR, ORI
                    3'b111: ALUControl = 3'b000; // AND, ANDI
                    default: ALUControl = 3'b010;
                endcase
            end
            default: ALUControl = 3'b010;
        endcase
    end
endmodule

// ALUControl encoding:
// 3'b000: AND (also used for SRL/SRLI)
// 3'b001: OR (also used for SRA/SRAI)
// 3'b010: ADD
// 3'b011: SLL
// 3'b100: XOR
// 3'b101: SLT
// 3'b110: SUB
// 3'b111: SLTU
