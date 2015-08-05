#!/usr/bin/python

import os

# Populate list with items 
L = []
for r,d,f in os.walk("."):
    for file in f:
        if file.endswith("_tb.vhd"):
            testbench = file.rstrip(".vhd")
            L.append( [r, testbench, None] )

# Run testbenches
i = iter(L)
while True:
    try:
        item = i.next()
    except StopIteration:
        break

    (dir, testbench, ret) = item

    cmd = 'cd %s; make TESTBENCH="%s"' % (dir, testbench)
    print('**** In %s running testbench %s' % (dir, testbench))
    ret = os.system(cmd)
    print('**** Return code is %d' % (ret))
    print 
    item[2] = ret
    
# Print results summary
heading = ('%-40s ==> %-40s ==> %3s' % ('Directory', 'Testbench', 'Return value'))
print(heading)
print('-' * len(heading))
for dir, testbench, ret in L:
    print('%-40s ==> %-40s ==> %3d' % (dir, testbench, ret))


