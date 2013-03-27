#!/bin/bash

cd ise

# Generate toplevel.prj
# TBD

# Synthesis
xst -intstyle xflow \
    -ifn "toplevel.xst" \
    -ofn "toplevel.syr"

if [ $? != 0 ]
	then echo "error in xst command"
	exit 1
fi

# Translate
ngdbuild \
	-intstyle xflow \
	-dd _ngo \
	-nt timestamp \
    -uc ../board.ucf \
    -uc ../carrier.ucf \
    -p xc6slx9-tqg144-3 toplevel.ngc toplevel.ngd

if [ $? != 0 ]
	then echo "error in ngdbuild command"
	exit 1
fi

# Map
map \
    -intstyle xflow \
    -p xc6slx9-tqg144-3 \
	-w -logic_opt off \
	-ol high \
	-t 1 \
	-xt 0 \
    -register_duplication off \
    -r 4 \
    -global_opt off \
    -mt off \
    -ir off \
    -pr off \
    -lc off \
    -power off \
    -o toplevel_map.ncd \
	toplevel.ngd toplevel.pcf
if [ $? != 0 ]
	then echo "error in map command"
	exit 1
fi

# Place and Route
par \
    -w \
	-intstyle xflow \
    -ol high \
    -mt off \
	toplevel_map.ncd toplevel.ncd toplevel.pcf
if [ $? != 0 ]
	then echo "error in par command"
	exit 1
fi

# Generate Post-Place & Route Static Timing".
trce \
    -intstyle xflow \
    -v 3 -s 3 -n 3 -fastpaths \
    -xml toplevel.twx toplevel.ncd \
    -o toplevel.twr toplevel.pcf
if [ $? != 0 ]
	then echo "error in trce command"
	exit 1
fi

# Generate Programming File".
# needs toplevel.ut
bitgen \
    -intstyle xflow \
    -f toplevel.ut \
	toplevel.ncd

cd ..

# Generate SVF from bitstream
impact \
	-batch impact.cmd
