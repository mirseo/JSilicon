// SPDX-FileCopyrightText: © 2024 JSilicon
// SPDX-License-Identifier: Apache-2.0

`ifndef JSILICON_TRANSACTION_SV
`define JSILICON_TRANSACTION_SV

class jsilicon_transaction extends uvm_sequence_item;
    
    // 입력 필드
    rand bit        rst_n;
    rand bit        ena;
    rand bit [7:0]  ui_in;
    rand bit [7:0]  uio_in;
    
    // 출력 필드
    bit [7:0]  uo_out;
    bit [7:0]  uio_out;
    bit [7:0]  uio_oe;
    
    // Manual mode 필드 (편의성을 위해)
    rand bit [3:0]  manual_a;
    rand bit [3:0]  manual_b;
    rand bit [2:0]  manual_opcode;
    
    // Mode 필드 (0: Manual, 1: CPU)
    rand bit        mode;
    
    // 예상 결과
    bit [15:0] expected_result;
    
    // UVM 매크로
    `uvm_object_utils_begin(jsilicon_transaction)
        `uvm_field_int(rst_n, UVM_ALL_ON)
        `uvm_field_int(ena, UVM_ALL_ON)
        `uvm_field_int(ui_in, UVM_ALL_ON)
        `uvm_field_int(uio_in, UVM_ALL_ON)
        `uvm_field_int(uo_out, UVM_ALL_ON)
        `uvm_field_int(uio_out, UVM_ALL_ON)
        `uvm_field_int(uio_oe, UVM_ALL_ON)
        `uvm_field_int(manual_a, UVM_ALL_ON)
        `uvm_field_int(manual_b, UVM_ALL_ON)
        `uvm_field_int(manual_opcode, UVM_ALL_ON)
        `uvm_field_int(mode, UVM_ALL_ON)
        `uvm_field_int(expected_result, UVM_ALL_ON)
    `uvm_object_utils_end
    
    // 제약 조건
    constraint c_default {
        rst_n == 1'b1;  // 기본적으로 리셋 해제
        ena == 1'b1;    // 기본적으로 활성화
    }
    
    constraint c_manual_range {
        manual_a inside {[0:15]};
        manual_b inside {[0:15]};
        manual_opcode inside {[0:7]};
    }
    
    // 생성자
    function new(string name = "jsilicon_transaction");
        super.new(name);
    endfunction
    
    // ui_in과 uio_in을 manual 필드로부터 생성
    function void pack_manual_inputs();
        ui_in = {manual_a, manual_b};
        uio_in = {manual_opcode, mode, 4'b0000};
    endfunction
    
    // manual 필드를 ui_in과 uio_in으로부터 추출
    function void unpack_manual_inputs();
        manual_a = ui_in[7:4];
        manual_b = ui_in[3:0];
        manual_opcode = uio_in[7:5];
        mode = uio_in[4];
    endfunction
    
    // ALU 연산 수행 및 예상 결과 계산
    function void calculate_expected_result();
        case(manual_opcode)
            3'b000: expected_result = manual_a + manual_b;          // ADD
            3'b001: expected_result = manual_a - manual_b;          // SUB
            3'b010: expected_result = manual_a * manual_b;          // MUL
            3'b011: expected_result = (manual_b == 0) ? 0 : manual_a / manual_b;  // DIV
            3'b100: expected_result = (manual_b == 0) ? 0 : manual_a % manual_b;  // MOD
            3'b101: expected_result = (manual_a == manual_b) ? 1 : 0;             // EQ
            3'b110: expected_result = (manual_a > manual_b) ? 1 : 0;              // GT
            3'b111: expected_result = (manual_a < manual_b) ? 1 : 0;              // LT
            default: expected_result = 16'h0000;
        endcase
    endfunction
    
    // 출력에서 ALU 결과 추출
    // uo_out[6:0] = alu_result[6:0]
    // uio_out[7:1] = alu_result[15:9]
    // alu_result[8:7]는 연결되지 않음
    function bit [15:0] get_alu_result_from_outputs();
        bit [15:0] result;
        result[6:0] = uo_out[6:0];
        result[8:7] = 2'b00;  // 연결되지 않은 비트
        result[15:9] = uio_out[7:1];
        return result;
    endfunction
    
    // 예상 결과를 출력 형식으로 변환
    function void get_expected_output_parts(output bit [6:0] exp_low, output bit [6:0] exp_high);
        exp_low = expected_result[6:0];
        exp_high = expected_result[15:9];
    endfunction
    
    // 실제 출력 파트 추출
    function void get_actual_output_parts(output bit [6:0] act_low, output bit [6:0] act_high);
        act_low = uo_out[6:0];
        act_high = uio_out[7:1];
    endfunction

endclass : jsilicon_transaction

`endif // JSILICON_TRANSACTION_SV

