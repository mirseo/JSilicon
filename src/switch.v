// CPU 모드 제어 모듈
// 0 : 외부 제어(Manual) 1 : 내장 ROM 명령 실행

`define default_netname none

module SWITCH (
    // 스위치 포트
    input wire mode,

    // 다중 mode 선택자로 조정
    input wire [7:0] manual_a, manual_b,
    input wire [2:0] manual_opcode,

    input wire [7:0] cpu_a, cpu_b,
    input wire [2:0] cpu_opcode,

    output wire [7:0] select_a, select_b,
    output wire [2:0] select_opcode
    );

    // SWITCH
    assign select_a = mode ? cpu_a : manual_a;
    assign select_b = mode ? cpu_b : manual_b;
    assign select_opcode = mode ? cpu_opcode : manual_opcode; 
endmodule