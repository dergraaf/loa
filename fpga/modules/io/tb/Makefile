
# Name of the testbench without extenstion
TESTBENCH = shiftout_tb

# VHDL files
ifeq ($(TESTBENCH),shiftout_tb)
FILES =  \
	../hdl/shiftout.vhd \
	../../utils/hdl/utils_pkg.vhd \
	../../utils/hdl/clock_divider.vhd
GHDL_SIM_OPT = --stop-time=4us
endif

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include ../../makefile.ghdl.mk

