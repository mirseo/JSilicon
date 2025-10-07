// mode=1, program counter + rom
// 프로그램 카운터 + 롬 ( CPU 모드 1 인 경우 )

`define default_netname none

(* keep_hierarchy *)
module PC (
    input wire clock,
    input wire reset,
    input wire ena,

    // 디버그 포트 - JSilicon.v (TOP)에서 사용하지 않도록 설정하여 제거
    // output wire [3:0] pc_out,
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

    // 루프 변수 추가
    integer i; 
    initial begin
        // ADD 3
        rom[0] = 8'b00000011;
        // SUB 2
        rom[1] = 8'b00100010;
        // MUL 5
        rom[2] = 8'b01000101;
        // NOP
        rom[3] = 8'b00000000;

        //  Sky130 합성에 맞춰서 조정
        for (i = 4; i < 16; i = i + 1)
            // 데이터를 쓰기 전에는 0으로 채워두기
            rom[i] = 8'b00000000;
    end

    always @(posedge clock or posedge reset) begin
        // 명시적 비트폭(합성 경고 해결)로 지정
        if (reset) pc <= 4'd0;
        else if (ena) begin
            // 롬 명령어 끝까지 도달하면 0으로 로드
            if (pc == 4'd3)
                pc <= 3'd0;
            else
                pc <= pc + 1;
        end
    end

    // 포트명 오류 수정
    assign instr_out = rom[pc];

    // 디버그 포트 - 합성 과정에서 pc_out 포트 제거로 인한 제거
    // assign pc_out = pc;

endmodule