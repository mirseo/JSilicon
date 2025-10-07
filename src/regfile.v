// 내부 레지스터 파일
// 구조 :2 PC + ROM > Decoder > REG > ALU > FSM + UART

`define default_netname none

(* keep_hierarchy *)
module REG (
    input wire clock,
    input wire reset,
    input wire ena,

    // 데이터 입출력
    input wire [2:0] opcode,
    // 명령어 저장
    input wire [7:0] data_in, 
    // FSM, ALU 데이터 저장
    output reg [7:0] data_out,

    // 디버그 포트
    // output wire [7:0] R0_out,
    // output wire [7:0] R1_out
    );

    reg [7:0] R0, R1;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            // 기본값 초기화
            R0 <= 0; R1 <= 0;
            data_out <= 8'b0;
        end else if (ena) begin
            case (opcode)
                // opcode 별 분리
                // LOAD R0, R1 (데이터 저장)
                3'b000: R0 <= data_in;
                3'b001: R1 <= data_in;

                // MOV (덮어쓰기)
                3'b010: R1 <= R0;
                3'b011: R0 <= R1;

                // OUT (출력)
                3'b100: data_out <= R0;
                3'b101: data_out <= R1;

                // NOP (기본값)
                default: data_out <= 8'b0;
            endcase
        end
    end

    // assign R0_out = R0;
    // assign R1_out = R1;
    
endmodule