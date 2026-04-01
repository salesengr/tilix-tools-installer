# Security Tools Installer

**Version:** 1.4.0
**Release Date:** April 1, 2026

A comprehensive user-space installation system for OSINT/CTI/PenTest security tools that requires **no sudo access**. Installs 41+ tools including runtimes, build tools, security applications, and web automation.

**Python support:** Validated with Python **3.13** (Python 3.13.8). No virtual environment required — tools install via `pip install --user` using the system Python.

**Architecture:** Modular design with 11 focused library modules for maintainability and extensibility.

## 🎯 Features

- ✅ **No sudo required** - Complete user-space installation
- ✅ **41+ security tools** - OSINT, CTI, reconnaissance, pentesting, and web automation
- ✅ **3 managed runtimes** - Node.js, Rust, system Go/Python (pip install --user, no venv)
- ✅ **Pre-built binaries** - Fast installs via GitHub releases; compile-from-source as fallback only
- ✅ **Web tools** - SeleniumBase, Playwright, Yandex Browser, Tor Browser
- ✅ **Interactive menu** - Easy point-and-click installation
- ✅ **CLI support** - Script automation and batch installation
- ✅ **XDG compliant** - Follows Linux filesystem standards
- ✅ **Comprehensive logging** - Track all installations with detailed logs
- ✅ **Dependency resolution** - Automatic prerequisite installation
- ✅ **Error handling** - Retry logic and robust error recovery
- ✅ **Shellcheck-ready design** - Scripts are written to be shellcheck-friendly (run locally to verify in your environment)

## 📦 What Gets Installed

Tools are organized by use-case. Install an entire category with one command.

### Passive OSINT (12 tools) — `--osint-tools`
- **sherlock** - Username search across 300+ social networks
- **holehe** - Email verification across websites
- **socialscan** - Username/email availability checker
- **theHarvester** - Multi-source OSINT gathering
- **spiderfoot** - Automated OSINT collection
- **photon** - Fast web crawler
- **wappalyzer** - Technology profiler
- **h8mail** - Email OSINT and breach hunting
- **waybackurls** - Wayback Machine URL fetcher
- **assetfinder** - Domain/subdomain finder
- **subfinder** - Subdomain discovery tool
- **git-hound** - GitHub reconnaissance

### Domain & Subdomain Enumeration (3 tools) — `--domain-tools`
- **sublist3r** - Subdomain enumeration
- **gobuster** - Directory/DNS/vhost bruteforcing
- **ffuf** - Fast web fuzzer

### Active Recon & Scanning (4 tools) — `--recon-tools`
- **httprobe** - HTTP/HTTPS service probe
- **rustscan** - Modern fast port scanner
- **feroxbuster** - Fast content discovery
- **nuclei** - Vulnerability scanner

### Cyber Threat Intelligence (5 tools) — `--cti-tools`
- **shodan** - Internet device search engine CLI
- **censys** - Internet-wide scanning data
- **yara** - Pattern matching for malware research
- **trufflehog** - Secret scanning in git repositories
- **virustotal** (`vt`) - VirusTotal CLI

### Security Testing (1 tool)
- **jwt-cracker** - JWT token analysis

### Utilities (6 tools) — `--utility-tools`
- **ripgrep** (`rg`) - Fast recursive grep
- **fd** - Fast file finder
- **bat** - Cat with syntax highlighting
- **sd** - Intuitive find & replace
- **dog** - Modern DNS client
- **aria2** - Multi-protocol download utility (HTTP/FTP/BitTorrent)

### Web Tools (4 tools) — `--web-tools`
- **SeleniumBase** - Browser automation with UC/CDP modes for bypassing bot-detection & CAPTCHAs
- **Playwright** - Cross-browser automation (uses system Chrome — no separate browser download)
- **Yandex Browser** - Chromium-based browser for Russian-language OSINT (amd64 only)
- **Tor Browser** - Anonymous browsing via the Tor network

