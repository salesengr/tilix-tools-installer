# Security Tools Installer

**Version:** 1.3.0
**Release Date:** January 2026

A comprehensive user-space installation system for OSINT/CTI/PenTest security tools that requires **no sudo access**. Installs 37+ tools including runtimes, build tools, and security applications.

**Architecture:** Modular design with 11 focused library modules for maintainability and extensibility.

## 🎯 Features

- ✅ **No sudo required** - Complete user-space installation
- ✅ **37+ security tools** - OSINT, CTI, reconnaissance, and pentesting
- ✅ **4 language runtimes** - Go, Node.js, Rust, Python venv
- ✅ **Interactive menu** - Easy point-and-click installation
- ✅ **CLI support** - Script automation and batch installation
- ✅ **XDG compliant** - Follows Linux filesystem standards
- ✅ **Comprehensive logging** - Track all installations with detailed logs
- ✅ **Dependency resolution** - Automatic prerequisite installation
- ✅ **Error handling** - Retry logic and robust error recovery

## 📦 What Gets Installed

### Tool Summary

| Category | Count | Key Tools |
|----------|-------|-----------|
| **Build Tools & Runtimes** | 5 | CMake, GitHub CLI, Go, Node.js, Rust |
| **Python Tools** | 12 | sherlock, holehe, theHarvester, sublist3r, nuclei |
| **Go Tools** | 8 | gobuster, ffuf, subfinder, nuclei, virustotal |
| **Node.js Tools** | 3 | trufflehog, git-hound, jwt-cracker |
| **Rust Tools** | 8 | feroxbuster, rustscan, ripgrep, fd, bat |
| **Total** | **37** | Complete OSINT/CTI/PenTest toolkit |

For complete tool descriptions, usage examples, and update instructions, see 📖 **[Security Tools Reference](docs/TOOLS_REFERENCE.md)**.

## 🚀 Quick Start

Choose your preferred installation method:

### Method 1: One-Command Bootstrap (Recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/tilix-tools-installer/main/installer.sh | bash
```

This single command will:
1. Clone the repository to `~/Documents/tilix-tools-installer` (if needed)
2. Set up XDG environment
3. Reload shell configuration
4. Launch interactive installation menu

**Note:** Requires `git` and `curl` to be installed.

---

### Method 2: Manual Setup

#### 1. Clone Repository
```bash
cd ~/Documents
git clone https://github.com/YOUR_USERNAME/tilix-tools-installer.git
cd tilix-tools-installer
```

#### 2. Run Bootstrap
```bash
bash installer.sh
```

This will:
1. Set up XDG environment
2. Reload shell configuration
3. Open interactive installation menu

---

### Method 3: Step-by-Step (Advanced Users)

If you prefer manual control over each step:

#### 1. Setup XDG Environment (First Time Only)

```bash
bash xdg_setup.sh
source ~/.bashrc  # or source ~/.zshrc for zsh
```

This creates the directory structure following XDG Base Directory standards.

#### 2. Install Tools

**Interactive Mode (Recommended)**
```bash
bash install_security_tools.sh
```

Then use the menu to select tools:
- Individual tools by number
- Categories (Python, Go, Node, Rust)
- Install everything (option 30)

**Command Line Mode**
```bash
# Install specific tools
bash install_security_tools.sh sherlock gobuster nuclei

# Install entire categories
bash install_security_tools.sh --python-tools
bash install_security_tools.sh --go-tools
bash install_security_tools.sh --node-tools
bash install_security_tools.sh --rust-tools

# Install everything (30-60 minutes)
bash install_security_tools.sh all

# Dry run (preview what would be installed)
bash install_security_tools.sh --dry-run sherlock gobuster
```

> After installations finish, run `source ~/.bashrc` (or open a new shell) so the new binaries are immediately on your PATH. The installer now prints this reminder whenever the menu refreshes or a CLI run completes.

### 3. Verify Installation

```bash
bash scripts/test_installation.sh
```

### 4. Analyze & Optimize Installation (Optional)

```bash
# Generate comprehensive diagnostic report
bash scripts/diagnose_installation.sh

# View specific sections
bash scripts/diagnose_installation.sh --inventory        # List installed tools
bash scripts/diagnose_installation.sh --disk-usage       # Analyze disk space
bash scripts/diagnose_installation.sh --build-artifacts  # Find cleanable files
bash scripts/diagnose_installation.sh --cleanup-plan     # Show safe cleanup commands

# Execute safe cleanup to recover disk space
bash scripts/diagnose_installation.sh --cleanup
```

The diagnostic script helps you:
- 📊 **Inventory:** See what's installed and tool versions
- 💾 **Disk Analysis:** Identify space usage by category (~1-1.5 GB can be recovered)
- 🧹 **Cleanup:** Safely remove build artifacts, caches, and archives
- ✅ **XDG Compliance:** Verify directory structure follows standards
- 🔍 **Troubleshooting:** Diagnose test failures and environment issues

**Note:** Requires Bash 4.0+ (available in Docker environments, not macOS system bash)

## 📁 Directory Structure

After installation, your files will be organized as follows:

```
~/.local/
├── bin/                    # User executables (tools, wrappers)
├── lib/                    # User libraries
├── share/                  # User data
│   └── virtualenvs/        # Python virtual environments
│       └── tools/          # Security tools venv
└── state/                  # Application state & logs
    └── install_tools/
        └── logs/           # Installation logs

