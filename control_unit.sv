`include "alu_decoder.sv"

module controller (input logic clk,
                   input logic reset,
                   input logic [6:0] op,
                   input logic [2:0] funct3,
                   input logic funct7b5,
                   input logic Zero,
                   output logic [1:0] ResultSrc,
                   output logic MemWrite,
                   output logic PCSrc,
                   output logic [1:0] ALUSrcA, ALUSrcB,
                   output logic AdrSrc,
                   output logic RegWrite,
                   output logic Jump,
                   output logic [2:0] ImmSrc,
                   output logic [3:0] ALUControl,
                   output logic IRWrite,
                   output logic PCWrite);

    logic [1:0] ALUOp;
    logic Branch;
    logic PCUpdate;

    localparam OP_LOAD   = 7'b0000011;
    localparam OP_STORE  = 7'b0100011;
    localparam OP_R_TYPE = 7'b0110011;
    localparam OP_I_ALU  = 7'b0010011;
    localparam OP_JAL    = 7'b1101111;
    localparam OP_BRANCH = 7'b1100011;
    localparam OP_U_TYPE = 7'b0110111;
    localparam OP_U_TYPE_2 = 7'b0010111;

    typedef enum logic [3:0] {
        FETCH    = 4'b0000,
        DECODE   = 4'b0001,
        MEMADR   = 4'b0010,
        MEMREAD  = 4'b0011,
        MEMWB    = 4'b0100,
        MEMWRITE = 4'b0101,
        EXECUTER = 4'b0110,
        EXECUTEI = 4'b0111,
        ALUWB    = 4'b1000,
        BEQ      = 4'b1001,
        JAL      = 4'b1010
    } statetype;

    statetype current_state, next_state;

    always_ff @(posedge clk, posedge reset) begin
        if (reset)
            current_state <= FETCH;
        else
            current_state <= next_state;
    end

    // Next state
    always_comb begin
        case (current_state)
            FETCH:  next_state = DECODE;
            DECODE:
                case(op)
                    OP_LOAD, OP_STORE: next_state = MEMADR;
                    OP_R_TYPE: next_state = EXECUTER;
                    OP_U_TYPE, OP_I_ALU, OP_U_TYPE_2: next_state = EXECUTEI;
                    OP_JAL: next_state = JAL;
                    OP_BRANCH: next_state = BEQ; 
                endcase  
            MEMADR: 
                case(op)
                    OP_LOAD: next_state = MEMREAD;
                    OP_STORE: next_state = MEMWRITE; 
                endcase
            EXECUTER, EXECUTEI, JAL: next_state = ALUWB;
            MEMREAD: next_state = MEMWB;
            MEMWB, MEMWRITE, ALUWB, BEQ: next_state = FETCH;
        endcase
    end

    // Output control logic for each state
    always_comb begin
        // Default values
        RegWrite = 1'b0; 
        ImmSrc = 3'bXXX; 
        ALUSrcA = 2'bXX; 
        ALUSrcB = 2'b00;
        MemWrite = 1'b0;
        ResultSrc = 2'bXX; 
        Branch = 1'b0; 
        ALUOp = 2'bXX; 
        Jump = 1'b0;
        AdrSrc = 1'b0; 
        IRWrite = 1'b0;
        PCUpdate = 1'b0;

        case (current_state)
            FETCH: begin
                AdrSrc = 1'b0;
                IRWrite = 1'b1; 
                ALUSrcA = 2'b00;  
                ALUSrcB = 2'b10; 
                ALUOp = 2'b00;  
                ResultSrc = 2'b10; 
                PCUpdate = 1'b1; 
            end

            DECODE: begin 
                ALUSrcA = 2'b10;
                ALUSrcB = 2'b01;
                ALUOp   = 2'b0;
                    // Choose immediate type based on opcode
                case(op)
                    7'b0000011: ImmSrc = 3'b000; // I-type (lw)
                    7'b0100011: ImmSrc = 3'b001; // S-type (sw)
                    7'b1100011: ImmSrc = 3'b010; // B-type
                    7'b0010111,
                    7'b0110111: ImmSrc = 3'b011; // U-type (AUIPC/LUI)
                    7'b1101111: ImmSrc = 3'b100; // JAL
                    default:    ImmSrc = 3'b000; 
                endcase
            end
            
            MEMADR: begin
                ALUSrcA = 2'b10;  
                ALUSrcB = 2'b01; 
                ALUOp = 2'b00;  
                if (op == 7'b0000011) ImmSrc = 3'b000; 
                else ImmSrc = 3'b001; 
            end
            
            MEMREAD: begin
                AdrSrc = 1'b1;   
                ResultSrc = 2'b00;
            end
            
            MEMWB: begin
                RegWrite = 1'b1;   
                ResultSrc = 2'b01; 
            end

            MEMWRITE: begin
                AdrSrc = 1'b1;
                MemWrite = 1'b1;

                // ALU is not used; provide safe defaults
                ALUSrcA = 2'b00;    // use PC or 0
                ALUSrcB = 2'b00;    // use register B or 0
                ALUOp   = 2'b00;    // ADD or dont-care

                // S-Type immediate (but not necessary here)
                ImmSrc = 3'b001;
            end

            ALUWB: begin
                ResultSrc = 2'b00;
                RegWrite = 1'b1;
            end

            EXECUTER: begin
                ALUSrcA = 2'b10;
                ALUSrcB = 2'b00;
                ALUOp   = 2'b10;
            end

            EXECUTEI: begin
                ALUSrcA = 2'b10;
                ALUSrcB = 2'b01;
                ALUOp   = 2'b10;
                ImmSrc = 3'b000; 
            end

            JAL: begin
                ALUSrcA = 2'b01;
                ALUSrcB = 2'b10;
                ALUOp   = 2'b00;
                ResultSrc = 2'b00;
                PCUpdate = 1'b1;
                ImmSrc = 3'b100; 
            end
            
            BEQ: begin
                ALUSrcA = 2'b10;
                ALUSrcB = 2'b00;
                ALUOp = 2'b01;
                ResultSrc = 2'b00;
                Branch = 1'b1;
                ImmSrc = 3'b010;
            end
            
            default: begin
                // All defaults already set above
            end
        endcase
    end

    aludec alu_decoder(op[5], funct3, funct7b5, ALUOp, ALUControl);

    assign PCSrc = Branch & Zero | Jump;
    assign PCWrite = PCUpdate | (Branch & Zero) | Jump;
endmodule
