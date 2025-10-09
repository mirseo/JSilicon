#!/bin/csh

# SPDX-FileCopyrightText: © 2024 JSilicon
# SPDX-License-Identifier: Apache-2.0

# VCS & Verdi Environment Setup Script for csh/tcsh
# This script helps set up the VCS and Verdi environment variables

echo "========================================="
echo "VCS & Verdi Environment Setup (csh/tcsh)"
echo "========================================="

# VCS 경로 설정 (사용자 환경에 맞게 수정)
# 예시 경로입니다. 실제 설치 경로로 변경하세요.
# set VCS_HOME_DEFAULT = "/tools/synopsys/vcs/current"
#set VERDI_HOME_DEFAULT = "/tools/synopsys/verdi/current"

# 기본값 또는 환경변수 사용
if (! $?VCS_HOME) then
    setenv VCS_HOME $VCS_HOME_DEFAULT
endif

if (! $?VERDI_HOME) then
    setenv VERDI_HOME $VERDI_HOME_DEFAULT
endif

# VCS 설정
if (-d "$VCS_HOME") then
    echo "Setting up VCS..."
    setenv PATH ${VCS_HOME}/bin:${PATH}
    
    # VCS 설정 스크립트 실행 (존재하는 경우)
    if (-f "${VCS_HOME}/cshrc/synopsys_sim.setup") then
        source ${VCS_HOME}/cshrc/synopsys_sim.setup
        echo "✓ VCS setup complete: $VCS_HOME"
    else
        echo "✓ VCS path added: $VCS_HOME"
        echo "⚠ Warning: synopsys_sim.setup not found"
    endif
else
    echo "✗ Error: VCS directory not found: $VCS_HOME"
    echo "  Please check your installation path"
endif

echo ""

# Verdi 설정
if (-d "$VERDI_HOME") then
    echo "Setting up Verdi..."
    setenv PATH ${VERDI_HOME}/bin:${PATH}
    setenv NOVAS_HOME $VERDI_HOME
    echo "✓ Verdi setup complete: $VERDI_HOME"
else
    echo "✗ Warning: Verdi directory not found: $VERDI_HOME"
    echo "  Verdi is optional. Simulation will work without it."
endif

echo ""
echo "========================================="
echo "Environment Variables Set:"
echo "========================================="
echo "VCS_HOME    = $VCS_HOME"
echo "VERDI_HOME  = $VERDI_HOME"
echo "PATH        = (VCS and Verdi added)"

echo ""
echo "========================================="
echo "Verification:"
echo "========================================="

# VCS 버전 확인
which vcs >& /dev/null
if ($status == 0) then
    echo "✓ VCS found:"
    vcs -ID |& head -3
else
    echo "✗ VCS not found in PATH"
endif

echo ""

# Verdi 버전 확인
which verdi >& /dev/null
if ($status == 0) then
    echo "✓ Verdi found:"
    verdi -version |& head -1
else
    echo "✗ Verdi not found in PATH"
endif

echo ""
echo "========================================="
echo "Next Steps:"
echo "========================================="
echo "1. To make these settings permanent, add the following to your ~/.cshrc:"
echo ""
echo "   setenv VCS_HOME $VCS_HOME"
echo "   setenv PATH \${VCS_HOME}/bin:\${PATH}"
echo "   setenv VERDI_HOME $VERDI_HOME"
echo "   setenv PATH \${VERDI_HOME}/bin:\${PATH}"
echo ""
echo "2. Run a test:"
echo "   cd JSilicon/sim"
echo "   ./run.sh run jsilicon_full_test"
echo ""
echo "========================================="

# 라이선스 확인
echo ""
echo "License Information:"
if ($?LM_LICENSE_FILE) then
    echo "✓ LM_LICENSE_FILE = $LM_LICENSE_FILE"
else
    echo "⚠ Warning: LM_LICENSE_FILE not set"
    echo "  You may need to set it for VCS/Verdi license"
    echo "  Example: setenv LM_LICENSE_FILE port@server"
endif

echo ""
echo "Setup script completed!"

