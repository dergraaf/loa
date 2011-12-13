# Usage
# =====
# 
# Define the following variables and then include this file:
# 
#   TESTBENCH
#		Testbench file without extensition
#   FILES
#		List of all VHDL files (e.g. ../hdl/spislave.vhd ../hdl/spislave_pkg.vhd)
#   WAVEFORM_SETTINGS
#		Save file for gtkwave, may be empty.
#		Use gtkwave > File > Write Save File (Strg + S) to generate the file
#   GHDL_SIM_OPT
#		Options for GHDL (e.g. "--stop-time=12us")

VHDLEX ?= .vhd

# Testbench
TESTBENCHPATH ?= $(TESTBENCH)$(VHDLEX)

# GHDL configuration
GHDL ?= ghdl
GHDL_IMPORT_FLAGS += --ieee=synopsys 
GHDL_FLAGS += $(GHDL_IMPORT_FLAGS) --syn-binding

SIMDIR ?= simulation
WAVEFORM_VIEWER ?= gtkwave

all: compile run

compile:
	# check if TESTBENCH is empty
ifeq ($(strip $(TESTBENCH)),)
	@echo "TESTBENCH not set. Use TESTBENCH=value to set it."
	@exit 2
endif
	mkdir -p simulation
	$(GHDL) -i $(GHDL_IMPORT_FLAGS) --workdir=$(SIMDIR) --work=work $(TESTBENCHPATH) $(FILES)
	$(GHDL) -m $(GHDL_FLAGS) --workdir=$(SIMDIR) --work=work $(TESTBENCH)
	@mv $(TESTBENCH) simulation/$(TESTBENCH)

run:
	@$(SIMDIR)/$(TESTBENCH) $(GHDL_SIM_OPT) --vcdgz=$(SIMDIR)/$(TESTBENCH).vcdgz --wave=$(SIMDIR)/$(TESTBENCH).ghw

view:
	$(WAVEFORM_VIEWER) $(SIMDIR)/$(TESTBENCH).ghw $(WAVEFORM_SETTINGS)

clean:
	#$(GHDL) --clean --workdir=simulation
	rm -rf $(SIMDIR)

