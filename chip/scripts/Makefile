DESIGN_DIR=../design
VERIF_DIR=../verif

TOP=chip

all: verilator sim

verilator:
	verilator -Wall --trace --cc --top-module ${TOP} --exe ${VERIF_DIR}/test.cpp \
					 -F ${DESIGN_DIR}/filelist.f
	make -C obj_dir/ -f V${TOP}.mk V${TOP}

sim: verilator
	lldb -o 'run' -o 'quit' obj_dir/V${TOP}

fpga: ${TOP}.bin upload

synthesis: 
	yosys -q -c ${TOP}.tcl -l synth.log

${TOP}.bin: synthesis chip.pcf constraint.py 
	nextpnr-ice40 --hx8k --pcf ${TOP}.pcf --package ct256 --pre-pack constraint.py --json ${TOP}.json --asc ${TOP}.asc -l pnr.log
	icepack ${TOP}.asc ${TOP}.bin

upload: ${TOP}.bin
	iceprog ${TOP}.bin

clean:
	rm -rf obj_dir trace.vcd
	rm -f ${TOP}.json ${TOP}.asc ${TOP}.ex ${TOP}.bin
	rm -f *.log
