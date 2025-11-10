module register #(
    parameter CLK_FREQ = 12000000
)(
    input logic clk,
    input logic write_enable_flag,
    input logic[4:0] a1,
    input logic [4:0] a2, 
    input logic [4:0] a3,
    input logic [31:0] write_data_input,
    output logic [31:0] read_data_1,
    output logic [31:0] read_data_2
);

    logic [31:0] regs [0:31];

    initial begin
        regs[0] = 32'd0; //hardwired 0
    end

    always_ff @(posedge clk) begin
        if (write_enable_flag && a3 > 0) begin // ensures that any register greater than zero can change
            regs[a3] <= write_data_input; 
        end
        regs[0] <= 32'd0;
    end

    always_comb begin
        read_data_1 = regs[a1];
        read_data_2 = regs[a2];
    end  


endmodule
