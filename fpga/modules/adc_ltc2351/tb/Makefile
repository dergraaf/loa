
# Name of the testbench without extenstion
TESTBENCH = adc_ltc2351_tb
#TESTBENCH = adc_ltc2351_2_tb

# VHDL files
ifeq ($(TESTBENCH), adc_ltc2351_tb)
FILES = \
../../spislave/hdl/bus_pkg.vhd \
../hdl/adc_ltc2351.vhd \
../hdl/adc_ltc2351_pkg.vhd 
else ifeq ($(TESTBENCH), adc_ltc2351_2_tb)
FILES = ../hdl/*.vhd
endif

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=50us

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include ../../makefile.ghdl.mk

