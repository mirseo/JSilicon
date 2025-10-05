// top 모듈
// FSM 커버
// 동작 구조 : USER INPUT > Jsilicon.v > FSM.v > ALU.v > UART.v

`define default_netname none

module tt_um_Jsilicon(
    input wire clock,
    input wire reset_n,

    // 사용자 입력 기능 추가
    input wire [7:0] user_input,
    input wire [7:0] user_io_input,
    
    // 사용자 출력 추가
    output wire [7:0] user_output,
    output wire [7:0] user_io_output,
    output wire tx
    );

    // 초기화 동기화
    wire reset = ~reset_n;

    // 내부 wire 지정
    wire [3:0] a = user_input[7:4];
    wire [3:0] b = user_input[3:0];
    // Opcode 지정
    wire [2:0] opcode = user_io_input[2:0];

    wire [15:0] alu_result;
    wire uart_tx;
    wire uart_busy;

    FSM core_init (
        .clock(clock),
        .reset(reset),
        .a ({4'b0000, a}),
        .b ({4'b0000, b}),
        .opcode(opcode),
        .alu_result(alu_result),
        .uart_tx(uart_tx),
        .uart_busy(uart_busy)
    );

    // 출력 지정
    assign user_output = alu_result[7:0];
    assign user_io_output = {7'b0, uart_tx};
    assign tx = uart_tx;
endmodule

