
# Name of the testbench without extenstion
TESTBENCH = symmetric_pwm_tb
#TESTBENCH = symmetric_pwm_deadtime_tb
#TESTBENCH = pwm_module_tb

# VHDL files
ifeq ($(TESTBENCH),symmetric_pwm_tb)
FILES =  ../hdl/symmetric_pwm.vhd

# Simulation break condition
GHDL_SIM_OPT = --stop-time=500us
else ifeq ($(TESTBENCH),symmetric_pwm_deadtime_tb)
FILES = \
	../hdl/symmetric_pwm_deadtime.vhd \
	../hdl/symmetric_pwm.vhd \
	../hdl/deadtime.vhd

# Simulation break condition
GHDL_SIM_OPT = --stop-time=500us
else
FILES =  \
	../../spislave/hdl/bus_pkg.vhd \
	../../utils/hdl/*.vhd \
	../hdl/*.vhd

# Simulation break condition
GHDL_SIM_OPT = --stop-time=1000us
endif

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include ../../makefile.ghdl.mk

