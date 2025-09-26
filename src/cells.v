/*
This file provides the mapping from the Wokwi modules to Verilog HDL.

It's only needed for Wokwi designs.
*/

`define default_netname none

(* keep_hierarchy *)
module buffer_cell (
    input wire in,
    output wire out
    );
    assign out = in;
endmodule

(* keep_hierarchy *)
module and_cell (
    input wire a,
    input wire b,
    output wire out
    );

    assign out = a & b;
endmodule

(* keep_hierarchy *)
module or_cell (
    input wire a,
    input wire b,
    output wire out
    );

    assign out = a | b;
endmodule

(* keep_hierarchy *)
module xor_cell (
    input wire a,
    input wire b,
    output wire out
    );

    assign out = a ^ b;
endmodule

(* keep_hierarchy *)
module nand_cell (
    input wire a,
    input wire b,
    output wire out
    );

    assign out = !(a&b);
endmodule

(* keep_hierarchy *)
module nor_cell (
    input wire a,
    input wire b,
    output wire out
    );

    assign out = !(a | b);
endmodule

(* keep_hierarchy *)
module xnor_cell (
    input wire a,
    input wire b,
    output wire out
    );

    assign out = !(a ^ b);
endmodule

(* keep_hierarchy *)
module not_cell (
    input wire in,
    output wire out
    );

    assign out = !in;
endmodule

(* keep_hierarchy *)
module mux_cell (
    input wire a,
    input wire b,
    input wire sel,
    output wire out
    );

    assign out = sel ? b : a;
endmodule

(* keep_hierarchy *)
module dff_cell (
    input wire clk,
    input wire d,
    output reg q,
    output wire notq
    );

    assign notq = !q;
    always @(posedge clk)
        q <= d;

endmodule

(* keep_hierarchy *)
module dffr_cell (
    input wire clk,
    input wire d,
    input wire r,
    output reg q,
    output wire notq
    );

    assign notq = !q;

    always @(posedge clk or posedge r) begin
        if (r)
            q <= 0;
        else
            q <= d;
    end
endmodule

(* keep_hierarchy *)
module dffsr_cell (
    input wire clk,
    input wire d,
    input wire s,
    input wire r,
    output reg q,
    output wire notq
    );

    assign notq = !q;

    always @(posedge clk or posedge s or posedge r) begin
        if (r)
            q <= 0;
        else if (s)
            q <= 1;
        else
            q <= d;
    end
endmodule
