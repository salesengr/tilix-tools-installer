#!/bin/bash
# Security Tools Installer - Tool Definitions Module
# Version: 1.3.0
# Purpose: Centralized tool metadata and category definitions

# ===== TOOL CATEGORIES =====

# Tool category arrays
BUILD_TOOLS=("cmake" "github_cli")
LANGUAGES=("nodejs" "rust")
PYTHON_RECON_PASSIVE=("sherlock" "holehe" "socialscan" "theHarvester" "spiderfoot")
PYTHON_RECON_DOMAIN=("sublist3r")
PYTHON_RECON_WEB=("photon" "wappalyzer")
PYTHON_THREAT_INTEL=("shodan" "censys" "yara")
PYTHON_CREDENTIAL=("h8mail")
GO_RECON_ACTIVE=("gobuster" "ffuf" "httprobe")
GO_RECON_PASSIVE=("waybackurls" "assetfinder" "subfinder")
GO_VULN_SCAN=("nuclei")
GO_THREAT_INTEL=("virustotal")
NODE_TOOLS=("trufflehog" "git-hound" "jwt-cracker")
RUST_RECON=("feroxbuster" "rustscan")
RUST_UTILS=("ripgrep" "fd" "bat" "sd" "tokei" "dog")

# Combined lists for bulk operations
ALL_PYTHON_TOOLS=("${PYTHON_RECON_PASSIVE[@]}" "${PYTHON_RECON_DOMAIN[@]}" "${PYTHON_RECON_WEB[@]}" "${PYTHON_THREAT_INTEL[@]}" "${PYTHON_CREDENTIAL[@]}")
ALL_GO_TOOLS=("${GO_RECON_ACTIVE[@]}" "${GO_RECON_PASSIVE[@]}" "${GO_VULN_SCAN[@]}" "${GO_THREAT_INTEL[@]}")
ALL_RUST_TOOLS=("${RUST_RECON[@]}" "${RUST_UTILS[@]}")

# ===== TOOL DEFINITIONS FUNCTION =====

