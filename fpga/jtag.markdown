Programming an FPGA
===================

The result of the implementation with the synthesis tools from Xilinx is a bit-file. 
This bit-file must be programmed into the FPGA. This can be done by various means:

*   JTAG
*   Platform Flash
*   Microcontroller

See Xilinx documentation for details. Here programming the FPGA using the JTAG port
is describe. Two different tools are tested: UrJtag and xc3sprogram. Both were used 
with the busblaster v2 hardware. 

Using UrJtag
------------


See http://urjtag.sourceforge.net/

### Generate a SVF File

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


### Download and Install

get UrJtag at http://sourceforge.net/projects/urjtag/files/latest/download?source=files

    $ cd urjtag-0.10
    $ ./configure --with-libftdi --enable-lowlevel=ftdi
    $ make
    $ sudo make install

you can also use the git repository:

    $ git clone git://urjtag.git.sourceforge.net/gitroot/urjtag/urjtag urjtag
    $ cd urjtag/urjtag
    $ sudo apt-get install autoconf autopoint libtool libusb-dev libftdi-dev python-dev flex bison
    $ autoreconf -i -s -v -f
    $ ./configure
    $ make
    $ sudo make install

And for Ubuntu users:

    $ sudo su
    $ echo "/usr/local/lib" > /etc/ld.so.conf.d/other.conf
    $ ldconfig
    $ exit



### Connect to your FPGA

    $ jtag
    jtag> cable jtagkey vid=0x0403 pid=0x6010 driver=ftdi-mpsse
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


### Program the FPGA

    jtag> svf toplevel.svf
    jtag> 


xc3sprog
--------

The benefit of xc3sprog is that it is not necessary to run Xilinx Impact. 
xc3sprog can write bit-files directly to FPGA. 

### Get the latest xc3sprog

The precompiled version did not work. You need cmake and libftdi-dev. 

    $ svn co https://xc3sprog.svn.sourceforge.net/svnroot/xc3sprog xc3sprog

Create a new build directory and dive into

    $ mkdir xc3sprog/build
    $ cd    xc3sprog/build
    $ cmake ../trunk
    $ make

### Test the tool

Now xc3sprog is ready. Make sure you can access the USB device. Adjust 
permissions of /dev/bus/usb/00?/0??.

   $  ./xc3sprog -c bbv2 -j

will show something like

    XC3SPROG (c) 2004-2011 xc3sprog project $Rev: 674 $ OS: Linux
    Free software: If you contribute nothing, expect nothing!
    Feedback on success/failure/enhancement requests:
        http://sourceforge.net/mail/?group_id=170565 
    Check Sourceforge for updates:
        http://sourceforge.net/projects/xc3sprog/develop
    
    Using Libftdi, 
    JTAG loc.:   0  IDCODE: 0x01414093  Desc:                        XC3S200 Rev: A  IR length:  6
    JTAG loc.:   1  IDCODE: 0x05045093  Desc:                         XCF02S Rev: A  IR length:  8

### Write to FPGA

This was a test using the Digilent Spartan 3 Development board. You can write
a bit-file to the FPGA (or with -p 1 to the platform flash) using:

    $ ./xc3sprog -c bbv2 /path/to/your/bitfile.bit

