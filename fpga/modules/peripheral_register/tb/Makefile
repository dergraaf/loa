
# Name of the testbench without extenstion
#TESTBENCH = peripheral_register_tb
TESTBENCH = reg_file_tb
#TESTBENCH = double_buffering_tb
#TESTBENCH = reg_file_bram_double_buffered_tb

# VHDL files
ifeq ($(TESTBENCH), peripheral_register_tb)
FILES = ../../spislave/hdl/bus_pkg.vhd \
		../hdl/reg_file_pkg.vhd \
		../hdl/peripheral_register.vhd
else ifeq ($(TESTBENCH), reg_file_tb)
FILES = \
	../../spislave/hdl/bus_pkg.vhd \
	../hdl/reg_file_pkg.vhd \
	../hdl/reg_file.vhd \
	../tb/reg_file_tb.vhd
else ifeq ($(TESTBENCH), reg_file_bram_double_buffered_tb)
FILES = ../../utils/hdl/utils_pkg.vhd \
	../../ram/hdl/xilinx_block_ram_pkg.vhd \
	../../ram/hdl/xilinx_block_ram.vhd \
	../../spislave/hdl/bus_pkg.vhd \
	../hdl/reg_file_pkg.vhd \
	../hdl/double_buffering.vhd \
	../../utils/hdl/edge_detect.vhd \
	../hdl/reg_file_bram_double_buffered.vhd
else ifeq ($(TESTBENCH), double_buffering_tb)
FILES = ../hdl/reg_file_pkg.vhd \
	../../utils/hdl/utils_pkg.vhd \
	../../utils/hdl/edge_detect.vhd \
	../hdl/double_buffering.vhd
endif

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=2us --disp-tree=inst

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include ../../makefile.ghdl.mk

