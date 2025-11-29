filename = top
pcf_file = iceBlinkPico.pcf

build:
	yosys -p "synth_ice40 -top top -json $(filename).json" $(filename).sv
	nextpnr-ice40 --up5k --package sg48 --json $(filename).json --pcf $(pcf_file) --asc $(filename).asc
	icepack $(filename).asc $(filename).bin

prog: #for sram
	dfu-util --device 1d50:6146 --alt 0 -D $(filename).bin -R

sim: mp4_test
	vvp mp4_test

mp4_test: mp4_tb.sv top.sv control_unit.sv datapath.sv
	iverilog -g2012 -o mp4_test mp4_tb.sv

test: mp4_test
	./test.sh

wave: mp4.vcd
	gtkwave mp4.vcd &

clean:
	rm -rf $(filename).blif $(filename).asc $(filename).json $(filename).bin mp4_test mp4.vcd

.PHONY: build prog sim test wave clean
