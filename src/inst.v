// 명령어 디코더 (Instruction Decoder)

`define default_netname none

(* keep_hierarchy *)
module DECODER (
    input wire clock,
    input wire reset,
    input wire ena,

    // PC 명령어 입력
    input wire [7:0] instr_in,

    output reg [2:0] alu_opcode,
    output reg [3:0] operand,
    // ALU 
    // 레지스터 선택기
    output reg reg_sel,
    // ALU 실행 명령
    output reg alu_enable,
    // 레지스터 쓰기 허용
    output reg write_enable
    );

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            alu_opcode <= 3'b000;
            operand <= 4'b0000;
            reg_sel <= 1'b0;
            alu_enable <= 1'b0;
            write_enable <= 1'b0;
        end else if (ena) begin
            // 명령구조 : [7:5] = opcode, [4:0]=operand 
            // ex, ADD 3  = [000](opcode) + [00011](operand)
            // 명령어 종류 (opcode)
            alu_opcode <= instr_in[7:5];
            // 목적지 레지스터 선택
            reg_sel <= instr_in[4];
            // 즉시 명령 입력 (즉시값)
            operand <= instr_in[3:0];

            // ALU ON
            alu_enable <= 1'b1;
            write_enable <= 1'b1;
        end else begin
            //ena Off 인 경우
            alu_enable <= 1'b0;
            write_enable <= 1'b0;
        end
    end


endmodule
