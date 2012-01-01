
# Name of the testbench without extenstion
#TESTBENCH = servo_sequencer_tb
TESTBENCH = servo_module_tb

# VHDL files
ifeq ($(TESTBENCH), servo_sequencer_tb)
FILES = ../hdl/servo_sequencer.vhd
GHDL_SIM_OPT = --stop-time=25ms
else ifeq ($(TESTBENCH), servo_module_tb)
FILES = ../hdl/*.vhd \
	../../utils/hdl/utils_pkg.vhd \
	../../spislave/hdl/bus_pkg.vhd
GHDL_SIM_OPT = --stop-time=27ms
endif

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
#GHDL_SIM_OPT = --stop-time=2us

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include ../../makefile.ghdl.mk

