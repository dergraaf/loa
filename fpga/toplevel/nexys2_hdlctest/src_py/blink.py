#!/usr/bin/env python 

import serial
import CrcMoose
import time
import sys 

class hdlc_busmaster:
    def __init__(self, port):
        self.s = serial.Serial(port, baudrate=115200, timeout=0.01, parity=serial.PARITY_ODD)

    def read(self, addr):
        cmd = "\x10" + chr((addr >> 8) & 0xff) + chr((addr) & 0xff)  
        cmd = "\x7e" + cmd + chr(CrcMoose.CRC8_SMBUS.calcString(cmd))
        self.s.write(cmd)

        reply = self.s.read(5)
        assert(len(reply) == 5)
        assert(reply[0] == "\x7e")
        assert(hex(CrcMoose.CRC8_SMBUS.calcString(reply[1:4]) == reply[4]))
        data = (ord(reply[2]) << 8) + ord(reply[3])
        return data

    def write(self, addr, data):
        cmd = "\x20" + chr((addr >> 8) & 0xff) + chr((addr) & 0xff) + chr((data >> 8) & 0xff) + chr((data) & 0xff) 
        cmd = "\x7e" + cmd + chr(CrcMoose.CRC8_SMBUS.calcString(cmd))
        self.s.write(cmd)

        reply = self.s.read(3)
        assert(len(reply) == 3)
        assert(reply[0] == "\x7e")
        assert(reply[1] == "\x21")
        assert(reply[2] == "\xe7")

if __name__ == "__main__":
    if len(sys.argv) == 1:
        port = "/dev/ttyUSB0"
    else:
        port = sys.argv[1]

    fpga = hdlc_busmaster(port)
    for x in range(100):
        sw = fpga.read(0x0000)
        led = 1 << (x%8)
        fpga.write(0x0000, led | sw)
        time.sleep(0.25)
    fpga.write(0x0000, 0x0055)
