
# Name of the testbench without extenstion
#TESTBENCH = adc_mcp3008_tb
TESTBENCH = adc_mcp3008_module_tb

# VHDL files
ifeq ($(TESTBENCH), adc_mcp3008_tb)
FILES = \
	../../spislave/hdl/bus_pkg.vhd \
	../hdl/adc_mcp3008.vhd \
	../hdl/adc_mcp3008_pkg.vhd 
else ifeq ($(TESTBENCH), adc_mcp3008_module_tb)
FILES = \
	../../spislave/hdl/bus_pkg.vhd \
	../../peripheral_register/hdl/reg_file_pkg.vhd \
	../../peripheral_register/hdl/reg_file.vhd \
	../hdl/adc_mcp3008.vhd \
	../hdl/adc_mcp3008_pkg.vhd \
	../hdl/adc_mcp3008_module.vhd \
	../tb/adc_mcp3008_module_tb.vhd 
endif

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
#GHDL_SIM_OPT = --stop-time=10us
GHDL_SIM_OPT = --stop-time=1000us

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include ../../makefile.ghdl.mk

