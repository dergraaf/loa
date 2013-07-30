
# Name of the testbench without extenstion
TESTBENCH = us_rx_module_tb
#TESTBENCH = entity_name2_tb

# VHDL files
ifeq ($(TESTBENCH), us_rx_module_tb)
FILES = ../hdl/us_rx_module.vhd \
	../hdl/us_rx_module_pkg.vhd \
	../../spislave/hdl/bus_pkg.vhd \
	../../adc_ltc2351/hdl/adc_ltc2351_pkg.vhd \
	../../signalprocessing/hdl/signalprocessing_pkg.vhd
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

