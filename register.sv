module register #(
    parameter CLK_FREQ = 12000000
)(
    input logic clk,
    input logic write_enable_flag,
    input logic[4:0] a1, // address of RS1
    input logic [4:0] a2, // address of RS2
    input logic [4:0] a3, // address of RD
    input logic [31:0] write_data_input, // incoming data into RD
    output logic [31:0] read_data_1,
    output logic [31:0] read_data_2
);

    logic [31:0] regs [0:31];

    initial begin
        integer i;
        for (i = 0; i < 32; i = i + 1) begin
            regs[i] = 32'd0;   // initialize all regs to 0
        end
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
