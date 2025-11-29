module simple_lw_tb;
    logic clk, reset;
    logic LED, RGB_R, RGB_G, RGB_B;
    
    // Clock generation
    always begin
        clk = 0; #10;
        clk = 1; #10;
    end
    
    // Test instance
    top u0(.clk(clk), .reset(reset), .LED(LED), .RGB_R(RGB_R), .RGB_G(RGB_G), .RGB_B(RGB_B));
    
    initial begin
        $dumpfile("simple_lw.vcd");
        $dumpvars(0, simple_lw_tb);
        
        // Reset
        reset = 1; 
        repeat (3) @(posedge clk);
        reset = 0;
        
        // Run for just one LW instruction (5 states)
        repeat (6) begin
            @(posedge clk);
            $display("T=%0t PC=%08x Instr=%08x State=%0d IRWrite=%b PCWrite=%b", 
                     $time, u0.dp.PC_current, u0.dp.instruction_out, 
                     u0.ctrl.current_state, u0.dp.IR_write, u0.dp.PC_write);
            
            // Add detailed debugging for each state
            case (u0.ctrl.current_state)
                1: $display("  DECODE: rs1=%0d imm=%h", u0.dp.instruction_out[19:15], $signed(u0.dp.instruction_out[31:20]));
                2: $display("  MEMADR: ALU_A=%08x ALU_B=%08x ALU_result=%08x", u0.dp.SrcA, u0.dp.SrcB, u0.dp.ALU_result);
                3: $display("  MEMREAD: MemAddr=%08x MemData=%08x AdrSrc=%b", u0.dp.mem_address, u0.dp.dmem_data, u0.dp.adr_src);
                4: $display("  MEMWB: WriteData=%08x WriteReg=%0d RegWrite=%b", u0.dp.result, u0.dp.instruction_out[11:7], u0.dp.reg_write);
            endcase
            
            // Stop after one complete instruction cycle
            if (u0.ctrl.current_state == 0 && u0.dp.PC_write == 1) begin
                $display("--- Completed one instruction cycle ---");
                break;
            end
        end
        
        // Check what instruction was decoded and final register state
        $display("\n=== Instruction Analysis ===");
        $display("Instruction: %08x", u0.dp.instruction_out);
        $display("Opcode: %07b (should be 0000011 for LW)", u0.dp.op_code);
        $display("funct3: %03b (should be 010 for LW)", u0.dp.funct3);
        $display("rs1: %0d", u0.dp.instruction_out[19:15]);
        $display("rd: %0d", u0.dp.instruction_out[11:7]);
        $display("imm: %0d (0x%h)", $signed(u0.dp.instruction_out[31:20]), u0.dp.instruction_out[31:20]);
        
        $display("\n=== Register File Check ===");
        $display("Register x%0d = 0x%h", u0.dp.instruction_out[11:7], u0.dp.main_register.regs[u0.dp.instruction_out[11:7]]);
        
        $finish;
    end
endmodule
