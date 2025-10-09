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

    input wire ena,
    input wire alu_ena,

    // 출력 wire
    output wire [15:0] alu_result,
    output wire uart_tx,
    output wire uart_busy
    );

    reg [1:0] state;

    // FSM - compress bits
    localparam INIT = 2'd0;
    // remove unused code (EXEC)
    localparam SEND = 2'd1;
    localparam WAIT = 2'd2;
    reg start_uart;

    
    // ALU 연동
    ALU alu_connect (
        .a(a),
        .b(b),
        .opcode(opcode),
        .ena(alu_ena),
        .result(alu_result)
    );

    // UART 연동
    UART_TX uart_connect(
        .clock(clock),
        .reset(reset),
        .start(start_uart),
        .data_in(alu_result[7:0]),
        .tx(uart_tx),
        .busy(uart_busy)
    );



    always @(posedge clock or posedge reset) begin
        if (reset) begin
            state <= INIT;
            // 하드코딩 값 삭제
            start_uart <= 1'b0;
        end else if (ena) begin
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
                    start_uart <= 1'b0; // 재 초기화
                    if (!uart_busy) state <= INIT;
                end

                default: begin
                    state <= INIT;
                    start_uart <= 1'b0;
                end
            endcase 
        end else begin
            state <= INIT;
            start_uart <= 1'b0;
        end
    end

endmodule