#!/usr/bin/env bash
#
# Modern Zsh Setup Script
# A robust, idempotent, cross-platform zsh configuration installer
#
# Supports: macOS, Linux (apt/dnf/pacman), WSL1/WSL2
# Features: Backups, error handling, customization, validation
#

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# ============================================================================
# Configuration & Constants
# ============================================================================

VERSION="2.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="${HOME}/.zsh-setup-backups/$(date +%Y%m%d-%H%M%S)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Configuration flags (can be overridden via environment or args)
INSTALL_OMZ="${INSTALL_OMZ:-true}"
INSTALL_P10K="${INSTALL_P10K:-true}"
INSTALL_PLUGINS="${INSTALL_PLUGINS:-true}"
INSTALL_FONTS="${INSTALL_FONTS:-true}"
INSTALL_K8S_TOOLS="${INSTALL_K8S_TOOLS:-false}"
SKIP_BACKUP="${SKIP_BACKUP:-false}"
VERBOSE="${VERBOSE:-false}"
DRY_RUN="${DRY_RUN:-false}"
NON_INTERACTIVE="${NON_INTERACTIVE:-false}"

# ============================================================================
# Helper Functions
# ============================================================================

# Output helpers
info() {
    echo -e "${BLUE}ℹ${NC} $*"
}

success() {
    echo -e "${GREEN}✓${NC} $*"
}

warn() {
    echo -e "${YELLOW}⚠${NC} $*"
}

error() {
    echo -e "${RED}✗${NC} $*" >&2
}

fatal() {
    error "$*"
    exit 1
}

verbose() {
    if [[ "${VERBOSE}" == "true" ]]; then
        echo -e "${CYAN}[DEBUG]${NC} $*"
    fi
}

section() {
    echo ""
    echo -e "${BOLD}${MAGENTA}▶ $*${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Ask yes/no question
ask() {
    local prompt="$1"
    local default="${2:-y}"

    if [[ "${NON_INTERACTIVE}" == "true" ]]; then
        [[ "${default}" == "y" ]] && return 0 || return 1
    fi

    local yn
    if [[ "${default}" == "y" ]]; then
        read -rp "$(echo -e "${CYAN}?${NC} ${prompt} [Y/n]: ")" yn
        yn=${yn:-y}
    else
        read -rp "$(echo -e "${CYAN}?${NC} ${prompt} [y/N]: ")" yn
        yn=${yn:-n}
    fi

    [[ "${yn}" =~ ^[Yy] ]] && return 0 || return 1
}

# Check if command exists
has_command() {
    command -v "$1" &>/dev/null
}

# Detect operating system
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if grep -qi microsoft /proc/version 2>/dev/null; then
            echo "wsl"
        else
            echo "linux"
        fi
    else
        echo "unknown"
    fi
}

# Detect package manager
detect_package_manager() {
    if has_command brew; then
        echo "brew"
    elif has_command apt-get; then
        echo "apt"
    elif has_command dnf; then
        echo "dnf"
    elif has_command pacman; then
        echo "pacman"
    else
        echo "unknown"
    fi
}

# Backup file if it exists
backup_file() {
    local file="$1"
    if [[ -e "${file}" ]] && [[ "${SKIP_BACKUP}" != "true" ]]; then
        mkdir -p "${BACKUP_DIR}"
        local backup_path="${BACKUP_DIR}/$(basename "${file}")"
        cp -r "${file}" "${backup_path}"
        verbose "Backed up ${file} to ${backup_path}"
        return 0
    fi
    return 1
}

# Run command with error handling
run_cmd() {
    local cmd="$*"
    verbose "Running: ${cmd}"

    if [[ "${DRY_RUN}" == "true" ]]; then
        info "[DRY RUN] Would run: ${cmd}"
        return 0
    fi

    if eval "${cmd}"; then
        return 0
    else
        local exit_code=$?
        error "Command failed (exit ${exit_code}): ${cmd}"
        return ${exit_code}
    fi
}

