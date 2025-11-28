module flop_enable #(parameter WIDTH = 32)
    (
        input logic clk,
        input logic reset,
        input logic enable,
        input logic [WIDTH - 1: 0] data,
        output logic [WIDTH - 1: 0] stored_value
    );

    always_ff @(posedge clk) begin
        if (reset) begin
            stored_value <= 0;
        end
        else if (enable) begin
            stored_value <= data;
        end
    end

endmodule
