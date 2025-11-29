#!/bin/bash
echo "Testing single LW instruction..."
echo "Instruction: lw x18, 4(x0)"
echo "Expected: Load 0xDEADBEEF from memory address 0x004 into register x18"
echo ""

# Temporarily switch to simple test files
sed -i '' 's/rv32i_test/simple_test/g' datapath.sv
sed -i '' 's/"simple_test"/"simple_test_data"/g' datapath.sv

# Compile and run
iverilog -g2012 -o simple_lw_test top.sv simple_lw_tb.sv

# Restore original test files
sed -i '' 's/simple_test_data/rv32i_test/g' datapath.sv
sed -i '' 's/simple_test/rv32i_test/g' datapath.sv

# Clean up
rm -f simple_lw_test
