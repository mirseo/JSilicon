// SPDX-FileCopyrightText: © 2024 JSilicon
// SPDX-License-Identifier: Apache-2.0

`timescale 1ns/1ps

module jsilicon_tb_top;
    
    import uvm_pkg::*;
    import jsilicon_pkg::*;
    
    // Clock generation
    logic clk;
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz clock (10ns period)
    end
    
    // Interface instantiation
    jsilicon_if vif(clk);
    
    // DUT instantiation
    tt_um_Jsilicon dut (
        .clk     (vif.clk),
        .rst_n   (vif.rst_n),
        .ena     (vif.ena),
        .ui_in   (vif.ui_in),
        .uio_in  (vif.uio_in),
        .uo_out  (vif.uo_out),
        .uio_out (vif.uio_out),
        .uio_oe  (vif.uio_oe)
    );
    
    // Waveform dumping
    initial begin
        `ifdef VCS
            // FSDB dumping for Verdi
            $fsdbDumpfile("jsilicon.fsdb");
            $fsdbDumpvars(0, jsilicon_tb_top);
            $fsdbDumpMDA();
        `else
            // VCD dumping as fallback
            $dumpfile("jsilicon_uvm.vcd");
            $dumpvars(0, jsilicon_tb_top);
        `endif
    end
    
    // UVM configuration and test execution
    initial begin
        // Set virtual interface in config DB
        uvm_config_db#(virtual jsilicon_if)::set(null, "*", "vif", vif);
        
        // Run the test
        run_test();
    end
    
    // Timeout watchdog
    initial begin
        #1000000;  // 1ms timeout
        `uvm_error("TIMEOUT", "Simulation timeout reached")
        $finish;
    end

endmodule : jsilicon_tb_top

