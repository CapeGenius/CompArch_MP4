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
    input logic adr_src, mem_write, IR_write, reg_write,
    input logic [1:0] result_src, alu_src_a, alu_src_b, imm_src,
    input logic [2:0] alu_control,
    output logic [6:0] op_code,
    output logic [2:0] funct3,
    output logic [6:0] funct7, 
    output logic Zero, 
    input logic RGB_R, RGB_B, RGB_R
);
    //create LED
    logic [31:0] led;

    // create CU logic
    logic PC_write_enable;
    logic mem_write_signal;
    logic adr_src;

    // create PC logic 
    logic PC_reset;
    logic [31:0] PC_next;
    logic [31:0] PC_current;

    // create ALU logic
    logic [31:0] result;

    // declare instruction logic
    logic [31:0] instruction;

    // declare data from data memory
    logic [31:0] dmem_out;

    //declaring all modules

    //program count register
    flop_enable #(.WIDTH (32)) 
    program_counter (
        .clk                (clk),
        .reset              (PC_reset),
        .enable             (PC_write_enable),
        .data               (PC_next),
        .stored_value       (PC_current)
    );

    // mux for address
    mux2 #(.WIDTH (32)) 
    address_mux (
        .d0         (PC_current),
        .d1         (result),
        .s          (adr_src),
        .y          (mem_adress)
    );

    // data memory module
    data_mem #(
        .DMEM_INIT_FILE_PREFIX   ("rv32i_test"), 
        .CLK_FREQ   (12000000)) 
    data_memory (
        .clk            (clk),
        .dmem_wren      (mem_write),
        .funct3         (funct3),
        .dmem_address   (mem_adress),
        .dmem_data_in   (write_data),
        .dmem_data_out  (dmem_out),
        .reset          (PC_reset),
        .led            (led),
        .red            (RGB_R),
        .green          (RGB_G),
        .blue           (RGB_B)
    );

    // instruction memory module
    instruction_mem #(
        .IMEM_INIT_FILE_PREFIX  ("rv32i_test")
    )
    instruction_memory (
        .clk            (clk),
        .imem_address   (mem_adress),
        .imem_data_out  (instruction)
    );


endmodule