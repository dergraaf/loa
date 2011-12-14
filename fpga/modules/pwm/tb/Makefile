
# Name of the testbench without extenstion
#TESTBENCH = pwm_tb
TESTBENCH = pwm_module_tb

# VHDL files
ifeq ($(TESTBENCH),pwm_tb)
FILES =  \
	../hdl/pwm.vhd \
	../hdl/pwm_pkg.vhd
else
FILES =  \
	../../spislave/hdl/bus_pkg.vhd \
	../../utils/hdl/*.vhd \
	../hdl/*.vhd
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

