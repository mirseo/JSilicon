# JSilicon UVM Testbench (VCS & Verdi)

이 디렉토리에는 JSilicon 코어를 위한 완전한 UVM (Universal Verification Methodology) 환경이 포함되어 있습니다.
**Synopsys VCS**와 **Verdi**를 기반으로 구성되었습니다.

> 📖 **빠른 시작**: [QUICKSTART.md](QUICKSTART.md)를 참조하세요!

## 구조

```
sim/
├── jsilicon_if.sv              # Interface 정의
├── jsilicon_transaction.sv     # Transaction/Sequence Item
├── jsilicon_driver.sv          # Driver
├── jsilicon_monitor.sv         # Monitor
├── jsilicon_agent.sv           # Agent
├── jsilicon_scoreboard.sv      # Scoreboard
├── jsilicon_env.sv             # Environment
├── jsilicon_sequences.sv       # Sequences (Reset, Manual, CPU, Random)
├── jsilicon_test.sv            # Tests
├── jsilicon_pkg.sv             # UVM Package
├── jsilicon_tb_top.sv          # Testbench Top Module
├── Makefile                    # Makefile for VCS
├── run.sh                      # 실행 스크립트 (bash)
├── setup_vcs.sh                # VCS 환경 설정 (bash)
├── setup_vcs.csh               # VCS 환경 설정 (csh/tcsh)
├── QUICKSTART.md               # 빠른 시작 가이드
└── README.md                   # 이 파일 (상세 문서)
```

## 테스트 종류

### 1. Manual Mode Test (`jsilicon_manual_test`)
- Manual mode (mode=0)에서 ALU 연산 테스트
- 모든 ALU 연산 (ADD, SUB, MUL, DIV, MOD, EQ, GT, LT) 검증
- `test.py`의 `manual_test_cases`를 기반으로 함

### 2. CPU Mode Test (`jsilicon_cpu_test`)
- CPU mode (mode=1)에서 명령어 실행 테스트
- ROM 프로그램 실행 확인
- PC wrap-around 테스트

### 3. Full Test (`jsilicon_full_test`)
- Manual mode와 CPU mode 모두 테스트
- 가장 포괄적인 테스트

### 4. Random Test (`jsilicon_random_test`)
- 랜덤 입력으로 DUT 검증
- 10-50개의 랜덤 트랜잭션 생성

## 환경 설정

### VCS 설정

시뮬레이션을 실행하기 전에 VCS 환경을 설정해야 합니다:

```bash
# VCS 환경 설정 (bash)
source /path/to/synopsys/vcs/bin/synopsys_sim.setup

# 또는 csh/tcsh
source /path/to/synopsys/vcs/cshrc/synopsys_sim.setup
```

### Verdi 설정 (선택사항)

파형 분석을 위해 Verdi를 사용하려면:

```bash
# Verdi 환경 설정 (bash)
export VERDI_HOME=/path/to/synopsys/verdi
export PATH=$VERDI_HOME/bin:$PATH

# 또는 csh/tcsh
setenv VERDI_HOME /path/to/synopsys/verdi
setenv PATH ${VERDI_HOME}/bin:${PATH}
```

## 실행 방법

### 방법 1: run.sh 스크립트 사용 (권장)

```bash
# 스크립트 실행 권한 부여 (최초 1회)
chmod +x run.sh

# 도움말 보기
./run.sh help

# 모든 테스트 실행
./run.sh run_all

# 특정 테스트 실행
./run.sh run jsilicon_manual_test
./run.sh run jsilicon_cpu_test
./run.sh run jsilicon_full_test
./run.sh run jsilicon_random_test

# Verdi GUI 모드로 실행
./run.sh gui
./run.sh gui jsilicon_manual_test

# 파형 뷰어 열기 (Verdi)
./run.sh wave

# 클린
./run.sh clean
```

### 방법 2: Makefile 직접 사용

