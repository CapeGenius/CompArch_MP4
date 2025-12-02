iverilog -g2012 -o simple_lw_tb simple_lw_tb.sv
vvp simple_lw_tb
gtkwave simple_lw_tb.vcd