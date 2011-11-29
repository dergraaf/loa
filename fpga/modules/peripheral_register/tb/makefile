# vhdl files

VHDLEX = .vhd
TESTBENCH = peripheral_register_tb

# testbench
TESTBENCHPATH = ${TESTBENCH}$(VHDLEX)

FILES = ../hdl/peripheral_register.vhd 
#\
#../hdl/spislave_pkg.vhd \

#$(TESTBENCHPATH)

 
#GHDL CONFIG
GHDL_CMD = ghdl
GHDL_IMPORT_FLAGS = --ieee=synopsys 
GHDL_FLAGS  = $(GHDL_IMPORT_FLAGS) --syn-binding 


SIMDIR = simulation
# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=12us
 
WAVEFORM_VIEWER = gtkwave
 
all: compile run
 
new :
	echo "Setting up project ${PROJECT}"
	mkdir src testbench simulation	
 
compile :
ifeq ($(strip $(TESTBENCH)),)
		@echo "TESTBENCH not set. Use TESTBENCH=value to set it."
		@exit 2
endif                                                                                             
 
	mkdir -p simulation
	$(GHDL_CMD) -i $(GHDL_IMPORT_FLAGS) --workdir=simulation --work=work $(TESTBENCHPATH) $(FILES)
	$(GHDL_CMD) -m $(GHDL_FLAGS) --workdir=simulation --work=work $(TESTBENCH)
	@mv $(TESTBENCH) simulation/$(TESTBENCH)                                                                                
 
run :
	@$(SIMDIR)/$(TESTBENCH) $(GHDL_SIM_OPT) --vcdgz=$(SIMDIR)/$(TESTBENCH).vcdgz --wave=$(SIMDIR)/$(TESTBENCH).ghw
 
view :
	#gunzip --stdout $(SIMDIR)/$(TESTBENCH).vcdgz | $(WAVEFORM_VIEWER) --vcd                                               
	$(WAVEFORM_VIEWER)  $(SIMDIR)/$(TESTBENCH).ghw

clean :
	$(GHDL_CMD) --clean --workdir=simulation