```bash
# 컴파일 (VCS로 컴파일)
make compile

# 컴파일 및 시뮬레이션
make simulate

# 특정 테스트 실행
make TEST=jsilicon_manual_test simulate
make TEST=jsilicon_cpu_test simulate
make TEST=jsilicon_full_test simulate
make TEST=jsilicon_random_test simulate

# 단축 명령어
make test_manual
make test_cpu
make test_full
make test_random

# Verdi GUI 모드
make verdi

# Interactive 모드 (UCLI)
make interactive

# 파형 보기 (Verdi)
make wave

# Coverage 리포트 생성
make cov

# Verbosity 레벨 변경
make VERBOSITY=UVM_HIGH simulate

# 클린
make clean

# 도움말
make help
```

### 방법 3: VCS 직접 실행

```bash
# 컴파일
vcs -full64 -sverilog -timescale=1ns/1ps -ntb_opts uvm-1.2 \
    -debug_access+all -kdb -lca -CFLAGS -DVCS \
    ../src/*.v jsilicon_if.sv jsilicon_pkg.sv jsilicon_tb_top.sv \
    -top jsilicon_tb_top -o simv

# 시뮬레이션 실행
./simv +UVM_TESTNAME=jsilicon_full_test +UVM_VERBOSITY=UVM_MEDIUM -l simv.log

# Verdi와 함께 실행
./simv +UVM_TESTNAME=jsilicon_full_test +UVM_VERBOSITY=UVM_MEDIUM -gui=verdi
```

## 필요 사항

### 필수 도구
- **Synopsys VCS** (2019.06 이상 권장)
  - UVM 1.2 내장
  - Full64 모드 지원
  - SystemVerilog 지원

### 선택적 도구
- **Verdi** (파형 분석 및 디버깅)
  - FSDB 파형 포맷 지원
  - 고급 디버깅 기능

### UVM 라이브러리
- UVM 1.2 (VCS에 내장되어 제공됨)
- `-ntb_opts uvm-1.2` 옵션으로 자동 활성화

## 출력 파일

### 시뮬레이션 결과
- `simv`: VCS 시뮬레이션 실행 파일
- `simv.log`: 시뮬레이션 로그 파일
- `simv.vdb/`: Coverage 데이터베이스

### 파형 파일
- `jsilicon.fsdb`: Verdi FSDB 파형 파일 (기본)
- `jsilicon_uvm.vcd`: VCD 파형 파일 (fallback)

### 디버그 파일
- `csrc/`: 컴파일된 C 소스
- `DVEfiles/`: DVE 관련 파일
- `verdiLog/`: Verdi 로그 파일
- `novas.rc`, `novas.conf`: Verdi 설정 파일

## 결과 확인

### 콘솔 출력
시뮬레이션 중 UVM 메시지가 출력되며, 최종적으로 Scoreboard가 통계를 출력합니다:

```
========================================
       Scoreboard Final Report
========================================
Total Transactions: 36
Passed: 12
Failed: 0
*** TEST PASSED ***
========================================
```

### 파형 분석
Verdi로 FSDB 파형을 확인할 수 있습니다:

```bash
# Verdi로 FSDB 열기
verdi -ssf jsilicon.fsdb -nologo

# 또는 스크립트 사용
./run.sh wave

# Makefile 사용
make wave
```

### Coverage 분석
```bash
# Coverage 리포트 생성
make cov

# 리포트 보기
firefox urgReport/dashboard.html
```

## Python cocotb 테스트와의 비교

| 특징 | cocotb (test.py) | UVM (sim/) |
|------|------------------|------------|
| 언어 | Python | SystemVerilog |
| 시뮬레이터 | Icarus, Verilator 등 | VCS, Verdi |
| 구조 | 단일 테스트 파일 | 모듈화된 컴포넌트 |
| 파형 | VCD | FSDB (고성능) |
| 재사용성 | 제한적 | 높음 |
| 확장성 | 제한적 | 매우 높음 |
| 학습 곡선 | 낮음 | 높음 |
| 업계 표준 | 새로운 방식 | 검증된 방법론 |
| 성능 | 중간 | 높음 |
| 비용 | 무료 | 상용 (라이선스 필요) |

## 트러블슈팅

