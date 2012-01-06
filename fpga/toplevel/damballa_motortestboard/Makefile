
PORT = /dev/ttyUSB1

toplevel.svf: ISE/toplevel.bit
	impact -batch impact.cmd

program: toplevel.svf
	jtag urjtag.cmd

dataflash:
	java -jar ../../../tools/upload/upload.jar --port $(PORT) ISE/toplevel.bin

.phony: program

