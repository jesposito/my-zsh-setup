#!/bin/bash

# Update and install necessary packages
sudo apt update
sudo apt install -y git zsh curl fonts-powerline

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Clone necessary plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/ahmetb/kubectx $HOME/.local/kubectx

# Create symlinks for kubectx and kubens
mkdir -p $HOME/.local/bin
ln -sf $HOME/.local/kubectx/kubectx $HOME/.local/bin/kubectx
ln -sf $HOME/.local/kubectx/kubens $HOME/.local/bin/kubens

# Install kubectl and helm
curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Set up .zshrc
cat <<EOT > ~/.zshrc

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(git vscode docker docker-compose kubectl npm zsh-syntax-highlighting zsh-autosuggestions)

source $ZSH/oh-my-zsh.sh

sudocode() {
    sudo "/mnt/c/Users/JedEsposito/AppData/Local/Programs/Microsoft VS Code/Code.exe" --user-data-dir="~/.vscode-root" "$@"
}

# VSCode function
code() {
    echo "Attempting to run VS Code..."
    WIN_PWD=$(wslpath -w "$(pwd)")
    echo "Current directory: $WIN_PWD"
    (/mnt/c/Users/JedEsposito/AppData/Local/Programs/Microsoft\ VS\ Code/Code.exe "$WIN_PWD" "$@" &>/dev/null &)
    echo "VS Code launched in background"
}

# explorer
open() {
	explorer.exe .
}

# PATH configuration
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# Environment variables
export PATH=$HOME/bin:/usr/local/bin:$PATH
export BROWSER="wslview"

# Unalias code if it exists
unalias code 2>/dev/null

# Add autocompletion for kubectl
source <(kubectl completion zsh)

# To customize prompt, run p10k configure or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Load dircolors for Solarized color scheme
eval $(dircolors ~/.dircolors)

# Aliases for kubectl
alias k=kubectl
complete -F __start_kubectl k
source <(kubectl completion zsh)
source <(helm completion zsh)
alias kns=kubens
alias kctx=kubectx

# Clear zsh completion dump file
rm -f ~/.zcompdump; compinit

# Added Aliases and Functions

# Navigation Aliases
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias ~="cd ~"
alias home="cd ~"

# Common Commands
alias ll="ls -alF"
alias la="ls -A"
alias l="ls -CF"
alias grep="grep --color=auto"
alias cp="cp -i"
alias mv="mv -i"
alias rm="rm -i"

# System and Process
alias df="df -h"
alias du="du -h -c"
alias top="htop"

# Git Aliases
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

# Docker Aliases
alias dps="docker ps"
alias dpa="docker ps -a"
alias di="docker images"
alias dr="docker run"
alias db="docker build"
alias dstop="docker stop"
alias drm="docker rm"
alias drmi="docker rmi"

# Kubernetes Aliases
alias k="kubectl"
alias kx="kubectx"
alias kns="kubens"

# VSCode Alias
alias code.="code ."

alias c='clear'
EOT

# Source the new .zshrc
source ~/.zshrc

