#!/usr/bin/env bash
#
# Test runner for zsh setup script
# Runs ShellCheck linting and Bats functional tests
#

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}ℹ${NC} $*"; }
success() { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}⚠${NC} $*"; }
error() { echo -e "${RED}✗${NC} $*"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo ""
echo "╔════════════════════════════════════════════════════════════════╗"
echo "║               Zsh Setup Test Suite                            ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

# Track test results
TESTS_PASSED=0
TESTS_FAILED=0

# ============================================================================
# ShellCheck Tests
# ============================================================================

info "Running ShellCheck..."
echo ""

if ! command -v shellcheck &>/dev/null; then
    warn "ShellCheck not installed, skipping linting"
    warn "Install with: apt install shellcheck  OR  brew install shellcheck"
else
    if shellcheck "$PROJECT_DIR/setup.sh"; then
        success "ShellCheck: All checks passed"
        ((TESTS_PASSED++))
    else
        error "ShellCheck: Issues found"
        ((TESTS_FAILED++))
    fi
fi

echo ""

# ============================================================================
# Bats Tests
# ============================================================================

info "Running Bats tests..."
echo ""

if ! command -v bats &>/dev/null; then
    warn "Bats not installed, skipping functional tests"
    warn "Install with:"
    warn "  - macOS: brew install bats-core"
    warn "  - Linux: apt install bats  OR  install from https://github.com/bats-core/bats-core"
    warn ""
    warn "Quick install:"
    warn "  git clone https://github.com/bats-core/bats-core.git /tmp/bats"
    warn "  cd /tmp/bats && sudo ./install.sh /usr/local"
else
    if bats "$SCRIPT_DIR/test_setup.bats"; then
        success "Bats: All tests passed"
        ((TESTS_PASSED++))
    else
        error "Bats: Some tests failed"
        ((TESTS_FAILED++))
    fi
fi

echo ""

# ============================================================================
# Syntax Validation
# ============================================================================

info "Running syntax validation..."
echo ""

if bash -n "$PROJECT_DIR/setup.sh"; then
    success "Bash syntax: Valid"
    ((TESTS_PASSED++))
else
    error "Bash syntax: Invalid"
    ((TESTS_FAILED++))
fi

echo ""

# ============================================================================
# Summary
# ============================================================================

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║                        Test Summary                            ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    success "All tests passed! ($TESTS_PASSED/$((TESTS_PASSED + TESTS_FAILED)))"
    echo ""
    exit 0
else
    error "Some tests failed! (Passed: $TESTS_PASSED, Failed: $TESTS_FAILED)"
    echo ""
    exit 1
fi
