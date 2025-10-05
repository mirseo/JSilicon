// mode=1, program counter + rom
// 프로그램 카운터 + 롬 ( CPU 모드 1 인 경우 )

`define default_netname none

(* keep_hierarchy *)
module PC (
    input wire clk,
    input wire reset,
    input wire ena,

    output wire [7:0] instr_out

    );

    reg [3:0] pc;
    // 하드코딩 롬 지정
    // wire 선언시 오류 발생 > reg로 수정
    reg [7:0] rom [0:15];

    // 내장 롬 명령어 지시 (프로그램)
    // 명령구조 : [7:5] = opcode, [4:0]=operand 
    // ex, ADD 3  = [000](opcode) + [00011](operand)
    // todo - FSM 명령어 추가하기 (25.10.06)  
    initial begin
        // ADD 3
        rom[0] = 8'b00000011;
        // SUB 2
        rom[1] = 8'b00100010;
        // MUL 5
        rom[2] = 8'b01000101;
        // NOP
        rom[3] = 8'b00000000;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) pc <= 0;
        else if (ena) pc <= pc + 1;
    end

    // 포트명 오류 수정
    assign instr_out = rom[pc];

endmodule