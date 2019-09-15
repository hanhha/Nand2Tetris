PAL.bin: MONO_PAL.sv iCE40.pcf
	yosys -q -p "synth_ice40 -top MONO_PAL -json PAL.json" MONO_PAL.sv
	nextpnr-ice40 --hx8k --pcf iCE40.pcf --package ct256 --json PAL.json --asc PAL.asc
	icepack PAL.asc PAL.bin

upload:
	iceprog PAL.bin

clean:
	rm -f PAL.json PAL.asc PAL.ex PAL.bin
