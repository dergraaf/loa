#/bin/bash
pushd modules/adc_ltc2351/tb/
make TESTBENCH=adc_ltc2351_tb
make TESTBENCH=adc_ltc2351_module_tb
make TESTBENCH=adc_ltc2351_model_tb
popd

pushd modules/adc_mcp3008/tb
make TESTBENCH=adc_mcp3008_tb
make TESTBENCH=adc_mcp3008_module_tb
popd

pushd modules/encoder/tb
make TESTBENCH=encoder_module_tb
make TESTBENCH=input_capture_tb
make TESTBENCH=quadrature_decoder_tb
popd

pushd modules/io/tb
make TESTBENCH=shiftout_tb
popd

pushd modules/ir_rx/tb
make TESTBENCH=ir_rx_adcs_tb
make TESTBENCH=ir_rx_module_tb
popd

pushd modules/ir_tx/tb
# make TESTBENCH=_tb
# make TESTBENCH=_tb
popd

pushd modules/motor_control/tb
make TESTBENCH=bldc_motor_module_tb
make TESTBENCH=commutation_tb
make TESTBENCH=comparator_module_tb
make TESTBENCH=symmetric_pwm_deadtime_tb
make TESTBENCH=symmetric_pwm_tb
popd

pushd modules/peripheral_register/tb
make TESTBENCH=double_buffering_tb
make TESTBENCH=peripheral_register_tb
make TESTBENCH=reg_file_bram_double_buffered_tb
make TESTBENCH=reg_file_bram_tb
make TESTBENCH=reg_file_tb
popd

pushd modules/pwm/tb
make TESTBENCH=pwm_module_tb
make TESTBENCH=pwm_tb
popd

pushd modules/ram/tb
make TESTBENCH=xilinx_block_ram_tb
popd

pushd modules/servo/tb
make TESTBENCH=servo_module_tb
make TESTBENCH=servo_sequencer_tb
popd

pushd modules/signalprocessing/tb
make TESTBENCH=goertzel_control_unit_tb
make TESTBENCH=goertzel_muxes_tb
make TESTBENCH=goertzel_pipeline_tb
make TESTBENCH=goertzel_pipelined_sim_tb
make TESTBENCH=goertzel_pipelined_tb
make TESTBENCH=goertzel_pipelined_v2_tb
make TESTBENCH=goertzel_tb
make TESTBENCH=timestamp_tb
popd

pushd modules/spislave/tb
make TESTBENCH=spi_slave_tb
popd

pushd modules/uss_rx/tb
# make TESTBENCH=_tb
# make TESTBENCH=_tb
popd

pushd modules/uss_tx/tb
make TESTBENCH=uss_tx_module_tb
popd

pushd modules/utils/tb
make TESTBENCH=clock_divider_tb
make TESTBENCH=edge_detect_tb
make TESTBENCH=event_hold_stage_tb
make TESTBENCH=fractional_clock_divider_tb
make TESTBENCH=fractional_clock_divider_variable_tb
make TESTBENCH=utils_tb
popd
