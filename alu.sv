module alu (
    input logic [31:0]      SrcA,
    input logic [31:0]      SrcB,
    input logic [2:0]       ALU_control,
    output logic [31:0]     ALU_result,
    output logic            Zero
);
    localparam [2:0] ADD =              3'b000;
    localparam [2:0] SUBTRACT =         3'b001;
    localparam [2:0] SET_LESS_THAN =    3'b101;
    localparam [2:0] OR =               3'b011;
    localparam [2:0] AND =              3'b010;

    always_comb begin 
        case (ALU_control)
            ADD: ALU_result = SrcA+SrcB; 
            SUBTRACT: ALU_result = SrcA-SrcB;
            SET_LESS_THAN: ALU_result = (SrcA < SrcB) ? 1 : 0;
            OR: ALU_result = (SrcA | SrcB);
            AND: ALU_result = (SrcA & SrcB);
            default: ALU_result = 32'b0;
        endcase
    end

    always_comb begin 
        case (ALU_result)
            0: Zero = 1; 
            default: Zero = 0;
        endcase
    end

endmodule
