`define default_netname none

// 지시자 추가 : 계층 변경 금지
(* keep_hierarchy *)
module sum_cell (
    // 입력 정의 (2개 입력 -> return으로 )
    input wire a,
    input wire b,

    output wire sum
    );

    // 결과 더해서 출력
    assign sum = a + b;
endmodule