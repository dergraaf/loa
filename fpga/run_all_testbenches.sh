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
make TESTBENCH=quadrature_decoder_tb
make TESTBENCH=input_capture_tb
popd

pushd modules/io/tb
make TESTBENCH=shiftout_tb
popd

