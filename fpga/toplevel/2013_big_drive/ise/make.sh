# Synthesis
xst -intstyle ise \
    -ifn "/home/rca/software/loa/fpga/toplevel/2013_big_drive/ise/toplevel.xst" \
    -ofn "/home/rca/software/loa/fpga/toplevel/2013_big_drive/ise/toplevel.syr"

# Translate
ngdbuild -intstyle ise -dd _ngo -nt timestamp \
    -uc /home/rca/software/loa/fpga/toplevel/2013_big_drive/board.ucf \
    -uc /home/rca/software/loa/fpga/toplevel/2013_big_drive/carrier.ucf \
    -p xc6slx9-tqg144-3 toplevel.ngc toplevel.ngd

# Map
map \
    -intstyle ise \
    -p xc6slx9-tqg144-3 -w -logic_opt off -ol high -t 1 -xt 0 \
    -register_duplication off \
    -r 4 -global_opt off -mt off -ir off -pr off -lc off \
    -power off -o toplevel_map.ncd toplevel.ngd toplevel.pcf

# Place and Route
par -w -intstyle ise -ol high -mt off toplevel_map.ncd toplevel.ncd toplevel.pcf

# Generate Post-Place & Route Static Timing".
trce -intstyle ise -v 3 -s 3 -n 3 -fastpaths \
    -xml toplevel.twx toplevel.ncd \
    -o toplevel.twr toplevel.pcf

# Generate Programming File".
bitgen -intstyle ise -f toplevel.ut toplevel.ncd

