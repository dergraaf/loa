
# Name of the testbench without extenstion
TESTBENCH = imotor_timer_tb
#TESTBENCH = entity_name2_tb

# VHDL files
ifeq ($(TESTBENCH), imotor_timer_tb)
FILES = ../hdl/imotor_timer.vhd 
else ifeq ($(TESTBENCH), imotor_timer_2_tb)
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

