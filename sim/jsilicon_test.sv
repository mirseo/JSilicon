// SPDX-FileCopyrightText: © 2024 JSilicon
// SPDX-License-Identifier: Apache-2.0

`ifndef JSILICON_TEST_SV
`define JSILICON_TEST_SV

// ============================================================
// Base Test
// ============================================================
class jsilicon_base_test extends uvm_test;
    
    `uvm_component_utils(jsilicon_base_test)
    
    // Environment
    jsilicon_env env;
    
    // 생성자
    function new(string name = "jsilicon_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        env = jsilicon_env::type_id::create("env", this);
    endfunction
    
    // End of elaboration phase
    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction
    
    // Run phase에서 reset 수행
    task run_phase(uvm_phase phase);
        jsilicon_reset_sequence reset_seq;
        
        phase.raise_objection(this);
        
        reset_seq = jsilicon_reset_sequence::type_id::create("reset_seq");
        reset_seq.start(env.agent.sequencer);
        
        phase.drop_objection(this);
    endtask

endclass : jsilicon_base_test

// ============================================================
// Manual Mode Test
// ============================================================
class jsilicon_manual_test extends jsilicon_base_test;
    
    `uvm_component_utils(jsilicon_manual_test)
    
    function new(string name = "jsilicon_manual_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    task run_phase(uvm_phase phase);
        jsilicon_reset_sequence reset_seq;
        jsilicon_manual_sequence manual_seq;
        
        phase.raise_objection(this);
        
        `uvm_info(get_type_name(), "========================================", UVM_NONE)
        `uvm_info(get_type_name(), "   Starting Manual Mode Test", UVM_NONE)
        `uvm_info(get_type_name(), "========================================", UVM_NONE)
        
        // Reset
        reset_seq = jsilicon_reset_sequence::type_id::create("reset_seq");
        reset_seq.start(env.agent.sequencer);
        
        // Manual mode test
        manual_seq = jsilicon_manual_sequence::type_id::create("manual_seq");
        manual_seq.start(env.agent.sequencer);
        
        // Wait for all transactions to be processed
        #1000;
        
        `uvm_info(get_type_name(), "Manual Mode Test Completed", UVM_NONE)
        
        phase.drop_objection(this);
    endtask

endclass : jsilicon_manual_test

// ============================================================
// CPU Mode Test
// ============================================================
class jsilicon_cpu_test extends jsilicon_base_test;
    
    `uvm_component_utils(jsilicon_cpu_test)
    
    function new(string name = "jsilicon_cpu_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    task run_phase(uvm_phase phase);
        jsilicon_reset_sequence reset_seq;
        jsilicon_cpu_sequence cpu_seq;
        
        phase.raise_objection(this);
        
        `uvm_info(get_type_name(), "========================================", UVM_NONE)
        `uvm_info(get_type_name(), "   Starting CPU Mode Test", UVM_NONE)
        `uvm_info(get_type_name(), "========================================", UVM_NONE)
        
        // Reset
        reset_seq = jsilicon_reset_sequence::type_id::create("reset_seq");
        reset_seq.start(env.agent.sequencer);
        
        // CPU mode test
        cpu_seq = jsilicon_cpu_sequence::type_id::create("cpu_seq");
        cpu_seq.start(env.agent.sequencer);
        
        // Wait for all transactions to be processed
        #1000;
        
        `uvm_info(get_type_name(), "CPU Mode Test Completed", UVM_NONE)
        
        phase.drop_objection(this);
    endtask

endclass : jsilicon_cpu_test

// ============================================================
// Full Test (Manual + CPU)
// ============================================================
class jsilicon_full_test extends jsilicon_base_test;
    
    `uvm_component_utils(jsilicon_full_test)
    
    function new(string name = "jsilicon_full_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    task run_phase(uvm_phase phase);
        jsilicon_reset_sequence reset_seq;
        jsilicon_manual_sequence manual_seq;
        jsilicon_cpu_sequence cpu_seq;
        
        phase.raise_objection(this);
        
        `uvm_info(get_type_name(), "========================================", UVM_NONE)
        `uvm_info(get_type_name(), "   Starting Full Test", UVM_NONE)
        `uvm_info(get_type_name(), "========================================", UVM_NONE)
        
        // Reset
        reset_seq = jsilicon_reset_sequence::type_id::create("reset_seq");
        reset_seq.start(env.agent.sequencer);
        
        // Manual mode test
        `uvm_info(get_type_name(), "--- Testing Manual Mode ---", UVM_NONE)
        manual_seq = jsilicon_manual_sequence::type_id::create("manual_seq");
        manual_seq.start(env.agent.sequencer);
        
        #500;
        
        // Reset before CPU mode
        reset_seq = jsilicon_reset_sequence::type_id::create("reset_seq");
        reset_seq.start(env.agent.sequencer);
        
        // CPU mode test
        `uvm_info(get_type_name(), "--- Testing CPU Mode ---", UVM_NONE)
        cpu_seq = jsilicon_cpu_sequence::type_id::create("cpu_seq");
        cpu_seq.start(env.agent.sequencer);
        
        // Wait for all transactions to be processed
        #1000;
        
        `uvm_info(get_type_name(), "Full Test Completed", UVM_NONE)
        
        phase.drop_objection(this);
    endtask

endclass : jsilicon_full_test

// ============================================================
// Random Test
// ============================================================
class jsilicon_random_test extends jsilicon_base_test;
    
    `uvm_component_utils(jsilicon_random_test)
    
    function new(string name = "jsilicon_random_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction
    
    task run_phase(uvm_phase phase);
        jsilicon_reset_sequence reset_seq;
        jsilicon_random_sequence random_seq;
        
        phase.raise_objection(this);
        
        `uvm_info(get_type_name(), "========================================", UVM_NONE)
        `uvm_info(get_type_name(), "   Starting Random Test", UVM_NONE)
        `uvm_info(get_type_name(), "========================================", UVM_NONE)
        
        // Reset
        reset_seq = jsilicon_reset_sequence::type_id::create("reset_seq");
        reset_seq.start(env.agent.sequencer);
        
        // Random test
        random_seq = jsilicon_random_sequence::type_id::create("random_seq");
        assert(random_seq.randomize());
        random_seq.start(env.agent.sequencer);
        
        // Wait for all transactions to be processed
        #2000;
        
        `uvm_info(get_type_name(), "Random Test Completed", UVM_NONE)
        
        phase.drop_objection(this);
    endtask

endclass : jsilicon_random_test

`endif // JSILICON_TEST_SV

