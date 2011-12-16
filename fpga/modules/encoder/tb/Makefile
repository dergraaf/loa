
# Name of the testbench without extenstion
TESTBENCH = encoder_module_tb
#TESTBENCH = quadrature_decoder_tb

# VHDL files
ifeq ($(TESTBENCH), encoder_module_tb)
FILES = ../hdl/*.vhd \
	../../spislave/hdl/bus_pkg.vhd
else
FILES = ../hdl/quadrature_decoder.vhd
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

