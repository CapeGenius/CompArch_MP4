`timescale 1ns/1ps
`include "top.sv"

module mp4_tb;

    logic clk = 0;
    logic reset = 1;
    logic LED, RGB_R, RGB_G, RGB_B;

    top u0 (
        .clk    (clk), 
        .reset  (reset),
        .LED    (LED), 
        .RGB_R  (RGB_R), 
        .RGB_G  (RGB_G), 
        .RGB_B  (RGB_B)
    );

    initial begin
        $dumpfile("mp4.vcd");
        $dumpvars(0, mp4_tb);
        
        // Reset sequence
        reset = 1;
        #20;
        reset = 0;
        
        // Monitor key signals with more details
        $monitor("Time=%0d PC=%h Instr=%h State=%h AdrSrc=%b IRWrite=%b PCWrite=%b LED=%b", 
                 $time, u0.dp.PC_current, u0.dp.instruction_out, 
                 u0.ctrl.current_state, u0.dp.adr_src, u0.dp.IR_write, u0.dp.PC_write, LED);
        
        // Run for enough time to execute several instructions
        #50000;
        
        // Check final register values
        $display("\n=== Final Register Values ===");
        for (int i = 0; i < 32; i++) begin
            if (u0.dp.main_register.regs[i] !== 0)
                $display("x%0d = 0x%h", i, u0.dp.main_register.regs[i]);
        end
        
        $display("\n=== Test Results ===");
        $display("x1 should be 0xFEDCBA98, actual = 0x%h", u0.dp.main_register.regs[1]);
        $display("x2 should be 0x0FEDCBA9, actual = 0x%h", u0.dp.main_register.regs[2]);
        $display("x18 should be 0xC0C0C0C0, actual = 0x%h", u0.dp.main_register.regs[18]);
        
        $finish;
    end

    // 50MHz clock (20ns period)
    always begin
        #10;
        clk = ~clk;
    end

endmodule

