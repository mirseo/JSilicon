// top 모듈
// FSM 커버
// 동작 구조 : USER INPUT > Jsilicon.v > FSM.v > ALU.v > UART.v

`define default_netname none

module Jsilicon(
    input wire clock,
    input wire reset,
    input wire tx
    );

    FSM core_init (
        .clock(clock),
        .reset(reset),
        .tx(tx),
    )
endmodule

