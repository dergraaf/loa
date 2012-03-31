#!/usr/bin/env python

import sys
import os
import string

header = '''
#include <xpcc/architecture/driver/accessor/flash.hpp>

// Bitstream for XC3S200A
FLASH_STORAGE(uint8_t bitstream[149516]) = 
{
	${data}
}
'''

if __name__ == '__main__':
	infile = sys.argv[1]
	outfile = sys.argv[2]
	filesize = 149516
	if os.path.getsize(infile) != filesize:
		print "Error in '%s': expect filesize %d bytes, but got %d bytes" % (infile, filesize, os.path.getsize(filename))
	
	count = 0
	data = ""
	for byte in open(infile).read():
		data += "0x%02x, " % ord(byte)
		
		count += 1
		if count == 16:
			count = 0
			data += "\n\t"
	
	open(outfile, 'w').write(string.Template(header).substitute(data=data))
	
