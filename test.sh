#!/bin/bash

echo "======================================"
echo "Testing RISC-V Multicycle Processor"
echo "======================================"
echo ""

# Check if iverilog is available
if ! command -v iverilog &> /dev/null; then
    echo "❌ Error: iverilog not found in PATH"
    echo "Please install Icarus Verilog or add it to your PATH"
    exit 1
fi

# Clean previous build
echo "🧹 Cleaning previous builds..."
rm -f mp4_test mp4.vcd output_2.txt instruction_output.txt

# Compile the design
echo "🔨 Compiling design..."
iverilog -g2012 -o mp4_test mp4_tb.sv
if [ $? -ne 0 ]; then
    echo "❌ Compilation failed!"
    exit 1
fi

echo "✅ Compilation successful!"
echo ""

# Run simulation
echo "▶️  Running simulation..."
vvp mp4_test

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Simulation completed successfully!"
    
    if [ -f mp4.vcd ]; then
        echo ""
        echo "📊 VCD file generated: mp4.vcd"
        echo "To view waveforms, run: gtkwave mp4.vcd"
    fi
else
    echo "❌ Simulation failed!"
    exit 1
fi
