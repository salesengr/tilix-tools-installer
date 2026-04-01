#!/bin/bash
# Security Tools Installer - Tool Definitions Module
# Version: 1.4.0
# Purpose: Centralized tool metadata and category definitions

# shellcheck disable=SC2034  # Variables used in parent script and other modules
# shellcheck disable=SC2154  # Associative array indices appear as undefined variables

# ===== TOOL CATEGORIES =====

# Build tools and runtimes
BUILD_TOOLS=("cmake" "github_cli")
LANGUAGES=("nodejs" "rust" "go_runtime")

# ===== USE-CASE CATEGORIES (v1.4.0) =====
# Menu and bulk install operations use these arrays.
# Tools are grouped by function, not by runtime.

PASSIVE_OSINT=("sherlock" "holehe" "socialscan" "theHarvester" "spiderfoot" "photon" "wappalyzer" "h8mail" "waybackurls" "assetfinder" "subfinder" "git-hound")
DOMAIN_ENUM=("sublist3r" "gobuster" "ffuf")
ACTIVE_RECON=("httprobe" "rustscan" "feroxbuster" "nuclei")
CTI_TOOLS=("shodan" "censys" "yara" "trufflehog" "virustotal")
SECURITY_TESTING=("jwt-cracker")
UTILITY_TOOLS=("ripgrep" "fd" "bat" "sd" "dog" "aria2")
WEB_TOOLS=("seleniumbase" "playwright" "yandex_browser" "tor_browser" "qtox")

# ===== INTERNAL RUNTIME ARRAYS =====
# Used internally for dependency resolution only (not exposed in menu).
# Each installer knows what runtime it needs; these help bulk installs
# ensure prerequisites are met.
_PYTHON_TOOLS=("sherlock" "holehe" "socialscan" "theHarvester" "spiderfoot" "photon" "wappalyzer" "h8mail" "sublist3r" "shodan" "censys" "yara")
_GO_TOOLS=("gobuster" "ffuf" "httprobe" "waybackurls" "assetfinder" "subfinder" "nuclei" "virustotal")
_NODE_TOOLS=("trufflehog" "git-hound" "jwt-cracker")
_RUST_TOOLS=("feroxbuster" "rustscan" "ripgrep" "fd" "bat" "sd" "dog")

# Legacy aliases — kept for backward compatibility with any external scripts
NODE_TOOLS=("${_NODE_TOOLS[@]}")
ALL_PYTHON_TOOLS=("${_PYTHON_TOOLS[@]}")
ALL_GO_TOOLS=("${_GO_TOOLS[@]}")
ALL_RUST_TOOLS=("${_RUST_TOOLS[@]}")
ALL_UTILITY_TOOLS=("${UTILITY_TOOLS[@]}")

# ===== TOOL DEFINITIONS FUNCTION =====

