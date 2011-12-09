setMode -bs
setCable -port svf -file toplevel.svf
addDevice -p 1 -file ISE/toplevel_damballa.bit
program -p 1
closeCable
quit
