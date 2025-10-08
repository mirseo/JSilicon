// SPDX-FileCopyrightText: © 2024 JSilicon
// SPDX-License-Identifier: Apache-2.0

`ifndef JSILICON_IF_SV
`define JSILICON_IF_SV

interface jsilicon_if(input logic clk);
    
    // 입력 신호
    logic        rst_n;
    logic        ena;
    logic [7:0]  ui_in;
    logic [7:0]  uio_in;
    
    // 출력 신호
    logic [7:0]  uo_out;
    logic [7:0]  uio_out;
    logic [7:0]  uio_oe;
    
    // Driver clocking block
    clocking driver_cb @(posedge clk);
        default input #1step output #1step;
        output rst_n;
        output ena;
        output ui_in;
        output uio_in;
        input  uo_out;
        input  uio_out;
        input  uio_oe;
    endclocking
    
    // Monitor clocking block
    clocking monitor_cb @(posedge clk);
        default input #1step output #1step;
        input rst_n;
        input ena;
        input ui_in;
        input uio_in;
        input uo_out;
        input uio_out;
        input uio_oe;
    endclocking
    
    // Driver modport
    modport driver_mp(
        clocking driver_cb,
        input clk
    );
    
    // Monitor modport
    modport monitor_mp(
        clocking monitor_cb,
        input clk
    );
    
    // DUT modport
    modport dut_mp(
        input  clk,
        input  rst_n,
        input  ena,
        input  ui_in,
        input  uio_in,
        output uo_out,
        output uio_out,
        output uio_oe
    );

endinterface : jsilicon_if

`endif // JSILICON_IF_SV

