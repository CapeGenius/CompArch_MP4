module aludec (input logic opb5, 
               input logic [2:0] funct3,
               input logic funct7b5,
               input logic [1:0] ALUOp,
               output logic [3:0] ALUControl);
    logic RtypeSub;
    assign RtypeSub = funct7b5 & opb5;
    
    always_comb begin
        case (ALUOp)
            2'b00: ALUControl = 4'b0000; // add (for loads/stores/AUIPC)
            2'b01: ALUControl = 4'b0001; // sub (for branches)
            2'b10: begin
                // R-type and I-type ALU operations: use funct3 and funct7
                case (funct3)
                    3'b000: ALUControl = RtypeSub ? 4'b0001 : 4'b0000; // SUB / ADD, ADDI
                    3'b111: ALUControl = 4'b0010; // AND, ANDI
                    3'b110: ALUControl = 4'b0011; // OR, ORI
                    3'b100: ALUControl = 4'b0100; // XOR, XORI
                    3'b010: ALUControl = 4'b0101; // SLT, SLTI
                    3'b011: ALUControl = 4'b0110; // SLTU
                    3'b001: ALUControl = 4'b0111; // SLL, SLLI
                    3'b101: begin
                        if (funct7b5) ALUControl = 4'b1001; // SRA, SRAI
                        else  ALUControl = 4'b1000; // SRL, SRLI
                    end
                    default: ALUControl = 4'b0000;
                endcase
            end
            default: ALUControl = 4'b0000;
        endcase
    end
endmodule
