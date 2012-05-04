mkdir -p simulation
ghdl -i --ieee=synopsys  --workdir=simulation --work=work real_tb.vhd 
ghdl -m --ieee=synopsys  --syn-binding --workdir=simulation --work=work real_tb
simulation/real_tb --stop-time=1000us --vcd=simulation/real_tb.vcd --wave=simulation/real_tb.ghw
gtkwave simulation/real_tb.ghw real_tb.sav