# Install package using detected package manager
install_package() {
    local package="$1"
    local pm="${PACKAGE_MANAGER}"

    info "Installing ${package}..."

    case "${pm}" in
        brew)
            run_cmd "brew install ${package}" || return 1
            ;;
        apt)
            run_cmd "sudo apt-get update -qq" || true
            run_cmd "sudo apt-get install -y ${package}" || return 1
            ;;
        dnf)
            run_cmd "sudo dnf install -y ${package}" || return 1
            ;;
        pacman)
            run_cmd "sudo pacman -S --noconfirm ${package}" || return 1
            ;;
        *)
            error "Unknown package manager: ${pm}"
            return 1
            ;;
    esac

    success "Installed ${package}"
    return 0
}

# ============================================================================
# Pre-flight Checks
# ============================================================================

preflight_checks() {
    section "Pre-flight Checks"

    # Detect environment
    OS_TYPE=$(detect_os)
    PACKAGE_MANAGER=$(detect_package_manager)

    info "Operating System: ${OS_TYPE}"
    info "Package Manager: ${PACKAGE_MANAGER}"

    if [[ "${PACKAGE_MANAGER}" == "unknown" ]]; then
        fatal "No supported package manager found (brew/apt/dnf/pacman)"
    fi

    # Check for required commands
    if ! has_command curl && ! has_command wget; then
        fatal "Neither curl nor wget found. Please install one of them."
    fi

    if ! has_command git; then
        warn "git not found, will install it"
        install_package git || fatal "Failed to install git"
    fi

    success "Pre-flight checks passed"
}

# ============================================================================
# Installation Functions
# ============================================================================

install_zsh() {
    section "Installing Zsh"

    if has_command zsh; then
        local zsh_version=$(zsh --version | cut -d' ' -f2)
        success "Zsh already installed (version ${zsh_version})"
        return 0
    fi

    info "Installing zsh..."
    case "${PACKAGE_MANAGER}" in
        brew)
            install_package zsh || return 1
            ;;
        apt)
            install_package zsh || return 1
            ;;
        dnf)
            install_package zsh || return 1
            ;;
        pacman)
            install_package zsh || return 1
            ;;
    esac

    success "Zsh installed successfully"
}

set_zsh_default() {
    section "Setting Zsh as Default Shell"

    local current_shell=$(basename "${SHELL}")
    if [[ "${current_shell}" == "zsh" ]]; then
        success "Zsh is already the default shell"
        return 0
    fi

    local zsh_path=$(command -v zsh)

    # Check if zsh is in /etc/shells
    if ! grep -q "^${zsh_path}$" /etc/shells 2>/dev/null; then
        info "Adding ${zsh_path} to /etc/shells"
        if [[ "${DRY_RUN}" != "true" ]]; then
            echo "${zsh_path}" | sudo tee -a /etc/shells >/dev/null
        fi
    fi

    if ask "Change default shell to zsh?" "y"; then
        if [[ "${DRY_RUN}" != "true" ]]; then
            chsh -s "${zsh_path}" || warn "Failed to change shell. You may need to run: chsh -s ${zsh_path}"
        fi
        success "Default shell set to zsh (restart terminal to apply)"
    else
        info "Skipped changing default shell"
    fi
}

install_oh_my_zsh() {
    section "Installing Oh My Zsh"

    if [[ "${INSTALL_OMZ}" != "true" ]]; then
        info "Skipping Oh My Zsh installation (disabled)"
        return 0
    fi

    local omz_dir="${ZSH:-${HOME}/.oh-my-zsh}"

    if [[ -d "${omz_dir}" ]]; then
        success "Oh My Zsh already installed at ${omz_dir}"
        return 0
    fi

    info "Installing Oh My Zsh..."

    local install_cmd='sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"'

    if [[ "${DRY_RUN}" != "true" ]]; then
        # Install with --unattended flag to prevent interactive prompts
        RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || {
            error "Oh My Zsh installation failed"
            return 1
        }
    fi

    success "Oh My Zsh installed successfully"
}

