
# Name of the testbench without extenstion
#TESTBENCH = hdlc_tb
TESTBENCH = hdlc_busmaster_tb

# VHDL files
ifeq ($(TESTBENCH), hdlc_tb)
FILES = ../hdl/hdlc_dec.vhd ../hdl/hdlc_enc.vhd ../hdl/hdlc_pkg.vhd ../../spislave/hdl/bus_pkg.vhd   
else ifeq ($(TESTBENCH), hdlc_busmaster_tb)
FILES = \
../hdl/hdlc_dec.vhd \
../hdl/hdlc_enc.vhd \
../hdl/hdlc_pkg.vhd \
../hdl/hdlc_busmaster.vhd \
../hdl/hdlc_crc_pkg.vhd \
../../spislave/hdl/bus_pkg.vhd \
../../peripheral_register/hdl/peripheral_register.vhd  \
../../peripheral_register/hdl/reg_file_pkg.vhd
endif

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=5us

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include ../../makefile.ghdl.mk

