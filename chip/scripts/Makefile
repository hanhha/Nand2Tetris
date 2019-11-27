DESIGN_DIR=../design
VERIF_DIR=../verif

TOP=chip

all: help 

.PHONY: lint 
lint: ##@Lint Run lint only
	verilator --lint-only --bbox-unsup --top-module ${TOP} -F ${DESIGN_DIR}/filelist.f

.PHONY: verilator
verilator: ##@Simulation Compile design and test environment
	verilator -Wall --trace --cc --top-module ${TOP} --exe ${VERIF_DIR}/test.cpp \
					 -F ${DESIGN_DIR}/filelist.f
	make -C obj_dir/ -f V${TOP}.mk V${TOP}

.PHONY: sim 
sim: verilator ##@Simulation Simulate design
	lldb -o 'run' -o 'quit' obj_dir/V${TOP}

.PHONY: fpga
fpga: ${TOP}.bin upload ##@Hardware Synthesize design, map and upload to FPGA device

.PHONY: synthesis
synthesis: ##@Hardware  Synthesize design
	yosys -q -c ${TOP}.tcl -l synth.log

${TOP}.bin: synthesis chip.pcf constraint.py 
	nextpnr-ice40 --hx8k --pcf ${TOP}.pcf --package ct256 --pre-pack constraint.py --json ${TOP}.json --asc ${TOP}.asc -l pnr.log
	icepack ${TOP}.asc ${TOP}.bin

.PHONY: upload
upload: ${TOP}.bin ##@Hardware Upload to device
	iceprog ${TOP}.bin

.PHONY: clean
clean: ##@Misc Clean up folder
	rm -rf obj_dir trace.vcd
	rm -f ${TOP}.json ${TOP}.asc ${TOP}.ex ${TOP}.bin
	rm -f *.log

HELP_FUN = \
         %help; \
         while(<>) { push @{$$help{$$2 // 'options'}}, [$$1, $$3] if /^(\w+)\s*:.*\#\#(?:@(\w+))?\s(.*)$$/ }; \
         print "Usage: make [target]\n\n"; \
     for (keys %help) { \
         print "$$_:\n"; $$sep = " " x (20 - length $$_->[0]); \
         print "  $$_->[0]$$sep$$_->[1]\n" for @{$$help{$$_}}; \
         print "\n"; }

.PHONY: help
help: ##@Misc Show this help message.
	@perl -e '${HELP_FUN}' ${MAKEFILE_LIST}
