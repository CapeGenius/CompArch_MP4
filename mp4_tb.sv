`timescale 1ns/1ps
`include "top.sv"

module mp4_tb;

    logic clk = 0;
    logic sw = 0;
    logic LED, RGB_R, RGB_G, RGB_B;

    top u0 (
        .clk    (clk), 
        .SW     (sw),
        .LED    (LED), 
        .RGB_R  (RGB_R), 
        .RGB_G  (RGB_G), 
        .RGB_B  (RGB_B)
    );

    initial begin
        $dumpfile("mp4.vcd");
        $dumpvars(0, mp4_tb);
        
        // Reset sequence
        sw = 0;
        #20;
        sw = 1;
        
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
        if (u0.dp.main_register.regs[1]  == 32'hFEDCBA98) $display("✓ x1  passed: expected 0xFEDCBA98, got 0x%h", u0.dp.main_register.regs[1]);  else $display("✗ x1  failed: expected 0xFEDCBA98, got 0x%h", u0.dp.main_register.regs[1]);
        if (u0.dp.main_register.regs[2]  == 32'h0FEDCBA9) $display("✓ x2  passed: expected 0x0FEDCBA9, got 0x%h", u0.dp.main_register.regs[2]);  else $display("✗ x2  failed: expected 0x0FEDCBA9, got 0x%h", u0.dp.main_register.regs[2]);
        if (u0.dp.main_register.regs[3]  == 32'hFFEDCBA9) $display("✓ x3  passed: expected 0xFFEDCBA9, got 0x%h", u0.dp.main_register.regs[3]);  else $display("✗ x3  failed: expected 0xFFEDCBA9, got 0x%h", u0.dp.main_register.regs[3]);
        if (u0.dp.main_register.regs[4]  == 32'h00123456) $display("✓ x4  passed: expected 0x00123456, got 0x%h", u0.dp.main_register.regs[4]);  else $display("✗ x4  failed: expected 0x00123456, got 0x%h", u0.dp.main_register.regs[4]);
        if (u0.dp.main_register.regs[5]  == 32'h00000002) $display("✓ x5  passed: expected 0x00000002, got 0x%h", u0.dp.main_register.regs[5]);  else $display("✗ x5  failed: expected 0x00000002, got 0x%h", u0.dp.main_register.regs[5]);
        if (u0.dp.main_register.regs[6]  == 32'h00123458) $display("✓ x6  passed: expected 0x00123458, got 0x%h", u0.dp.main_register.regs[6]);  else $display("✗ x6  failed: expected 0x00123458, got 0x%h", u0.dp.main_register.regs[6]);
        if (u0.dp.main_register.regs[7]  == 32'h00000002) $display("✓ x7  passed: expected 0x00000002, got 0x%h", u0.dp.main_register.regs[7]);  else $display("✗ x7  failed: expected 0x00000002, got 0x%h", u0.dp.main_register.regs[7]);
        if (u0.dp.main_register.regs[8]  == 32'h0048D158) $display("✓ x8  passed: expected 0x0048D158, got 0x%h", u0.dp.main_register.regs[8]);  else $display("✗ x8  failed: expected 0x0048D158, got 0x%h", u0.dp.main_register.regs[8]);
        if (u0.dp.main_register.regs[9]  == 32'h0048D15F) $display("✓ x9  passed: expected 0x0048D15F, got 0x%h", u0.dp.main_register.regs[9]);  else $display("✗ x9  failed: expected 0x0048D15F, got 0x%h", u0.dp.main_register.regs[9]);
        if (u0.dp.main_register.regs[10] == 32'h12346028) $display("✓ x10 passed: expected 0x12346028, got 0x%h", u0.dp.main_register.regs[10]); else $display("✗ x10 failed: expected 0x12346028, got 0x%h", u0.dp.main_register.regs[10]);
        if (u0.dp.main_register.regs[11] == 32'h00000001) $display("✓ x11 passed: expected 0x00000001, got 0x%h", u0.dp.main_register.regs[11]); else $display("✗ x11 failed: expected 0x00000001, got 0x%h", u0.dp.main_register.regs[11]);
        if (u0.dp.main_register.regs[12] == 32'h00000000) $display("✓ x12 passed: expected 0x00000000, got 0x%h", u0.dp.main_register.regs[12]); else $display("✗ x12 failed: expected 0x00000000, got 0x%h", u0.dp.main_register.regs[12]);
        if (u0.dp.main_register.regs[13] == 32'h00001038) $display("✓ x13 passed: expected 0x00001038, got 0x%h", u0.dp.main_register.regs[13]); else $display("✗ x13 failed: expected 0x00001038, got 0x%h", u0.dp.main_register.regs[13]);
        if (u0.dp.main_register.regs[14] == 32'h00001060) $display("✓ x14 passed: expected 0x00001060, got 0x%h", u0.dp.main_register.regs[14]); else $display("✗ x14 failed: expected 0x00001060, got 0x%h", u0.dp.main_register.regs[14]);
        if (u0.dp.main_register.regs[15] == 32'h00000000) $display("✓ x15 passed: expected 0x00000000, got 0x%h", u0.dp.main_register.regs[15]); else $display("✗ x15 failed: expected 0x00000000, got 0x%h", u0.dp.main_register.regs[15]);
        if (u0.dp.main_register.regs[16] == 32'h00001048) $display("✓ x16 passed: expected 0x00001048, got 0x%h", u0.dp.main_register.regs[16]); else $display("✗ x16 failed: expected 0x00001048, got 0x%h", u0.dp.main_register.regs[16]);
        if (u0.dp.main_register.regs[17] == 32'h000000C0) $display("✓ x17 passed: expected 0x000000C0, got 0x%h", u0.dp.main_register.regs[17]); else $display("✗ x17 failed: expected 0x000000C0, got 0x%h", u0.dp.main_register.regs[17]);
        if (u0.dp.main_register.regs[18] == 32'hC0C0C0C0) $display("✓ x18 passed: expected 0xC0C0C0C0, got 0x%h", u0.dp.main_register.regs[18]); else $display("✗ x18 failed: expected 0xC0C0C0C0, got 0x%h", u0.dp.main_register.regs[18]);
        if (u0.dp.main_register.regs[20] == 32'hFFFFC0C0) $display("✓ x20 passed: expected 0xFFFFC0C0, got 0x%h", u0.dp.main_register.regs[20]); else $display("✗ x20 failed: expected 0xFFFFC0C0, got 0x%h", u0.dp.main_register.regs[20]);
        if (u0.dp.main_register.regs[21] == 32'h0000C0C0) $display("✓ x21 passed: expected 0x0000C0C0, got 0x%h", u0.dp.main_register.regs[21]); else $display("✗ x21 failed: expected 0x0000C0C0, got 0x%h", u0.dp.main_register.regs[21]);
        if (u0.dp.main_register.regs[22] == 32'hFFFFFFC0) $display("✓ x22 passed: expected 0xFFFFFFC0, got 0x%h", u0.dp.main_register.regs[22]); else $display("✗ x22 failed: expected 0xFFFFFFC0, got 0x%h", u0.dp.main_register.regs[22]);
        if (u0.dp.main_register.regs[23] == 32'h000000C0) $display("✓ x23 passed: expected 0x000000C0, got 0x%h", u0.dp.main_register.regs[23]); else $display("✗ x23 failed: expected 0x000000C0, got 0x%h", u0.dp.main_register.regs[23]);
        
        assert(u0.dp.main_register.regs[1]  == 32'hFEDCBA98);
        assert(u0.dp.main_register.regs[2]  == 32'h0FEDCBA9);
        assert(u0.dp.main_register.regs[3]  == 32'hFFEDCBA9);
        assert(u0.dp.main_register.regs[4]  == 32'h00123456);
        assert(u0.dp.main_register.regs[5]  == 32'h00000002);
        assert(u0.dp.main_register.regs[6]  == 32'h00123458);
        assert(u0.dp.main_register.regs[7]  == 32'h00000002);
        assert(u0.dp.main_register.regs[8]  == 32'h0048D158);
        assert(u0.dp.main_register.regs[9]  == 32'h0048D15F);
        assert(u0.dp.main_register.regs[10] == 32'h12346028);
        assert(u0.dp.main_register.regs[11] == 32'h00000001);
        assert(u0.dp.main_register.regs[12] == 32'h00000000);
        assert(u0.dp.main_register.regs[13] == 32'h00001038);
        assert(u0.dp.main_register.regs[14] == 32'h00001060);
        assert(u0.dp.main_register.regs[15] == 32'h00000000);
        assert(u0.dp.main_register.regs[16] == 32'h00001048);
        assert(u0.dp.main_register.regs[17] == 32'h000000C0);
        assert(u0.dp.main_register.regs[18] == 32'hC0C0C0C0);
        assert(u0.dp.main_register.regs[20] == 32'hFFFFC0C0);
        assert(u0.dp.main_register.regs[21] == 32'h0000C0C0);
        assert(u0.dp.main_register.regs[22] == 32'hFFFFFFC0);
        assert(u0.dp.main_register.regs[23] == 32'h000000C0);
        
        $display("All register tests passed!");
        $finish;
    end

    // 50MHz clock (20ns period)
    always begin
        #10;
        clk = ~clk;
    end

endmodule

