module memory_array #(
    parameter INIT_FILE = ""
)(
    input logic     clk, 
    input logic     write_enable, 
    input logic     [31:0] address, 
    input logic     [7:0] data_in, 
    output logic    [7:0] data_out
);

    logic [7:0] memory [0:1023]; // 1024 8-bit locations

    logic [9:0] reduced_address;

    int i;

    // Reducing the address because we only have 4kB of memory
    assign reduced_address = address[11:2];

    // Initialize memory array
    initial begin
        if (INIT_FILE) begin
            $readmemh(INIT_FILE, memory);
        end
        else begin
            for (i = 0; i < 1024; i++) begin
                memory[i] = 8'd0;
            end
        end
    end

    always_ff @(posedge clk) begin
        if (write_enable) begin
            memory[reduced_address] <= data_in;
        end
        else begin
            data_out <= memory[reduced_address];
        end
    end

endmodule
