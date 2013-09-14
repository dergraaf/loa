Project Loa
===========

The goal of the project is to develop a powerfull and flexible control board
for robotic (and other) applications.

A microcontroller from the STM32F series from ST is used as the central
processing unit. It is coupled with a Spartan-3 FPGA from Xilinx which will
be used as a powerfull I/O-Expander. With this combination it is possible to
control multiple motors with encoders and other actuators while processing
sensor data and controlling the robot.

For small robots everything will fit into the control board, for big system
the board can act as combined motor controller and sensor preprocessor.
The actual planning etc. can than be outsourced to a faster microcontroller
or PC connected via USB or a fast UART bus.

Naming
------

A "Loa" is a allknowing ghost in Voodoo. The different boards are named
after loas.
