# Default simulator
SIM ?= verilator
TOPLEVEL_LANG ?= verilog

# Paths to your SystemVerilog source files
# Order matters: Packages must be compiled before the modules that use them
# VERILOG_SOURCES += $(PWD)/rtl/pkg/rv32i_pkg.sv
VERILOG_SOURCES += $(wildcard $(PWD)/rtl/memory/*.sv)
VERILOG_SOURCES += $(wildcard $(PWD)/rtl/core/*.sv)
# VERILOG_SOURCES += $(PWD)/dv/wrappers/tb_top.sv

# The top-level module in your singlecycle.sv
TOPLEVEL = singlecycle

# The Python test file to run (located in dv/tests/test_top.py)
# Note: Use dot notation, dropping the .py extension
export PYTHONPATH := $(PWD)/dv/tests:$(PYTHONPATH)
MODULE = test_top


# Verilator compiler arguments
# --trace: Enables VCD waveform generation
# --trace-structs: Dumps internal struct/enum states
# -Wall -Wno-fatal: Shows warnings but prevents them from crashing the build
EXTRA_ARGS += --trace --trace-structs -Wall -Wno-fatal
# If you prefer FST waveforms (better for GTKWave/Surfer), uncomment this line instead:
# EXTRA_ARGS += --trace-fst --trace-structs -Wall -Wno-fatal

# Include the standard Cocotb makefile machinery
include $(shell cocotb-config --makefiles)/Makefile.sim

# The path is now relative to this Makefile
HEX_PROGRAM = $(PWD)/tests_sw/program.hex

# Pass it to Verilator/Cocotb
EXTRA_ARGS += -GINIT_FILE='"$(HEX_PROGRAM)"'

# Clean up simulation artifacts
clean_sim: clean
	rm -rf sim/ build/ __pycache__/ results.xml dump.vcd dump.fst