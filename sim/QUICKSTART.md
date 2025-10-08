# Quick Start Guide - VCS & Verdi UVM Environment

JSilicon UVM 테스트벤치를 빠르게 시작하기 위한 가이드입니다.

## 📋 사전 준비

### 1. VCS 및 Verdi 확인

```bash
# VCS 확인
which vcs
vcs -ID

# Verdi 확인 (선택사항)
which verdi
verdi -version
```

### 2. 환경 설정 (필요한 경우)

#### Bash/Shell 사용자:
```bash
source ./setup_vcs.sh
```

#### Csh/Tcsh 사용자:
```csh
source ./setup_vcs.csh
```

또는 수동으로:
```bash
# Bash
export VCS_HOME=/path/to/vcs
export PATH=$VCS_HOME/bin:$PATH
export VERDI_HOME=/path/to/verdi
export PATH=$VERDI_HOME/bin:$PATH

# Csh
setenv VCS_HOME /path/to/vcs
setenv PATH ${VCS_HOME}/bin:${PATH}
setenv VERDI_HOME /path/to/verdi
setenv PATH ${VERDI_HOME}/bin:${PATH}
```

## 🚀 빠른 실행

### 옵션 1: 스크립트 사용 (가장 쉬움)

```bash
cd JSilicon/sim

# 전체 테스트 실행
./run.sh run_all

# 특정 테스트만 실행
./run.sh run jsilicon_full_test
```

### 옵션 2: Makefile 사용

```bash
cd JSilicon/sim

# 컴파일 및 시뮬레이션
make simulate

# 또는 단계별
make compile    # 1. 컴파일
./simv          # 2. 실행
```

## 📊 결과 확인

### 콘솔 출력
시뮬레이션이 성공하면 다음과 같은 메시지가 표시됩니다:

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

### 파형 확인

```bash
# Verdi로 파형 보기
./run.sh wave

# 또는
make wave

# 또는 직접
verdi -ssf jsilicon.fsdb -nologo
```

## 🎯 주요 테스트

```bash
# Manual Mode Test - ALU 연산 테스트
./run.sh run jsilicon_manual_test

# CPU Mode Test - ROM 프로그램 실행
./run.sh run jsilicon_cpu_test

# Full Test - 전체 기능 테스트
./run.sh run jsilicon_full_test

# Random Test - 랜덤 테스트
./run.sh run jsilicon_random_test
```

## 🐛 GUI 디버깅

```bash
# Verdi GUI와 함께 실행
./run.sh gui

# 또는
make verdi

# Interactive 모드 (UCLI)
make interactive
```

## 🧹 정리

```bash
# 생성된 파일 삭제
./run.sh clean

# 또는
make clean
```

## ⚡ 자주 사용하는 명령어

```bash
# === 기본 실행 ===
./run.sh run jsilicon_full_test       # Full test 실행
make simulate                          # 컴파일 및 실행
make TEST=jsilicon_manual_test simulate # Manual test 실행

# === GUI/디버깅 ===
./run.sh gui                          # Verdi GUI
./run.sh wave                         # 파형 보기
make verdi                            # Verdi와 실행

# === Verbosity 조정 ===
make VERBOSITY=UVM_HIGH simulate      # 상세 로그
make VERBOSITY=UVM_LOW simulate       # 간단한 로그

# === 유틸리티 ===
./run.sh clean                        # 클린
make help                             # 도움말
```

## 📁 생성되는 파일

실행 후 다음 파일들이 생성됩니다:

| 파일/디렉토리 | 설명 |
|--------------|------|
| `simv` | VCS 시뮬레이션 실행 파일 |
| `simv.log` | 시뮬레이션 로그 |
| `jsilicon.fsdb` | Verdi 파형 파일 |
| `csrc/` | 컴파일된 C 소스 |
| `simv.vdb/` | Coverage 데이터 |

## ❓ 문제 해결

### VCS를 찾을 수 없음
```bash
# VCS 경로 확인
which vcs

# 환경 설정
source /path/to/vcs/bin/synopsys_sim.setup
```

### 컴파일 에러
```bash
# 클린 후 재시도
make clean
make compile
```

### 라이선스 에러
```bash
# 라이선스 설정 확인
echo $LM_LICENSE_FILE

# 라이선스 서버 확인
lmstat -a
```

### Verdi를 찾을 수 없음
Verdi가 없어도 시뮬레이션은 실행됩니다. VCD 파일이 생성됩니다.

## 📚 더 많은 정보

- 상세 사용법: `README.md`
- Makefile 도움말: `make help`
- 스크립트 도움말: `./run.sh help`

## 💡 팁

1. **첫 실행 시**: `./run.sh run jsilicon_full_test`로 시작하세요
2. **디버깅**: Verdi GUI를 사용하면 편리합니다 (`./run.sh gui`)
3. **빠른 테스트**: Manual test가 가장 빠릅니다
4. **상세 로그**: `VERBOSITY=UVM_HIGH` 옵션 사용

## ✅ 체크리스트

시작하기 전 확인사항:

- [ ] VCS가 설치되어 있고 PATH에 있음
- [ ] Verdi가 설치되어 있음 (선택사항)
- [ ] 라이선스가 설정되어 있음
- [ ] sim/ 디렉토리에 있음

준비되었다면:
```bash
./run.sh run jsilicon_full_test
```

성공! 🎉

