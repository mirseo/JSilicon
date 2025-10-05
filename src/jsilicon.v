// top 모듈
// FSM 커버
// 동작 구조 : USER INPUT > Jsilicon.v > FSM.v > ALU.v > UART.v

`define default_netname none

module tt_um_Jsilicon(
    // Tinytapeout 요구 변수명으로 수정 
    input wire clk,
    input wire rst_n,

    // 사용자 입력 기능 추가
    input wire [7:0] ui_in,
    input wire [7:0] uio_in,

    // Enable Input 추가
    input wire ena,
    
    // 출력핀 재지정
    output wire uio_oe,
    
    // 사용자 출력 추가
    output wire [7:0] uo_out,
    output wire [7:0] uio_out,
    output wire tx
    );

    // 초기화 동기화
    wire reset = ~rst_n;

    // 내부 wire 지정
    wire [3:0] a = ui_in[7:4];
    wire [3:0] b = ui_in[3:0];
    // Opcode 지정
    wire [2:0] opcode = uio_in[2:0];

    wire [15:0] alu_result;
    wire uart_tx;
    wire uart_busy;

    FSM core_init (
        .clock(clk),
        .reset(reset),
        .ena(ena),
        .a ({4'b0000, a}),
        .b ({4'b0000, b}),
        .opcode(opcode),
        .alu_result(alu_result),
        .uart_tx(uart_tx),
        .uart_busy(uart_busy)
    );

    // 출력 지정
    assign uo_out = alu_result[7:0];
    assign uio_out = uio_oe ? alu_result[7:0] : 8'bz;
    assign tx = uart_tx;
endmodule

