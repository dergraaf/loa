
# PORT = /dev/tty.SLAB_USBtoUART
# PORT = /dev/tty.usbserial-AH000JY3
# PORT = /dev/tty.usbserial
PORT = /dev/tty.usbserial-A900LKAF

toplevel.svf: ise/toplevel.bit
	impact -batch impact.cmd

program: toplevel.svf
	jtag urjtag.cmd

dataflash:
	java -jar ../../../tools/upload/upload.jar --port $(PORT) ise/toplevel.bin

.phony: program

