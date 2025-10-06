// 내부 레지스터 파일

`define default_netname none

(* keep_hierarchy *)
module REG (
    input wire clock,
    input wire reset,
    input wire [2:0] opcode,

    input wire ena
    
    );

    reg [7:0] R0, R1;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            R0 <= 0; R1 <= 0;
        end else if (ena) begin
            case (opcode)
                // opcode 별 분리
            endcase
        end
    end
    
endmodule