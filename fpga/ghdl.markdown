
GHDL
====

GHDL is an open-source VHDL simulator. It compiles VHDL files into an executable
which then can be run to generate a waveform files. gtkwave or other
waveform viewers may be used to view the generated files.

GHDL is based on the GNU compiler GCC and runs on Linux, Windows and Apple OS X.


Installation
------------

For Ubuntu:

    $ sudo apt-get install ghdl


Usage
-----

    $ ghdl -i FILES

First GHDL is ran with the -i option and a list of all files in the design.
This analysis all units in the design in the correct order, and will check
for errors in the VHDL code.

    $ ghdl -m TESTBENCH_NAME

Next GHDL is ran with the -m option and the name of the top unit which will
usually be a testbench. This analysis and elaborates the design and creates
an executable to run the simulation.

    $ ghdl -r TESTBENCH_NAME
    or
    $ ./TESTBENCH_NAME

The simulation is ran executing ghdl with the -r option or by running the
generated executable.


FAQ
---

Code triggers "error: bound check failed (#0)":
   Perhaps a generic without a value
