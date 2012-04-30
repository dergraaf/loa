
# Name of the testbench without extenstion
TESTBENCH = toplevel_tb

# VHDL files
FILES =  \
	../toplevel.vhd \
	../fpga_memory_map.vhd \
	../../../modules/spislave/hdl/*.vhd \
	../../../modules/ram/hdl/*.vhd \
	../../../modules/peripheral_register/hdl/*.vhd \
	../../../modules/motor_control/hdl/*.vhd \
	../../../modules/utils/hdl/*.vhd \
	../../../modules/adc_ltc2351/hdl/*.vhd \
	../../../modules/uss_tx/hdl/*.vhd \
	../../../modules/ir_tx/hdl/*.vhd \
	../../../modules/signalprocessing/hdl/*.vhd \
	../../../modules/ir_rx/hdl/*.vhd \
	../../../modules/adc_mcp3008/hdl/*.vhd

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = default.sav

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=2ms

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include ../../../modules/makefile.ghdl.mk

