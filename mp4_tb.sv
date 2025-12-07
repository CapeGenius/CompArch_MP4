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
        assert(u0.dp.main_register.regs[1]  == 32'hFEDCBA98) else $error("x1  failed: expected 0xFEDCBA98, got 0x%h", u0.dp.main_register.regs[1]);
        assert(u0.dp.main_register.regs[2]  == 32'h0FEDCBA9) else $error("x2  failed: expected 0x0FEDCBA9, got 0x%h", u0.dp.main_register.regs[2]);
        assert(u0.dp.main_register.regs[3]  == 32'hFFEDCBA9) else $error("x3  failed: expected 0xFFEDCBA9, got 0x%h", u0.dp.main_register.regs[3]);
        assert(u0.dp.main_register.regs[4]  == 32'h00123456) else $error("x4  failed: expected 0x00123456, got 0x%h", u0.dp.main_register.regs[4]);
        assert(u0.dp.main_register.regs[5]  == 32'h00000002) else $error("x5  failed: expected 0x00000002, got 0x%h", u0.dp.main_register.regs[5]);
        assert(u0.dp.main_register.regs[6]  == 32'h00123458) else $error("x6  failed: expected 0x00123458, got 0x%h", u0.dp.main_register.regs[6]);
        assert(u0.dp.main_register.regs[7]  == 32'h00000002) else $error("x7  failed: expected 0x00000002, got 0x%h", u0.dp.main_register.regs[7]);
        assert(u0.dp.main_register.regs[8]  == 32'h0048D158) else $error("x8  failed: expected 0x0048D158, got 0x%h", u0.dp.main_register.regs[8]);
        assert(u0.dp.main_register.regs[9]  == 32'h0048D15F) else $error("x9  failed: expected 0x0048D15F, got 0x%h", u0.dp.main_register.regs[9]);
        assert(u0.dp.main_register.regs[10] == 32'h12346028) else $error("x10 failed: expected 0x12346028, got 0x%h", u0.dp.main_register.regs[10]);
        assert(u0.dp.main_register.regs[11] == 32'h00000001) else $error("x11 failed: expected 0x00000001, got 0x%h", u0.dp.main_register.regs[11]);
        assert(u0.dp.main_register.regs[12] == 32'h00000000) else $error("x12 failed: expected 0x00000000, got 0x%h", u0.dp.main_register.regs[12]);
        assert(u0.dp.main_register.regs[13] == 32'h00001038) else $error("x13 failed: expected 0x00001038, got 0x%h", u0.dp.main_register.regs[13]);
        assert(u0.dp.main_register.regs[14] == 32'h00001060) else $error("x14 failed: expected 0x00001060, got 0x%h", u0.dp.main_register.regs[14]);
        assert(u0.dp.main_register.regs[15] == 32'h00000000) else $error("x15 failed: expected 0x00000000, got 0x%h", u0.dp.main_register.regs[15]);
        assert(u0.dp.main_register.regs[16] == 32'h00001048) else $error("x16 failed: expected 0x00001048, got 0x%h", u0.dp.main_register.regs[16]);
        assert(u0.dp.main_register.regs[17] == 32'h000000C0) else $error("x17 failed: expected 0x000000C0, got 0x%h", u0.dp.main_register.regs[17]);
        assert(u0.dp.main_register.regs[18] == 32'hC0C0C0C0) else $error("x18 failed: expected 0xC0C0C0C0, got 0x%h", u0.dp.main_register.regs[18]);
        assert(u0.dp.main_register.regs[20] == 32'hFFFFC0C0) else $error("x20 failed: expected 0xFFFFC0C0, got 0x%h", u0.dp.main_register.regs[20]);
        assert(u0.dp.main_register.regs[21] == 32'h0000C0C0) else $error("x21 failed: expected 0x0000C0C0, got 0x%h", u0.dp.main_register.regs[21]);
        assert(u0.dp.main_register.regs[22] == 32'hFFFFFFC0) else $error("x22 failed: expected 0xFFFFFFC0, got 0x%h", u0.dp.main_register.regs[22]);
        assert(u0.dp.main_register.regs[23] == 32'h000000C0) else $error("x23 failed: expected 0x000000C0, got 0x%h", u0.dp.main_register.regs[23]);
        
        $display("All register tests passed!");
        $finish;
    end

    // 50MHz clock (20ns period)
    always begin
        #10;
        clk = ~clk;
    end

endmodule

