// 헤드 연산 할당 장치

`define default_netname none

(* keep_hierarchy *)
module FSM(
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

    

endmodule