// SPDX-FileCopyrightText: © 2024 JSilicon
// SPDX-License-Identifier: Apache-2.0

`ifndef JSILICON_PKG_SV
`define JSILICON_PKG_SV

package jsilicon_pkg;
    
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    // Include all UVM components in order
    `include "jsilicon_transaction.sv"
    `include "jsilicon_driver.sv"
    `include "jsilicon_monitor.sv"
    `include "jsilicon_agent.sv"
    `include "jsilicon_scoreboard.sv"
    `include "jsilicon_env.sv"
    `include "jsilicon_sequences.sv"
    `include "jsilicon_test.sv"
    
endpackage : jsilicon_pkg

`endif // JSILICON_PKG_SV

