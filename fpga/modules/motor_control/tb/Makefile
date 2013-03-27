
# Name of the testbench without extenstion
#TESTBENCH = symmetric_pwm_tb
#TESTBENCH = symmetric_pwm_deadtime_tb
#TESTBENCH = commutation_tb
#TESTBENCH = comparator_module_tb
#TESTBENCH = bldc_motor_module_tb
#TESTBENCH = dc_driver_stage_converter_tb
TESTBENCH = bldc_driver_stage_converter_tb

# VHDL files
ifeq ($(TESTBENCH),symmetric_pwm_tb)
FILES =  \
	../hdl/symmetric_pwm.vhd
GHDL_SIM_OPT = --stop-time=500us
else ifeq ($(TESTBENCH),symmetric_pwm_deadtime_tb)
FILES = \
	../../spislave/hdl/bus_pkg.vhd \
	../hdl/motor_control_pkg.vhd \
	../hdl/symmetric_pwm_deadtime.vhd \
	../hdl/symmetric_pwm.vhd \
	../hdl/deadtime.vhd
GHDL_SIM_OPT = --stop-time=500us
else ifeq ($(TESTBENCH),commutation_tb)
FILES = \
	../hdl/motor_control_pkg.vhd \
	../hdl/commutation.vhd \
	../hdl/symmetric_pwm_deadtime.vhd \
	../hdl/symmetric_pwm.vhd \
	../hdl/deadtime.vhd
GHDL_SIM_OPT = --stop-time=1200us
else ifeq ($(TESTBENCH),comparator_module_tb)
FILES = \
	../../spislave/hdl/bus_pkg.vhd \
	../../utils/hdl/*.vhd \
	../../peripheral_register/hdl/*.vhd \
	../hdl/*.vhd
GHDL_SIM_OPT = --stop-time=400us
else ifeq ($(TESTBENCH),dc_driver_stage_converter_tb)
FILES = \
	../../spislave/hdl/bus_pkg.vhd \
	../hdl/motor_control_pkg.vhd \
	../hdl/driver_stages.vhd
GHDL_SIM_OPT = --stop-time=1us
else ifeq ($(TESTBENCH),bldc_driver_stage_converter_tb)
FILES = \
	../../spislave/hdl/bus_pkg.vhd \
	../hdl/motor_control_pkg.vhd \
	../hdl/driver_stages.vhd
GHDL_SIM_OPT = --stop-time=1us
else
FILES =  \
	../../spislave/hdl/bus_pkg.vhd \
	../../utils/hdl/*.vhd \
	../hdl/*.vhd
GHDL_SIM_OPT = --stop-time=1000us
endif

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include ../../makefile.ghdl.mk

