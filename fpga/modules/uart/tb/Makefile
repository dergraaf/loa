
# Name of the testbench without extenstion
#TESTBENCH ?= uart_rx_tb
#TESTBENCH ?= uart_rx_disable_tb
#TESTBENCH ?= uart_tx_tb
TESTBENCH ?= uart_loopback_tb
#TESTBENCH ?= uart_tb

# VHDL files
ifeq ($(TESTBENCH), uart_rx_tb)
FILES = uart_tb_pkg.vhd\
	../hdl/*.vhd
GHDL_SIM_OPT = --stop-time=6us

else ifeq ($(TESTBENCH), uart_rx_disable_tb)
FILES = uart_tb_pkg.vhd\
	../hdl/*.vhd
GHDL_SIM_OPT = --stop-time=6us

else ifeq ($(TESTBENCH), uart_tx_tb)
FILES = uart_tb_pkg.vhd\
	../hdl/*.vhd
GHDL_SIM_OPT = --stop-time=6us

else ifeq ($(TESTBENCH), uart_loopback_tb)
FILES = uart_tb_pkg.vhd\
	../hdl/*.vhd
GHDL_SIM_OPT = --stop-time=10us

else ifeq ($(TESTBENCH), uart_tb)
FILES = uart_tb_pkg.vhd\
	../hdl/*.vhd
GHDL_SIM_OPT = --stop-time=20us
endif

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Simulation break condition
#GHDL_SIM_OPT += --assert-level=error

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include ../../makefile.ghdl.mk

