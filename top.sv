`include "datapath.sv"
`include "control_unit.sv"

module top (
    input logic clk,
    input logic reset,
    output logic LED,
    output logic RGB_R,
    output logic RGB_G, 
    output logic RGB_B
);

    // Control signals between controller and datapath
    logic [1:0] ResultSrc;
    logic MemWrite;
    logic PCSrc;
    logic [1:0] ALUSrcA, ALUSrcB;
    logic AdrSrc;
    logic RegWrite;
    logic Jump;
    logic [2:0] ImmSrc;
    logic [2:0] ALUControl;
    logic IRWrite;
    logic PCWrite;
    
    // Status signals from datapath to controller
    logic [6:0] op;
    logic [2:0] funct3;
    logic [6:0] funct7;
    logic Zero;
    
    // LED outputs from datapath
    logic led, red, green, blue;

    // Controller instance
    controller ctrl (
        .clk(clk),
        .reset(reset),
        .op(op),
        .funct3(funct3),
        .funct7b5(funct7[5]),
        .Zero(Zero),
        .ResultSrc(ResultSrc),
        .MemWrite(MemWrite),
        .PCSrc(PCSrc),
        .ALUSrcA(ALUSrcA),
        .ALUSrcB(ALUSrcB),
        .AdrSrc(AdrSrc),
        .RegWrite(RegWrite),
        .Jump(Jump),
        .ImmSrc(ImmSrc),
        .ALUControl(ALUControl),
        .IRWrite(IRWrite),
        .PCWrite(PCWrite)
    );

    // Datapath instance  
    datapath dp (
        .clk(clk),
        .reset(reset),
        .adr_src(AdrSrc),
        .mem_write(MemWrite),
        .IR_write(IRWrite),
        .reg_write(RegWrite),
        .PC_write(PCWrite),
        .result_src(ResultSrc),
        .alu_src_a(ALUSrcA),
        .alu_src_b(ALUSrcB),
        .imm_src(ImmSrc),
        .alu_control(ALUControl),
        .op_code(op),
        .funct3(funct3),
        .funct7(funct7),
        .Zero(Zero),
        .led(led),
        .red(red),
        .green(green),
        .blue(blue)
    );

    assign LED = ~led;
    assign RGB_R = ~red;
    assign RGB_G = ~green;
    assign RGB_B = ~blue;

endmodule
