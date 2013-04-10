
# Name of the testbench without extenstion
#TESTBENCH = imotor_timer_tb
#TESTBENCH = imotor_uart_tx_tb
#TESTBENCH = imotor_sender_tb
#TESTBENCH = imotor_receiver_tb
TESTBENCH = imotor_transceiver_tb
#TESTBENCH = imotor_module_tb

# VHDL files
FILES = \
  ../hdl/imotor_module_pkg.vhd \
  ../../utils/hdl/*.vhd \
  ../../spislave/hdl/bus_pkg.vhd \
  ../../peripheral_register/hdl/*.vhd

ifeq ($(TESTBENCH), imotor_timer_tb)
FILES += \
  ../hdl/imotor_timer.vhd 
else ifeq ($(TESTBENCH), imotor_uart_tx_tb)
FILES += \
  ../hdl/imotor_uart_tx.vhd \
  ../hdl/imotor_timer.vhd
else ifeq ($(TESTBENCH), imotor_sender_tb)
FILES += \
  ../hdl/imotor_uart_tx.vhd \
  ../hdl/imotor_timer.vhd \
  ../hdl/imotor_sender.vhd 
else ifeq ($(TESTBENCH), imotor_receiver_tb)
FILES += \
  ../../uart/hdl/uart_pkg.vhd \
  ../hdl/imotor_receiver.vhd \
  ../hdl/imotor_timer.vhd
else ifeq ($(TESTBENCH), imotor_transceiver_tb)
FILES +=\
  ../../uart/hdl/uart_pkg.vhd \
  ../../uart/hdl/uart_tx.vhd \
  ../../uart/hdl/uart_rx.vhd \
  ../hdl/imotor_timer.vhd \
  ../hdl/imotor_sender.vhd \
  ../hdl/imotor_receiver.vhd \
  ../hdl/imotor_transceiver.vhd
else ifeq ($(TESTBENCH), imotor_modulde_tb)
FILES += \
  ../../uart/hdl/uart_pkg.vhd \
  ../../uart/hdl/uart_tx.vhd \
  ../../uart/hdl/uart_rx.vhd \
  ../hdl/imotor_timer.vhd \
  ../hdl/imotor_sender.vhd \
  ../hdl/imotor_receiver.vhd \
  ../hdl/imotor_transceiver.vhd \
  ../hdl/imotor_module.vhd
else
FILES = ../hdl/*.vhd
endif

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=500us

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include ../../makefile.ghdl.mk
