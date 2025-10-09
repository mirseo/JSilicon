// SPDX-FileCopyrightText: © 2024 JSilicon
// SPDX-License-Identifier: Apache-2.0

`ifndef JSILICON_DRIVER_SV
`define JSILICON_DRIVER_SV

class jsilicon_driver extends uvm_driver #(jsilicon_transaction);
    
    `uvm_component_utils(jsilicon_driver)
    
    // Virtual interface
    virtual jsilicon_if vif;
    
    // 생성자
    function new(string name = "jsilicon_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual jsilicon_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(), "Virtual interface not found in config DB")
        end
    endfunction
    
    // Run phase
    task run_phase(uvm_phase phase);
        forever begin
            seq_item_port.get_next_item(req);
            drive_transaction(req);
            seq_item_port.item_done();
        end
    endtask
    
    // 트랜잭션 드라이브
    task drive_transaction(jsilicon_transaction tr);
        @(vif.driver_cb);
        vif.driver_cb.rst_n  <= tr.rst_n;
        vif.driver_cb.ena    <= tr.ena;
        vif.driver_cb.ui_in  <= tr.ui_in;
        vif.driver_cb.uio_in <= tr.uio_in;
        
        `uvm_info(get_type_name(), $sformatf("Driving transaction: rst_n=%0b, ena=%0b, ui_in=0x%02h, uio_in=0x%02h", 
                  tr.rst_n, tr.ena, tr.ui_in, tr.uio_in), UVM_HIGH)
    endtask
    
    // 리셋 태스크
    task reset_dut();
        `uvm_info(get_type_name(), "Resetting DUT", UVM_MEDIUM)
        
        vif.driver_cb.rst_n  <= 1'b0;
        vif.driver_cb.ena    <= 1'b1;
        vif.driver_cb.ui_in  <= 8'h00;
        vif.driver_cb.uio_in <= 8'h00;
        
        repeat(10) @(vif.driver_cb);
        
        vif.driver_cb.rst_n <= 1'b1;
        
        `uvm_info(get_type_name(), "Reset complete", UVM_MEDIUM)
    endtask

endclass : jsilicon_driver

`endif // JSILICON_DRIVER_SV

