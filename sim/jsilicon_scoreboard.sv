// SPDX-FileCopyrightText: © 2024 JSilicon
// SPDX-License-Identifier: Apache-2.0

`ifndef JSILICON_SCOREBOARD_SV
`define JSILICON_SCOREBOARD_SV

class jsilicon_scoreboard extends uvm_scoreboard;
    
    `uvm_component_utils(jsilicon_scoreboard)
    
    // Analysis export
    uvm_analysis_imp #(jsilicon_transaction, jsilicon_scoreboard) ap_imp;
    
    // 통계
    int total_transactions;
    int passed_transactions;
    int failed_transactions;
    
    // 생성자
    function new(string name = "jsilicon_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        total_transactions = 0;
        passed_transactions = 0;
        failed_transactions = 0;
    endfunction
    
    // Build phase
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap_imp = new("ap_imp", this);
    endfunction
    
    // Write method - analysis port로부터 트랜잭션 수신
    function void write(jsilicon_transaction tr);
        bit [6:0] expected_low, expected_high;
        bit [6:0] actual_low, actual_high;
        bit match;
        
        total_transactions++;
        
        // 리셋 상태이거나 ena가 비활성화된 경우 체크하지 않음
        if(!tr.rst_n || !tr.ena) begin
            `uvm_info(get_type_name(), "Skipping check during reset or when disabled", UVM_HIGH)
            return;
        end
        
        // Manual mode에서만 결과 체크
        if(tr.mode == 1'b0) begin
            // 예상 결과 계산
            tr.calculate_expected_result();
            
            // 예상 출력 파트 추출
            tr.get_expected_output_parts(expected_low, expected_high);
            
            // 실제 출력 파트 추출
            tr.get_actual_output_parts(actual_low, actual_high);
            
            // 비교
            match = (actual_low == expected_low) && (actual_high == expected_high);
            
            if(match) begin
                passed_transactions++;
                `uvm_info(get_type_name(), 
                         $sformatf("PASS: A=%0d, B=%0d, Op=%0d, Expected=[%02h,%02h], Got=[%02h,%02h]",
                                   tr.manual_a, tr.manual_b, tr.manual_opcode,
                                   expected_high, expected_low, actual_high, actual_low), 
                         UVM_MEDIUM)
            end else begin
                failed_transactions++;
                `uvm_error(get_type_name(), 
                          $sformatf("FAIL: A=%0d, B=%0d, Op=%0d, Expected=[%02h,%02h], Got=[%02h,%02h]",
                                    tr.manual_a, tr.manual_b, tr.manual_opcode,
                                    expected_high, expected_low, actual_high, actual_low))
            end
        end else begin
            // CPU mode - 단순히 출력만 로그
            `uvm_info(get_type_name(), 
                     $sformatf("CPU Mode: uo_out=0x%02h, uio_out=0x%02h", 
                               tr.uo_out, tr.uio_out), 
                     UVM_MEDIUM)
        end
    endfunction
    
    // Report phase
    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        
        `uvm_info(get_type_name(), "========================================", UVM_NONE)
        `uvm_info(get_type_name(), "       Scoreboard Final Report", UVM_NONE)
        `uvm_info(get_type_name(), "========================================", UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("Total Transactions: %0d", total_transactions), UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("Passed: %0d", passed_transactions), UVM_NONE)
        `uvm_info(get_type_name(), $sformatf("Failed: %0d", failed_transactions), UVM_NONE)
        
        if(failed_transactions == 0 && passed_transactions > 0) begin
            `uvm_info(get_type_name(), "*** TEST PASSED ***", UVM_NONE)
        end else if(failed_transactions > 0) begin
            `uvm_error(get_type_name(), "*** TEST FAILED ***")
        end
        `uvm_info(get_type_name(), "========================================", UVM_NONE)
    endfunction

endclass : jsilicon_scoreboard

`endif // JSILICON_SCOREBOARD_SV

