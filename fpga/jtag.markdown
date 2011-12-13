Programming a FPGA with UrJtag
==============================

See http://urjtag.sourceforge.net/

Generate a SVF File
-------------------

Create a new file called "impact.cmd" with the following content:

    setMode -bs
    setCable -port svf -file toplevel.svf
    addDevice -p 1 -file path/to/your/bitfile.bit
    program -p 1
    closeCable
    quit

Now run impact to create a SVF file:

    $ impact -batch impact.cmd

If the 'impact' command isn't found check that the ISE path is added to PATH.
For example add the following to ~/.bashrc (adapt it your ISE-path):
    export PATH=$PATH:/home/user/fpga/xilinx_ise/ISE_DS/ISE/bin/lin/


Download and Install
--------------------

get UrJtag at http://sourceforge.net/projects/urjtag/files/latest/download?source=files

    $ cd urjtag-0.10
    $ ./configure --with-libftdi --enable-lowlevel=ftdi
    $ make
    $ sudo make install


Connect to your FPGA
--------------------

    $ jtag
    jtag> cable jtagkey vid=0403 pid=6010 driver=ftdi-mpsse
    Connected to libftdi driver.
    jtag> detect
    IR length: 6
    Chain length: 1
    Device Id: 00000001010000011100000010010011 (0x000000000141C093)
      Manufacturer: Xilinx
      Part(0):         xc3s400
      Stepping:     0
      Filename:     /usr/local/share/urjtag/xilinx/xc3s400/xc3s400
    jtag> 


Program the FPGA
----------------

    jtag> svf toplevel.svf
    jtag> 

