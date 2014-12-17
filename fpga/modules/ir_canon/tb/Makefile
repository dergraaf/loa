# Name of the testbench without extenstion
TESTBENCH = ir_canon_tb

# VHDL files

# Common files
FILES = \
	../hdl/ir_canon_pkg.vhd \
	../hdl/ir_canon_cfg_pkg.vhd \
	../hdl/ir_canon.vhd \

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=15ms --disp-tree=inst

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include ../../makefile.ghdl.mk