### Build Tools & Runtimes
- **CMake** - Build system generator
- **GitHub CLI** - Manage GitHub from the terminal
- **Go Runtime** - Auto-installed to `~/opt/go` if not present system-wide
- **Node.js** - Uses system Node.js (image-bundled); tarball fallback only
- **Rust** - Installed via rustup for tools that require cargo compile

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
- Install bulk categories from the menu (options 42-48)

**Command Line Mode**
```bash
# Install specific tools
bash install_security_tools.sh sherlock gobuster nuclei

# Install by use-case category (v1.4.0+)
bash install_security_tools.sh --osint-tools
bash install_security_tools.sh --domain-tools
bash install_security_tools.sh --recon-tools
bash install_security_tools.sh --cti-tools
bash install_security_tools.sh --utility-tools
bash install_security_tools.sh --web-tools

# Install everything
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
│   └── python3.13/         # Python tools (pip --user packages)
└── state/                  # Application state & logs
    └── install_tools/
        └── logs/           # Installation logs

~/opt/
├── gopath/                 # Go workspace (requires system Go)
│   └── bin/               # Compiled Go tools
├── node/                   # Node.js (only if system Node absent)
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

| Component | Size | Notes |
|-----------|------|-------|
| CMake | ~50 MB | |
| GitHub CLI | ~90 MB | |
| Rust toolchain | ~800 MB | Only if Rust tools selected |
| Go runtime | ~120 MB | Only if not present in system |
| Node.js | ~0 MB | Uses system Node; tarball fallback ~50 MB |
| Python tools (pip --user) | ~80 MB | No venv overhead |
| Go tools (pre-built binaries) | ~100 MB | Downloaded, not compiled |
| Rust tools (pre-built binaries) | ~30 MB | Downloaded, not compiled |
| Web tools | ~120 MB | Tor Browser + SeleniumBase/Playwright packages |
| **Total (typical)** | **~400-800 MB** | Depends on categories selected |

*Note: Pre-built binaries used where available — no long compile times for most tools.*

## ⏱️ Installation Time

| Flag | Time Estimate | Notes |
|------|---------------|-------|
| XDG setup only | ~1 min | |
| `--osint-tools` | ~3 min | Pre-built binaries |
| `--domain-tools` | ~13 sec | Pre-built binaries |
| `--recon-tools` | ~6 min | Pre-built + some cargo |
| `--cti-tools` | ~4 min | pip --user + pre-built |
| `--utility-tools` | ~2 min | Pre-built binaries |
| `--web-tools` | ~5 min | pip install + apt |
| **Everything** | **~20-30 min** | **vs 60+ min before v1.4.0** |

## 🔧 Usage Examples

### Passive OSINT
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

### Domain & Active Recon
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

### Active Recon
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

### Web Tools

The Tilix image ships **Google Chrome** at `/usr/bin/google-chrome`. Check your version with `google-chrome --version`. All web automation tools use it directly — no separate browser download needed.

#### Launching Chrome Directly
```bash
# Headless (no display required)
google-chrome --headless --no-sandbox --disable-dev-shm-usage --dump-dom https://example.com

# Screenshot
google-chrome --headless --no-sandbox --screenshot=/tmp/screenshot.png https://example.com

# With a specific user-data-dir (persistent session)
google-chrome --headless --no-sandbox --user-data-dir=/tmp/chrome-session https://example.com

# Interactive (requires VNC/display session in Tilix)
google-chrome
```

#### SeleniumBase — Stealth Browser Automation
SeleniumBase works with the Chrome browser already installed in the Tilix image.
```bash
# Standard Selenium mode (fastest, but detectable)
python3 -c "
from seleniumbase import Driver
driver = Driver(browser='chrome', headless=True)
driver.get('https://example.com')
print(driver.title)
driver.quit()
"

# UC Mode — Undetected ChromeDriver (bypasses most bot detection)
python3 -c "
from seleniumbase import Driver
driver = Driver(uc=True)
driver.uc_open_with_reconnect('https://target.com', reconnect_time=3)
print(driver.get_current_url())
driver.quit()
"

# CDP Mode — Chrome DevTools Protocol (stealthiest, handles Cloudflare)
python3 -c "
from seleniumbase import SB
with SB(uc=True, test=True, locale_code='en') as sb:
    sb.uc_open_with_reconnect('https://target.com', reconnect_time=4)
    sb.uc_gui_click_captcha()  # Auto-solve checkbox CAPTCHAs
    print(sb.get_page_source()[:500])
