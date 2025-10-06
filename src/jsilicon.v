// top 모듈
// FSM 커버
// 동작 구조 - Manual : USER INPUT > Jsilicon.v > FSM.v (Internal ALU, UART)
// 동작 구조 - CPU(AUTO)
// Foward : PC > DECODER > REG > SWITCH > FSM (Internal ALU, UART)
// Write-Back : ALU Result (FSM output) > REG

`define default_netname none

module tt_um_Jsilicon(
    // Tinytapeout 요구 변수명으로 수정 
    input wire clk,
    input wire rst_n,

    // 사용자 입력 기능 추가
    input wire [7:0] ui_in,
    input wire [7:0] uio_in,

    // Enable Input 추가
    input wire ena,
    
    // 출력핀 재지정
    output wire [7:0] uio_oe,
    
    // 사용자 출력 추가
    output wire [7:0] uo_out,
    output wire [7:0] uio_out
    );

    // 초기화 동기화
    wire reset = ~rst_n;

    // Manual 제어 할당
    // 내부 wire 지정
    wire [3:0] manual_a = ui_in[7:4];
    wire [3:0] manual_b = ui_in[3:0];
    // Opcode 지정
    // 연결 추가 - Opcode 
    wire [2:0] manual_opcode = uio_in[7:5];
    // Mode 핀 추가
    // 0 : Manual, 1 = CPU 
    wire mode = uio_in[4]; 

    // CPU 모드 (PC + Decoder)
    wire [3:0] pc_cnt;
    wire [7:0] instr;

    PC pc_inst (
        .clock(clk),
        .reset(reset),
        .ena(ena),
        .pc_out(pc_cnt),
        .instr_out(instr)
    );

    wire [2:0] decoder_alu_opcode;
    wire [3:0] decoder_operand;
    wire decoder_reg_sel;
    wire decoder_alu_enable;
    wire decoder_write_enable;

    DECODER dec_inst (
        .clock(clk),
        .reset(reset),
        .ena(ena),
        .instr_in(instr),
        .alu_opcode(decoder_alu_opcode),
        .operand(decoder_operand),
        .reg_sel(decoder_reg_sel),
        .alu_enable(decoder_alu_enable),
        .write_enable(decoder_write_enable)
    );

    // REG 경로 추가
    wire [15:0] alu_result;

    wire [7:0] wb_data = decoder_alu_enable ? alu_result[7:0] : {4'b0000, decoder_operand};
    wire [2:0] regfile_opcode = decoder_write_enable ? (decoder_reg_sel ? 3'b001 : 3'b000) : 3'b111;

    wire R0, R1, reg_data_out;

    REG reg_inst (
        .clock(clk),
        .reset(reset),
        .ena(ena),
        .opcode(regfile_opcode),
        .data_in(wb_data),
        .data_out(reg_data_out),
        .R0_out(R0),
        .R1_out(R1)
    );

    // ALU - CPU mode
    wire [7:0] cpu_a = R0;
    wire [7:0] cpu_b = R1;
    wire [2:0] cpu_opcode = decoder_alu_opcode;

    // SWITCH 제어
    // 모듈 사용으로 변경
    wire [7:0] select_a;
    wire [7:0] select_b;
    wire [2:0] select_opcode;
    SWITCH switch_inst (
        .mode(mode),
        .manual_a({4'b0000, manual_a}),
        .manual_b({4'b0000, manual_b}),
        .manual_opcode(manual_opcode),
        .cpu_a(cpu_a),
        .cpu_b(cpu_b),
        .cpu_opcode(cpu_opcode),
        .select_a(select_a),
        .select_b(select_b),
        .select_opcode(select_opcode)
    );

    wire uart_tx;
    wire uart_busy;
    wire alu_ena = mode ? (ena & decoder_alu_enable) : ena;

    FSM core_init (
        .clock(clk),
        .reset(reset),
        .ena(ena),
        .a (select_a),
        .b (select_b),
        .opcode(select_opcode),
        .alu_ena(alu_ena),
        .alu_result(alu_result),
        .uart_tx(uart_tx),
        .uart_busy(uart_busy)
    );

    // 출력 핀 설정
    assign uio_oe = 8'b00000001;

    // 출력 지정
    assign uo_out = { uart_busy, alu_result[6:0] };
    assign uio_out = { alu_result[15:9], uart_tx };
endmodule

