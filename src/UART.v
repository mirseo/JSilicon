`define default_netname none

module uart_tx(
    input wire clock,
    input wire reset,
    input wire start,
    input wire [7:0] data_in, 

    output reg tx,
    output reg busy
    );

    parameter CLOCK_DIV = 104; // 시스템 클럭 9600bps 지정

    reg [7:0] data_reg;
    reg [3:0] bit_idx;
    reg [15:0] clock_count;
    reg [2:0] state;
    
    localparam IDLE = 3'd0;
    localparam START = 3'd1;
    localparam DATA = 3'd2;
    localparam STOP = 3'd3;

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            tx <= 1'b1;
            busy <= 1'b0;
            state <= IDLE;
            clock_count <= 0;
            bit_idx <= 0;
        end else begin
            case (state)
            // 상태코드 분리
                // IDLE 상태 시
                IDLE: begin
                    tx <= 1'b1;
                    busy <= 1'b0;
                    if (start) begin
                        data_reg <= data_in;
                        state <= START;
                        busy <= 1'b1;
                    end
                end
                // START 
                START: begin
                    tx <= 1'b0; 
                    if (clock_count == CLOCK_DIV) begin
                        clock_count <= 16'd0;
                        state <= DATA;
                        bit_idx <= 1'b0;
                    end else clock_count <= clock_count + 1'b1;
                end

                // DATA
                DATA: begin
                    tx <= data_reg[bit_idx];
                    if (clock_count == CLOCK_DIV) begin
                        clock_count <= 16'd0;
                        if (bit_idx == 7) state <= STOP;
                        else bit_idx <= bit_idx + 1'b1;
                    end else clock_count <= clock_count + 1'b1;
                end

                // STOP
                STOP: begin
                    tx <= 1'b1;
                    if (clock_count == CLOCK_DIV) begin
                        state <= IDLE;
                        busy <= 1'b0;
                        clock_count <= 16'd0;
                    end else clock_count <= clock_count + 1;
                end
            endcase
        end
    end
endmodule