install_powerlevel10k() {
    section "Installing Powerlevel10k Theme"

    if [[ "${INSTALL_P10K}" != "true" ]]; then
        info "Skipping Powerlevel10k installation (disabled)"
        return 0
    fi

    local p10k_dir="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/themes/powerlevel10k"

    if [[ -d "${p10k_dir}" ]]; then
        success "Powerlevel10k already installed"
        if ask "Update Powerlevel10k to latest version?" "n"; then
            run_cmd "git -C '${p10k_dir}' pull" || warn "Failed to update Powerlevel10k"
        fi
        return 0
    fi

    info "Installing Powerlevel10k..."
    run_cmd "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git '${p10k_dir}'" || {
        error "Failed to install Powerlevel10k"
        return 1
    }

    success "Powerlevel10k installed successfully"
}

install_zsh_plugins() {
    section "Installing Zsh Plugins"

    if [[ "${INSTALL_PLUGINS}" != "true" ]]; then
        info "Skipping plugin installation (disabled)"
        return 0
    fi

    local custom_dir="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"

    # zsh-syntax-highlighting
    local syntax_dir="${custom_dir}/plugins/zsh-syntax-highlighting"
    if [[ -d "${syntax_dir}" ]]; then
        success "zsh-syntax-highlighting already installed"
    else
        info "Installing zsh-syntax-highlighting..."
        run_cmd "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git '${syntax_dir}'" || warn "Failed to install zsh-syntax-highlighting"
    fi

    # zsh-autosuggestions
    local suggest_dir="${custom_dir}/plugins/zsh-autosuggestions"
    if [[ -d "${suggest_dir}" ]]; then
        success "zsh-autosuggestions already installed"
    else
        info "Installing zsh-autosuggestions..."
        run_cmd "git clone https://github.com/zsh-users/zsh-autosuggestions.git '${suggest_dir}'" || warn "Failed to install zsh-autosuggestions"
    fi

    success "Plugins installed successfully"
}

install_nerd_fonts() {
    section "Installing Nerd Fonts"

    if [[ "${INSTALL_FONTS}" != "true" ]]; then
        info "Skipping font installation (disabled)"
        return 0
    fi

    case "${OS_TYPE}" in
        macos)
            if has_command brew; then
                info "Installing MesloLGS NF font via Homebrew..."
                run_cmd "brew tap homebrew/cask-fonts" || true
                run_cmd "brew install --cask font-meslo-lg-nerd-font" || warn "Font installation failed"
                success "Font installed (configure your terminal to use 'MesloLGS NF')"
            else
                warn "Homebrew not found, skipping font installation"
                info "Manual install: https://github.com/romkatv/powerlevel10k#fonts"
            fi
            ;;
        linux|wsl)
            info "Installing MesloLGS NF font..."
            local font_dir="${HOME}/.local/share/fonts"
            mkdir -p "${font_dir}"

            if [[ "${DRY_RUN}" != "true" ]]; then
                local fonts=(
                    "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
                    "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf"
                    "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf"
                    "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"
                )

                for font_url in "${fonts[@]}"; do
                    local font_file="${font_dir}/$(basename "${font_url}" | sed 's/%20/ /g')"
                    if [[ ! -f "${font_file}" ]]; then
                        curl -fsSL "${font_url}" -o "${font_file}" || warn "Failed to download $(basename "${font_url}")"
                    fi
                done

                # Refresh font cache
                if has_command fc-cache; then
                    fc-cache -f "${font_dir}" 2>/dev/null || true
                fi
            fi

            success "Fonts installed (configure your terminal to use 'MesloLGS NF')"

            if [[ "${OS_TYPE}" == "wsl" ]]; then
                info "On WSL, configure your Windows Terminal settings to use 'MesloLGS NF' font"
            fi
            ;;
    esac
}

