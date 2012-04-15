
# Name of the testbench without extenstion
TESTBENCH = goertzel_tb

# VHDL files
ifeq ($(TESTBENCH), goertzel_tb)
FILES = \
../../utils/hdl/utils_pkg.vhd \
../../spislave/hdl/bus_pkg.vhd \
../../adc_mcp3008/hdl/reg_file_pkg.vhd \
../../adc_mcp3008/hdl/reg_file.vhd \
../../adc_ltc2351/hdl/adc_ltc2351.vhd \
../../adc_ltc2351/hdl/adc_ltc2351_pkg.vhd \
../../adc_ltc2351/hdl/adc_ltc2351_model.vhd \
../hdl/signalprocessing_pkg.vhd \
../hdl/goertzel.vhd 
else ifeq ($(TESTBENCH), adc_ltc2351_module_tb)
FILES = \
../../adc_mcp3008/tb/reg_file_tb.vhd 
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
