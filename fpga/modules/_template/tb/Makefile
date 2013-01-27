
# Name of the testbench without extenstion
TESTBENCH = entity_name_tb
#TESTBENCH = entity_name2_tb

# VHDL files
ifeq ($(TESTBENCH), entity_name_tb)
FILES = ../hdl/entity_name.vhd 
else ifeq ($(TESTBENCH), entity_name2_tb)
FILES = ../hdl/*.vhd
endif

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=2us

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include ../../makefile.ghdl.mk

