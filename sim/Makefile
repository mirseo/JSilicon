# SPDX-FileCopyrightText: © 2024 JSilicon
# SPDX-License-Identifier: Apache-2.0

# Makefile for UVM testbench with VCS

# Simulator selection (default: VCS)
SIM ?= vcs

# Test selection
TEST ?= jsilicon_full_test

# Verbosity level
VERBOSITY ?= UVM_MEDIUM

# Directories
SRC_DIR = ../src
SIM_DIR = .
TEST_DIR = ../test

# Source files
RTL_FILES = \
	$(SRC_DIR)/alu.v \
	$(SRC_DIR)/fsm.v \
	$(SRC_DIR)/inst.v \
	$(SRC_DIR)/pc.v \
	$(SRC_DIR)/regfile.v \
	$(SRC_DIR)/switch.v \
	$(SRC_DIR)/uart.v \
	$(SRC_DIR)/jsilicon.v

# UVM files
UVM_FILES = \
	jsilicon_if.sv \
	jsilicon_pkg.sv \
	jsilicon_tb_top.sv

# VCS compilation options
VCS_OPTS = \
	-full64 \
	-sverilog \
	-timescale=1ns/1ps \
	-ntb_opts uvm-1.2 \
	-debug_access+all \
	-kdb \
	-lca \
	-CFLAGS -DVCS

# VLOGAN options for analysis
VLOGAN_OPTS = \
	-full64 \
	-sverilog \
	-timescale=1ns/1ps \
	-ntb_opts uvm-1.2

# Runtime options
SIMV_OPTS = \
	+UVM_TESTNAME=$(TEST) \
	+UVM_VERBOSITY=$(VERBOSITY) \
	-l simv.log

# GUI options (Verdi)
VERDI_OPTS = \
	-ssf jsilicon.fsdb \
	-nologo

# Simulation executable
SIMV = ./simv

# Default target
all: compile

# Compile with VCS
compile:
	@echo "==================================="
	@echo "Compiling with VCS..."
	@echo "==================================="
	vcs $(VCS_OPTS) \
		$(RTL_FILES) \
		$(UVM_FILES) \
		-top jsilicon_tb_top \
		-o simv

# Simulate
simulate: compile
	@echo "==================================="
	@echo "Running UVM test: $(TEST)"
	@echo "==================================="
	$(SIMV) $(SIMV_OPTS)

# Run with Verdi GUI
verdi: compile
	@echo "==================================="
	@echo "Running with Verdi GUI: $(TEST)"
	@echo "==================================="
	$(SIMV) $(SIMV_OPTS) -gui=verdi

# Interactive mode
interactive: compile
	@echo "==================================="
	@echo "Running in interactive mode: $(TEST)"
	@echo "==================================="
	$(SIMV) $(SIMV_OPTS) -ucli

# Run specific tests
test_manual:
	@$(MAKE) TEST=jsilicon_manual_test simulate

test_cpu:
	@$(MAKE) TEST=jsilicon_cpu_test simulate

test_full:
	@$(MAKE) TEST=jsilicon_full_test simulate

test_random:
	@$(MAKE) TEST=jsilicon_random_test simulate

# View waveform with Verdi
wave:
	@if [ -f "jsilicon.fsdb" ]; then \
		echo "Opening Verdi..."; \
		verdi $(VERDI_OPTS) & \
	else \
		echo "Error: jsilicon.fsdb not found. Run simulation first."; \
		exit 1; \
	fi

# Post-process waveform
wave_dump:
	@echo "Opening existing FSDB with Verdi..."
	verdi -ssf jsilicon.fsdb -nologo &

# Coverage report
cov:
	@echo "Generating coverage report..."
	urg -dir simv.vdb -report urgReport

# Clean
clean:
	@echo "Cleaning generated files..."
	rm -rf simv* csrc DVEfiles
	rm -rf *.log *.vpd *.fsdb *.vcd
	rm -rf urgReport
	rm -rf work.lib++
	rm -rf verdiLog novas* *.conf
	rm -rf AN.DB
	rm -rf .vlogansetup.args .vcs*
	rm -rf *.key

# Help
help:
	@echo "=========================================="
	@echo "UVM Testbench Makefile for VCS & Verdi"
	@echo "=========================================="
	@echo ""
	@echo "Targets:"
	@echo "  all          - Compile with VCS (default)"
	@echo "  compile      - Compile RTL and UVM files with VCS"
	@echo "  simulate     - Compile and run simulation"
	@echo "  verdi        - Run simulation with Verdi GUI"
	@echo "  interactive  - Run simulation in interactive mode (UCLI)"
	@echo "  test_manual  - Run manual mode test"
	@echo "  test_cpu     - Run CPU mode test"
	@echo "  test_full    - Run full test (manual + CPU)"
	@echo "  test_random  - Run random test"
	@echo "  wave         - View waveform with Verdi"
	@echo "  wave_dump    - Open existing FSDB file"
	@echo "  cov          - Generate coverage report"
	@echo "  clean        - Remove generated files"
	@echo "  help         - Show this help message"
	@echo ""
	@echo "Variables:"
	@echo "  TEST         - Test to run (default: jsilicon_full_test)"
	@echo "  VERBOSITY    - UVM verbosity (default: UVM_MEDIUM)"
	@echo "  SIM          - Simulator to use (default: vcs)"
	@echo ""
	@echo "Examples:"
	@echo "  make                                    - Compile with VCS"
	@echo "  make simulate                           - Compile and run"
	@echo "  make TEST=jsilicon_manual_test simulate - Run manual test"
	@echo "  make verdi                              - Run with Verdi GUI"
	@echo "  make wave                               - View waveform"
	@echo "  make VERBOSITY=UVM_HIGH simulate        - Run with high verbosity"
	@echo "  make clean all                          - Clean and rebuild"

.PHONY: all compile simulate verdi interactive test_manual test_cpu test_full test_random wave wave_dump cov clean help

