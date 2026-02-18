# ============================================================================
# ChaCha20 FPGA - Comprehensive Makefile
# ============================================================================
# Targets:
#   make qr_test   - Run quarter_round testbench
#   make sim       - Run full system simulation (top_tb)
#   make synth     - Run synthesis for target FPGA
#   make clean     - Remove all build artifacts
#   make all       - Run all tests and synthesis
# ============================================================================

# Directory structure
SRC_DIR     := src
TB_DIR      := tb
SCRIPT_DIR  := scripts
BUILD_DIR   := build

# Build subdirectories
QR_BUILD    := $(BUILD_DIR)/qr_test
SIM_BUILD   := $(BUILD_DIR)/sim
SYNTH_BUILD := $(BUILD_DIR)/synth

# Source files
RTL_SOURCES := $(SRC_DIR)/quarter_round.sv \
               $(SRC_DIR)/state.sv \
               $(SRC_DIR)/block.sv \
               $(SRC_DIR)/top.sv

QR_TB       := $(TB_DIR)/quarter_round_tb.sv
TOP_TB      := $(TB_DIR)/top_tb.sv

# FPGA target part (change as needed)
# For PYNQ-Z2: xc7z020clg400-1 (requires Zynq device support)
# For testing: xc7a35tcpg236-1 (Artix-7, commonly installed)
FPGA_PART   ?= xc7a35tcpg236-1
TOP_MODULE  := chacha20_top

# Vivado tools
XVLOG       := xvlog
XELAB       := xelab
XSIM        := xsim
VIVADO      := vivado

# Compilation flags
XVLOG_FLAGS := --sv
XELAB_FLAGS := -debug typical