install_kubernetes_tools() {
    section "Installing Kubernetes Tools"

    if [[ "${INSTALL_K8S_TOOLS}" != "true" ]]; then
        info "Skipping Kubernetes tools (disabled, use INSTALL_K8S_TOOLS=true to enable)"
        return 0
    fi

    local bin_dir="${HOME}/.local/bin"
    mkdir -p "${bin_dir}"

    # kubectl
    if has_command kubectl; then
        success "kubectl already installed"
    else
        info "Installing kubectl..."
        if [[ "${DRY_RUN}" != "true" ]]; then
            case "${OS_TYPE}" in
                macos)
                    install_package kubectl || warn "kubectl installation failed"
                    ;;
                linux|wsl)
                    local kubectl_version=$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)
                    curl -fsSL "https://storage.googleapis.com/kubernetes-release/release/${kubectl_version}/bin/linux/amd64/kubectl" -o "${bin_dir}/kubectl" || {
                        warn "Failed to download kubectl"
                        return 1
                    }
                    chmod +x "${bin_dir}/kubectl"
                    success "kubectl installed"
                    ;;
            esac
        fi
    fi

    # kubectx and kubens
    local kubectx_dir="${HOME}/.local/kubectx"
    if [[ -d "${kubectx_dir}" ]]; then
        success "kubectx/kubens already installed"
    else
        info "Installing kubectx and kubens..."
        run_cmd "git clone https://github.com/ahmetb/kubectx '${kubectx_dir}'" || warn "Failed to install kubectx"
        ln -sf "${kubectx_dir}/kubectx" "${bin_dir}/kubectx" 2>/dev/null || true
        ln -sf "${kubectx_dir}/kubens" "${bin_dir}/kubens" 2>/dev/null || true
    fi

    # helm
    if has_command helm; then
        success "helm already installed"
    else
        info "Installing helm..."
        if [[ "${DRY_RUN}" != "true" ]]; then
            curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash || warn "Helm installation failed"
        fi
    fi
}

# ============================================================================
# Configuration Generation
# ============================================================================

generate_zshrc() {
    section "Generating .zshrc Configuration"

    local zshrc_path="${HOME}/.zshrc"

    # Backup existing .zshrc
    if backup_file "${zshrc_path}"; then
        success "Backed up existing .zshrc to ${BACKUP_DIR}"
    fi

    info "Creating new .zshrc..."

    if [[ "${DRY_RUN}" == "true" ]]; then
        info "[DRY RUN] Would create ${zshrc_path}"
        return 0
    fi

    # Detect WSL user if applicable
    local wsl_username=""
    local wsl_vscode_path=""
    if [[ "${OS_TYPE}" == "wsl" ]]; then
        # Try to detect Windows username from common paths
        if [[ -d "/mnt/c/Users" ]]; then
            wsl_username=$(ls /mnt/c/Users | grep -v "Public\|Default" | head -n1)
            if [[ -n "${wsl_username}" ]]; then
                wsl_vscode_path="/mnt/c/Users/${wsl_username}/AppData/Local/Programs/Microsoft VS Code/Code.exe"
            fi
        fi
    fi

    cat > "${zshrc_path}" << 'ZSHRC_EOF'
# ============================================================================
# Zsh Configuration
# Generated by my-zsh-setup
# ============================================================================

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Set theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Uncomment to enable case-sensitive completion
# CASE_SENSITIVE="true"

# Uncomment to enable hyphen-insensitive completion
# HYPHEN_INSENSITIVE="true"

# Uncomment to disable auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change auto-update frequency (days)
# export UPDATE_ZSH_DAYS=13

# Uncomment to disable colors in ls
# DISABLE_LS_COLORS="true"

# Plugins to load
plugins=(
    git
    docker
    docker-compose
    npm
    zsh-syntax-highlighting
    zsh-autosuggestions
)

# Add kubectl plugin if available
if command -v kubectl &>/dev/null; then
    plugins+=(kubectl)
fi

# Add vscode plugin for VSCode integration
if command -v code &>/dev/null; then
    plugins+=(vscode)
fi

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# ============================================================================
# User Configuration
# ============================================================================

# PATH configuration
if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ]; then
    PATH="$HOME/.local/bin:$PATH"
