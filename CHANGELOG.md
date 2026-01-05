# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-01-05

### 🎉 Major Rewrite

Complete rewrite of the zsh setup script with modern best practices and enterprise-grade features.

### ✨ Added

#### Core Features
- **Idempotent installation** - Safe to run multiple times without breaking existing setup
- **Cross-platform support** - Works on macOS, Linux (apt/dnf/pacman), and WSL1/WSL2
- **Comprehensive error handling** - Graceful failure with helpful error messages
- **Automatic backups** - Backs up existing configurations before making changes
- **Dry-run mode** - Preview changes without actually making them (`--dry-run`)
- **Non-interactive mode** - Perfect for automation and CI/CD (`--non-interactive`)
- **Verbose output** - Debug mode for troubleshooting (`--verbose`)

#### Customization Options
- Command-line flags for selective component installation
- Environment variables for configuration
- Skip options for all major components:
  - `--skip-omz` - Skip Oh My Zsh
  - `--skip-p10k` - Skip Powerlevel10k
  - `--skip-plugins` - Skip plugins
  - `--skip-fonts` - Skip Nerd Fonts
  - `--skip-backup` - Skip backups
- Optional Kubernetes tools installation (`--install-k8s`)

#### Platform Detection
- Automatic OS detection (macOS, Linux, WSL)
- Package manager detection (brew, apt, dnf, pacman)
- WSL-specific features and configurations
- Automatic Windows username detection for WSL

#### Installation Components
- **Powerlevel10k theme** - Now properly installed (was missing in v1.0)
- **Nerd Fonts** - Automatic MesloLGS NF font installation
- **Enhanced plugins** - Better plugin management and validation
- **Kubernetes tools** - Optional kubectl, helm, kubectx, kubens installation

#### Configuration Generation
- Dynamic .zshrc generation based on environment
- Platform-specific configurations
- WSL-aware VSCode integration
- Conditional plugin loading
- Better organized configuration structure

#### Quality Assurance
- Comprehensive test suite with Bats
- ShellCheck linting configuration
- Syntax validation
- Installation validation
- Test runner script (`tests/run_tests.sh`)

#### Documentation
- Complete README rewrite with:
  - Feature highlights
  - Usage examples
  - Platform-specific instructions
  - Troubleshooting guide
  - Contributing guidelines
- Inline code documentation
- Help system (`--help`)

### 🔧 Changed

- **Script structure** - Completely reorganized for better maintainability
- **Error handling** - Uses `set -euo pipefail` for safer execution
- **Output formatting** - Colored, organized output with clear sections
- **Backup system** - Timestamped backups with restore instructions
- **Installation flow** - More logical, step-by-step process

### 🗑️ Removed

- Hardcoded WSL paths - Now uses automatic detection
- Non-working dircolors reference
- Forced shell sourcing in non-interactive script
- Duplicate kubectl completion calls
- Unnecessary `source .zshrc` at end of script

### 🐛 Fixed

- **Critical**: Powerlevel10k wasn't being installed (referenced but not cloned)
- **Critical**: Oh-My-Zsh installation failing in non-interactive mode
- **Critical**: Script not idempotent - would fail on re-run
- **Critical**: No backup of existing .zshrc
- **Security**: Missing sudo checks could cause silent failures
- **Portability**: Hardcoded user paths made script unusable for others
- **Portability**: Only worked on apt-based systems
- **UX**: No error messages or user feedback
- **UX**: No way to customize installation
- **Safety**: Could overwrite configs without warning

### 🔒 Security

- Added validation for all external downloads
- HTTPS-only for all remote operations
- No execution of unverified scripts
- Safe variable handling with `set -u`
- Proper error propagation with `set -e` and `set -o pipefail`

### 📦 Dependencies

No new runtime dependencies added. Optional testing dependencies:
- ShellCheck (for linting)
- Bats (for testing)

### 🚀 Performance

- Parallel installation where possible
- Shallow git clones for faster downloads
- Skip unnecessary updates if components exist

---

## [1.0.0] - Initial Release

### Features

- Basic zsh installation via apt
- Oh My Zsh installation
- zsh-syntax-highlighting plugin
- zsh-autosuggestions plugin
- Basic kubectl and helm installation
- Hardcoded .zshrc configuration
- WSL-specific VSCode integration

### Known Issues (Fixed in 2.0.0)

- Not idempotent
- Only works on Ubuntu/Debian
- Hardcoded user paths
- No error handling
- Missing Powerlevel10k installation
- No backup mechanism
- No customization options
- No tests

---

[2.0.0]: https://github.com/jesposito/my-zsh-setup/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/jesposito/my-zsh-setup/releases/tag/v1.0.0
