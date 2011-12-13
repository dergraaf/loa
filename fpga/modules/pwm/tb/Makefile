
# Name of the testbench without extenstion
TESTBENCH = pwm_tb

# VHDL files
FILES =  \
	../hdl/pwm.vhd \
	../hdl/pwm_pkg.vhd

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = default.sav

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=300us

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include ../../makefile.ghdl.mk