fi

export PATH

# ============================================================================
# Environment Variables
# ============================================================================

# Default editor
export EDITOR='vim'
export VISUAL='vim'

# ============================================================================
# Platform-Specific Configuration
# ============================================================================
ZSHRC_EOF

    # Add WSL-specific configuration
    if [[ "${OS_TYPE}" == "wsl" ]]; then
        cat >> "${zshrc_path}" << WSLCONFIG

# WSL-Specific Configuration
if grep -qi microsoft /proc/version 2>/dev/null; then
    # Browser configuration
    export BROWSER="wslview"

    # VSCode integration (adjust path if needed)
WSLCONFIG

        if [[ -n "${wsl_vscode_path}" ]] && [[ -f "${wsl_vscode_path}" ]]; then
            cat >> "${zshrc_path}" << VSCODEPATH
    VSCODE_PATH="${wsl_vscode_path}"

    # Function to open VSCode with sudo
    sudocode() {
        sudo "\${VSCODE_PATH}" --user-data-dir="~/.vscode-root" "\$@"
    }

    # Function to open VSCode from current directory
    code() {
        if [[ -n "\${VSCODE_PATH}" ]] && [[ -f "\${VSCODE_PATH}" ]]; then
            local win_pwd=\$(wslpath -w "\$(pwd)")
            ("\${VSCODE_PATH}" "\${win_pwd}" "\$@" &>/dev/null &)
        else
            command code "\$@"
        fi
    }
VSCODEPATH
        else
            cat >> "${zshrc_path}" << VSCODEGEN
    # VSCode functions (customize paths as needed)
    # Uncomment and adjust if you have VSCode in Windows:
    # VSCODE_PATH="/mnt/c/Users/YOUR_USERNAME/AppData/Local/Programs/Microsoft VS Code/Code.exe"
    #
    # sudocode() {
    #     sudo "\${VSCODE_PATH}" --user-data-dir="~/.vscode-root" "\$@"
    # }
    #
    # code() {
    #     if [[ -n "\${VSCODE_PATH}" ]] && [[ -f "\${VSCODE_PATH}" ]]; then
    #         local win_pwd=\$(wslpath -w "\$(pwd)")
    #         ("\${VSCODE_PATH}" "\${win_pwd}" "\$@" &>/dev/null &)
    #     else
    #         command code "\$@"
    #     fi
    # }
VSCODEGEN
        fi

        cat >> "${zshrc_path}" << 'WSLCONFIG2'

    # Function to open Windows Explorer
    open() {
        explorer.exe "${1:-.}"
    }
fi

WSLCONFIG2
    fi

    # Add remaining configuration
    cat >> "${zshrc_path}" << 'ZSHRC_EOF2'
# ============================================================================
# Aliases
# ============================================================================

# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias home="cd ~"

# Common commands
alias c='clear'
alias ll="ls -alF"
alias la="ls -A"
alias l="ls -CF"
alias grep="grep --color=auto"
alias cp="cp -i"
alias mv="mv -i"
alias rm="rm -i"

# System and process
alias df="df -h"
alias du="du -h -c"

# Git aliases
alias ga="git add"
alias gc="git commit"
alias gcm="git commit -m"
alias gp="git push"
alias gl="git pull"
alias gst="git status"
alias gco="git checkout"
alias gbr="git branch"
alias gd="git diff"
alias gcl="git clone"
alias glog="git log --oneline --graph --decorate"

