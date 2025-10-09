#!/bin/bash

# SPDX-FileCopyrightText: © 2024 JSilicon
# SPDX-License-Identifier: Apache-2.0

# UVM Test Runner Script for VCS & Verdi

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

print_error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

print_info() {
    echo -e "${YELLOW}[INFO] $1${NC}"
}

# Check if VCS is available
check_simulator() {
    if ! command -v vcs &> /dev/null; then
        print_error "VCS not found in PATH"
        print_info "Please ensure VCS is installed and in your PATH"
        print_info "You may need to source the VCS setup script:"
        print_info "  source /path/to/vcs/bin/synopsys_sim.setup"
        exit 1
    fi
    print_success "VCS found: $(vcs -ID | head -1)"
    
    # Check for Verdi (optional)
    if command -v verdi &> /dev/null; then
        print_success "Verdi found: $(verdi -version 2>&1 | head -1)"
    else
        print_info "Verdi not found - waveform viewing will be limited"
    fi
}

# Clean previous runs
clean() {
    print_info "Cleaning previous simulation files..."
    make clean 2>/dev/null || true
}

# Compile
compile() {
    print_header "Compiling RTL and UVM Files"
    if make compile; then
        print_success "Compilation successful"
    else
        print_error "Compilation failed"
        exit 1
    fi
}

# Run test
run_test() {
    local test_name=$1
    print_header "Running Test: $test_name"
    
    if make TEST=$test_name simulate; then
        print_success "Test $test_name completed"
    else
        print_error "Test $test_name failed"
        return 1
    fi
}

# Run all tests
run_all_tests() {
    print_header "Running All Tests"
    
    local tests=("jsilicon_manual_test" "jsilicon_cpu_test" "jsilicon_full_test")
    local failed_tests=()
    
    for test in "${tests[@]}"; do
        if ! run_test $test; then
            failed_tests+=($test)
        fi
        echo ""
    done
    
    print_header "Test Summary"
    echo -e "Total tests: ${#tests[@]}"
    echo -e "Passed: $((${#tests[@]} - ${#failed_tests[@]}))"
    echo -e "Failed: ${#failed_tests[@]}"
    
    if [ ${#failed_tests[@]} -eq 0 ]; then
        print_success "All tests passed!"
        return 0
    else
        print_error "Failed tests: ${failed_tests[*]}"
        return 1
    fi
}

# Run with Verdi GUI
run_gui() {
    print_header "Running Simulation with Verdi GUI"
    local test_name=${1:-jsilicon_full_test}
    
    if ! command -v verdi &> /dev/null; then
        print_error "Verdi not found in PATH"
        print_info "Running in interactive mode instead..."
        make TEST=$test_name interactive
    else
        make TEST=$test_name verdi
    fi
}

# View waveform
view_wave() {
    print_info "Opening waveform viewer (Verdi)..."
    
    if [ -f "jsilicon.fsdb" ]; then
        make wave
    elif [ -f "jsilicon_uvm.vcd" ]; then
        print_info "FSDB not found, but VCD file exists"
        if command -v verdi &> /dev/null; then
            print_info "Opening VCD with Verdi..."
            verdi -vcd jsilicon_uvm.vcd -nologo &
        elif command -v gtkwave &> /dev/null; then
            print_info "Opening VCD with GTKWave..."
            gtkwave jsilicon_uvm.vcd &
        else
            print_error "No waveform viewer found (Verdi or GTKWave)"
            exit 1
        fi
    else
        print_error "No waveform file found. Please run simulation first."
        exit 1
    fi
}

# Show usage
usage() {
    cat << EOF
========================================
UVM Test Runner Script for VCS & Verdi
========================================

Usage: $0 [OPTION]

Options:
    compile             Compile RTL and UVM files with VCS
    run <test>          Run specific test
    run_all             Run all tests
    gui [test]          Run simulation with Verdi GUI
    wave                View waveform with Verdi
    clean               Clean generated files
    help                Show this help message

Available Tests:
    jsilicon_manual_test   - Manual mode test
    jsilicon_cpu_test      - CPU mode test
    jsilicon_full_test     - Full test (default)
    jsilicon_random_test   - Random test

Examples:
    $0 compile                           # Compile only with VCS
    $0 run jsilicon_manual_test          # Run manual test
    $0 run_all                           # Run all tests
    $0 gui                               # Run Verdi GUI with full test
    $0 gui jsilicon_manual_test          # Run Verdi GUI with manual test
    $0 wave                              # View waveform with Verdi

Requirements:
    - Synopsys VCS (required for simulation)
    - Verdi (optional, for waveform viewing)

Setup:
    Make sure VCS is in your PATH:
    $ source /path/to/vcs/bin/synopsys_sim.setup
    
    Or add to your ~/.bashrc or ~/.cshrc

EOF
}

# Main script
main() {
    cd "$(dirname "$0")"
    
    if [ $# -eq 0 ]; then
        usage
        exit 0
    fi
    
    case "$1" in
        compile)
            check_simulator
            compile
            ;;
        run)
            if [ -z "$2" ]; then
                print_error "Please specify a test name"
                usage
                exit 1
            fi
            check_simulator
            compile
            run_test "$2"
            ;;
        run_all)
            check_simulator
            clean
            compile
            run_all_tests
            ;;
        gui)
            check_simulator
            compile
            run_gui "$2"
            ;;
        wave)
            view_wave
            ;;
        clean)
            clean
            print_success "Clean complete"
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
}

main "$@"

