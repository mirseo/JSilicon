<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## JSilicon v0.2 – A Dual-Mode 8-bit CPU/ALU Core

![JSilicon Render Image](../image/gds_render.png)

**JSilicon** 은 제가 대한민국에서 복무한 군 복무 기간(2025) 동안 처음부터 설계하고 구현한 **8-bit CPU/ALU core**입니다. 이 프로젝트는 매우 제한된 환경에서도 완전한 수준의 CPU 설계가 가능함을 보여주는 개념 증명(Proof-of-Concept)입니다.

버전 0.2는 원래의 수동 ALU 기능에 CPU 모드를 추가한 구현체입니다. 이 변경으로 미리 ROM에 프로그래밍된 명령어를 자동으로 실행할 수 있습니다. 이를 구현하기 위해서 **프로그램 카운터(PC)**, **명령어 디코더**, **레지스터 파일**과 같은 핵심 CPU 구성 요소들이 추가되었습니다.  

JSilicon 시리즈는 JavaScript의 문법상 단순함과 접근 가능한 실리콘 설계 철학에서 영감을 받았습니다. 최종 목표로는 JS 런타임을 자체적으로 구동하는 ASIC을 개발하는 것을 목적으로 하고 있습니다.  

## Overview  
- **PC (Program Counter & ROM)** - 16x8 비트 명령어 세트를 내부 ROM(Read-Only Memory)에 저장하고, CPU 모드에서 순차적으로 명령어를 가져오는 역할을 수행합니다.

- **Decoder** - PC(Program Counter)에서 명령어를 해석하고 다른 구성요소를 제어하는 신호를 생성합니다. 

- **REG (Register File)** - CPU의 작업 공간입니다. R0, R1으로 활용되는 2개의 기본 범용 레지스터를 제공합니다. 

- **ALU (Arithmetic Logic Unit)** - 덧셈, 뺄셈, 곱셈을 포함한 8개의 기본 수학(산술) 및 논리 연산을 수행합니다.

- **SWITCH** - Mode 핀에 기반하여 데이터 경로를 선택합니다. 외부의 수동 제어와 내부 CPU 코어 간의 전환 역할을 수행합니다.   

- **FSM (Finite State Machine)** - 중앙 컨트롤러 역할로, ALU 및 UART의 타이밍 관리를 처리합니다.  

- **UART_TX** - JSilicon이 처리한 결과를 시리얼 데이터로 변환하여 PC 및 MCU와 같은 외부 장비로 전송합니다.  

---

## Pinout
| 핀 (Pin) | 입출력 (Direction) | 설명 (Description) |
|---|---|---|
| `clk` | Input | 시스템 클럭 (12 MHz) |
| `rst_n` | Input | 리셋 신호 (Active-Low) |
| `ena` | Input | 칩 활성화 (Active-High) |
| `ui_in[7:4]` | Input  | (Manual Mode) 연산의 'A' 변수로 사용할 값 입력 (4 bits) |
| `ui_in[3:0]` | Input  | (Manual Mode) 연산의 'B' 변수로 사용할 값 입력 (4 bits) |
| `uio_in[7:5]` | Input  | (Manual Mode) 연산 코드 설정 (3 bits) |
| `uio_in[4]` | Input | 모드 변경 (0: Manual, 1: CPU) |
| `uo_out[7]` | Output | UART Busy 상태 (1: Busy) |
| `uo_out[6:0]`| Output | ALU 결과, 하위 7비트 (`alu_result[6:0]`) |
| `uio_out[7:1]`| Output | ALU 결과, 상위 8비트 (`alu_result[15:8]`) |
| `uio_out[0]` | Output | UART TX 직렬 데이터 출력 (9600 bps) |

## How to test
1. **Manual Mode(Mode = 0)**  
   수동 모드로 실행하기 위해서는 `uio_in[4]` 핀을 '0'으로 설정하세요. 이 모드에서는 수동 ALU로서 동작합니다.  

   A. 연산할 값 제공: JSilicon이 연산에 활용한 값을 `ui_in[7:4]` 및 `ui_in[3:0]` 핀에 각각 4비트로 제공해주세요.  
        - `ui_in[7:4]` 핀에는 연산의 'A' 변수에 사용할 값을 입력해주세요.  
        - `ui_in[3:0]` 핀에는 연산의 'B' 변수에 사용할 값을 입력해주세요.

   B. 연산 설정하기: `uio_in[7:5]` 핀을 사용하여 JSilicon이 수행할 연산을 설정할 수 있습니다. 지원하는 연산은 다음 내용을 확인하세요.  
         - `000` : A + B  
         - `001` : A - B  
         - `010` : A * B  
         - `011` : A / B  
         - `100` : A % B  
         - `101` : A == B  
         - `110` : A > B  
         - `111` : A < B  

   C. 처리 결과 확인: JSilicon의 처리 결과는 즉시 `uo_out` 및 `uio_out` 핀을 통해 확인할 수 있습니다.  

   D. (추가 옵션) 시리얼 출력: 처리 결과와 동일한 결과가 `uio_out[0]` 핀을 통해 UART로 전송됩니다.
         - UART 어댑터를 활용하여 (9600 bps, 8N1)로 설정하면 처리 결과를 수신할 수 있습니다.
         - `uio_out[0]` 핀은 UART TX 라인의 상태를 모니터링하는 핀입니다.

   E. 계산 초기화: 새로운 계산을 실행하기 위해서는, `rst_n` 핀을 잠시 '0'으로 낮췄다가 다시 '1'로 올려주세요.  

