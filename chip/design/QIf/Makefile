TOP=QIf
VERILATOR_WNO=-Wno-LITENDIAN -Wno-style

all: help

.PHONY: lint
lint: ##@Lint Run lint using Verilator
	verilator -F ../Common/filelist.f -F filelist.f --top-module ${TOP} --lint-only

.PHONY: formal
formal: clean ##@Verification Run formal verification using SymbiYosys
	sby ${TOP}.sby

.PHONY: clean
clean:
	rm -rf ${TOP} obj_dir

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
