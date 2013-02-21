
# Name of the testbench without extenstion
#TESTBENCH = imotor_timer_tb
#TESTBENCH = imotor_uart_tx_tb
TESTBENCH = imotor_sender_tb

# VHDL files
FILES = \
  ../hdl/imotor_module_pkg.vhd \
  ../../utils/hdl/*.vhd \
  ../../spislave/hdl/bus_pkg.vhd

ifeq ($(TESTBENCH), imotor_timer_tb)
FILES += \
  ../hdl/imotor_timer.vhd 
else ifeq ($(TESTBENCH), imotor_uart_tx_tb)
FILES += \
  ../hdl/imotor_uart_tx.vhd
else ifeq ($(TESTBENCH), imotor_sender_tb)
FILES += \
  ../hdl/imotor_timer.vhd \
  ../hdl/imotor_sender.vhd 
else
FILES = ../hdl/*.vhd
endif

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=20us

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include ../../makefile.ghdl.mk
