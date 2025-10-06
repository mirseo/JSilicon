// CPU 모드 제어 모듈
// 0 : 외부 제어(Manual) 1 : 내장 ROM 명령 실행

`define default_netname none

module SWITCH (
    // 스위치 포트
    input wire mode,
    
    // 외부 데이터 주입
    input wire [2:0] opcode,
    input wire [7:0] operand,

    // CPU 제어
    input wire [2:0] cpu_opcode,
    input wire [7:0] cpu_operand,

    // ALU 제어
    output wire [2:0] alu_opcode,
    output wire [7:0] alu_operand
    );

    // SWITCH
    assign alu_operand = (mode == 1'b1) ? cpu_operand : operand;
    assign alu_opcode = (mode == 1'b1) ? cpu_opcode : opcode;
endmodule