// 헤드 연산 할당 장치

`define default_netname none

(* keep_hierarchy *)
module FSM (
    input wire clock,
    input wire reset,
    // 입력 wire 분리
    input wire [7:0] a,
    input wire [7:0] b,
    input wire [2:0] opcode,

    // 출력 wire
    output wire [15:0] alu_result,
    output wire uart_tx,
    output wire uart_busy
    );

    // ALU 연동
    ALU alu_connect (
        .a(a),
        .b(b),
        .opcode(opcode),
        .result(alu_result)
    );

    // UART 연동
    UART_TX uart_connect(
        .clock(clock),
        .reset(reset),
        .start(start_uart),
        .data_in(alu_result[7:0]),
        .tx(uart_tx),
        .busy()
    );

    // FSM 
    localparam INIT = 3'd0;
    // remove unused code (EXEC)
    localparam SEND = 3'd1;
    localparam WAIT = 3'd2;

    reg [2:0] state;
    reg start_uart;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            state <= INIT;
            // 하드코딩 값 삭제
            start_uart <= 1'b0;
        end else begin
            case (state)
                INIT: begin
                    start_uart <= 1'b1;
                    state <= SEND;
                end

                SEND: begin
                    // 안정성 코드 추가 (state가 INIT이 될 수 있음)
                    if (uart_busy) begin
                        start_uart <= 1'b0;
                        state <= WAIT;
                    end
                end

                WAIT: begin
                    if (!uart_busy) state <= INIT;
                end
            endcase 
        end
    end

endmodule