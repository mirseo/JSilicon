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
    ALU alu_result (
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
        .data_in(alu_connect[7:0]),
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
            // remove hardcording value
            start_uart <= 1'b1;
        end else begin
            case (state)
                INIT: begin
                    start_uart <= 1'b1;
                    state <= SEND;
                end

                SEND: begin
                    start_uart <= 1'b1;
                    state <= WAIT;
                end

                WAIT: begin
                    if (!uart_connect.busy) state <= INIT;
                end
            endcase 
        end
    end

endmodule