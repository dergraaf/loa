Configuration Workflow
======================

FPGA connected by JTAG
----------------------

	 VHDL Files, UCF Files
	  |
	  | Xilinx ISE: xst, ngdbuild, map, par, trce, bitgen
	  v
	 ise/toplevel.bit
	  |
	  | Xilinx ISE: impact -batch impact.cmd
	  v
	 ise/toplevel.svf
	  |
	  | UrJTAG: jtag urjtag.cmd
	  v
	 FPGA per JTAG
	 
Configure FPGA by STM32
-----------------------

The configuration must be stored into the external flash. 
There is a java tool


	 VHDL Files, UCF Files
	  |
	  | Xilinx ISE: xst, ngdbuild, map, par, trce, bitgen
	  v
	 ise/toplevel.bit
	  |
	  | 
	  v
	  
	  