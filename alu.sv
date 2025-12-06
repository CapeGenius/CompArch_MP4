module alu (
    input logic [31:0]      SrcA,
    input logic [31:0]      SrcB,
    input logic [3:0]       ALU_control,
    output logic [31:0]     ALU_result,
    output logic            Zero
);
    localparam [3:0] ADD =                      4'b0000;
    localparam [3:0] SUBTRACT =                 4'b0001;
    localparam [3:0] AND =                      4'b0010;
    localparam [3:0] OR =                       4'b0011;
    localparam [3:0] XOR =                      4'b0100;
    localparam [3:0] SET_LESS_THAN =            4'b0101;
    localparam [3:0] SET_LESS_THAN_UNSIGNED =   4'b0110;
    localparam [3:0] SHIFT_LEFT_LOGICAL =       4'b0111;
    localparam [3:0] SHIFT_RIGHT_LOGICAL =      4'b1000;
    localparam [3:0] SHIFT_RIGHT_ARITHMETIC =   4'b1001;

    always_comb begin 
        case (ALU_control)
            ADD: ALU_result = SrcA+SrcB; 
            SUBTRACT: ALU_result = SrcA-SrcB;
            AND: ALU_result = (SrcA & SrcB);
            OR: ALU_result = (SrcA | SrcB);
            XOR: ALU_result = (SrcA ^ SrcB);
            SET_LESS_THAN: ALU_result = ($signed(SrcA) < $signed(SrcB)) ? 1 : 0;
            SET_LESS_THAN_UNSIGNED: ALU_result = (SrcA < SrcB) ? 1 : 0;
            SHIFT_LEFT_LOGICAL: ALU_result = SrcA << SrcB[4:0];
            SHIFT_RIGHT_LOGICAL: ALU_result = SrcA >> SrcB[4:0];
            SHIFT_RIGHT_ARITHMETIC: ALU_result = $signed(SrcA) >>> SrcB[4:0];
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