# Docker aliases
alias dps="docker ps"
alias dpa="docker ps -a"
alias di="docker images"
alias dr="docker run"
alias db="docker build"
alias dstop="docker stop"
alias drm="docker rm"
alias drmi="docker rmi"
alias dlog="docker logs"
alias dexec="docker exec -it"

# ============================================================================
# Kubernetes Configuration (if installed)
# ============================================================================

if command -v kubectl &>/dev/null; then
    # Enable kubectl completion
    source <(kubectl completion zsh)

    # Kubernetes aliases
    alias k="kubectl"
    alias kx="kubectx"
    alias kns="kubens"

    # Make completion work with k alias
    complete -F __start_kubectl k
fi

if command -v helm &>/dev/null; then
    source <(helm completion zsh)
fi

# ============================================================================
# Custom Functions
# ============================================================================

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
    if [ -f "$1" ]; then
        case "$1" in
            *.tar.bz2)   tar xjf "$1"     ;;
            *.tar.gz)    tar xzf "$1"     ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xf "$1"      ;;
            *.tbz2)      tar xjf "$1"     ;;
            *.tgz)       tar xzf "$1"     ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# ============================================================================
# Powerlevel10k Configuration
# ============================================================================

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ============================================================================
# Additional Customizations
# ============================================================================

# Add your custom configurations below this line

ZSHRC_EOF2

    success "Created ${zshrc_path}"

    info "Run 'p10k configure' to customize your prompt"
}

# ============================================================================
# Validation & Summary
# ============================================================================