"

# CLI screenshot
sbase get https://example.com --headless -o screenshot.png
```

#### Playwright — Cross-Browser Automation
Playwright uses the system Chrome (`/usr/bin/google-chrome`) already present in the Tilix image.
Pass `executable_path` to avoid downloading separate browser binaries (~620MB).
```bash
# Basic page fetch using system Chrome
python3 -c "
from playwright.sync_api import sync_playwright
with sync_playwright() as p:
    browser = p.chromium.launch(headless=True, executable_path='/usr/bin/google-chrome')
    page = browser.new_page()
    page.goto('https://example.com')
    print(page.title())
    browser.close()
"

# Stealth mode — evade basic bot detection
python3 -c "
from playwright.sync_api import sync_playwright
with sync_playwright() as p:
    browser = p.chromium.launch(headless=True, args=['--disable-blink-features=AutomationControlled'])
    ctx = browser.new_context(user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36')
    page = ctx.new_page()
    page.goto('https://example.com')
    print(page.evaluate('navigator.userAgent'))
    browser.close()
"

# Screenshot a page
python3 -c "
from playwright.sync_api import sync_playwright
with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page()
    page.goto('https://example.com')
    page.screenshot(path='screenshot.png')
    browser.close()
"

# List available browsers
playwright install --list
```

#### Yandex Browser — Russian OSINT
Yandex Browser is a Chromium-based browser useful for accessing Russian-language
services and Yandex-specific features (Yandex Search, Yandex Maps, Russian social media).
```bash
# Launch Yandex Browser (requires display / VNC session in Tilix)
yandex-browser-beta

# Headless screenshot via Selenium (same API as Chrome)
python3 -c "
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
opts = Options()
opts.binary_location = '/usr/bin/yandex-browser-beta'
opts.add_argument('--headless')
opts.add_argument('--no-sandbox')
opts.add_argument('--disable-dev-shm-usage')
driver = webdriver.Chrome(options=opts)
driver.get('https://yandex.ru/search/?text=osint')
print(driver.title)
driver.quit()
"

# Useful Yandex OSINT endpoints
# https://yandex.ru/search/         — Yandex Search
# https://yandex.ru/images/         — Yandex Image Search (reverse image)
# https://yandex.ru/maps/            — Yandex Maps
# https://social.yandex.ru/          — Yandex Social
```

#### Tor Browser — Anonymous Browsing
Tor Browser routes all traffic through the Tor network for anonymous OSINT.
```bash
# Start Tor Browser (requires display / VNC session in Tilix)
tor-browser

# Start detached (background)
~/opt/tor-browser/Browser/start-tor-browser --detach

# Use Tor as SOCKS5 proxy with curl (Tor daemon must be running)
# First start Tor daemon separately:
tor &
# Then use the SOCKS5 proxy on localhost:9050
curl --socks5 localhost:9050 https://check.torproject.org/api/ip

# Use Tor proxy with Python requests
python3 -c "
import requests
proxies = {'http': 'socks5h://localhost:9050', 'https': 'socks5h://localhost:9050'}
r = requests.get('https://check.torproject.org/api/ip', proxies=proxies)
print(r.json())
"

# Check your Tor exit IP
curl --socks5 localhost:9050 https://api.ipify.org

# Access .onion sites (requires Tor daemon)
curl --socks5 localhost:9050 http://duckduckgogg42xjoc72x3sjasowoarfbgcmvfimaftt6twagswzczad.onion
```

## 🔄 Updating Tools

### Python Tools
```bash
# Update individual tools (no venv — installed directly via pip --user)
pip install --user --upgrade sherlock-project holehe socialscan
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
# Check user-space packages
pip show sherlock-project holehe shodan

# Reinstall a specific tool
pip install --user --force-reinstall sherlock-project

# Check ~/.local/bin for tool wrappers
ls -la ~/.local/bin/sherlock holehe shodan
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
- pip --user installs are isolated to ~/.local/lib/python3.13
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
