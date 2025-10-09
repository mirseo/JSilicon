// SPDX-FileCopyrightText: © 2024 JSilicon
// SPDX-License-Identifier: Apache-2.0

`ifndef JSILICON_AGENT_SV
`define JSILICON_AGENT_SV

class jsilicon_agent extends uvm_agent;
    
    `uvm_component_utils(jsilicon_agent)
    
    // Agent 컴포넌트
    jsilicon_driver    driver;
    jsilicon_monitor   monitor;
    uvm_sequencer #(jsilicon_transaction) sequencer;
    
    // Analysis port
    uvm_analysis_port #(jsilicon_transaction) ap;
    
    // 생성자
    function new(string name = "jsilicon_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        // Monitor는 항상 생성
        monitor = jsilicon_monitor::type_id::create("monitor", this);
        
        // Active agent인 경우 driver와 sequencer 생성
        if(get_is_active() == UVM_ACTIVE) begin
            driver = jsilicon_driver::type_id::create("driver", this);
            sequencer = uvm_sequencer#(jsilicon_transaction)::type_id::create("sequencer", this);
        end
        
        // Analysis port 생성
        ap = new("ap", this);
    endfunction
    
    // Connect phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Monitor의 analysis port를 agent의 analysis port에 연결
        monitor.ap.connect(ap);
        
        // Active agent인 경우 driver와 sequencer 연결
        if(get_is_active() == UVM_ACTIVE) begin
            driver.seq_item_port.connect(sequencer.seq_item_export);
        end
    endfunction

endclass : jsilicon_agent

`endif // JSILICON_AGENT_SV