### VCS를 찾을 수 없음
VCS 환경이 제대로 설정되지 않았을 수 있습니다:

```bash
# VCS 설정 확인
which vcs

# VCS 버전 확인
vcs -ID

# 환경 변수 확인
echo $VCS_HOME

# 설정 스크립트 실행
source /path/to/vcs/bin/synopsys_sim.setup
```

### UVM을 찾을 수 없음
VCS 2019.06 이상에서는 `-ntb_opts uvm-1.2` 옵션으로 자동 로드됩니다. 에러가 발생하면:

```bash
# VCS UVM 버전 확인
vcs -ntb_opts uvm-1.2 -ID

# 수동으로 UVM 경로 지정 (필요시)
export UVM_HOME=$VCS_HOME/etc/uvm-1.2
```

### Verdi가 없는 경우
Verdi가 없어도 시뮬레이션은 정상 작동합니다. VCD 파일이 생성되므로 다른 뷰어를 사용할 수 있습니다:

```bash
# GTKWave 사용
gtkwave jsilicon_uvm.vcd
```

### FSDB 관련 에러
`$fsdbDumpfile` 에러가 발생하면 Verdi/FSDB 라이브러리가 없는 것입니다:
- VCD 모드로 폴백되어 자동으로 동작합니다
- Verdi 라이선스를 확인하세요

### 컴파일 에러
```bash
# RTL 파일 경로 확인
ls -l ../src/*.v

# Syntax 체크
vcs -sverilog -nc ../src/jsilicon.v

# Full debug 모드로 재컴파일
make clean
make VERBOSITY=UVM_DEBUG simulate
```

### 라이선스 에러
```bash
# VCS 라이선스 확인
echo $LM_LICENSE_FILE

# 라이선스 서버 확인
lmstat -a
```

## 커스터마이징

### 새로운 테스트 추가
1. `jsilicon_test.sv`에 새로운 테스트 클래스 추가
2. `jsilicon_sequences.sv`에 필요한 시퀀스 추가
3. Makefile에 단축 타겟 추가 (선택사항)

### Verbosity 레벨 변경
명령줄에서 `VERBOSITY` 변수를 설정하여 변경:

```bash
# 높은 상세도로 실행
make VERBOSITY=UVM_HIGH simulate

# 디버그 모드
make VERBOSITY=UVM_DEBUG simulate

# 최소 출력
make VERBOSITY=UVM_LOW simulate
```

사용 가능한 레벨:
- `UVM_NONE`: 최소 출력
- `UVM_LOW`: 낮은 상세도
- `UVM_MEDIUM`: 중간 상세도 (기본)
- `UVM_HIGH`: 높은 상세도
- `UVM_FULL`: 최대 출력
- `UVM_DEBUG`: 디버그 정보 포함

### VCS 컴파일 옵션 커스터마이징
Makefile의 `VCS_OPTS`를 수정하여 추가 옵션 설정:

```makefile
# Coverage 활성화
VCS_OPTS += -cm line+cond+fsm+tgl+branch

# Assert 활성화
VCS_OPTS += -assert enable_diag

# 최적화 레벨 조정
VCS_OPTS += -O3
```

## 참고 자료

### UVM 관련
- [UVM 1.2 User Guide](https://www.accellera.org/downloads/standards/uvm)
- [SystemVerilog UVM Tutorial](https://verificationguide.com/uvm/)
- [UVM Cookbook](https://verificationacademy.com/cookbook/uvm)

### VCS 관련
- VCS User Guide: `$VCS_HOME/doc/UserGuide.pdf`
- VCS UVM Guide: `$VCS_HOME/doc/uvm_guide.pdf`
- [Synopsys SolvNet](https://solvnet.synopsys.com/)

### Verdi 관련
- Verdi User Guide: `$VERDI_HOME/doc/verdi.pdf`
- [Verdi Debug Documentation](https://www.synopsys.com/verification/debug.html)

### 기타
- Original cocotb test: `../test/test.py`
- JSilicon RTL: `../src/`

## 라이선스

Apache-2.0 License

## 작성자

JSilicon Team, 2024

