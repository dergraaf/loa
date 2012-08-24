
# Name of the testbench without extenstion
TESTBENCH = toplevel_tb

# VHDL files
FILES =  \
	../toplevel.vhd \
	../fpga_memory_map.vhd \
	../../../modules/utils/hdl/utils_pkg.vhd \
	../../../modules/utils/hdl/clock_divider.vhd \
	../../../modules/utils/hdl/fractional_clock_divider_variable.vhd \
	../../../modules/utils/hdl/edge_detect.vhd \
	../../../modules/spislave/hdl/bus_pkg.vhd \
	../../../modules/spislave/hdl/spislave_pkg.vhd \
	../../../modules/spislave/hdl/spislave.vhd \
	../../../modules/motor_control/hdl/motor_control_pkg.vhd \
	../../../modules/motor_control/hdl/deadtime.vhd \
	../../../modules/adc_ltc2351/hdl/adc_ltc2351_pkg.vhd \
	../../../modules/adc_ltc2351/hdl/adc_ltc2351.vhd \
	../../../modules/uss_tx/hdl/uss_tx_pkg.vhd \
	../../../modules/uss_tx/hdl/uss_tx_module.vhd \
	../../../modules/ram/hdl/xilinx_block_ram_pkg.vhd \
	../../../modules/ram/hdl/xilinx_block_ram.vhd \
	../../../modules/peripheral_register/hdl/reg_file_pkg.vhd \
	../../../modules/peripheral_register/hdl/peripheral_register.vhd \
	../../../modules/peripheral_register/hdl/reg_file.vhd \
	../../../modules/peripheral_register/hdl/double_buffering.vhd \
	../../../modules/peripheral_register/hdl/reg_file_bram_double_buffered.vhd \
	../../../modules/ir_rx/hdl/ir_rx_module_pkg.vhd \
	../../../modules/ir_rx/hdl/ir_rx_module.vhd \
	../../../modules/ir_rx/hdl/ir_rx_adcs.vhd \
	../../../modules/ir_tx/hdl/ir_tx_pkg.vhd \
	../../../modules/ir_tx/hdl/ir_tx_module.vhd \
	../../../modules/signalprocessing/hdl/signalprocessing_pkg.vhd \
	../../../modules/signalprocessing/hdl/goertzel_muxes.vhd \
	../../../modules/signalprocessing/hdl/goertzel_control_unit.vhd \
	../../../modules/signalprocessing/hdl/goertzel_pipeline.vhd \
	../../../modules/signalprocessing/hdl/goertzel_pipelined_v2.vhd \
	../../../modules/signalprocessing/hdl/timestamp_generator.vhd \
	../../../modules/signalprocessing/hdl/timestamp_taker.vhd

# Default settings for gtkwave (visable signal etc.)
#  use gtkwave > File > Write Save File (Strg + S) to generate the file
WAVEFORM_SETTINGS = $(TESTBENCH).sav

# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=2ms

# Load default options for GHDL.
# Defines make [all|compile|run|view|clean]
include ../../../modules/makefile.ghdl.mk

