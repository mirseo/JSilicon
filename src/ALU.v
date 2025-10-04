`define default_netname none

(* keep_hierarchy *)
module ALU(
    // 입력 정의(ALU)
    input wire [7:0] a,
    input wire [7:0] b,
    input wire [2:0] opcode,

    output reg [15:0] result,
    );

    // opcode
    // 000 - (+)
    // 001 - (-)
    // 010 - (*)
    // 011 - (/)
    // 100 - (%)
    // 101 - IF(==)
    // 110 - (>)
    // 111 - (<)

    // 곱셈과 0 나눔 벡터
    wire [15:0] multiply_temp = a * b;
    wire div_by_zero = (b == 8'h00);

    always @(*) begin
        // 기본값 세팅
        result = 16'b0000;
        case (opcode)
            // 데이터 업데이트 // 8진수 > 16 진수 변경
            3'b000: result = {{8{1'b0}}, a + b};
            3'b001: result = {{8{1'b0}}, a - b};
            3'b010: result = multiply_temp; 
            3'b011: result = div_by_zero ? 16'b0000 : {{8{1'b0}}, a / b};
            3'b100: result = div_by_zero ? 16'b0000 : {{8{1'b0}}, a % b}; 
            3'b101: result = (a == b) ? 16'h0001 : 16h'0000;
            3'b110: result = (a > b) ? 16'h0001 : 16h'0000;
            3'b111: result = (a < b) ? 16'h0001 : 16h'0000;
            // 비정의 코드 반환
            default: result = 16'XXXX;
        endcase
    end
endmodule