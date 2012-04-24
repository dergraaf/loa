
# Name of the testbench without extension
TESTBENCH = xilinx_block_ram_tb

# VHDL files
ifeq ($(TESTBENCH),xilinx_block_ram_tb)
FILES =  \
	../../utils/hdl/utils_pkg.vhd \
	../hdl/xilinx_block_ram_pkg.vhd \
	../hdl/xilinx_block_ram.vhd
endif

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=1000us

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include ../../makefile.ghdl.mk

