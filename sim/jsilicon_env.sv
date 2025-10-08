// SPDX-FileCopyrightText: © 2024 JSilicon
// SPDX-License-Identifier: Apache-2.0

`ifndef JSILICON_ENV_SV
`define JSILICON_ENV_SV

class jsilicon_env extends uvm_env;
    
    `uvm_component_utils(jsilicon_env)
    
    // Environment 컴포넌트
    jsilicon_agent      agent;
    jsilicon_scoreboard scoreboard;
    
    // 생성자
    function new(string name = "jsilicon_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        agent = jsilicon_agent::type_id::create("agent", this);
        scoreboard = jsilicon_scoreboard::type_id::create("scoreboard", this);
    endfunction
    
    // Connect phase
    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        
        // Agent의 analysis port를 scoreboard에 연결
        agent.ap.connect(scoreboard.ap_imp);
    endfunction

endclass : jsilicon_env

`endif // JSILICON_ENV_SV

