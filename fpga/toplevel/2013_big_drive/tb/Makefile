
# Name of the testbench without extenstion
TESTBENCH = toplevel_tb

# VHDL files
FILES =  \
	../toplevel.vhd \
	../../../modules/spislave/hdl/*.vhd \
	../../../modules/peripheral_register/hdl/*.vhd \
	../../../modules/motor_control/hdl/*.vhd \
	../../../modules/imotor/hdl/*.vhd \
	../../../modules/uart/hdl/*.vhd \
	../../../modules/encoder/hdl/*.vhd \
	../../../modules/pwm/hdl/*.vhd \
	../../../modules/utils/hdl/*.vhd \
	../../../modules/servo/hdl/*.vhd \
	../../../modules/adc_ad7266/hdl/*.vhd \
	../../../../../season/big/generated/drive_robot/fpga_memory_map.vhd 

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=200us

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include ../../../modules/makefile.ghdl.mk

