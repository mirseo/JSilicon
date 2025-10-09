// SPDX-FileCopyrightText: © 2024 JSilicon
// SPDX-License-Identifier: Apache-2.0

`ifndef JSILICON_SEQUENCES_SV
`define JSILICON_SEQUENCES_SV

// ============================================================
// Base Sequence
// ============================================================
class jsilicon_base_sequence extends uvm_sequence #(jsilicon_transaction);
    
    `uvm_object_utils(jsilicon_base_sequence)
    
    function new(string name = "jsilicon_base_sequence");
        super.new(name);
    endfunction
    
endclass : jsilicon_base_sequence

// ============================================================
// Reset Sequence
// ============================================================
class jsilicon_reset_sequence extends jsilicon_base_sequence;
    
    `uvm_object_utils(jsilicon_reset_sequence)
    
    function new(string name = "jsilicon_reset_sequence");
        super.new(name);
    endfunction
    
    task body();
        jsilicon_transaction tr;
        
        `uvm_info(get_type_name(), "Starting reset sequence", UVM_MEDIUM)
        
        // Reset assertion
        tr = jsilicon_transaction::type_id::create("tr");
        start_item(tr);
        tr.rst_n = 1'b0;
        tr.ena = 1'b1;
        tr.ui_in = 8'h00;
        tr.uio_in = 8'h00;
        finish_item(tr);
        
        // Hold reset for 10 cycles
        repeat(10) begin
            tr = jsilicon_transaction::type_id::create("tr");
            start_item(tr);
            tr.rst_n = 1'b0;
            tr.ena = 1'b1;
            tr.ui_in = 8'h00;
            tr.uio_in = 8'h00;
            finish_item(tr);
        end
        
        // Reset de-assertion
        tr = jsilicon_transaction::type_id::create("tr");
        start_item(tr);
        tr.rst_n = 1'b1;
        tr.ena = 1'b1;
        tr.ui_in = 8'h00;
        tr.uio_in = 8'h00;
        finish_item(tr);
        
        `uvm_info(get_type_name(), "Reset sequence completed", UVM_MEDIUM)
    endtask
    
endclass : jsilicon_reset_sequence

// ============================================================
// Manual Mode Test Sequence
// ============================================================
class jsilicon_manual_sequence extends jsilicon_base_sequence;
    
    `uvm_object_utils(jsilicon_manual_sequence)
    
    function new(string name = "jsilicon_manual_sequence");
        super.new(name);
    endfunction
    
    task body();
        jsilicon_transaction tr;
        
        // Test.py의 manual_test_cases를 참고한 테스트 케이스
        typedef struct {
            bit [2:0] opcode;
            bit [3:0] a;
            bit [3:0] b;
        } test_case_t;
        
        test_case_t test_cases[] = '{
            '{3'b000, 10, 5},   // ADD: 10 + 5 = 15
            '{3'b001, 10, 5},   // SUB: 10 - 5 = 5
            '{3'b010, 10, 5},   // MUL: 10 * 5 = 50
            '{3'b011, 10, 5},   // DIV: 10 / 5 = 2
            '{3'b011, 10, 0},   // DIV: 10 / 0 = 0 (special case)
            '{3'b100, 10, 3},   // MOD: 10 % 3 = 1
            '{3'b101, 10, 10},  // EQ:  10 == 10 -> 1
            '{3'b101, 10, 5},   // EQ:  10 == 5 -> 0
            '{3'b110, 10, 5},   // GT:  10 > 5 -> 1
            '{3'b110, 5, 10},   // GT:  5 > 10 -> 0
            '{3'b111, 5, 10},   // LT:  5 < 10 -> 1
            '{3'b111, 10, 5}    // LT:  10 < 5 -> 0
        };
        
        `uvm_info(get_type_name(), "Starting Manual Mode test sequence", UVM_MEDIUM)
        
        foreach(test_cases[i]) begin
            tr = jsilicon_transaction::type_id::create("tr");
            start_item(tr);
            
            tr.rst_n = 1'b1;
            tr.ena = 1'b1;
            tr.mode = 1'b0;  // Manual mode
            tr.manual_a = test_cases[i].a;
            tr.manual_b = test_cases[i].b;
            tr.manual_opcode = test_cases[i].opcode;
            tr.pack_manual_inputs();
            
            finish_item(tr);
            
            `uvm_info(get_type_name(), 
                     $sformatf("Test %0d: A=%0d, B=%0d, Opcode=%03b", 
                               i, test_cases[i].a, test_cases[i].b, test_cases[i].opcode), 
                     UVM_MEDIUM)
            
            // Wait for result to stabilize
            repeat(2) begin
                tr = jsilicon_transaction::type_id::create("tr");
                start_item(tr);
                tr.rst_n = 1'b1;
                tr.ena = 1'b1;
                tr.mode = 1'b0;
                tr.manual_a = test_cases[i].a;
                tr.manual_b = test_cases[i].b;
                tr.manual_opcode = test_cases[i].opcode;
                tr.pack_manual_inputs();
                finish_item(tr);
            end
        end
        
        `uvm_info(get_type_name(), "Manual Mode test sequence completed", UVM_MEDIUM)
    endtask
    
