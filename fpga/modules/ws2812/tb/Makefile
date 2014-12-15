# Name of the testbench without extenstion
#TESTBENCH = ws2812_tb
TESTBENCH = ws2812_8x1_tb
#TESTBENCH = onewire_read_tb

# VHDL files

# Common files
FILES = \
	../hdl/ws2812_pkg.vhd \
	../hdl/ws2812_cfg_pkg.vhd \
	../hdl/ws2812.vhd \
	../hdl/ws2812_8x1.vhd \

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=15ms --disp-tree=inst

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include ../../makefile.ghdl.mk

