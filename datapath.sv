`include "memory/data_mem.sv"
`include "memory/instruction_mem.sv"
`include "register.sv"
`include "alu.sv"
`include "extend_unit.sv"
`include "flop_enable.sv"
`include "flop.sv"
`include "mux2.sv"
`include "mux3.sv"

module datapath (
                input logic clk,
                input logic adr_src, mem_write, IR_write, reg_write, PC_write,
                input logic [1:0] result_src, alu_src_a, alu_src_b, imm_src,
                input logic [2:0] alu_control,
                output logic [6:0] op_code,
                output logic [2:0] funct3,
                output logic [6:0] funct7, 
                output logic Zero, 
                output logic led, red, green, blue);
    // create reset
    logic gen_reset;
    logic dmem_reset;

    assign gen_reset = 0; 
    
    // create PC logic 
    logic PC_reset;
    logic [31:0] PC_next;
    logic [31:0] PC_current;
    logic [31:0] old_PC;

    // declare instruction logic
    logic [31:0] instruction_in, instruction_out;

    // declare data from data memory
    logic [31:0] dmem_out;
    logic [31:0] dmem_data;
    logic [31:0] mem_address;

    // declare logic for register
    logic[4:0] rs1, rs2, rd1; // address of RD1
    logic [31:0] write_data_input, read_data_1, read_data_2;
    logic [31:0] stored_read_data_1, stored_read_data_2;
    logic [31:7] immediate; 
    logic [31:0] immed_extend;

    //declare logic for ALUs
    logic [31:0] SrcA, SrcB, ALU_result, ALU_out, result;

    //assign rs1, rs2, rd, and extend
    assign rs1 = instruction_out[19:15];
    assign rs2 = instruction_out[24:20];
    assign rd = instruction_out[11:7];

    // assign instruction values to op code, funct3, funct7, and immediate
    assign immediate = instruction_out[31:7];
    assign op_code = instruction_out[6:0];
    assign funct3 = instruction_out[14:12];
    assign funct7 = instruction_out[31:25];

    //declaring all modules
    //program count register
    flop_enable #(.WIDTH (32)) 
    program_counter (
        .clk                (clk),
        .reset              (gen_reset),
        .enable             (PC_write),
        .data               (result),
        .stored_value       (PC_current)
    );

    // mux for address
    mux2 #(.WIDTH (32)) 
    address_mux (
        .d0         (PC_current),
        .d1         (result),
        .s          (adr_src),
        .y          (mem_address)
    );

    // data memory module   
    data_mem #(
        .DMEM_INIT_FILE_PREFIX   ("rv32i_test"), 
        .CLK_FREQ   (12000000)) 
    data_memory (
        .clk            (clk),
        .dmem_wren      (mem_write),
        .funct3         (funct3),
        .dmem_address   (mem_address),
        .dmem_data_in   (stored_read_data_2),
        .dmem_data_out  (dmem_out),
        .reset          (dmem_reset),
        .led            (led),
        .red            (red),
        .green          (green),
        .blue           (blue)
    );

    // instruction memory module
    instruction_mem #(
        .IMEM_INIT_FILE_PREFIX  ("rv32i_test")
    )
    instruction_memory (
        .clk            (clk),
        .imem_address   (mem_address),
        .imem_data_out  (instruction_in)
    );

    //IR register
    flop_enable #(.WIDTH (32)) 
    instr_reg (
        .clk                (clk),
        .reset              (gen_reset),
        .enable             (IR_write),
        .data               (instruction_in),
        .stored_value       (instruction_out)
    );

    //IR register 2 for program counter
    flop_enable #(.WIDTH (32)) 
    PC_reg_2 (
        .clk                (clk),
        .reset              (gen_reset),
        .enable             (IR_write),
        .data               (PC_current),
        .stored_value       (old_PC)
    );

    flop flop_dmem (
        .clk            (clk),
        .reset          (gen_reset),
        .data           (dmem_out),
        .stored_value   (dmem_data)
    );


    //main register
    register main_register(
        .clk                (clk), 
        .write_enable_flag  (reg_write), 
        .a1                 (rs1),
        .a2                 (rs2),
        .a3                 (rd1),
        .write_data_input   (result),
        .read_data_1        (read_data_1),
        .read_data_2        (read_data_2)
    );

    extend extend_immediate(
        .instr  (immediate),
        .immsrc (imm_src),
        .immext (immed_extend)
    );

    flop a_flop_1 (
        .clk            (clk),
        .reset          (gen_reset),
        .data           (read_data_1),
        .stored_value   (stored_read_data_1)
    );

    flop a_flop_2 (
        .clk            (clk),
        .reset          (gen_reset),
        .data           (read_data_2),
        .stored_value   (stored_read_data_2)
    );

    mux3 mux_src_a (
        .d0     (PC_current),
        .d1     (old_PC),
        .d2     (stored_read_data_1),
        .s      (alu_src_a),
        .y      (SrcA)
    );

    mux3 mux_src_b (
        .d0     (stored_read_data_2),
        .d1     (immed_extend),
        .d2     (4),
        .s      (alu_src_b),
        .y      (SrcB)
    );

    alu alu_module (
        .SrcA           (SrcA),
        .SrcB           (SrcB),
        .ALU_control    (alu_control),
        .ALU_result     (ALU_result),
        .Zero           (Zero)
    );

    flop alu_flop (
        .clk            (clk),
        .reset          (gen_reset),
        .data           (ALU_result),
        .stored_value   (ALU_out)
    );

    mux3 mux_alu_out (
        .d0     (ALU_out),
        .d1     (dmem_data),
        .d2     (ALU_result),
        .s      (result_src),
        .y      (result)
    );





endmodule