# Function: define_tools
# Purpose: Initialize all tool metadata (info, sizes, dependencies, locations)
# Returns: Always succeeds
define_tools() {
    # Build Tools
    TOOL_INFO[cmake]="CMake|Build system generator|Build Tool"
    TOOL_SIZES[cmake]="50MB"
    TOOL_DEPENDENCIES[cmake]=""
    TOOL_INSTALL_LOCATION[cmake]="$HOME/.local/bin/cmake"

    TOOL_INFO[github_cli]="GitHub CLI|GitHub workflow automation|Build Tool"
    TOOL_SIZES[github_cli]="90MB"
    TOOL_DEPENDENCIES[github_cli]=""
    TOOL_INSTALL_LOCATION[github_cli]="$HOME/.local/bin/gh"

    # Languages
    TOOL_INFO[go_runtime]="Go Runtime|Go programming language runtime (user-space install)|Language"
    TOOL_SIZES[go_runtime]="500MB"
    TOOL_DEPENDENCIES[go_runtime]=""
    TOOL_INSTALL_LOCATION[go_runtime]="$HOME/opt/go/bin/go"

    TOOL_INFO[nodejs]="Node.js|JavaScript runtime|Language"
    TOOL_SIZES[nodejs]="50MB"
    TOOL_DEPENDENCIES[nodejs]=""
    TOOL_INSTALL_LOCATION[nodejs]="$HOME/opt/node/"

    TOOL_INFO[rust]="Rust|Systems programming language|Language"
    TOOL_SIZES[rust]="800MB"
    TOOL_DEPENDENCIES[rust]=""
    TOOL_INSTALL_LOCATION[rust]="\$CARGO_HOME/"

    # Python prerequisite
    TOOL_INFO[python_venv]="Python Virtual Environment|Required for Python tools|Python Environment"
    TOOL_SIZES[python_venv]="50MB"
    TOOL_DEPENDENCIES[python_venv]=""
    TOOL_INSTALL_LOCATION[python_venv]="\$XDG_DATA_HOME/virtualenvs/tools/"

    # Python OSINT Tools
    TOOL_INFO[sherlock]="Sherlock|Username search across social networks|OSINT"
    TOOL_SIZES[sherlock]="30MB"
    TOOL_DEPENDENCIES[sherlock]="python_venv"
    TOOL_INSTALL_LOCATION[sherlock]="$HOME/.local/bin/sherlock"

    TOOL_INFO[holehe]="Holehe|Email verification across sites|OSINT"
    TOOL_SIZES[holehe]="25MB"
    TOOL_DEPENDENCIES[holehe]="python_venv"
    TOOL_INSTALL_LOCATION[holehe]="$HOME/.local/bin/holehe"

    TOOL_INFO[socialscan]="Socialscan|Username/email availability checker|OSINT"
    TOOL_SIZES[socialscan]="20MB"
    TOOL_DEPENDENCIES[socialscan]="python_venv"
    TOOL_INSTALL_LOCATION[socialscan]="$HOME/.local/bin/socialscan"

    TOOL_INFO[h8mail]="h8mail|Email OSINT and breach hunting|OSINT/CTI"
    TOOL_SIZES[h8mail]="25MB"
    TOOL_DEPENDENCIES[h8mail]="python_venv"
    TOOL_INSTALL_LOCATION[h8mail]="$HOME/.local/bin/h8mail"

    TOOL_INFO[photon]="Photon|Fast web crawler and OSINT tool|OSINT"
    TOOL_SIZES[photon]="30MB"
    TOOL_DEPENDENCIES[photon]="python_venv"
    TOOL_INSTALL_LOCATION[photon]="$HOME/.local/bin/photon"

    TOOL_INFO[sublist3r]="Sublist3r|Subdomain enumeration tool|OSINT"
    TOOL_SIZES[sublist3r]="25MB"
    TOOL_DEPENDENCIES[sublist3r]="python_venv"
    TOOL_INSTALL_LOCATION[sublist3r]="$HOME/.local/bin/sublist3r"

    # Python CTI Tools
    TOOL_INFO[shodan]="Shodan CLI|Search engine for Internet-connected devices|CTI"
    TOOL_SIZES[shodan]="10MB"
    TOOL_DEPENDENCIES[shodan]="python_venv"
    TOOL_INSTALL_LOCATION[shodan]="$HOME/.local/bin/shodan"

    TOOL_INFO[censys]="Censys|Internet-wide scanning data|CTI"
    TOOL_SIZES[censys]="5MB"
    TOOL_DEPENDENCIES[censys]="python_venv"
    TOOL_INSTALL_LOCATION[censys]="$HOME/.local/bin/censys"

    TOOL_INFO[theHarvester]="theHarvester|Email/subdomain/host gathering|OSINT/CTI"
    TOOL_SIZES[theHarvester]="15MB"
    TOOL_DEPENDENCIES[theHarvester]="python_venv"
    TOOL_INSTALL_LOCATION[theHarvester]="$HOME/.local/bin/theHarvester"

    TOOL_INFO[spiderfoot]="SpiderFoot|Automated OSINT collection|OSINT/CTI"
    TOOL_SIZES[spiderfoot]="30MB"
    TOOL_DEPENDENCIES[spiderfoot]="python_venv"
    TOOL_INSTALL_LOCATION[spiderfoot]="$HOME/.local/bin/spiderfoot"

    TOOL_INFO[yara]="YARA|Pattern matching for malware research|CTI"
    TOOL_SIZES[yara]="5MB"
    TOOL_DEPENDENCIES[yara]="python_venv"
    TOOL_INSTALL_LOCATION[yara]="$HOME/.local/bin/yara"

    TOOL_INFO[wappalyzer]="Wappalyzer|Technology profiler|OSINT"
    TOOL_SIZES[wappalyzer]="15MB"
    TOOL_DEPENDENCIES[wappalyzer]="python_venv"
    TOOL_INSTALL_LOCATION[wappalyzer]="$HOME/.local/bin/wappalyzer"

    # Go Tools
    TOOL_INFO[gobuster]="Gobuster|Directory/DNS/vhost bruteforcing|Active Recon"
    TOOL_SIZES[gobuster]="15MB"
    TOOL_DEPENDENCIES[gobuster]=""
    TOOL_INSTALL_LOCATION[gobuster]="\$GOPATH/bin/gobuster"

    TOOL_INFO[ffuf]="FFuF|Fast web fuzzer|Active Recon"
    TOOL_SIZES[ffuf]="12MB"
    TOOL_DEPENDENCIES[ffuf]=""
    TOOL_INSTALL_LOCATION[ffuf]="\$GOPATH/bin/ffuf"

    TOOL_INFO[httprobe]="httprobe|HTTP/HTTPS service probe|Active Recon"
    TOOL_SIZES[httprobe]="5MB"
    TOOL_DEPENDENCIES[httprobe]=""
    TOOL_INSTALL_LOCATION[httprobe]="\$GOPATH/bin/httprobe"

    TOOL_INFO[waybackurls]="waybackurls|Wayback Machine URL fetcher|OSINT"
    TOOL_SIZES[waybackurls]="5MB"
    TOOL_DEPENDENCIES[waybackurls]=""
    TOOL_INSTALL_LOCATION[waybackurls]="\$GOPATH/bin/waybackurls"

    TOOL_INFO[assetfinder]="assetfinder|Domain/subdomain finder|OSINT"
    TOOL_SIZES[assetfinder]="5MB"
    TOOL_DEPENDENCIES[assetfinder]=""
    TOOL_INSTALL_LOCATION[assetfinder]="\$GOPATH/bin/assetfinder"

    TOOL_INFO[subfinder]="subfinder|Subdomain discovery tool|OSINT"
    TOOL_SIZES[subfinder]="15MB"
    TOOL_DEPENDENCIES[subfinder]=""
    TOOL_INSTALL_LOCATION[subfinder]="\$GOPATH/bin/subfinder"

    TOOL_INFO[nuclei]="Nuclei|Vulnerability scanner|Vuln Scan"
    TOOL_SIZES[nuclei]="20MB"
    TOOL_DEPENDENCIES[nuclei]=""
    TOOL_INSTALL_LOCATION[nuclei]="\$GOPATH/bin/nuclei"

    TOOL_INFO[virustotal]="VirusTotal CLI|VT API interaction|CTI"
    TOOL_SIZES[virustotal]="10MB"
    TOOL_DEPENDENCIES[virustotal]=""
    TOOL_INSTALL_LOCATION[virustotal]="\$GOPATH/bin/vt"

    # Node.js Tools
    TOOL_INFO[trufflehog]="TruffleHog|Secret scanning in git repos|CTI"
    TOOL_SIZES[trufflehog]="15MB"
    TOOL_DEPENDENCIES[trufflehog]="nodejs"
    TOOL_INSTALL_LOCATION[trufflehog]="$HOME/.local/bin/trufflehog"

    TOOL_INFO[git-hound]="git-hound|GitHub reconnaissance|OSINT"
    TOOL_SIZES[git-hound]="10MB"
    TOOL_DEPENDENCIES[git-hound]="nodejs"
    TOOL_INSTALL_LOCATION[git-hound]="$HOME/.local/bin/git-hound"

    TOOL_INFO[jwt-cracker]="JWT Cracker|JWT token analysis|Security Testing"
    TOOL_SIZES[jwt-cracker]="5MB"
    TOOL_DEPENDENCIES[jwt-cracker]="nodejs"
    TOOL_INSTALL_LOCATION[jwt-cracker]="$HOME/.local/bin/jwt-cracker"

    # Rust Tools
    TOOL_INFO[feroxbuster]="feroxbuster|Fast content discovery|Active Recon"
    TOOL_SIZES[feroxbuster]="5MB"
    TOOL_DEPENDENCIES[feroxbuster]="rust"
    TOOL_INSTALL_LOCATION[feroxbuster]="\$CARGO_HOME/bin/feroxbuster"

    TOOL_INFO[rustscan]="RustScan|Modern fast port scanner|Active Recon"
    TOOL_SIZES[rustscan]="3MB"
    TOOL_DEPENDENCIES[rustscan]="rust"
    TOOL_INSTALL_LOCATION[rustscan]="\$CARGO_HOME/bin/rustscan"

    TOOL_INFO[ripgrep]="ripgrep|Fast recursive grep|Utility"
    TOOL_SIZES[ripgrep]="2MB"
    TOOL_DEPENDENCIES[ripgrep]="rust"
    TOOL_INSTALL_LOCATION[ripgrep]="\$CARGO_HOME/bin/rg"

    TOOL_INFO[fd]="fd|Fast file finder|Utility"
    TOOL_SIZES[fd]="1.5MB"
    TOOL_DEPENDENCIES[fd]="rust"
    TOOL_INSTALL_LOCATION[fd]="\$CARGO_HOME/bin/fd"

    TOOL_INFO[bat]="bat|Cat with syntax highlighting|Utility"
    TOOL_SIZES[bat]="2MB"
    TOOL_DEPENDENCIES[bat]="rust"
    TOOL_INSTALL_LOCATION[bat]="\$CARGO_HOME/bin/bat"

    TOOL_INFO[sd]="sd|Intuitive find & replace|Utility"
    TOOL_SIZES[sd]="1MB"
    TOOL_DEPENDENCIES[sd]="rust"
    TOOL_INSTALL_LOCATION[sd]="\$CARGO_HOME/bin/sd"


    TOOL_INFO[dog]="dog|Modern DNS client|Utility"
    TOOL_SIZES[dog]="1.5MB"
    TOOL_DEPENDENCIES[dog]="rust"
    TOOL_INSTALL_LOCATION[dog]="\$CARGO_HOME/bin/dog"

    # Utility Tools
    TOOL_INFO[aria2]="aria2|Multi-protocol download utility (HTTP/FTP/BitTorrent/Metalink)|Utility"
    TOOL_SIZES[aria2]="5MB"
    TOOL_DEPENDENCIES[aria2]=""
    TOOL_INSTALL_LOCATION[aria2]="$HOME/.local/bin/aria2c"
}

    # Web Tools
    TOOL_INFO[seleniumbase]="SeleniumBase|Browser automation with UC/CDP modes for bypassing bot-detection|Web Tools"
    TOOL_SIZES[seleniumbase]="50MB"
    TOOL_DEPENDENCIES[seleniumbase]=""
    TOOL_INSTALL_LOCATION[seleniumbase]="$HOME/.local/bin/sbase"

    TOOL_INFO[playwright]="Playwright|Cross-browser automation framework (Chromium/Firefox/WebKit)|Web Tools"
    TOOL_SIZES[playwright]="100MB"
    TOOL_DEPENDENCIES[playwright]=""
    TOOL_INSTALL_LOCATION[playwright]="$HOME/.local/bin/playwright"

    TOOL_INFO[yandex_browser]="Yandex Browser|Chromium-based browser for Russian-language OSINT|Web Tools"
    TOOL_SIZES[yandex_browser]="300MB"
    TOOL_DEPENDENCIES[yandex_browser]=""
    TOOL_INSTALL_LOCATION[yandex_browser]="/usr/bin/yandex-browser-beta"

    TOOL_INFO[tor_browser]="Tor Browser|Anonymous browsing via Tor network|Web Tools"
    TOOL_SIZES[tor_browser]="333MB"
    TOOL_DEPENDENCIES[tor_browser]=""
    TOOL_INSTALL_LOCATION[tor_browser]="$HOME/opt/tor-browser/Browser/start-tor-browser"

    TOOL_INFO[qtox]="qTox|Encrypted peer-to-peer chat client (Tox protocol)|Web Tools"
    TOOL_SIZES[qtox]="65MB"
    TOOL_DEPENDENCIES[qtox]=""
    TOOL_INSTALL_LOCATION[qtox]="$HOME/opt/qtox/squashfs-root/AppRun"
    TOOL_SIZES[tor_browser]="100MB"
    TOOL_DEPENDENCIES[tor_browser]=""
    TOOL_INSTALL_LOCATION[tor_browser]="$HOME/opt/tor-browser/Browser/start-tor-browser"
