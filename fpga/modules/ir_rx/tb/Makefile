
# Name of the testbench without extenstion
#TESTBENCH = ir_rx_module_tb
#TESTBENCH = ir_rx_adcs_tb

# VHDL files

ADV_FILES = \
../../utils/hdl/utils_pkg.vhd \
../../utils/hdl/edge_detect.vhd \
../../spislave/hdl/bus_pkg.vhd \
../../ram/hdl/xilinx_block_ram_pkg.vhd \
../../ram/hdl/xilinx_block_ram.vhd \
../../spislave/hdl/bus_pkg.vhd \
../../peripheral_register/hdl/reg_file_pkg.vhd \
../../peripheral_register/hdl/reg_file.vhd \
../../peripheral_register/hdl/double_buffering.vhd \
../../peripheral_register/hdl/reg_file_bram_double_buffered.vhd \
../../adc_ltc2351/hdl/adc_ltc2351.vhd \
../hdl/ir_rx_adcs.vhd \
../../adc_ltc2351/hdl/adc_ltc2351_pkg.vhd \
../../adc_ltc2351/hdl/adc_ltc2351_model.vhd \
../../signalprocessing/hdl/signalprocessing_pkg.vhd \
../../signalprocessing/hdl/goertzel.vhd \
../../signalprocessing/hdl/goertzel_control_unit.vhd \
../../signalprocessing/hdl/goertzel_muxes.vhd \
../../signalprocessing/hdl/goertzel_pipeline.vhd \
../../signalprocessing/hdl/goertzel_pipelined_v2.vhd \
../../signalprocessing/hdl/timestamp_taker.vhd \
../../signalprocessing/hdl/timestamp_generator.vhd \
../hdl/ir_rx_module_pkg.vhd \
../hdl/ir_rx_module.vhd 

ifeq ($(TESTBENCH), ir_rx_module_tb) 
FILES = \
$(ADV_FILES) 
else ifeq ($(TESTBENCH), ir_rx_module_timestamp_tb)
FILES = \
$(ADV_FILES) \
../../signalprocessing/hdl/timestamp.vhd 
else ifeq ($(TESTBENCH), ir_rx_adcs_tb)
FILES = \
$(ADV_FILES) \
../../adc_ltc2351/hdl/adc_ltc2351_pkg.vhd \
../../adc_ltc2351/hdl/adc_ltc2351.vhd \
../hdl/ir_rx_adcs.vhd
endif

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=1000us

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include ../../makefile.ghdl.mk
