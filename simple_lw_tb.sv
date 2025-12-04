`include "top.sv"
`timescale  10ns/10ns

module simple_lw_tb;
    logic clk, reset;
    logic LED, RGB_R, RGB_G, RGB_B;
    
    // DUT instance
    top u0 (
        .clk(clk),
        .reset(reset),
        .LED(LED),
        .RGB_R(RGB_R),
        .RGB_G(RGB_G),
        .RGB_B(RGB_B)
    );

    initial begin

        $dumpfile("simple_lw_tb.vcd");
        $dumpvars(0, simple_lw_tb);

        clk = 0;
        reset = 1; 
        repeat (3) @(posedge clk);
        reset = 0;
        
        #20000
        $finish;
    end

    always begin
        #4
        clk = ~clk;
    end
    
    // --- Testbench Logic ---

endmodule
