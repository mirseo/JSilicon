`define default_netname none

// 덧셈 모듈
// 지시자 추가 : 계층 변경 금지
(* keep_hierarchy *)
module Sum_cell (
    // 1비트 > 8비트로 업그레이드
    input wire [7:0] a,
    input wire [7:0] b,

    output wire [7:0] sum
    );

    // 결과 더해서 출력
    assign sum = a + b;
endmodule

// 뺄셈 연산 모듈
(* keep_hierarchy *)
module Minus_cell (
    input wire [7:0] a,
    input wire [7:0] b,

    output wire [7:0] minus
    );

    assign minus = a - b
endmodule

// 곱셈 연산 모듈
(* keep_hierarchy *)
module Multiply_cell (
    input wire [7:0] a,
    input wire [7:0] b,

    output wire [7:0] minus
    );

    assign minus = a * b
endmodule
