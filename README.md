# Modern Zsh Setup

[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/jesposito/my-zsh-setup)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash-orange.svg)](https://www.gnu.org/software/bash/)

A robust, idempotent, cross-platform zsh configuration installer that sets up a beautiful and functional terminal environment.

## ✨ Features

### 🔄 **Robust & Idempotent**
- Safe to run multiple times
- Automatic backup of existing configurations
- Comprehensive error handling and validation
- Dry-run mode to preview changes

### 🌍 **Cross-Platform**
- **macOS** (with Homebrew)
- **Linux** (Ubuntu/Debian, Fedora, Arch)
- **WSL1/WSL2** with automatic Windows integration detection

### 🎨 **Complete Setup**
- **[Zsh](https://www.zsh.org/)** - Modern shell with powerful features
- **[Oh My Zsh](https://ohmyz.sh/)** - Framework for managing zsh configuration
- **[Powerlevel10k](https://github.com/romkatv/powerlevel10k)** - Beautiful, fast prompt theme
- **Plugins**:
  - [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
  - [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- **[Nerd Fonts](https://www.nerdfonts.com/)** - MesloLGS NF for icons
- **Optional**: Kubernetes tools (kubectl, helm, kubectx, kubens)

### ⚙️ **Highly Customizable**
- Command-line flags for selective installation
- Environment variables for configuration
- Non-interactive mode for automation
- Configurable via dotfiles

## 🚀 Quick Start

### One-Line Install

```bash
git clone https://github.com/jesposito/my-zsh-setup.git
cd my-zsh-setup
./setup.sh
```

### Dry Run (Preview Changes)

```bash
./setup.sh --dry-run
```

### Non-Interactive Install

```bash
./setup.sh --non-interactive
```

## 📋 Requirements

- **Git**
- **curl** or **wget**
- One of: `apt`, `dnf`, `pacman`, or `brew` (Homebrew)
- **sudo** access (for package installation)

## 🎯 Usage

### Basic Usage

```bash
./setup.sh [OPTIONS]
```

### Command-Line Options

| Option | Description |
|--------|-------------|
| `-h, --help` | Show help message |
| `-v, --verbose` | Enable verbose output |
| `-n, --dry-run` | Preview changes without making them |
| `-y, --non-interactive` | Run without prompts (use defaults) |
| `--skip-omz` | Skip Oh My Zsh installation |
| `--skip-p10k` | Skip Powerlevel10k installation |
| `--skip-plugins` | Skip plugin installation |
| `--skip-fonts` | Skip font installation |
| `--skip-backup` | Skip backing up existing configs |
| `--install-k8s` | Install Kubernetes tools |

### Environment Variables

You can also configure the installer using environment variables:

```bash
# Disable specific components
INSTALL_OMZ=false ./setup.sh

# Install with Kubernetes tools
INSTALL_K8S_TOOLS=true ./setup.sh

# Verbose dry run
VERBOSE=true DRY_RUN=true ./setup.sh
```

| Variable | Default | Description |
|----------|---------|-------------|
| `INSTALL_OMZ` | `true` | Install Oh My Zsh |
| `INSTALL_P10K` | `true` | Install Powerlevel10k |
| `INSTALL_PLUGINS` | `true` | Install zsh plugins |
| `INSTALL_FONTS` | `true` | Install Nerd Fonts |
| `INSTALL_K8S_TOOLS` | `false` | Install Kubernetes tools |
| `SKIP_BACKUP` | `false` | Skip configuration backups |
| `VERBOSE` | `false` | Verbose output |
| `DRY_RUN` | `false` | Dry run mode |
| `NON_INTERACTIVE` | `false` | Non-interactive mode |

## 📚 Examples

### Minimal Installation (No Fonts)

```bash
./setup.sh --skip-fonts
```

### Install with Kubernetes Tools

```bash
./setup.sh --install-k8s
```

### Automated/CI Installation

```bash
INSTALL_FONTS=false INSTALL_K8S_TOOLS=false ./setup.sh --non-interactive
```

### Preview What Will Be Installed

```bash
./setup.sh --dry-run --verbose
```

### Custom Installation

```bash
# Install only zsh with custom plugins, skip theme
INSTALL_P10K=false ./setup.sh --skip-fonts
```

## 🛠️ What Gets Installed

### Core Components

1. **Zsh** - Modern shell with advanced features
2. **Oh My Zsh** - Plugin and theme framework
3. **Powerlevel10k** - Fast, customizable prompt theme
4. **MesloLGS NF Font** - Nerd Font with icon support

### Included Plugins

- `git` - Git integration and aliases
- `docker` - Docker command completion
- `docker-compose` - Docker Compose integration
- `kubectl` - Kubernetes CLI integration (if kubectl installed)
- `npm` - Node package manager shortcuts
- `vscode` - VSCode integration
- `zsh-syntax-highlighting` - Fish-like syntax highlighting
- `zsh-autosuggestions` - Fish-like autosuggestions

### Pre-Configured Aliases

#### Navigation
```bash
..      # cd ..
...     # cd ../..
....    # cd ../../..
~       # cd ~
home    # cd ~
```

#### Git
```bash
ga      # git add
gc      # git commit
gcm     # git commit -m
gp      # git push
gl      # git pull
gst     # git status
gco     # git checkout
glog    # git log --oneline --graph --decorate
```

#### Docker
```bash
dps     # docker ps
dpa     # docker ps -a
di      # docker images
dlog    # docker logs
dexec   # docker exec -it
```

#### Kubernetes (if installed)
```bash
k       # kubectl
kx      # kubectx
kns     # kubens
```

### Custom Functions

- `mkcd <dir>` - Create directory and cd into it
- `extract <file>` - Extract various archive formats
- `code` - Open VSCode (WSL-aware on Windows)
- `open` - Open Windows Explorer (WSL only)

## 🖥️ Platform-Specific Features

### macOS
- Uses Homebrew for package installation
- Installs fonts via Homebrew Cask

### Linux
- Supports apt, dnf, and pacman
- Downloads fonts to `~/.local/share/fonts`

### WSL (Windows Subsystem for Linux)
- Automatically detects WSL environment
- Configures VSCode integration with Windows
- Sets up Windows Explorer integration
- Browser configuration for wslview

## 🔧 Post-Installation

### 1. Restart Your Terminal

```bash
exec zsh
```

### 2. Configure Powerlevel10k

Run the configuration wizard:

```bash
p10k configure
```

### 3. Configure Your Terminal Font

Set your terminal to use **MesloLGS NF** font:

- **iTerm2** (macOS): Preferences → Profiles → Text → Font
- **Terminal.app** (macOS): Preferences → Profiles → Font
- **Windows Terminal**: Settings → Profiles → Appearance → Font face
- **GNOME Terminal**: Preferences → Profiles → Text → Custom font

### 4. Customize Your Config

Edit `~/.zshrc` to add your personal customizations:

```bash
vim ~/.zshrc
# or
code ~/.zshrc
```

## 🔄 Backup & Restore

### Automatic Backups

The installer automatically backs up existing configurations to:

```
~/.zsh-setup-backups/YYYYMMDD-HHMMSS/
```

### Restore Previous Configuration

```bash
# Find your backup
ls -la ~/.zsh-setup-backups/

# Restore
cp ~/.zsh-setup-backups/20260105-123456/.zshrc ~/.zshrc
```

### Skip Backups

```bash
./setup.sh --skip-backup
```

## 🧪 Testing

### Run All Tests

```bash
cd tests
./run_tests.sh
```

### Individual Tests

#### ShellCheck (Linting)

```bash
shellcheck setup.sh
```

#### Bats (Functional Tests)

```bash
bats tests/test_setup.bats
```

#### Syntax Validation

```bash
bash -n setup.sh
```

### Install Test Dependencies

#### macOS

```bash
brew install shellcheck bats-core
```

#### Ubuntu/Debian

```bash
sudo apt install shellcheck bats
```

#### Fedora

```bash
sudo dnf install ShellCheck bats
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Setup

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`./tests/run_tests.sh`)
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## 📝 Configuration Files

After installation, you'll have:

- `~/.zshrc` - Main zsh configuration
- `~/.p10k.zsh` - Powerlevel10k theme configuration
- `~/.oh-my-zsh/` - Oh My Zsh installation directory
- `~/.zsh-setup-backups/` - Backup directory

## 🐛 Troubleshooting

### Zsh Not Default Shell

Manually set zsh as default:

```bash
chsh -s $(which zsh)
```

### Fonts Not Showing

1. Make sure your terminal is using **MesloLGS NF** font
2. Restart your terminal
3. Run `p10k configure` again

### Plugins Not Loading

Check that plugins are sourced in `~/.zshrc`:

```bash
grep "plugins=" ~/.zshrc
```

### Oh My Zsh Installation Failed

Try installing manually:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

### Permission Denied

Make sure the script is executable:

```bash
chmod +x setup.sh
```

## 🔒 Security

- All downloads are from official sources
- Uses HTTPS for all remote operations
- No credentials or sensitive data stored
- Safe to run with `--dry-run` first

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Oh My Zsh](https://ohmyz.sh/) - Zsh framework
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) - Prompt theme
- [zsh-users](https://github.com/zsh-users) - Plugin authors
- [Nerd Fonts](https://www.nerdfonts.com/) - Font developers

## 🌟 Star History

If you find this useful, please consider giving it a star! ⭐

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/jesposito/my-zsh-setup/issues)
- **Discussions**: [GitHub Discussions](https://github.com/jesposito/my-zsh-setup/discussions)

---

**Made with ❤️ by [jesposito](https://github.com/jesposito)**

**Enhanced with 🤖 by [Claude Code](https://claude.com/claude-code)**
