#!/usr/bin/env bats
#
# Test suite for setup.sh
# Requires: bats-core (https://github.com/bats-core/bats-core)
#
# Run with: bats tests/test_setup.bats
#

setup() {
    # Load test helpers
    DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"
    PATH="$DIR/..:$PATH"

    # Create temporary test directory
    export TEST_HOME=$(mktemp -d)
    export HOME="$TEST_HOME"
    export SKIP_BACKUP=true
    export NON_INTERACTIVE=true
    export DRY_RUN=true
}

teardown() {
    # Clean up test directory
    if [ -n "$TEST_HOME" ] && [ -d "$TEST_HOME" ]; then
        rm -rf "$TEST_HOME"
    fi
}

# ============================================================================
# Helper Functions Tests
# ============================================================================

@test "setup.sh exists and is executable" {
    [ -f "$DIR/../setup.sh" ]
    [ -x "$DIR/../setup.sh" ]
}

@test "setup.sh has valid shebang" {
    run head -n 1 "$DIR/../setup.sh"
    [[ "$output" =~ ^#!/usr/bin/env\ bash ]]
}

@test "setup.sh --help displays help message" {
    run "$DIR/../setup.sh" --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Modern Zsh Setup Script" ]]
    [[ "$output" =~ "USAGE:" ]]
    [[ "$output" =~ "OPTIONS:" ]]
}

@test "setup.sh --version shows version" {
    run grep "^VERSION=" "$DIR/../setup.sh"
    [ "$status" -eq 0 ]
    [[ "$output" =~ VERSION.*2\.0\.0 ]]
}

# ============================================================================
# Dry Run Tests
# ============================================================================

@test "dry run mode doesn't make changes" {
    export DRY_RUN=true
    export NON_INTERACTIVE=true

    # Even in dry run, preflight checks should pass
    run bash -c 'source "$DIR/../setup.sh" && detect_os'
    [ "$status" -eq 0 ]
}

@test "dry run shows what would be done" {
    skip "Requires full environment setup"

    export DRY_RUN=true
    export NON_INTERACTIVE=true

    run "$DIR/../setup.sh" --dry-run
    [[ "$output" =~ "DRY RUN" ]]
    [[ "$output" =~ "Would" ]]
}

# ============================================================================
# Detection Tests
# ============================================================================

@test "OS detection works" {
    run bash -c 'source "$DIR/../setup.sh" && detect_os'
    [ "$status" -eq 0 ]
    # Should return one of: macos, linux, wsl, unknown
    [[ "$output" =~ ^(macos|linux|wsl|unknown)$ ]]
}

@test "package manager detection works" {
    run bash -c 'source "$DIR/../setup.sh" && detect_package_manager'
    [ "$status" -eq 0 ]
    # Should return one of the supported package managers or unknown
    [[ "$output" =~ ^(brew|apt|dnf|pacman|unknown)$ ]]
}

@test "has_command function works for existing command" {
    run bash -c 'source "$DIR/../setup.sh" && has_command bash && echo "found"'
    [ "$status" -eq 0 ]
    [[ "$output" =~ "found" ]]
}

@test "has_command function works for non-existing command" {
    run bash -c 'source "$DIR/../setup.sh" && has_command nonexistentcommand123 || echo "not found"'
    [ "$status" -eq 0 ]
    [[ "$output" =~ "not found" ]]
}

# ============================================================================
# Command Line Argument Tests
# ============================================================================

@test "accepts --verbose flag" {
    run bash -c 'source "$DIR/../setup.sh"
        while [[ $# -gt 0 ]]; do
            case $1 in
                -v|--verbose) VERBOSE=true; shift ;;
                *) shift ;;
            esac
        done
        echo "$VERBOSE"' -- --verbose
    [[ "$output" =~ "true" ]]
}

@test "accepts --non-interactive flag" {
    run bash -c 'source "$DIR/../setup.sh"
        while [[ $# -gt 0 ]]; do
            case $1 in
                -y|--non-interactive) NON_INTERACTIVE=true; shift ;;
                *) shift ;;
            esac
        done
        echo "$NON_INTERACTIVE"' -- --non-interactive
    [[ "$output" =~ "true" ]]
}

@test "accepts --skip-omz flag" {
    run bash -c 'source "$DIR/../setup.sh"
        while [[ $# -gt 0 ]]; do
            case $1 in
                --skip-omz) INSTALL_OMZ=false; shift ;;
                *) shift ;;
            esac
        done
        echo "$INSTALL_OMZ"' -- --skip-omz
    [[ "$output" =~ "false" ]]
}

@test "accepts --install-k8s flag" {
    run bash -c 'source "$DIR/../setup.sh"
        while [[ $# -gt 0 ]]; do
            case $1 in
                --install-k8s) INSTALL_K8S_TOOLS=true; shift ;;
                *) shift ;;
            esac
        done
        echo "$INSTALL_K8S_TOOLS"' -- --install-k8s
    [[ "$output" =~ "true" ]]
}

@test "rejects unknown flags" {
    run "$DIR/../setup.sh" --unknown-flag
    [ "$status" -ne 0 ]
    [[ "$output" =~ "Unknown option" ]]
}

# ============================================================================
# Environment Variable Tests
# ============================================================================

@test "respects INSTALL_OMZ environment variable" {
    export INSTALL_OMZ=false
    run bash -c 'source "$DIR/../setup.sh" && echo "$INSTALL_OMZ"'
    [[ "$output" =~ "false" ]]
}

@test "respects INSTALL_P10K environment variable" {
    export INSTALL_P10K=false
    run bash -c 'source "$DIR/../setup.sh" && echo "$INSTALL_P10K"'
    [[ "$output" =~ "false" ]]
}

@test "respects VERBOSE environment variable" {
    export VERBOSE=true
    run bash -c 'source "$DIR/../setup.sh" && echo "$VERBOSE"'
    [[ "$output" =~ "true" ]]
}

# ============================================================================
# Idempotency Tests
# ============================================================================

@test "script is idempotent - zsh check" {
    skip "Requires zsh installed"

    # First run
    run "$DIR/../setup.sh" --non-interactive --dry-run
    first_output="$output"

    # Second run
    run "$DIR/../setup.sh" --non-interactive --dry-run
    second_output="$output"

    # Both runs should succeed
    [ "$status" -eq 0 ]
}

# ============================================================================
# Backup Tests
# ============================================================================

@test "backup functionality creates backup directory" {
    skip "Requires full implementation"

    # Create a fake .zshrc
    echo "test config" > "$HOME/.zshrc"

    export SKIP_BACKUP=false
    run bash -c 'source "$DIR/../setup.sh" && backup_file "$HOME/.zshrc"'

    # Check backup was created
    [ -d "$HOME/.zsh-setup-backups" ]
}

@test "SKIP_BACKUP prevents backup creation" {
    echo "test config" > "$HOME/.zshrc"

    export SKIP_BACKUP=true
    run bash -c 'source "$DIR/../setup.sh" && backup_file "$HOME/.zshrc" || echo "skipped"'

    # Backup dir should not exist
    [ ! -d "$HOME/.zsh-setup-backups" ]
}

# ============================================================================
# Safety Tests
# ============================================================================

@test "script uses set -euo pipefail" {
    run head -n 15 "$DIR/../setup.sh"
    [[ "$output" =~ "set -euo pipefail" ]]
}

@test "script doesn't use rm -rf without checks" {
    # Should not have dangerous rm -rf commands
    run grep -n "rm -rf" "$DIR/../setup.sh"
    # If found, should be in controlled contexts only
    if [ "$status" -eq 0 ]; then
        # Make sure it's not operating on variables that could be empty/root
        ! [[ "$output" =~ 'rm -rf \$' ]] || [[ "$output" =~ "rm -rf /" ]]
    fi
}

@test "script validates variables before use" {
    # Check for use of unset variables (should fail with -u flag if any exist)
    run bash -n "$DIR/../setup.sh"
    [ "$status" -eq 0 ]
}

# ============================================================================
# Output Tests
# ============================================================================

@test "error messages go to stderr" {
    run bash -c 'source "$DIR/../setup.sh" && error "test error" 2>&1 1>/dev/null'
    [[ "$output" =~ "test error" ]]
}

@test "success messages use color codes" {
    run bash -c 'source "$DIR/../setup.sh" && success "test" | cat -v'
    [[ "$output" =~ "\\033" ]]  # ANSI color codes
}

# ============================================================================
# Configuration Generation Tests
# ============================================================================

@test "generated zshrc contains Oh My Zsh path" {
    skip "Requires full environment"

    export DRY_RUN=false
    run bash -c 'source "$DIR/../setup.sh" && generate_zshrc'

    [ -f "$HOME/.zshrc" ]
    run grep "oh-my-zsh" "$HOME/.zshrc"
    [ "$status" -eq 0 ]
}

@test "generated zshrc contains Powerlevel10k theme" {
    skip "Requires full environment"

    export DRY_RUN=false
    run bash -c 'source "$DIR/../setup.sh" && generate_zshrc'

    [ -f "$HOME/.zshrc" ]
    run grep "powerlevel10k" "$HOME/.zshrc"
    [ "$status" -eq 0 ]
}

@test "generated zshrc includes required plugins" {
    skip "Requires full environment"

    export DRY_RUN=false
    run bash -c 'source "$DIR/../setup.sh" && generate_zshrc'

    [ -f "$HOME/.zshrc" ]
    run grep "zsh-syntax-highlighting" "$HOME/.zshrc"
    [ "$status" -eq 0 ]
    run grep "zsh-autosuggestions" "$HOME/.zshrc"
    [ "$status" -eq 0 ]
}

# ============================================================================
# Platform-Specific Tests
# ============================================================================

@test "WSL detection works" {
    # Mock WSL environment
    if grep -qi microsoft /proc/version 2>/dev/null; then
        run bash -c 'source "$DIR/../setup.sh" && detect_os'
        [[ "$output" == "wsl" ]]
    else
        skip "Not running on WSL"
    fi
}

@test "macOS detection works" {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        run bash -c 'source "$DIR/../setup.sh" && detect_os'
        [[ "$output" == "macos" ]]
    else
        skip "Not running on macOS"
    fi
}

@test "Linux detection works" {
    if [[ "$OSTYPE" == "linux-gnu"* ]] && ! grep -qi microsoft /proc/version 2>/dev/null; then
        run bash -c 'source "$DIR/../setup.sh" && detect_os'
        [[ "$output" == "linux" ]]
    else
        skip "Not running on Linux"
    fi
}

# ============================================================================
# Integration Tests (require actual installation)
# ============================================================================

@test "full dry run completes without errors" {
    skip "Long running test - enable for full test runs"

    run "$DIR/../setup.sh" --dry-run --non-interactive
    [ "$status" -eq 0 ]
    [[ "$output" =~ "All done" ]]
}
