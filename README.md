# Security Tools Installer

**Version:** 1.3.3
**Release Date:** Feb 25 2026

A comprehensive user-space installation system for OSINT/CTI/PenTest security tools that requires **no sudo access**. Installs 37+ tools including runtimes, build tools, and security applications.

**Python support:** Validated with Python **3.13** (matching `salesengr/tilix-app:latest`, currently Python 3.13.8).

**Architecture:** Modular design with 11 focused library modules for maintainability and extensibility.

## 🎯 Features

- ✅ **No sudo required** - Complete user-space installation
- ✅ **37+ security tools** - OSINT, CTI, reconnaissance, and pentesting
- ✅ **3 managed runtimes + Python venv** - Node.js, Rust, Python venv (uses system Go for Go tools)
- ✅ **Interactive menu** - Easy point-and-click installation
- ✅ **CLI support** - Script automation and batch installation
- ✅ **XDG compliant** - Follows Linux filesystem standards
- ✅ **Comprehensive logging** - Track all installations with detailed logs
- ✅ **Dependency resolution** - Automatic prerequisite installation
- ✅ **Error handling** - Retry logic and robust error recovery
- ✅ **Shellcheck-ready design** - Scripts are written to be shellcheck-friendly (run locally to verify in your environment)

## 📦 What Gets Installed

### Build Tools & Runtimes
- **CMake** 3.28.1 - Build system generator
- **GitHub CLI** 2.53.0 - Manage GitHub from the terminal
- **Go** (system prerequisite) - Used to build/install Go-based tools
- **Node.js** 20.10.0 - JavaScript runtime
- **Rust** (latest) - Systems programming language

### Python Tools (12 tools)
**OSINT/Reconnaissance:**
- sherlock - Username search across 300+ social networks
- holehe - Email verification across websites
- socialscan - Username/email availability checker
- theHarvester - Multi-source OSINT gathering
- spiderfoot - Automated OSINT collection
- sublist3r - Subdomain enumeration
- photon - Fast web crawler

**Cyber Threat Intelligence:**
- shodan - Internet device search engine CLI
- censys - Internet-wide scanning data
- yara - Pattern matching for malware research
- h8mail - Email OSINT and breach hunting

### Go Tools (8 tools)
**Active Reconnaissance:**
- gobuster - Directory/DNS/vhost bruteforcing
- ffuf - Fast web fuzzer
- httprobe - HTTP/HTTPS service probe
- nuclei - Vulnerability scanner

**Passive Reconnaissance:**
- waybackurls - Wayback Machine URL fetcher
- assetfinder - Domain/subdomain finder
- subfinder - Subdomain discovery tool

**CTI:**
- virustotal - VirusTotal CLI

### Node.js Tools (3 tools)
- trufflehog - Secret scanning in git repositories
- git-hound - GitHub reconnaissance
- jwt-cracker - JWT token analysis

### Rust Tools (8 tools)
**Reconnaissance:**
- feroxbuster - Fast content discovery
- rustscan - Modern fast port scanner

**Utilities:**
- ripgrep - Fast recursive grep
- fd - Fast file finder
- bat - Cat with syntax highlighting
- sd - Intuitive find & replace
- tokei - Code statistics analyzer
- dog - Modern DNS client

## 🚀 Quick Start

Choose your preferred installation method:

### Method 1: One-Command Bootstrap

**Two-Step (Recommended for interactive menu):**
```bash
curl -fsSL https://raw.githubusercontent.com/salesengr/tilix-tools-installer/main/installer.sh -o installer.sh
bash installer.sh
```

**One-Step (Note: interactive menu not available when piped):**
```bash
curl -fsSL https://raw.githubusercontent.com/salesengr/tilix-tools-installer/main/installer.sh | bash
```

This will:
1. Clone the repository (if needed)
2. Set up XDG environment
3. Reload shell configuration
4. Launch interactive installation menu (two-step only)

**Note:** Requires `git` and `curl` to be installed. For the interactive menu, use the two-step approach.

---

### Method 2: Manual Setup