endclass : jsilicon_manual_sequence

// ============================================================
// CPU Mode Test Sequence
// ============================================================
class jsilicon_cpu_sequence extends jsilicon_base_sequence;
    
    `uvm_object_utils(jsilicon_cpu_sequence)
    
    function new(string name = "jsilicon_cpu_sequence");
        super.new(name);
    endfunction
    
    task body();
        jsilicon_transaction tr;
        
        `uvm_info(get_type_name(), "Starting CPU Mode test sequence", UVM_MEDIUM)
        
        // Set mode to CPU (mode = 1)
        tr = jsilicon_transaction::type_id::create("tr");
        start_item(tr);
        tr.rst_n = 1'b1;
        tr.ena = 1'b1;
        tr.mode = 1'b1;  // CPU mode
        tr.ui_in = 8'h00;
        tr.uio_in = 8'h10;  // mode bit set
        finish_item(tr);
        
        // ROM 프로그램: ADD 3, SUB 2, MUL 5, NOP
        // PC는 자동으로 증가하며 명령어를 실행
        // 각 사이클마다 출력을 관찰
        
        // Cycle 1: ADD instruction
        repeat(2) begin
            tr = jsilicon_transaction::type_id::create("tr");
            start_item(tr);
            tr.rst_n = 1'b1;
            tr.ena = 1'b1;
            tr.mode = 1'b1;
            tr.ui_in = 8'h00;
            tr.uio_in = 8'h10;
            finish_item(tr);
        end
        `uvm_info(get_type_name(), "CPU Cycle 1: ADD", UVM_MEDIUM)
        
        // Cycle 2: SUB instruction
        repeat(1) begin
            tr = jsilicon_transaction::type_id::create("tr");
            start_item(tr);
            tr.rst_n = 1'b1;
            tr.ena = 1'b1;
            tr.mode = 1'b1;
            tr.ui_in = 8'h00;
            tr.uio_in = 8'h10;
            finish_item(tr);
        end
        `uvm_info(get_type_name(), "CPU Cycle 2: SUB", UVM_MEDIUM)
        
        // Cycle 3: MUL instruction
        repeat(1) begin
            tr = jsilicon_transaction::type_id::create("tr");
            start_item(tr);
            tr.rst_n = 1'b1;
            tr.ena = 1'b1;
            tr.mode = 1'b1;
            tr.ui_in = 8'h00;
            tr.uio_in = 8'h10;
            finish_item(tr);
        end
        `uvm_info(get_type_name(), "CPU Cycle 3: MUL", UVM_MEDIUM)
        
        // Cycle 4: NOP instruction
        repeat(1) begin
            tr = jsilicon_transaction::type_id::create("tr");
            start_item(tr);
            tr.rst_n = 1'b1;
            tr.ena = 1'b1;
            tr.mode = 1'b1;
            tr.ui_in = 8'h00;
            tr.uio_in = 8'h10;
            finish_item(tr);
        end
        `uvm_info(get_type_name(), "CPU Cycle 4: NOP", UVM_MEDIUM)
        
        // Cycle 5: PC wrap-around, ADD again
        repeat(1) begin
            tr = jsilicon_transaction::type_id::create("tr");
            start_item(tr);
            tr.rst_n = 1'b1;
            tr.ena = 1'b1;
            tr.mode = 1'b1;
            tr.ui_in = 8'h00;
            tr.uio_in = 8'h10;
            finish_item(tr);
        end
        `uvm_info(get_type_name(), "CPU Cycle 5: PC Wrap-around", UVM_MEDIUM)
        
        `uvm_info(get_type_name(), "CPU Mode test sequence completed", UVM_MEDIUM)
    endtask
    
endclass : jsilicon_cpu_sequence

// ============================================================
// Random Test Sequence
// ============================================================
class jsilicon_random_sequence extends jsilicon_base_sequence;
    
    `uvm_object_utils(jsilicon_random_sequence)
    
    rand int num_transactions;
    
    constraint c_num_trans {
        num_transactions inside {[10:50]};
    }
    
    function new(string name = "jsilicon_random_sequence");
        super.new(name);
    endfunction
    
    task body();
        jsilicon_transaction tr;
        
        `uvm_info(get_type_name(), $sformatf("Starting random sequence with %0d transactions", num_transactions), UVM_MEDIUM)
        
        repeat(num_transactions) begin
            tr = jsilicon_transaction::type_id::create("tr");
            start_item(tr);
            
            assert(tr.randomize() with {
                rst_n == 1'b1;
                ena == 1'b1;
                mode == 1'b0;  // Manual mode만 테스트
            });
            
            tr.pack_manual_inputs();
            finish_item(tr);
        end
        
        `uvm_info(get_type_name(), "Random sequence completed", UVM_MEDIUM)
    endtask
    
endclass : jsilicon_random_sequence

`endif // JSILICON_SEQUENCES_SV

