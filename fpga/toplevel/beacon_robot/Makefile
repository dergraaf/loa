
PORT = /dev/ttyUSB0

toplevel.svf: ise/toplevel.bit
	impact -batch impact.cmd

header: ise/toplevel.bin
	python bin2c.py ise/toplevel.bin /home/alpha/rca/roboter/2012_captain/software/projects/beacon_system/beacon/stm32/bitstream.hpp

program: toplevel.svf
	jtag urjtag.cmd

dataflash:
	java -jar ../../../tools/upload/upload.jar --port $(PORT) ise/toplevel.bin

.phony: program dataflash

