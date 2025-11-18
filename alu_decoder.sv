module aludec (input logic opb5, 
               input logic [2:0] funct3,
               input logic funct7b5,
               input logic [1:0] ALUOp,
               output logic [2:0] ALUControl);

    logic RtypeSub;
    assign RtypeSub = funct7b5 & opb5;

    always_comb begin
        case (ALUOp)
            2'b00: ALUControl = 3'b010; // add
            2'b01: ALUControl = 3'b110; // sub
            2'b10: begin
                // R-type: use funct3 and funct7 (RtypeSub) to select ALU operation
                case (funct3)
                    3'b000: ALUControl = RtypeSub ? 3'b110 : 3'b010;
                    3'b111: ALUControl = 3'b000; // AND
                    3'b110: ALUControl = 3'b001; // OR
                    3'b100: ALUControl = 3'b100; // XOR
                    default: ALUControl = 3'b010;
                endcase
            end
            default: ALUControl = 3'b010;
        endcase
    end

endmodule
