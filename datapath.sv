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
    input logic clk
);

    logic PC_reset;


    // create CU logic
    logic PC_write_enable;
    logic mem_write_signal;
    logic adr_src;

    // create PC logic 
    logic [31:0] PC_next;
    logic [31:0] PC_current;

    // create ALU logic
    logic [31:0] result;

    // create memory logic

    flop_enable #(.WIDTH (32)) program_counter (
        .clk                (clk),
        .reset              (PC_reset),
        .enable             (PC_write_enable),
        .data               (PC_next),
        .stored_value       (PC_current)
    );

    mux2 #(.WIDTH (32)) address_mux (
        .d0         (PC_current),
        .d1         (result),
        .s          (adr_src),
        .y          (mem_adress)
    );


endmodule