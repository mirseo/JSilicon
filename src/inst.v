// 명령어 디코더 (Instruction Decoder)

`define default_netname none

(* keep_hierarchy *)
module INST (
    input wire clock,
    input wire reset,
    input wire ena,

    );

    wire [2:0] opcode =  instr[7:5];
    wire [3:0] operand = instr[3:0];

    reg [7:0] instr;

    always @(posedge clock or posedge reset) begin
        if (reset) instr <= 8'b0;
        else if (ena) instr <= ui_in;
    end


endmodule
