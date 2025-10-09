// SPDX-FileCopyrightText: © 2024 JSilicon
// SPDX-License-Identifier: Apache-2.0

`ifndef JSILICON_MONITOR_SV
`define JSILICON_MONITOR_SV

class jsilicon_monitor extends uvm_monitor;
    
    `uvm_component_utils(jsilicon_monitor)
    
    // Virtual interface
    virtual jsilicon_if vif;
    
    // Analysis port
    uvm_analysis_port #(jsilicon_transaction) ap;
    
    // 생성자
    function new(string name = "jsilicon_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual jsilicon_if)::get(this, "", "vif", vif)) begin
            `uvm_fatal(get_type_name(), "Virtual interface not found in config DB")
        end
        ap = new("ap", this);
    endfunction
    
    // Run phase
    task run_phase(uvm_phase phase);
        jsilicon_transaction tr;
        
        forever begin
            @(vif.monitor_cb);
            
            // 트랜잭션 생성
            tr = jsilicon_transaction::type_id::create("tr");
            
            // 입력 신호 캡처
            tr.rst_n  = vif.monitor_cb.rst_n;
            tr.ena    = vif.monitor_cb.ena;
            tr.ui_in  = vif.monitor_cb.ui_in;
            tr.uio_in = vif.monitor_cb.uio_in;
            
            // 출력 신호 캡처
            tr.uo_out  = vif.monitor_cb.uo_out;
            tr.uio_out = vif.monitor_cb.uio_out;
            tr.uio_oe  = vif.monitor_cb.uio_oe;
            
            // Manual 필드 추출
            tr.unpack_manual_inputs();
            
            `uvm_info(get_type_name(), $sformatf("Monitored transaction: ui_in=0x%02h, uio_in=0x%02h, uo_out=0x%02h, uio_out=0x%02h", 
                      tr.ui_in, tr.uio_in, tr.uo_out, tr.uio_out), UVM_HIGH)
            
            // Analysis port로 전송
            ap.write(tr);
        end
    endtask

endclass : jsilicon_monitor

`endif // JSILICON_MONITOR_SV

