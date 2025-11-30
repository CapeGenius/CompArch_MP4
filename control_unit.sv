`include "main_decoder.sv"
`include "alu_decoder.sv"

// things to do --> create a nested case statement that determines next states based on op code and current state

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
                   output logic [2:0] ALUControl,
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
                    OP_I_ALU: next_state = EXECUTEI;
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
            MEMWB, MEM_WRITE, ALUWB, BEQ: next_state = FETCH;
        endcase
    end

    // Output control logic for each state
    always_comb begin
        // Default values
        RegWrite = 1'b0; 
        ImmSrc = 3'b000; 
        ALUSrcA = 2'b00; ALUSrcB = 2'b00;
        MemWrite = 1'b0;
        ResultSrc = 2'b00; 
        Branch = 1'b0; 
        ALUOp = 2'b00; 
        Jump = 1'b0;
        AdrSrc = 1'b0; 
        IRWrite = 1'b0;
        PCUpdate = 1'b0;

        case (current_state)
            FETCH: begin
                AdrSrc = 1'b0;      // Address from PC
                IRWrite = 1'b1;     // Load instruction into IR
                ALUSrcA = 2'b00;    // PC
                ALUSrcB = 2'b10;    // 4
                ALUOp = 2'b00;      // ADD
                ResultSrc = 2'b10;  // ALUResult
                PCUpdate = 1'b1;    // Update PC with PC+4
            end

            DECODE: begin 
                ALUSrcA = 2'b10;
                ALUSrcB = 2'b01;
                ALUOp   = 2'b0;
            end
            
            MEMADR: begin
                ALUSrcA = 2'b10;    // Register A
                ALUSrcB = 2'b01;    // Immediate
                ALUOp = 2'b00;      // ADD for memory address
                if (op == 7'b0000011) ImmSrc = 3'b000;  // I-type for LW
                else ImmSrc = 3'b001;                   // S-type for SW
            end
            
            MEMREAD: begin
                AdrSrc = 1'b1;      // Address from ALU
                ResultSrc = 2'b00;  // ALU result (for address)
            end
            
            MEMWB: begin
                RegWrite = 1'b1;    // Write to register
                ResultSrc = 2'b01;  // Memory data
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
