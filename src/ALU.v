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

    always @(*) begin
        case (opcode)
            3'b000: result =  a + b;
            3'b001: result =  a - b;
        endcase
    end
endmodule