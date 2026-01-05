# My Zsh Setup

[![Version](https://img.shields.io/badge/version-2.0.0-blue.svg)](https://github.com/jesposito/my-zsh-setup)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/shell-bash-orange.svg)](https://www.gnu.org/software/bash/)

A zsh configuration installer that attempts to set up a nice terminal environment across different platforms. Originally created for my own use, but might be helpful for others.

> **⚠️ Note**: This is a relatively new rewrite (v2.0.0) and needs more real-world testing across different environments. If you encounter issues, please [open an issue](https://github.com/jesposito/my-zsh-setup/issues) or contribute a fix!

## ✨ What It Does

### 🔄 **Tries to be Safe**
- Attempts to run multiple times without breaking things (idempotent)
- Backs up existing configurations automatically
- Includes error handling and validation
- Dry-run mode to see what would happen

### 🌍 **Cross-Platform Goals**
- **macOS** (with Homebrew)
- **Linux** (Ubuntu/Debian, Fedora, Arch)
- **WSL1/WSL2** with Windows integration attempts

*Note: Primarily tested on WSL/Ubuntu. Other platforms need more testing.*

### 🎨 **What Gets Installed**
- **[Zsh](https://www.zsh.org/)** - Shell with nice features
- **[Oh My Zsh](https://ohmyz.sh/)** - Framework for managing zsh
- **[Powerlevel10k](https://github.com/romkatv/powerlevel10k)** - Fast, customizable prompt theme
- **Plugins**:
  - [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
  - [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
- **[Nerd Fonts](https://www.nerdfonts.com/)** - MesloLGS NF for icons
- **Optional**: Kubernetes tools (kubectl, helm, kubectx, kubens)

### ⚙️ **Customization Options**
- Command-line flags for selective installation
- Environment variables for configuration
- Non-interactive mode for automation

## 🚀 Quick Start

> **⚠️ Recommended**: Run with `--dry-run` first to see what it will do!

### Preview First (Recommended)

```bash
git clone https://github.com/jesposito/my-zsh-setup.git
cd my-zsh-setup
./setup.sh --dry-run
```

### Standard Install

```bash
./setup.sh
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

**Contributions are very welcome!** This script needs more testing across different environments and setups. If you:

- Find a bug → [Open an issue](https://github.com/jesposito/my-zsh-setup/issues)
- Have a platform it doesn't work on → Please help test/fix it
- Want to add a feature → Pull requests appreciated
- Have improvement ideas → Let's discuss them

### How to Contribute

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/your-feature`)
3. Make your changes
4. Test thoroughly (especially `./setup.sh --dry-run`)
5. Run tests if possible (`./tests/run_tests.sh`)
6. Commit your changes
7. Push to the branch and open a Pull Request

### Testing Help Needed

Especially looking for testing on:
- **macOS** (Intel and Apple Silicon)
- **Fedora/RHEL** (dnf package manager)
- **Arch Linux** (pacman package manager)
- **Different WSL versions and configurations**

Even just trying it out and reporting success/failure helps!

## 📝 Configuration Files

After installation, you'll have:

- `~/.zshrc` - Main zsh configuration
- `~/.p10k.zsh` - Powerlevel10k theme configuration
- `~/.oh-my-zsh/` - Oh My Zsh installation directory
- `~/.zsh-setup-backups/` - Backup directory

## 🐛 Troubleshooting

### Something Broke?

First, check your backups:

```bash
ls -la ~/.zsh-setup-backups/
# Restore if needed:
cp ~/.zsh-setup-backups/YYYYMMDD-HHMMSS/.zshrc ~/.zshrc
```

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

### Still Having Issues?

Please [open an issue](https://github.com/jesposito/my-zsh-setup/issues) with:
- Your OS and version
- Error messages
- Output from `./setup.sh --verbose --dry-run`

## 🔒 Security Notes

- Downloads are from official sources (Oh My Zsh, Powerlevel10k, etc.)
- Uses HTTPS for remote operations
- No credentials or sensitive data stored
- **Always review scripts before running them!**
- Use `--dry-run` first to see what it will do

If you spot any security issues, please [report them](https://github.com/jesposito/my-zsh-setup/issues).

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Credits

This builds on the excellent work of:
- [Oh My Zsh](https://ohmyz.sh/) - Zsh framework
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k) - Prompt theme by romkatv
- [zsh-users](https://github.com/zsh-users) - Plugin authors
- [Nerd Fonts](https://www.nerdfonts.com/) - Font developers

## 📞 Getting Help

- **Issues**: [GitHub Issues](https://github.com/jesposito/my-zsh-setup/issues)
- **Discussions**: [GitHub Discussions](https://github.com/jesposito/my-zsh-setup/discussions)

## 💭 About

Originally created for my own use to quickly set up zsh on new machines. The v2.0.0 rewrite aimed to make it more portable and useful for others, but it still needs more testing across different environments.

If this helps you, great! If you find issues or have improvements, please contribute back.

---

**Made by [jesposito](https://github.com/jesposito)**

**v2.0.0 rewrite with 🤖 [Claude Code](https://claude.com/claude-code)**
