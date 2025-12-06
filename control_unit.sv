`include "alu_decoder.sv"

module controller (input logic clk,
                   input logic reset,
                   input logic [6:0] op,
                   input logic [2:0] funct3,
                   input logic funct7b5,
                   input logic Zero,
                   input logic ALUResultLSB,  // LSB of ALU result
                   output logic [2:0] ResultSrc,
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
    
    string cycle_state = "";

    localparam OP_LOAD   = 7'b0000011;
    localparam OP_STORE  = 7'b0100011;
    localparam OP_R_TYPE = 7'b0110011;
    localparam OP_I_ALU  = 7'b0010011;
    localparam OP_I_JALR = 7'b1100111;
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
        JAL      = 4'b1010,
        BUFFER_MEM_WRITE = 4'b1111
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
                    OP_U_TYPE, OP_I_ALU, OP_I_JALR, OP_U_TYPE_2: next_state = EXECUTEI;
                    OP_JAL: next_state = JAL;
                    OP_BRANCH: next_state = BEQ; 
                    default: next_state = FETCH;  // <---
                endcase  
            MEMADR: 
                case(op)
                    OP_LOAD: next_state = MEMREAD;
                    OP_STORE: next_state = MEMWRITE; 
                    default:   next_state = FETCH;
                endcase
            EXECUTER, EXECUTEI, JAL: next_state = ALUWB;
            MEMREAD: next_state = MEMWB;
            MEMWRITE: next_state = BUFFER_MEM_WRITE;
            MEMWB, BUFFER_MEM_WRITE, ALUWB, BEQ: next_state = FETCH;
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
                ResultSrc = 3'b010;
                PCUpdate = 1'b1; 
            end

            DECODE: begin 
                if (op == OP_JAL || op == OP_BRANCH)
                    ALUSrcA = 2'b01;  // old_PC
                else
                    ALUSrcA = 2'b10;  // stored_read_data_1 (for JALR)
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
                ResultSrc = 3'b000;
                if (op == 7'b0000011) ImmSrc = 3'b000; 
                else ImmSrc = 3'b001; 
            end
            
            MEMREAD: begin
                AdrSrc = 1'b1;   
                ResultSrc = 3'b000;
            end
            
            MEMWB: begin
                RegWrite = 1'b1;   
                ResultSrc = 3'b001;
            end

            MEMWRITE: begin
                AdrSrc = 1'b1;
                MemWrite = 1'b1;
                ResultSrc = 3'b000;

                // // ALU is not used; provide safe defaults
                ALUSrcA = 2'b00;    // use PC or 0
                ALUSrcB = 2'b00;    // use register B or 0
                ALUOp   = 2'b00;    // ADD or dont-care

                // S-Type immediate (but not necessary here)
                ImmSrc = 3'b001;
            end

            ALUWB: begin
                if (op == OP_U_TYPE) begin // LUI
                    ResultSrc = 3'b011;
                    ImmSrc = 3'b011;
                end
                else if (op == OP_JAL || op == OP_I_JALR) begin
                    ResultSrc = 3'b100;  // return_address (old_PC+4)
                end
                else begin
                    ResultSrc = 3'b000;
                end
                RegWrite = 1'b1;
            end

            EXECUTER: begin
                ALUSrcA = 2'b10;
                ALUSrcB = 2'b00;
                ALUOp   = 2'b10;
            end

            EXECUTEI: begin
                case (op)
                    //LUI
                    OP_U_TYPE: begin
                        ALUSrcA = 2'b10;
                        ALUSrcB = 2'b01;
                        ALUOp   = 2'b00;
                        ImmSrc = 3'b011;
                        ResultSrc = 3'b011;
                    end 

                    //AUIPC
                    OP_U_TYPE_2: begin
                        ALUSrcA = 2'b01;
                        ALUSrcB = 2'b01;
                        ALUOp   = 2'b00;
                        ImmSrc = 3'b011;
                    end

                    // I-type ALU
                    default: begin
                        ALUSrcA = 2'b10;
                        ALUSrcB = 2'b01;
                        ALUOp   = 2'b10;
                        // Use special immediate format for shift instructions
                        if (funct3 == 3'b001 || funct3 == 3'b101)
                            ImmSrc = 3'b101;  // Shift immediate (5-bit)
                        else
                            ImmSrc = 3'b000;  // Regular I-type (12-bit)
                    end
                endcase
            end

            JAL: begin
                ALUSrcA = 2'b01;
                ALUSrcB = 2'b01;
                ALUOp   = 2'b00;
                ResultSrc = 3'b000;
                PCUpdate = 1'b1;
                ImmSrc = 3'b100; 
                Jump = 1'b1;
            end
            
            BEQ: begin
                ALUSrcA = 2'b10;
                ALUSrcB = 2'b00;
                ResultSrc = 3'b000;
                Branch = 1'b1;
                ImmSrc = 3'b010;
                // Signal branch comparisons to ALU decoder
                ALUOp = 2'b11;
            end
            
            default: begin
                // All defaults already set above
            end
        endcase
    end
    //string for state name
    always_comb begin
        cycle_state = "";
        case(current_state)
            FETCH:      cycle_state = "FETCH";  
            DECODE:     cycle_state = "DECODE";
            MEMADR:     cycle_state = "MEMADR";
            MEMREAD:    cycle_state = "MEMREAD";
            MEMWB:      cycle_state = "MEMWB";
            MEMWRITE:   cycle_state = "MEMWRITE";
            BUFFER_MEM_WRITE: cycle_state = "BUFFER_MEM_WRITE";
            EXECUTER:   cycle_state = "EXECUTER";
            EXECUTEI:   cycle_state = "EXECUTEI";
            ALUWB:      cycle_state = "ALUWB";
            BEQ:        cycle_state = "BEQ";
            JAL:        cycle_state = "JAL";
        endcase
        
    end

    aludec alu_decoder(op[5], funct3, funct7b5, ALUOp, ALUControl);

    logic BranchTaken;
    always_comb begin
        if (Branch) begin
            case (funct3)
                3'b000: BranchTaken = Zero;            // BEQ
                3'b001: BranchTaken = ~Zero;           // BNE
                3'b100: BranchTaken = ALUResultLSB;    // BLT
                3'b101: BranchTaken = ~ALUResultLSB;   // BGE
                3'b110: BranchTaken = ALUResultLSB;    // BLTU
                3'b111: BranchTaken = ~ALUResultLSB;   // BGEU
                default: BranchTaken = 0;
            endcase
        end else begin
            BranchTaken = 0;
        end
    end

    assign PCSrc = BranchTaken | Jump;
    assign PCWrite = PCUpdate | BranchTaken | Jump;
endmodule
