
# Name of the testbench without extenstion
#TESTBENCH = goertzel_tb
#TESTBENCH = goertzel_pipelined_tb

#TESTBENCH = goertzel_pipeline_tb
#TESTBENCH = goertzel_control_unit_tb
#TESTBENCH = goertzel_muxes_tb
#TESTBENCH = goertzel_pipelined_v2_tb
#TESTBENCH = goertzel_pipelined_sim_tb
#TESTBENCH = io_test

# VHDL files
ifeq ($(TESTBENCH), goertzel_tb)
FILES = \
../../utils/hdl/utils_pkg.vhd \
../../spislave/hdl/bus_pkg.vhd \
../../peripheral_register/hdl/reg_file_pkg.vhd \
../../peripheral_register/hdl/reg_file.vhd \
../../adc_ltc2351/hdl/adc_ltc2351.vhd \
../../adc_ltc2351/hdl/adc_ltc2351_pkg.vhd \
../../adc_ltc2351/hdl/adc_ltc2351_model.vhd \
../hdl/signalprocessing_pkg.vhd \
../hdl/goertzel.vhd 
else ifeq ($(TESTBENCH), goertzel_pipelined_tb)
FILES = \
../../utils/hdl/utils_pkg.vhd \
../../spislave/hdl/bus_pkg.vhd \
../../peripheral_register/hdl/reg_file_pkg.vhd \
../../peripheral_register/hdl/reg_file.vhd \
../../adc_ltc2351/hdl/adc_ltc2351.vhd \
../../adc_ltc2351/hdl/adc_ltc2351_pkg.vhd \
../../adc_ltc2351/hdl/adc_ltc2351_model.vhd \
../hdl/signalprocessing_pkg.vhd \
../hdl/goertzel_pipelined.vhd 
else ifeq ($(TESTBENCH), goertzel_pipeline_tb)
FILES = \
../../utils/hdl/utils_pkg.vhd \
../../spislave/hdl/bus_pkg.vhd \
../../peripheral_register/hdl/reg_file_pkg.vhd \
../../peripheral_register/hdl/reg_file.vhd \
../../adc_ltc2351/hdl/adc_ltc2351.vhd \
../../adc_ltc2351/hdl/adc_ltc2351_pkg.vhd \
../../adc_ltc2351/hdl/adc_ltc2351_model.vhd \
../hdl/signalprocessing_pkg.vhd \
../hdl/goertzel_pipeline.vhd
else ifeq ($(TESTBENCH), goertzel_muxes_tb)
FILES = \
../../utils/hdl/utils_pkg.vhd \
../../spislave/hdl/bus_pkg.vhd \
../../peripheral_register/hdl/reg_file_pkg.vhd \
../../peripheral_register/hdl/reg_file.vhd \
../../adc_ltc2351/hdl/adc_ltc2351.vhd \
../../adc_ltc2351/hdl/adc_ltc2351_pkg.vhd \
../../adc_ltc2351/hdl/adc_ltc2351_model.vhd \
../hdl/signalprocessing_pkg.vhd \
../hdl/goertzel_muxes.vhd
else ifeq ($(TESTBENCH), goertzel_control_unit_tb)
FILES = \
../../utils/hdl/utils_pkg.vhd \
../../spislave/hdl/bus_pkg.vhd \
../../peripheral_register/hdl/reg_file_pkg.vhd \
../../peripheral_register/hdl/reg_file.vhd \
../../adc_ltc2351/hdl/adc_ltc2351.vhd \
../../adc_ltc2351/hdl/adc_ltc2351_pkg.vhd \
../../adc_ltc2351/hdl/adc_ltc2351_model.vhd \
../hdl/signalprocessing_pkg.vhd \
../hdl/goertzel_control_unit.vhd
else ifeq ($(TESTBENCH), goertzel_pipelined_v2_tb)
FILES = \
../../utils/hdl/utils_pkg.vhd \
../../spislave/hdl/bus_pkg.vhd \
../../peripheral_register/hdl/reg_file_pkg.vhd \
../../peripheral_register/hdl/reg_file.vhd \
../../adc_ltc2351/hdl/adc_ltc2351.vhd \
../../adc_ltc2351/hdl/adc_ltc2351_pkg.vhd \
../../adc_ltc2351/hdl/adc_ltc2351_model.vhd \
../hdl/signalprocessing_pkg.vhd \
../hdl/goertzel_control_unit.vhd \
../hdl/goertzel_muxes.vhd \
../hdl/goertzel_pipelined_v2.vhd
else ifeq ($(TESTBENCH), goertzel_pipelined_sim_tb)
FILES = \
../../utils/hdl/utils_pkg.vhd \
../../utils/hdl/edge_detect.vhd \
../../ram/hdl/xilinx_block_ram_pkg.vhd \
../../spislave/hdl/bus_pkg.vhd \
../../adc_ltc2351/hdl/adc_ltc2351_pkg.vhd \
../../ram/hdl/xilinx_block_ram_pkg.vhd \
../../ram/hdl/xilinx_block_ram.vhd \
../../peripheral_register/hdl/reg_file_pkg.vhd \
../../peripheral_register/hdl/double_buffering.vhd \
../../peripheral_register/hdl/reg_file_bram_double_buffered.vhd \
../hdl/signalprocessing_pkg.vhd \
./signal_sources_pkg.vhd \
./signal_sources.vhd \
../hdl/goertzel_control_unit.vhd \
../hdl/goertzel_muxes.vhd \
../hdl/goertzel_pipeline.vhd \
../hdl/goertzel_pipelined_v2.vhd
else ifeq ($(TESTBENCH), timestamp_tb)
FILES = \
../hdl/timestamp.vhd \
../hdl/signalprocessing_pkg.vhd \
timestamp_tb.vhd
else ifeq ($(TESTBENCH), real_tb)
FILES = \
real_tb.vhd
else ifeq ($(TESTBENCH), io_test)
FILES = \
io_test.vhd
endif

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=2ms

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include ../../makefile.ghdl.mk