# Colors for output
COLOR_RESET := \033[0m
COLOR_BLUE  := \033[1;34m
COLOR_GREEN := \033[1;32m
COLOR_CYAN  := \033[1;36m

# ============================================================================
# Phony targets
# ============================================================================
.PHONY: all qr_test sim synth clean help check_vivado

# Default target
all: qr_test sim synth

help:
	@echo "=========================================="
	@echo "ChaCha20 FPGA Build System"
	@echo "=========================================="
	@echo "Available targets:"
	@echo "  make qr_test   - Run quarter_round unit test"
	@echo "  make sim       - Run full ChaCha20 simulation"
	@echo "  make synth     - Synthesize design for $(FPGA_PART)"
	@echo "  make clean     - Remove all build artifacts"
	@echo "  make all       - Run all tests and synthesis"
	@echo ""
	@echo "Variables:"
	@echo "  FPGA_PART      - Target FPGA part (current: $(FPGA_PART))"
	@echo ""
	@echo "Examples:"
	@echo "  make sim"
	@echo "  make synth FPGA_PART=xc7z020clg400-1"
	@echo "=========================================="

# Check if Vivado is available
check_vivado:
	@which $(VIVADO) > /dev/null || \
		(echo "ERROR: Vivado not found in PATH"; \
		 echo "Source Vivado settings: source /path/to/Vivado/settings64.sh"; \
		 exit 1)

# ============================================================================
# Quarter Round Test
# ============================================================================
qr_test: check_vivado $(QR_BUILD)/.timestamp
	@echo "$(COLOR_BLUE)=========================================$(COLOR_RESET)"
	@echo "$(COLOR_BLUE)Running Quarter Round Test$(COLOR_RESET)"
	@echo "$(COLOR_BLUE)=========================================$(COLOR_RESET)"
	@cd $(QR_BUILD) && $(XSIM) qr_sim -runall
	@echo "$(COLOR_GREEN)✓ Quarter Round test complete$(COLOR_RESET)"

$(QR_BUILD)/.timestamp: $(SRC_DIR)/quarter_round.sv $(QR_TB) | $(QR_BUILD)
	@echo "$(COLOR_CYAN)Compiling quarter_round module...$(COLOR_RESET)"
	@cd $(QR_BUILD) && $(XVLOG) $(XVLOG_FLAGS) ../../$(SRC_DIR)/quarter_round.sv
	@echo "$(COLOR_CYAN)Compiling quarter_round testbench...$(COLOR_RESET)"
	@cd $(QR_BUILD) && $(XVLOG) $(XVLOG_FLAGS) ../../$(QR_TB)
	@echo "$(COLOR_CYAN)Elaborating quarter_round simulation...$(COLOR_RESET)"
	@cd $(QR_BUILD) && $(XELAB) quarter_round_tb $(XELAB_FLAGS) -s qr_sim
	@touch $@

$(QR_BUILD):
	@mkdir -p $(QR_BUILD)

# ============================================================================
# Full System Simulation
# ============================================================================
sim: check_vivado $(SIM_BUILD)/.timestamp
	@echo "$(COLOR_BLUE)=========================================$(COLOR_RESET)"
	@echo "$(COLOR_BLUE)Running ChaCha20 System Simulation$(COLOR_RESET)"
	@echo "$(COLOR_BLUE)=========================================$(COLOR_RESET)"
	@cd $(SIM_BUILD) && $(XSIM) top_sim -runall
	@echo "$(COLOR_GREEN)✓ System simulation complete$(COLOR_RESET)"

$(SIM_BUILD)/.timestamp: $(RTL_SOURCES) $(TOP_TB) | $(SIM_BUILD)
	@echo "$(COLOR_CYAN)Compiling RTL sources...$(COLOR_RESET)"
	@cd $(SIM_BUILD) && $(XVLOG) $(XVLOG_FLAGS) \
		../../$(SRC_DIR)/quarter_round.sv \
		../../$(SRC_DIR)/state.sv \
		../../$(SRC_DIR)/block.sv \
		../../$(SRC_DIR)/top.sv
	@echo "$(COLOR_CYAN)Compiling top-level testbench...$(COLOR_RESET)"
	@cd $(SIM_BUILD) && $(XVLOG) $(XVLOG_FLAGS) ../../$(TOP_TB)
	@echo "$(COLOR_CYAN)Elaborating system simulation...$(COLOR_RESET)"
	@cd $(SIM_BUILD) && $(XELAB) chacha20_top_tb $(XELAB_FLAGS) -s top_sim
	@touch $@

$(SIM_BUILD):
	@mkdir -p $(SIM_BUILD)

# ============================================================================
# Synthesis
# ============================================================================
synth: check_vivado $(SYNTH_BUILD)/.timestamp
	@echo "$(COLOR_GREEN)=========================================$(COLOR_RESET)"
	@echo "$(COLOR_GREEN)SYNTHESIS COMPLETE$(COLOR_RESET)"
	@echo "$(COLOR_GREEN)=========================================$(COLOR_RESET)"
	@echo ""
	@echo "Reports saved to: $(SYNTH_BUILD)/"
	@echo "  - utilization.rpt"
	@echo "  - timing.rpt"
	@echo ""
	@echo "Quick Summary:"
	@grep -A 10 "Slice Logic" $(SYNTH_BUILD)/utilization.rpt | head -n 12

$(SYNTH_BUILD)/.timestamp: $(RTL_SOURCES) | $(SYNTH_BUILD)
	@echo "$(COLOR_BLUE)=========================================$(COLOR_RESET)"
	@echo "$(COLOR_BLUE)ChaCha20 Synthesis$(COLOR_RESET)"
	@echo "$(COLOR_BLUE)Target: $(FPGA_PART)$(COLOR_RESET)"
	@echo "$(COLOR_BLUE)=========================================$(COLOR_RESET)"
	@echo "$(COLOR_CYAN)Starting synthesis (this may take a few minutes)...$(COLOR_RESET)"
	@cd $(SYNTH_BUILD) && $(VIVADO) -mode batch -source ../../$(SCRIPT_DIR)/run_synth.tcl \
		-tclargs $(FPGA_PART) $(TOP_MODULE) ../../$(SRC_DIR)
	@touch $@

$(SYNTH_BUILD):
	@mkdir -p $(SYNTH_BUILD)

# ============================================================================
# Clean
# ============================================================================
clean:
	@echo "$(COLOR_CYAN)Cleaning build artifacts...$(COLOR_RESET)"
	@rm -rf $(BUILD_DIR)
	@rm -rf $(SCRIPT_DIR)/sim_build $(SCRIPT_DIR)/synth_build
	@rm -rf *.jou *.log .Xil
	@rm -rf vivado*.jou vivado*.log
	@echo "$(COLOR_GREEN)✓ Clean complete$(COLOR_RESET)"

# ============================================================================
# End of Makefile
# ============================================================================
