# My Zsh Setup

This repository contains a script to set up my zsh environment on any new machine. It includes the installation of necessary dependencies and configurations to set up my preferred zshrc file.

## Setup Script

The setup script installs the following dependencies:
- Homebrew
- Oh My Zsh
- Powerlevel10k theme
- Various Zsh plugins (syntax highlighting, autosuggestions)
- Kubernetes tools (kubectx, kubens)
- Powerline fonts

## Zshrc Configuration

### Plugins
- **git**: Git integration.
- **vscode**: Visual Studio Code integration.
- **docker**: Docker commands integration.
- **docker-compose**: Docker Compose commands integration.
- **kubectl**: Kubernetes command-line tool integration.
- **npm**: Node package manager integration.

### Aliases
- **c**: Alias for clear.

### Functions
- **sudocode**: Opens Visual Studio Code with sudo privileges.
- **code**: Opens Visual Studio Code from the current directory in the WSL environment.

### Environment Variables
- **PATH**: Includes custom bin directories.
- **BROWSER**: Set to use wslview.

### Other Settings
- Unalias `code` if it exists.
- Add autocompletion for kubectl.
- Powerlevel10k instant prompt.

## How to Use

1. Clone this repository:
    ```sh
    git clone git@github.com:jesposito/my-zsh-setup.git
    ```

2. Run the setup script:
    ```sh
    cd my-zsh-setup
    ./setup.sh
    ```

This will install all necessary dependencies and set up your zsh environment with the provided configurations.
