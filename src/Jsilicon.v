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

    assign minus = a - b;
endmodule

// 곱셈 연산 모듈
(* keep_hierarchy *)
module Multiply_cell (
    input wire [7:0] a,
    input wire [7:0] b,

    // 8비트 곱셈의 최대 출력은 16진수 255 => 결과값에 16진수 사용
    output wire [15:0] multiply
    );

    wire multiply_by_zero;
    assign multiply_by_zero = (b == 8'h00);

    assign multiply = multiply_by_zero ? 16'h00 : (a * b);
endmodule

// 나눗셈 연산 모듈
(* keep_hierarchy *)
module Division_cell (
    input wire [7:0] a,
    input wire [7:0] b,

    // 나눗셈에서 몫과 나머지 추가
    output wire [7:0] quotient,
    output wire [7:0] remainder
    );

    wire div_by_zero;
    // 0으로 나누는 경우 체크 추가
    assign div_by_zero = (b == 8'h00);

    assign quotient = div_by_zero ? 8'h00 : (a / b);
    assign remainder = div_by_zero ? 8'h00 : (a % b);
endmodule

// If 연산 모듈
module if_cell(
    input wire [7:0] a,
    input wire [7:0] b,
    input wire [1:0] command,

    // wire 0 => (== 실행)
    // wire 1 => ( > 실행)
    // wire 2 => ( < 실행)

    // always 내부 할당 시 reg 타입 사용
    output reg equal_flag
    );

    always @(*) begin
        equal_flag = 1'b0;

        case (command)
            2'b00: equal_flag = (a == b);
            2'b01: equal_flag = (a > b);
            2'b10: equal_flag = (a < b);
            default: 1'b0;
        endcase
    end

endmodule