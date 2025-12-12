module instruction_mem #(
    parameter IMEM_INIT_FILE_PREFIX = ""
)(
    input logic         clk,
    input logic         [31:0] imem_address,
    output logic        [31:0] imem_data_out
);

    logic [7:0] imem_data_out0;
    logic [7:0] imem_data_out1;
    logic [7:0] imem_data_out2;
    logic [7:0] imem_data_out3; 

    assign imem_data_out = (imem_address[31:12] == 20'd1) ? { imem_data_out3, imem_data_out2, imem_data_out1, imem_data_out0 } : 32'd0;

    memory_array #(
        .INIT_FILE      ((IMEM_INIT_FILE_PREFIX != "") ? { IMEM_INIT_FILE_PREFIX, "0.txt" } : "")
    ) imem0 (
        .clk                (clk),
        .write_enable       (1'b0),
        .address            (imem_address),
        .data_in            (8'b0),
        .data_out           (imem_data_out0)
    );

    memory_array #(
        .INIT_FILE      ((IMEM_INIT_FILE_PREFIX != "") ? { IMEM_INIT_FILE_PREFIX, "1.txt" } : "")
    ) imem1 (
        .clk                (clk),
        .write_enable       (1'b0),
        .address            (imem_address),
        .data_in            (8'b0),
        .data_out           (imem_data_out1)
    );

    memory_array #(
        .INIT_FILE      ((IMEM_INIT_FILE_PREFIX != "") ? { IMEM_INIT_FILE_PREFIX, "2.txt" } : "")
    ) imem2 (
        .clk                (clk),
        .write_enable       (1'b0),
        .address            (imem_address),
        .data_in            (8'b0),
        .data_out           (imem_data_out2)
    );

    memory_array #(
        .INIT_FILE      ((IMEM_INIT_FILE_PREFIX != "") ? { IMEM_INIT_FILE_PREFIX, "3.txt" } : "")
    ) imem3 (
        .clk                (clk),
        .write_enable       (1'b0),
        .address            (imem_address),
        .data_in            (8'b0),
        .data_out           (imem_data_out3)
    );
    

endmodule
