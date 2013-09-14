###############################################################################
#
# Copyright (c) 2013, AUTHOR
# All Rights Reserved.
#
# The file is part for the Loa project and is released under the
# 3-clause BSD license. See the file `LICENSE` for the full license
# governing this code.
#
###############################################################################

# Name of the testbench without extenstion
TESTBENCH = fifo_sync_tb
#TESTBENCH = fifo_sync2_tb

# VHDL files
ifeq ($(TESTBENCH), fifo_sync_tb)
FILES = \
../hdl/fifo_sync_pkg.vhd \
../hdl/fifo_sync.vhd \


else ifeq ($(TESTBENCH), fifo_sync2_tb)
FILES = ../hdl/*.vhd
endif

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=2us

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include ../../makefile.ghdl.mk

GHDL_IMPORT_FLAGS += --std=02