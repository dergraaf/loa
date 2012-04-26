
# Name of the testbench without extenstion
TESTBENCH = ir_rx_module_tb

# VHDL files
ifeq ($(TESTBENCH), ir_rx_module_tb)
FILES = \
../../utils/hdl/utils_pkg.vhd \
../../utils/hdl/edge_detect.vhd \
../../spislave/hdl/bus_pkg.vhd \
../../ram/hdl/xilinx_block_ram_pkg.vhd \
../../ram/hdl/xilinx_block_ram.vhd \
../../peripheral_register/hdl/reg_file_pkg.vhd \
../../peripheral_register/hdl/reg_file.vhd \
../../peripheral_register/hdl/double_buffering.vhd \
../../peripheral_register/hdl/reg_file_bram_double_buffered.vhd \
../../adc_ltc2351/hdl/adc_ltc2351.vhd \
../../adc_ltc2351/hdl/adc_ltc2351_pkg.vhd \
../../adc_ltc2351/hdl/adc_ltc2351_model.vhd \
../../signalprocessing/hdl/signalprocessing_pkg.vhd \
../../signalprocessing/hdl/goertzel.vhd \
../../signalprocessing/hdl/goertzel_control_unit.vhd \
../../signalprocessing/hdl/goertzel_muxes.vhd \
../../signalprocessing/hdl/goertzel_pipeline.vhd \
../../signalprocessing/hdl/goertzel_pipelined_v2.vhd \
../hdl/ir_rx_module_pkg.vhd \
../hdl/ir_rx_module.vhd 
else ifeq ($(TESTBENCH), adc_ltc2351_module_tb)
FILES = \
../../peripheral_register/tb/reg_file_tb.vhd 
endif

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=100us

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include ../../makefile.ghdl.mk