~/opt/
├── go/                     # Go installation
├── gopath/                 # Go workspace
│   └── bin/               # Compiled Go tools
├── node/                   # Node.js installation
└── src/                    # Source code downloads

~/.local/share/cargo/       # Rust installation
└── bin/                    # Compiled Rust tools
```

## 📚 Documentation

Comprehensive guides are available in the `docs/` directory:

- **[Script Usage](docs/script_usage.md)** - How to run the setup, installer, and tests
- **[Diagnostic Script Guide](docs/DIAGNOSTIC_USAGE.md)** - Analyze, optimize, and troubleshoot installations
- **[XDG Setup Guide](docs/xdg_setup.md)** - Environment configuration explained
- **[Extending the Script](docs/EXTENDING_THE_SCRIPT.md)** - Add your own tools
- **[Compatibility Analysis](docs/USER_SPACE_COMPATIBILITY.md)** - Technical deep-dive
- **[Tool Installation Summary](docs/tool_installation_summary.md)** - Where each tool lands on disk

## 💾 Installation Requirements

| Requirement | Details |
|-------------|---------|
| **Disk Space** | 1.3-2 GB total (Rust: 800MB, Go: 120MB, Python: 80MB, Node.js: 50MB, Tools: ~200MB) |
| **Time** | 30-60 minutes (complete installation), Rust tools take 20-30 min |
| **OS** | Ubuntu 20.04+ or compatible Linux distribution |
| **Python** | 3.8+ (usually pre-installed) |
| **Permissions** | Regular user account (no sudo required) |
| **Network** | Internet connection for downloads |

*Note: Rust is the largest and slowest component. You can skip Rust tools if space/time is limited.*

## 🔧 Quick Usage Examples

```bash
# Username search across 300+ platforms
sherlock john_doe

# Fast directory bruteforcing
gobuster dir -u https://target.com -w wordlist.txt

# Subdomain discovery
subfinder -d target.com -o subdomains.txt

# Vulnerability scanning with 5,000+ templates
nuclei -u https://target.com

# Fast port scanning
rustscan -a target.com
```

For complete usage examples for all 37 tools, see 📖 **[Security Tools Reference](docs/TOOLS_REFERENCE.md)**.

## 🔄 Updating Tools

### Python Tools
```bash
source ~/.local/share/virtualenvs/tools/bin/activate
pip install --upgrade sherlock-project holehe socialscan
deactivate
```

### Go Tools
```bash
go install github.com/OJ/gobuster/v3@latest
go install github.com/ffuf/ffuf/v2@latest
```

### Rust Tools
```bash
cargo install ripgrep --force
cargo install fd-find --force
```

## 🐛 Troubleshooting

### Tools not found after installation
```bash
source ~/.bashrc  # Reload environment
```

### Python import errors
```bash
# Check venv exists
ls -la ~/.local/share/virtualenvs/tools/

# Manually activate and test
source ~/.local/share/virtualenvs/tools/bin/activate
sherlock --help
deactivate
```

### Go tools not in PATH
```bash
# Check GOPATH is set
echo $GOPATH

# Verify tools installed
ls -la ~/opt/gopath/bin/
```

### Download failures
Check the detailed log files in `~/.local/state/install_tools/logs/` for specific errors.


## 🔐 Security Notes

- All tools install to user space (`~/.local/`, `~/opt/`)
- No system files are modified
- No privileged operations are performed
- Virtual environments isolate Python dependencies
- Each language runtime is self-contained

## 📊 Installation Logs

All installations are logged to:
- **Individual tool install logs:** `~/.local/state/install_tools/logs/[tool]-[timestamp].log`
- **History:** `~/.local/state/install_tools/installation_history.log`

View recent installations:
```bash
tail -n 50 ~/.local/state/install_tools/installation_history.log
```

## 🤝 Contributing

To add new tools to the installer:

1. Read the [Extending the Script](docs/EXTENDING_THE_SCRIPT.md) guide
2. Add tool definition to `define_tools()`
3. Create installation function
4. Add to appropriate category array
5. Test thoroughly with `--dry-run`

### Agent-Assisted Development

This project uses 7 specialized AI agents to streamline development, testing, and security auditing. Agents enforce project conventions automatically and reduce development time by 60-70%.

For agent workflows and usage patterns, see 📖 **[Agent Usage Guide](.claude/agents/AGENT_USAGE.md)**.

## 📝 Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

## 📄 License

This project is provided as-is for educational and professional security testing purposes. Always obtain proper authorization before using security tools on systems you don't own or have explicit permission to test.

## 🙏 Credits

Built for user-space security tool installation without requiring root privileges. Designed for:
- Security researchers
- Penetration testers
- OSINT investigators
- CTI analysts
- DevOps engineers in restricted environments

## 💬 Support

- Check the documentation in `docs/`
- Review installation logs for errors
- Run `bash scripts/test_installation.sh` to verify setup
- Use `--dry-run` to preview installations

---

**Ready to get started?**

```bash
# 1. Setup environment
bash xdg_setup.sh && source ~/.bashrc

# 2. Install tools
bash install_security_tools.sh

# 3. Start using them!
sherlock --help
gobuster --help
nuclei --help
```
