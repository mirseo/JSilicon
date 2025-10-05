// mode=1, program counter + rom
// 프로그램 카운터 + 롬 ( CPU 모드 1 인 경우 )

`define default_netname none

(* keep_hierarchy *)
module PC (
    input wire clk,
    input wire reset,
    input wire ena,

    output wire [7:0] instr

    );

    reg [3:0] pc;
    // 하드코딩 롬 지정
    wire [7:0] rom [0:15];

    always @(posedge clk or posedge reset) begin
        if (reset) pc <= 0;
        else if (ena) pc <= pc + 1;
    end

    assign instr = rom[pc];

endmodule