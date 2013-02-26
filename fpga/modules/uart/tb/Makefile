
# Name of the testbench without extenstion
TESTBENCH = uart_rx_tb
#TESTBENCH = uart_tx_tb
#TESTBENCH = uart_loopback_tb

# VHDL files
ifeq ($(TESTBENCH), uart_rx_tb)
FILES = ../hdl/*.vhd
else ifeq ($(TESTBENCH), uart_tx_tb)
FILES = ../hdl/*.vhd
else ifeq ($(TESTBENCH), uart_loopback_tb)
FILES = ../hdl/*.vhd
endif

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=6us

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include ../../makefile.ghdl.mk