# Function: define_tools
# Purpose: Initialize all tool metadata (info, sizes, dependencies, locations)
# Returns: Always succeeds
define_tools() {
    # Build Tools
    TOOL_INFO[cmake]="CMake|Build system generator|Build Tool"
    TOOL_SIZES[cmake]="50MB"
    TOOL_DEPENDENCIES[cmake]=""
    TOOL_INSTALL_LOCATION[cmake]="~/.local/bin/cmake"

    TOOL_INFO[github_cli]="GitHub CLI|GitHub workflow automation|Build Tool"
    TOOL_SIZES[github_cli]="90MB"
    TOOL_DEPENDENCIES[github_cli]=""
    TOOL_INSTALL_LOCATION[github_cli]="~/.local/bin/gh"

    # Languages
    TOOL_INFO[nodejs]="Node.js|JavaScript runtime|Language"
    TOOL_SIZES[nodejs]="50MB"
    TOOL_DEPENDENCIES[nodejs]=""
    TOOL_INSTALL_LOCATION[nodejs]="~/opt/node/"

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
    TOOL_INSTALL_LOCATION[sherlock]="~/.local/bin/sherlock"

    TOOL_INFO[holehe]="Holehe|Email verification across sites|OSINT"
    TOOL_SIZES[holehe]="25MB"
    TOOL_DEPENDENCIES[holehe]="python_venv"
    TOOL_INSTALL_LOCATION[holehe]="~/.local/bin/holehe"

    TOOL_INFO[socialscan]="Socialscan|Username/email availability checker|OSINT"
    TOOL_SIZES[socialscan]="20MB"
    TOOL_DEPENDENCIES[socialscan]="python_venv"
    TOOL_INSTALL_LOCATION[socialscan]="~/.local/bin/socialscan"

    TOOL_INFO[h8mail]="h8mail|Email OSINT and breach hunting|OSINT/CTI"
    TOOL_SIZES[h8mail]="25MB"
    TOOL_DEPENDENCIES[h8mail]="python_venv"
    TOOL_INSTALL_LOCATION[h8mail]="~/.local/bin/h8mail"

    TOOL_INFO[photon]="Photon|Fast web crawler and OSINT tool|OSINT"
    TOOL_SIZES[photon]="30MB"
    TOOL_DEPENDENCIES[photon]="python_venv"
    TOOL_INSTALL_LOCATION[photon]="~/.local/bin/photon"

    TOOL_INFO[sublist3r]="Sublist3r|Subdomain enumeration tool|OSINT"
    TOOL_SIZES[sublist3r]="25MB"
    TOOL_DEPENDENCIES[sublist3r]="python_venv"
    TOOL_INSTALL_LOCATION[sublist3r]="~/.local/bin/sublist3r"

    # Python CTI Tools
    TOOL_INFO[shodan]="Shodan CLI|Search engine for Internet-connected devices|CTI"
    TOOL_SIZES[shodan]="10MB"
    TOOL_DEPENDENCIES[shodan]="python_venv"
    TOOL_INSTALL_LOCATION[shodan]="~/.local/bin/shodan"

    TOOL_INFO[censys]="Censys|Internet-wide scanning data|CTI"
    TOOL_SIZES[censys]="5MB"
    TOOL_DEPENDENCIES[censys]="python_venv"
    TOOL_INSTALL_LOCATION[censys]="~/.local/bin/censys"

    TOOL_INFO[theHarvester]="theHarvester|Email/subdomain/host gathering|OSINT/CTI"
    TOOL_SIZES[theHarvester]="15MB"
    TOOL_DEPENDENCIES[theHarvester]="python_venv"
    TOOL_INSTALL_LOCATION[theHarvester]="~/.local/bin/theHarvester"

    TOOL_INFO[spiderfoot]="SpiderFoot|Automated OSINT collection|OSINT/CTI"
    TOOL_SIZES[spiderfoot]="30MB"
    TOOL_DEPENDENCIES[spiderfoot]="python_venv"
    TOOL_INSTALL_LOCATION[spiderfoot]="~/.local/bin/spiderfoot"

    TOOL_INFO[yara]="YARA|Pattern matching for malware research|CTI"
    TOOL_SIZES[yara]="5MB"
    TOOL_DEPENDENCIES[yara]="python_venv"
    TOOL_INSTALL_LOCATION[yara]="~/.local/bin/yara"

    TOOL_INFO[wappalyzer]="Wappalyzer|Technology profiler|OSINT"
    TOOL_SIZES[wappalyzer]="15MB"
    TOOL_DEPENDENCIES[wappalyzer]="python_venv"
    TOOL_INSTALL_LOCATION[wappalyzer]="~/.local/bin/wappalyzer"

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
    TOOL_INSTALL_LOCATION[trufflehog]="~/.local/bin/trufflehog"

    TOOL_INFO[git-hound]="git-hound|GitHub reconnaissance|OSINT"
    TOOL_SIZES[git-hound]="10MB"
    TOOL_DEPENDENCIES[git-hound]="nodejs"
    TOOL_INSTALL_LOCATION[git-hound]="~/.local/bin/git-hound"

    TOOL_INFO[jwt-cracker]="JWT Cracker|JWT token analysis|Security Testing"
    TOOL_SIZES[jwt-cracker]="5MB"
    TOOL_DEPENDENCIES[jwt-cracker]="nodejs"
    TOOL_INSTALL_LOCATION[jwt-cracker]="~/.local/bin/jwt-cracker"

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

    TOOL_INFO[tokei]="tokei|Code statistics analyzer|Utility"
    TOOL_SIZES[tokei]="2MB"
    TOOL_DEPENDENCIES[tokei]="rust"
    TOOL_INSTALL_LOCATION[tokei]="\$CARGO_HOME/bin/tokei"

    TOOL_INFO[dog]="dog|Modern DNS client|Utility"
    TOOL_SIZES[dog]="1.5MB"
    TOOL_DEPENDENCIES[dog]="rust"
    TOOL_INSTALL_LOCATION[dog]="\$CARGO_HOME/bin/dog"
}
