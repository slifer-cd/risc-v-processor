# Default simulator
SIM ?= verilator
TOPLEVEL_LANG ?= verilog

# Enable all warnings and waveform tracing (--trace)
EXTRA_ARGS += -Wall --trace

# Point to the SystemVerilog source file
VERILOG_SOURCES += $(PWD)/modules/immediate_extender.sv

# Name of the top-level module in your SystemVerilog file
TOPLEVEL = immediate_extender

# Name of your Python test file (without the .py extension)
MODULE = test_module

# Include the standard Cocotb makefiles
include $(shell cocotb-config --makefiles)/Makefile.sim