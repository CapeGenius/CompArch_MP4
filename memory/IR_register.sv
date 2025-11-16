module IR_register (
    input logic clk,
    input logic write_enable, 
    input logic [31:0] instruction_in,
    output logic [31:0] instruction_out
);
    logic [31:0] internal_reg;

    assign instruction_out = internal_reg;

    always_ff @(posedge clk) begin
        if (write_enable == 1)
            internal_reg <= instruction_in;
    end

endmodule