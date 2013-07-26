
# Name of the testbench without extenstion
# TESTBENCH = uss_tx_module_tb
TESTBENCH = serialiser_tb

# VHDL files
ifeq ($(TESTBENCH), uss_tx_module_tb)
FILES = \
../../spislave/hdl/bus_pkg.vhd \
../../peripheral_register/hdl/reg_file_pkg.vhd \
../../peripheral_register/hdl/reg_file.vhd \
../../motor_control/hdl/motor_control_pkg.vhd \
../../motor_control/hdl/deadtime.vhd \
../../utils/hdl/utils_pkg.vhd \
../../utils/hdl/fractional_clock_divider_variable.vhd \
../hdl/uss_tx_pkg.vhd \
../hdl/uss_tx_module.vhd
else ifeq ($(TESTBENCH), serialiser_tb)
FILES = ../hdl/serialiser.vhd \
../../utils/hdl/utils_pkg.vhd \
../../utils/hdl/fractional_clock_divider.vhd
endif

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=500us

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include ../../makefile.ghdl.mk

