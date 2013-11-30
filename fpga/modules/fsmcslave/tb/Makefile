
# Name of the testbench without extenstion
TESTBENCH = fsmcslave_tb

# VHDL files
FILES =  \
	../../spislave/hdl/bus_pkg.vhd fsmc_test_data_pck.vhd fsmcmaster_pck.vhd ../hdl/*.vhd

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=15us

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include ../../makefile.ghdl.mk

