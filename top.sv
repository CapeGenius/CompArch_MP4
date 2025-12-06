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
    logic [2:0] ResultSrc;
    logic MemWrite;
    logic PCSrc;
    logic [1:0] ALUSrcA, ALUSrcB;
    logic AdrSrc;
    logic RegWrite;
    logic Jump;
    logic [2:0] ImmSrc;
    logic [3:0] ALUControl;
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
        .ALUResultLSB(ALUResultLSB),
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
        .ALUResultLSB(ALUResultLSB),
        .led(led),
        .red(red),
        .green(green),
        .blue(blue)
    );
    integer file;
    initial begin
        file = $fopen("output_2.txt", "w");

        if (file == 0) begin
            $display("ERROR: Could not open file");
            $finish;
        end
    end

    always @(posedge clk) begin
        $fdisplay(file, "instruction: %h, state: %s", dp.instruction_out, ctrl.cycle_state);
        $fflush(file); 
        $fdisplay(file, "                PC & Instr         - pc:%h, PC_next:%h, instruction_in: %h, instruction_out: %h, opcode: %b",
                    dp.PC_current, dp.result, dp.instruction_in, dp.instruction_out, dp.op_code);
        $fflush(file); 
        $fdisplay(file, "                ALU Information    - alu_out:%h, alu_result:%h,  SrcA:%h, SrcB:%h, SrcA_crtl:%h, SrcB_crtl:%h alu_ctrl:%h,",
                    dp.ALU_out, dp.ALU_result, dp.SrcA, dp.SrcB, dp.alu_src_a, dp.alu_src_b, dp.alu_control);
        $fflush(file); 
        $fdisplay(file, "                Control Signals     - PCWrite: %b, AdrSrc %b, MemWrite %b, IRWrite %b, Result_Src: %b, ALU_Crtl: %b, ImmSrc: %b, RegWrite: %b", 
        PCWrite, AdrSrc, MemWrite, IRWrite, ResultSrc, ALUControl, ImmSrc, RegWrite );
        // $fdisplay(fd, "                 alu_out:%h, alu_result:%h,  SrcA:%h, SrcB:%h, SrcA_crtl:%h, SrcB_crtl:%h alu_ctrl:%h, ")
        $fflush(file); 
    end

    final begin
        $fclose(file);
    end
    assign LED = ~led;
    assign RGB_R = ~red;
    assign RGB_G = ~green;
    assign RGB_B = ~blue;

endmodule
