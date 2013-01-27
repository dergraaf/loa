#!/usr/bin/python

import os

for r,d,f in os.walk("."):
    for file in f:
        if file.endswith("_tb.vhd"):
            print 'Found', file, 'in', r
            testbench = file.rstrip(".vhd")
            cmd = 'cd %s; make TESTBENCH="%s"' % (r, testbench)
            os.system(cmd)

