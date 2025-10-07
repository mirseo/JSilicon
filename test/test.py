# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles

async def reset_dut(dut):
    """
    Resets the DUT.
    """
    dut._log.info("Resetting DUT")
    dut.rst_n.value = 0
    # Keep inputs stable during reset
    dut.ui_in.value = 0
    dut.uio_in.value = 0
    dut.ena.value = 1
    await ClockCycles(dut.clk, 10)
    dut.rst_n.value = 1
    dut._log.info("Reset complete")

def get_result_from_outputs(dut):
    """
    Reconstructs the 16-bit ALU result from the fragmented output pins.
    Note: alu_result[8:7] are not wired to any output in the Verilog top module.
    This function will check the visible parts of the result.
    """
    # uo_out[6:0] = alu_result[6:0]
    # uio_out[7:1] = alu_result[15:9]
    
    result_low_part = dut.uo_out.value.integer & 0x7F
    result_high_part = (dut.uio_out.value.integer >> 1) & 0x7F
    
    return result_low_part, result_high_part

def calculate_expected_parts(expected_full_result):
    """
    Calculates the expected low and high parts of the result based on the DUT's wiring.
    """
    expected_low = expected_full_result & 0x7F
    expected_high = (expected_full_result >> 9) & 0x7F
    
    return expected_low, expected_high


@cocotb.test()
async def test_project(dut):
    """
    Main test function for the Jsilicon core.
    """
    dut._log.info("Starting test for Jsilicon Core")

    # Set the clock period to 10 us (100 KHz)
    clock = Clock(dut.clk, 10, unit="us")
    cocotb.start_soon(clock.start())

    # Initial reset
    await reset_dut(dut)

    # =================================================================
    # 1. Manual Mode Test (mode = 0)
    # =================================================================
    dut._log.info("--- Testing Manual Mode (mode=0) ---")
    
    # Test cases: [Opcode, A, B, Expected Result]
    manual_test_cases = [
        # Opcode, A, B, Expected
        (0b000, 10, 5, 15),     # 10 + 5 = 15
        (0b001, 10, 5, 5),      # 10 - 5 = 5
        (0b010, 10, 5, 50),     # 10 * 5 = 50
        (0b011, 10, 5, 2),      # 10 / 5 = 2
        (0b011, 10, 0, 0),      # 10 / 0 = 0 (special case)
        (0b100, 10, 3, 1),      # 10 % 3 = 1
        (0b101, 10, 10, 1),     # 10 == 10 -> True
        (0b101, 10, 5, 0),      # 10 == 5  -> False
        (0b110, 10, 5, 1),      # 10 > 5   -> True
        (0b110, 5, 10, 0),      # 5 > 10   -> False
        (0b111, 5, 10, 1),      # 5 < 10   -> True
        (0b111, 10, 5, 0),      # 10 < 5   -> False
    ]

    for opcode, a, b, expected in manual_test_cases:
        dut._log.info(f"Manual Test: A={a}, B={b}, Opcode={bin(opcode)[2:].zfill(3)}")

        # Set inputs for Manual mode
        # mode pin uio_in[4] is 0
        dut.ui_in.value = (a << 4) | b
        dut.uio_in.value = (opcode << 5)

        # Wait for combinational logic to settle
        await ClockCycles(dut.clk, 1)
        
        # Get actual result parts from outputs
        actual_low, actual_high = get_result_from_outputs(dut)
        
        # Get expected result parts
        expected_low, expected_high = calculate_expected_parts(expected)

        dut._log.info(f"Expected: {expected} (high={expected_high}, low={expected_low}), "
                      f"Got: (high={actual_high}, low={actual_low})")
        
        assert actual_low == expected_low, f"Mismatch on low part for A={a}, B={b}, Opcode={opcode}"
        assert actual_high == expected_high, f"Mismatch on high part for A={a}, B={b}, Opcode={opcode}"

    # =================================================================
    # 2. CPU Mode Test (mode = 1)
    # =================================================================
    dut._log.info("--- Testing CPU Mode (mode=1) ---")
    
    # Reset before switching mode
    await reset_dut(dut)
    
    # Set mode to CPU by setting uio_in[4] to 1
    dut.uio_in.value = (1 << 4)
    # Ensure other inputs are zeroed, although they should be ignored
    dut.ui_in.value = 0
    
    # The internal ROM program is: ADD 3, SUB 2, MUL 5, NOP
    # The architecture (Rdest = R0 op R1) and reset state (R0=0, R1=0)
    # means the ALU result will always be 0 for these operations.
    
    # --- Cycle 1: Fetches 'ADD 3', executes R0 + R1 ---
    await ClockCycles(dut.clk, 2) # Allow time for first instruction to propagate
    dut._log.info("CPU Cycle 1: Executing ADD")
    actual_low, actual_high = get_result_from_outputs(dut)
    expected_low, expected_high = calculate_expected_parts(0) # 0 + 0 = 0
    assert actual_low == expected_low and actual_high == expected_high, "CPU ADD instruction failed"
    dut._log.info("CPU ADD Result: OK")

    # --- Cycle 2: Fetches 'SUB 2', executes R0 - R1 ---
    await ClockCycles(dut.clk, 1)
    dut._log.info("CPU Cycle 2: Executing SUB")
    actual_low, actual_high = get_result_from_outputs(dut)
    expected_low, expected_high = calculate_expected_parts(0) # 0 - 0 = 0
    assert actual_low == expected_low and actual_high == expected_high, "CPU SUB instruction failed"
    dut._log.info("CPU SUB Result: OK")

    # --- Cycle 3: Fetches 'MUL 5', executes R0 * R1 ---
    await ClockCycles(dut.clk, 1)
    dut._log.info("CPU Cycle 3: Executing MUL")
    actual_low, actual_high = get_result_from_outputs(dut)
    expected_low, expected_high = calculate_expected_parts(0) # 0 * 0 = 0
    assert actual_low == expected_low and actual_high == expected_high, "CPU MUL instruction failed"
    dut._log.info("CPU MUL Result: OK")

    # --- Cycle 4: Fetches 'NOP' ---
    await ClockCycles(dut.clk, 1)
    dut._log.info("CPU Cycle 4: Executing NOP")
    # In NOP, alu_enable is 0, so ALU output defaults to 0
    actual_low, actual_high = get_result_from_outputs(dut)
    expected_low, expected_high = calculate_expected_parts(0) 
    assert actual_low == expected_low and actual_high == expected_high, "CPU NOP instruction failed"
    dut._log.info("CPU NOP Result: OK")
    
    # --- Cycle 5: PC wraps around, Fetches 'ADD 3' again ---
    await ClockCycles(dut.clk, 1)
    dut._log.info("CPU Cycle 5: PC Wrap-around, re-executing ADD")
    actual_low, actual_high = get_result_from_outputs(dut)
    expected_low, expected_high = calculate_expected_parts(0) # 0 + 0 = 0
    assert actual_low == expected_low and actual_high == expected_high, "CPU re-execution of ADD failed"
    dut._log.info("CPU PC Wrap-around: OK")

    dut._log.info("All tests passed!")