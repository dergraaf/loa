# Name of the testbench without extenstion
#TESTBENCH = onewire_reset_tb
#TESTBENCH = onewire_write_tb
#TESTBENCH = onewire_read_tb
TESTBENCH = ds18b20_tb

# VHDL files

# Common files
FILES = \
	../../onewire/hdl/onewire_pkg.vhd \
	../../onewire/hdl/onewire_cfg_pkg.vhd \
	../../onewire/hdl/onewire.vhd \
	../hdl/ds18b20.vhd \
	../hdl/ds18b20_pkg.vhd 

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=10ms --disp-tree=inst

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include ../../makefile.ghdl.mk

