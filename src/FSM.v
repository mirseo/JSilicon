// 헤드 연산 할당 장치

`define default_netname none

(* keep_hierarchy *)
module FSM (
    input wire clock,
    input wire reset,
    input wire tx
    );

    reg [7:0] a, b;
    reg [2:0] opcode;
    wire [15:0] alu_result;
    reg start_uart;

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
        .data_in(alu_connect[7:0]),
        .tx(tx),
        .busy()
    );

    // FSM 
    localparam INIT = 3'd0;
    localparam EXEC = 3'd1;
    localparam SEND = 3'd2;
    localparam WAIT = 3'd3;

    reg [2:0] state;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            state <= INIT;
            a <= 1'd0;
            b <= 1'd0;

            opcode <= 3'b000;
            start_uart <= 0;
        end else begin
            case (state)
                INIT: begin
                    // 기본값 할당 > 5 + 10 할당값
                    a <= 8'd5;
                    b <= 8'd10;
                    opcode <= 3'b000; 
                    state <= EXEC;
                end

                EXEC: begin
                    state <= SEND;
                end

                SEND: begin
                    start_uart <= 1'b1;
                    state <= WAIT;
                end

                WAIT: begin
                    start_uart <= 1'b0;
                    if (!uart_connect.busy) state <= INIT;
                end
            endcase 
        end
    end

endmodule