2. **CPU Mode (Mode = 1)**  
   CPU 모드로 실행하기 위해서는 `uio_in[4]`핀을 '1'으로 설정하세요.

      1. (`ena` = 1) 플래그로 칩이 활성화되면, 내부 ROM에 저장된 프로그램을 자동으로 실행합니다.  

      2. CPU 모드로 설정된 경우, 외부 입력 핀인 `ui_in` 및 `uio_in[7:5]` 는 무시됩니다.  

      3. 기본 내장된 프로그램은 다음과 같습니다:  
         - `ADD 3`
         - `SUB 2`
         - `MUL 5`
         - `NOP`  (실행 종료 후, 반복 실행)  

      4. 각 명령어의 처리 결과는 `uo_out` 과 `uio_out` 핀으로 출력되며, 같은 결과가 UART로도 출력됩니다.

## Notes

- **Clock** : JSilicon은 TinyTapeout의 표준인 12Mhz 클럭 환경에서 설계되었습니다. (12Mhz 권장)  
- **Logic Levels** : JSilicon의 모든 I/O 핀은 3.3V CMOS 로직에서 동작합니다. (TinyTapeout 표준)  
- **Bidirectional Pins** : `uio` 핀은 JSilicon의 입력과 출력 모두에 활용됩니다. 입력으로는 `uio[7:5]` 가 연산 코드를 결정하며 `uio[4]` 가 동작 모드를 결정합니다. 출력에서는 `uio[0]`을 통해 UART_TX 신호가 출력되며 나머지 핀인 `uio[3:1]` 은 사용하지 않습니다.  

## Vision
JSilicon은 단순한 칩이 아닙니다. 정확히는 제약 속에서 실리콘 칩을 만들어가는 이야기입니다.  

테이프아웃을 준비 중인 이 첫번째 칩은 대한민국의 의무 군 복무 중에 제작되었습니다. 그리고 가장 제한된 환경에서도 하드웨어 개발과 창조가 가능함을 증명하려고 합니다.   

차기 버전에서는 JSilicon를 RISC와 같은 기능을 갖춘 보다 강력한 칩으로 확장할 예정입니다.  

## Milestone - JSilicon v0.2 GDS Layout
![JSilicon GDS Layout](../image/gds_render.png)  

2025년 10월, JSilicon v0.2는 중요한 이정표에 도달했습니다:  
완전한 **GDSII 레이아웃**의 성공적인 생성을 통해 논리 설계에서 물리적 실리콘으로의 전환 작업을 완료했습니다.  

**JSilicon v0.2**를 웹 기반 3D 뷰어를 통해 확인해보세요.  
이 웹사이트에서 칩의 최종 GDSII 구조를 3D로 확인할 수 있습니다.  
표준 셀에서 라우팅 레이어까지 실제 실리콘에서 나타날 구조입니다.  

[View JSilicon v0.2 GDS Layout in 3D](https://mirseo.dev/)  

## License
이 프로젝트는 [MIT License](https://opensource.org/license/mit/). 를 따릅니다.  

## Author Message
안녕하세요 저는 대한민국에서 군 복무를 하고 있는 서준혁이라고 합니다.  

JSilicon 프로젝트를 시작한 이유는, 군대에서의 시간도 의미 있음을 증명하고 싶었습니다.  
그리고 해낼 것입니다.  

그곳에 길이 없어 보여도, 늘 그래왔듯이 길을 찾겠습니다.  

사양이 낮은 컴퓨터, 인터넷 창 한 두개만 열어도 버벅이고 꺼지는 장치라도,  
이런 것을 창조해낼 수 있습니다.  

포기하지 마십시오.  

제가 JSilicon을 만들어냈듯이, 당신도 해낼 수 있습니다.  

Copyright 2025. JunHyeok Seo (mirseo). All rights reserved.    

## Language
- [한국어](./docs/README_ko.md)
- [English](../README.md)

File: docs/v0.2/JSilicon-ko-0.2.md  