validate_installation() {
    section "Validating Installation"

    local errors=0

    # Check zsh
    if has_command zsh; then
        success "zsh: $(zsh --version)"
    else
        error "zsh: NOT FOUND"
        ((errors++))
    fi

    # Check Oh My Zsh
    if [[ -d "${HOME}/.oh-my-zsh" ]]; then
        success "Oh My Zsh: Installed"
    else
        warn "Oh My Zsh: NOT FOUND"
    fi

    # Check Powerlevel10k
    if [[ -d "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k" ]]; then
        success "Powerlevel10k: Installed"
    else
        warn "Powerlevel10k: NOT FOUND"
    fi

    # Check plugins
    if [[ -d "${HOME}/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]]; then
        success "zsh-syntax-highlighting: Installed"
    else
        warn "zsh-syntax-highlighting: NOT FOUND"
    fi

    if [[ -d "${HOME}/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]]; then
        success "zsh-autosuggestions: Installed"
    else
        warn "zsh-autosuggestions: NOT FOUND"
    fi

    # Check .zshrc
    if [[ -f "${HOME}/.zshrc" ]]; then
        success ".zshrc: Configured"
    else
        error ".zshrc: NOT FOUND"
        ((errors++))
    fi

    return ${errors}
}

show_summary() {
    section "Installation Summary"

    success "Zsh setup completed successfully!"
    echo ""

    if [[ "${SKIP_BACKUP}" != "true" ]] && [[ -d "${BACKUP_DIR}" ]]; then
        info "Backups saved to: ${BACKUP_DIR}"
    fi

    echo ""
    echo "Next steps:"
    echo "  1. Restart your terminal or run: exec zsh"
    echo "  2. Run 'p10k configure' to customize your prompt"
    echo "  3. Customize ~/.zshrc as needed"
    echo ""

    if [[ "${OS_TYPE}" == "wsl" ]]; then
        echo "WSL-specific notes:"
        echo "  • Configure Windows Terminal to use 'MesloLGS NF' font"
        echo "  • Update VSCode paths in ~/.zshrc if needed"
        echo ""
    fi

    if [[ -n "${BACKUP_DIR}" ]] && [[ -d "${BACKUP_DIR}" ]]; then
        echo "To restore previous configuration:"
        echo "  cp ${BACKUP_DIR}/.zshrc ~/.zshrc"
        echo ""
    fi
}

# ============================================================================
# Usage & Help
# ============================================================================

show_help() {
    cat << EOF
Modern Zsh Setup Script v${VERSION}

A robust, idempotent, cross-platform zsh configuration installer.

USAGE:
    ./setup.sh [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    -v, --verbose           Enable verbose output
    -n, --dry-run           Show what would be done without making changes
    -y, --non-interactive   Run without prompts (use defaults)

    --skip-omz              Skip Oh My Zsh installation
    --skip-p10k             Skip Powerlevel10k installation
    --skip-plugins          Skip plugin installation
    --skip-fonts            Skip font installation
    --skip-backup           Skip backing up existing configs

    --install-k8s           Install Kubernetes tools (kubectl, helm, kubectx)

ENVIRONMENT VARIABLES:
    INSTALL_OMZ=true|false         Install Oh My Zsh (default: true)
    INSTALL_P10K=true|false        Install Powerlevel10k (default: true)
    INSTALL_PLUGINS=true|false     Install plugins (default: true)
    INSTALL_FONTS=true|false       Install Nerd Fonts (default: true)
    INSTALL_K8S_TOOLS=true|false   Install K8s tools (default: false)
    SKIP_BACKUP=true|false         Skip backups (default: false)
    VERBOSE=true|false             Verbose output (default: false)
    DRY_RUN=true|false             Dry run mode (default: false)

EXAMPLES:
    # Standard installation
    ./setup.sh

    # Dry run to see what would happen
    ./setup.sh --dry-run

    # Install without Kubernetes tools, non-interactive
    ./setup.sh --non-interactive

    # Install with Kubernetes tools
    ./setup.sh --install-k8s

    # Minimal installation (no fonts, no k8s tools)
    ./setup.sh --skip-fonts

SUPPORTED PLATFORMS:
    • macOS (with Homebrew)
    • Linux (Ubuntu/Debian, Fedora, Arch)
    • WSL1/WSL2

EOF
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -n|--dry-run)
                DRY_RUN=true
                VERBOSE=true
                shift
                ;;
            -y|--non-interactive)
                NON_INTERACTIVE=true
                shift
                ;;
            --skip-omz)
                INSTALL_OMZ=false
                shift
                ;;
            --skip-p10k)
                INSTALL_P10K=false
                shift
                ;;
            --skip-plugins)
                INSTALL_PLUGINS=false
                shift
                ;;
            --skip-fonts)
                INSTALL_FONTS=false
                shift
                ;;
            --skip-backup)
                SKIP_BACKUP=true
                shift
                ;;
            --install-k8s)
                INSTALL_K8S_TOOLS=true
                shift
                ;;
            *)
                error "Unknown option: $1"
                echo "Run './setup.sh --help' for usage information"
                exit 1
                ;;
        esac
    done

    # Print header
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║           Modern Zsh Setup v${VERSION}                        ║"
    echo "║   Robust • Idempotent • Cross-Platform                        ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""

    if [[ "${DRY_RUN}" == "true" ]]; then
        warn "DRY RUN MODE - No changes will be made"
        echo ""
    fi

    # Run installation steps
    preflight_checks || fatal "Pre-flight checks failed"
    install_zsh || fatal "Zsh installation failed"
    set_zsh_default
    install_oh_my_zsh || fatal "Oh My Zsh installation failed"
    install_powerlevel10k
    install_zsh_plugins
    install_nerd_fonts
    install_kubernetes_tools
    generate_zshrc || fatal "Failed to generate .zshrc"

    # Validate and show summary
    if validate_installation; then
        show_summary
    else
        warn "Installation completed with some warnings"
        show_summary
    fi

    echo ""
    success "All done! Enjoy your new zsh setup! 🚀"
    echo ""
}

# Run main function
main "$@"
