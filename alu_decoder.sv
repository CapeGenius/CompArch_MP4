module aludec (input logic opb5, 
               input logic [2:0] funct3,
               input logic funct7b5,
               input logic [1:0] ALUOp,
               output logic [2:0] ALUControl);
    logic RtypeSub;
    assign RtypeSub = funct7b5 & opb5;
    
    always_comb begin
        case (ALUOp)
            2'b00: ALUControl = 3'b000; // add (for loads/stores/AUIPC)
            2'b01: ALUControl = 3'b001; // sub (for branches)
            2'b10: begin
                // R-type and I-type ALU operations: use funct3 and funct7
                case (funct3)
                    3'b000: ALUControl = RtypeSub ? 3'b001 : 3'b000; // SUB / ADD, ADDI
                    3'b010: ALUControl = 3'b101; // SLT, SLTI
                    3'b110: ALUControl = 3'b011; // OR, ORI
                    3'b111: ALUControl = 3'b010; // AND, ANDI
                    default: ALUControl = 3'b000;
                endcase
            end
            default: ALUControl = 3'b000;
        endcase
    end
endmodule

// ALUControl encoding
// 3'b000: ADD
// 3'b001: SUBTRACT  
// 3'b010: AND
// 3'b011: OR
// 3'b101: SET_LESS_THAN