#### 1. Clone Repository
```bash
git clone https://github.com/salesengr/tilix-tools-installer.git
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
- Install bulk categories from the menu (options 34-37)

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
├── gopath/                 # Go workspace (requires system Go)
│   └── bin/               # Compiled Go tools
├── node/                   # Node.js installation
└── src/                    # Source code downloads

~/.local/share/cargo/       # Rust installation
└── bin/                    # Compiled Rust tools
```

## 📚 Documentation

Comprehensive guides are available in the `docs/` directory:

- **[XDG Setup Guide](docs/xdg_setup.md)** - Environment configuration explained
- **[Extending the Script](docs/EXTENDING_THE_SCRIPT.md)** - Add your own tools
- **[Tool Installation Summary](docs/tool_installation_summary.md)** - Where each tool lands on disk
- **[Node Audit Coverage](docs/security/node-audit.md)** - npm/fallback audit process and limitations

## 💾 Disk Space Requirements

| Component | Size |
|-----------|------|
| CMake | ~50 MB |
| GitHub CLI | ~90 MB |
| Go installation | ~120 MB |
| Node.js installation | ~50 MB |
| Rust installation | ~800 MB |
| Python venv + tools | ~80 MB |
| Go tools (compiled) | ~100 MB |
| Node.js tools | ~80 MB |
| Rust tools (compiled) | ~30 MB |
| **Total** | **~1.3-2 GB** |

*Note: Rust is the largest component. You can skip Rust tools if space is limited.*

## ⏱️ Installation Time

| Installation Type | Time Estimate |
|-------------------|---------------|
| XDG setup only | 1 minute |
| Python tools only | 5-10 minutes |
| Go tools only | 5-15 minutes |
| Node.js tools only | 2-5 minutes |
| Rust tools only | 20-30 minutes* |
| **Everything** | **30-60 minutes** |

*Rust tools compile from source and take significantly longer.*

## 🔧 Usage Examples

### Python Tools
```bash
# Username search
sherlock john_doe

# Email verification
holehe target@example.com

# Breach hunting
h8mail -t victim@example.com

# Subdomain enumeration
sublist3r -d example.com
```

### Go Tools
```bash
# Directory bruteforce
gobuster dir -u https://target.com -w wordlist.txt

# Fast fuzzing
ffuf -u https://target.com/FUZZ -w wordlist.txt

# Subdomain discovery
subfinder -d target.com -o subdomains.txt

# Vulnerability scanning
nuclei -u https://target.com
```

### Rust Tools
```bash
# Fast port scan
rustscan -a target.com

# Content discovery
feroxbuster -u https://target.com

# Fast grep
rg "pattern" /path/to/search
```

### Utility Tools
```bash
# Download a file (single connection)
aria2c https://example.com/file.iso

# Download with 8 parallel connections (much faster for large files)
aria2c --split=8 --max-connection-per-server=8 https://example.com/large.iso

# Download to a specific directory with a custom filename
aria2c --dir=/tmp --out=myfile.iso https://example.com/file.iso

# Download multiple files from a list
aria2c --input-file=urls.txt

# Resume an interrupted download
aria2c --continue=true https://example.com/large.iso

# Run as a daemon with JSON-RPC interface (for use with frontends)
aria2c --enable-rpc --rpc-listen-all=true --daemon=true
```

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

## 📋 Requirements

- **OS:** Ubuntu 20.04+ (or compatible Linux distribution)
- **Python:** 3.8+ (usually pre-installed)
- **Disk Space:** 2GB free space
- **Network:** Internet connection for downloads
- **Permissions:** Regular user account (no sudo required)

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

## 📝 Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed version history.

## 📄 License

This project is provided as-is for educational and professional security testing purposes. Always obtain proper authorization before using security tools on systems you don't own or have explicit permission to test.

## 💬 Support

- Check the documentation in `docs/`
- Review installation logs for errors
- Validate setup with dry-run: `bash install_security_tools.sh --dry-run all`
- If installed locally, run `make lint` / `make fmt-check` for shell quality checks
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
