#!/bin/bash
# Security Tools Installer (OSINT/CTI/PenTest)
# Version: 1.0.1
# For Ubuntu 20.04+ container without sudo access
#
# PREREQUISITE: Run xdg_setup.sh first
#
# Usage:
#   bash install_security_tools.sh                    # Interactive menu
#   bash install_security_tools.sh sherlock gobuster  # Install specific tools
#   bash install_security_tools.sh --python-tools     # Install category
#   bash install_security_tools.sh all                # Install everything
#   bash install_security_tools.sh --dry-run sherlock # Preview installation

# Disable exit on error for better error handling
set +e

# ===== COLOR CODES =====
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;36m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'


# ===== GLOBAL VARIABLES =====
SCRIPT_VERSION="1.0.1"
DRY_RUN=false
CHECK_UPDATES=false
SUCCESSFUL_INSTALLS=()
FAILED_INSTALLS=()
declare -A FAILED_INSTALL_LOGS
declare -A INSTALLED_STATUS
declare -A TOOL_DEPENDENCIES
declare -A TOOL_INFO
declare -A TOOL_SIZES
declare -A TOOL_INSTALL_LOCATION
# ===== LOGGING SETUP =====
LOG_DIR="$HOME/.local/state/install_tools/logs"
HISTORY_LOG="$HOME/.local/state/install_tools/installation_history.log"

init_logging() {
    mkdir -p "$LOG_DIR"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installation session started" >> "$HISTORY_LOG"
}

create_tool_log() {
    local tool=$1
    local timestamp=$(date +%Y%m%d_%H%M%S)
    echo "$LOG_DIR/${tool}-${timestamp}.log"
}

cleanup_old_logs() {
    local tool=$1
    cd "$LOG_DIR" 2>/dev/null || return
    ls -t ${tool}-*.log 2>/dev/null | tail -n +11 | xargs -r rm
}

log_installation() {
    local tool=$1
    local status=$2
    local logfile=$3
    
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $tool - $status" >> "$HISTORY_LOG"
    
    if [[ "$status" == "failure" ]]; then
        echo "  Log: $logfile" >> "$HISTORY_LOG"
    fi
}

# ===== DOWNLOAD HELPERS =====

# Download with retry and verification
download_file() {
    local url=$1
    local output=$2
    local max_retries=3
    local retry=0
    
    while [ $retry -lt $max_retries ]; do
        echo "Attempting download (try $((retry + 1))/$max_retries)..."
        
        if wget --progress=bar:force --show-progress "$url" -O "$output" 2>&1; then
            if [ -f "$output" ]; then
                echo "Download successful"
                return 0
            fi
        fi
        
        retry=$((retry + 1))
        if [ $retry -lt $max_retries ]; then
            echo "Download failed, retrying in 2 seconds..."
            sleep 2
        fi
    done
    
    echo "ERROR: Failed to download after $max_retries attempts: $url"
    return 1
}

# Verify file exists before processing
verify_file_exists() {
    local filepath=$1
    local description=$2
    
    if [ ! -f "$filepath" ]; then
        echo "ERROR: $description not found: $filepath"
        return 1
    fi
    
    return 0
}

# ===== TOOL DEFINITIONS =====
# [Rest of tool definitions remain the same]
# Tool categories
BUILD_TOOLS=("cmake" "github_cli")
LANGUAGES=("go" "nodejs" "rust")
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
    TOOL_INFO[go]="Go|Programming language runtime|Language"
    TOOL_SIZES[go]="120MB"
    TOOL_DEPENDENCIES[go]=""
    TOOL_INSTALL_LOCATION[go]="~/opt/go/"
    
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
    TOOL_DEPENDENCIES[gobuster]="go"
    TOOL_INSTALL_LOCATION[gobuster]="\$GOPATH/bin/gobuster"
    
    TOOL_INFO[ffuf]="FFuF|Fast web fuzzer|Active Recon"
    TOOL_SIZES[ffuf]="12MB"
    TOOL_DEPENDENCIES[ffuf]="go"
    TOOL_INSTALL_LOCATION[ffuf]="\$GOPATH/bin/ffuf"
    
    TOOL_INFO[httprobe]="httprobe|HTTP/HTTPS service probe|Active Recon"
    TOOL_SIZES[httprobe]="5MB"
    TOOL_DEPENDENCIES[httprobe]="go"
    TOOL_INSTALL_LOCATION[httprobe]="\$GOPATH/bin/httprobe"
    
    TOOL_INFO[waybackurls]="waybackurls|Wayback Machine URL fetcher|OSINT"
    TOOL_SIZES[waybackurls]="5MB"
    TOOL_DEPENDENCIES[waybackurls]="go"
    TOOL_INSTALL_LOCATION[waybackurls]="\$GOPATH/bin/waybackurls"
    
    TOOL_INFO[assetfinder]="assetfinder|Domain/subdomain finder|OSINT"
    TOOL_SIZES[assetfinder]="5MB"
    TOOL_DEPENDENCIES[assetfinder]="go"
    TOOL_INSTALL_LOCATION[assetfinder]="\$GOPATH/bin/assetfinder"
    
    TOOL_INFO[subfinder]="subfinder|Subdomain discovery tool|OSINT"
    TOOL_SIZES[subfinder]="15MB"
    TOOL_DEPENDENCIES[subfinder]="go"
    TOOL_INSTALL_LOCATION[subfinder]="\$GOPATH/bin/subfinder"
    
    TOOL_INFO[nuclei]="Nuclei|Vulnerability scanner|Vuln Scan"
    TOOL_SIZES[nuclei]="20MB"
    TOOL_DEPENDENCIES[nuclei]="go"
    TOOL_INSTALL_LOCATION[nuclei]="\$GOPATH/bin/nuclei"
    
    TOOL_INFO[virustotal]="VirusTotal CLI|VT API interaction|CTI"
    TOOL_SIZES[virustotal]="10MB"
    TOOL_DEPENDENCIES[virustotal]="go"
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

# ===== INSTALLATION STATUS CHECKS =====

is_installed() {
    local tool=$1
    
    case "$tool" in
        cmake)
            [ -f "$HOME/.local/bin/cmake" ] && return 0 ;;
        github_cli)
            [ -f "$HOME/.local/bin/gh" ] && return 0 ;;
        go)
            [ -f "$HOME/opt/go/bin/go" ] && return 0 ;;
        nodejs)
            [ -f "$HOME/opt/node/bin/node" ] && return 0 ;;
        rust)
            [ -f "$HOME/.local/share/cargo/bin/cargo" ] && return 0 ;;
        python_venv)
            [ -d "$XDG_DATA_HOME/virtualenvs/tools" ] && return 0 ;;
        # Python tools check wrapper
        sherlock|holehe|socialscan|h8mail|photon|sublist3r|shodan|censys|theHarvester|spiderfoot|yara|wappalyzer)
            [ -f "$HOME/.local/bin/$tool" ] && return 0 ;;
        # Go tools
        gobuster|ffuf|httprobe|waybackurls|assetfinder|subfinder|nuclei)
            [ -f "$HOME/opt/gopath/bin/$tool" ] && return 0 ;;
        virustotal)
            [ -f "$HOME/opt/gopath/bin/vt" ] && return 0 ;;
        # Node tools
        trufflehog|git-hound|jwt-cracker)
            [ -f "$HOME/.local/bin/$tool" ] && return 0 ;;
        # Rust tools
        feroxbuster|rustscan|sd|tokei|dog)
            command -v "$tool" &>/dev/null && return 0 ;;
        ripgrep)
            command -v rg &>/dev/null && return 0 ;;
        fd)
            command -v fd &>/dev/null && return 0 ;;
        bat)
            command -v bat &>/dev/null && return 0 ;;
    esac
    
    return 1
}

scan_installed_tools() {
    for tool in "${!TOOL_INFO[@]}"; do
        if is_installed "$tool"; then
            INSTALLED_STATUS[$tool]="true"
        else
            INSTALLED_STATUS[$tool]="false"
        fi
    done
}

# ===== DEPENDENCY RESOLUTION =====

check_dependencies() {
    local tool=$1
    local deps=${TOOL_DEPENDENCIES[$tool]}
    
    if [[ -z "$deps" ]]; then
        return 0
    fi
    
    for dep in $deps; do
        if ! is_installed "$dep"; then
            echo -e "${YELLOW}  Installing prerequisite: $dep${NC}"
            install_tool "$dep"
            if [ $? -ne 0 ]; then
                return 1
            fi
        fi
    done
    
    return 0
}

# ===== INSTALLATION FUNCTIONS WITH FIXED ERROR HANDLING =====

# Build Tools
install_cmake() {
    local logfile=$(create_tool_log "cmake")
    
    {
        echo "=========================================="
        echo "Installing CMake"
        echo "Started: $(date)"
        echo "=========================================="
        
        mkdir -p "$HOME/opt/src"
        cd "$HOME/opt/src" || exit 1
        CMAKE_VERSION="3.28.1"
        local filename="cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz"
        local url="https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/${filename}"
        
        echo "Downloading CMake ${CMAKE_VERSION}..."
        if ! download_file "$url" "$filename"; then
            echo "ERROR: Failed to download CMake"
            return 1
        fi
        
        if ! verify_file_exists "$filename" "CMake tarball"; then
            return 1
        fi
        
        echo "Extracting..."
        if ! tar -xzf "$filename"; then
            echo "ERROR: Failed to extract CMake"
            return 1
        fi
        
        echo "Installing to ~/.local/..."
        if [ ! -d "cmake-${CMAKE_VERSION}-linux-x86_64" ]; then
            echo "ERROR: Extracted directory not found"
            return 1
        fi
        
        cp -r cmake-${CMAKE_VERSION}-linux-x86_64/bin/* "$HOME/.local/bin/" || return 1
        cp -r cmake-${CMAKE_VERSION}-linux-x86_64/share/* "$HOME/.local/share/" || return 1
        
        echo "Cleaning up..."
        rm -rf cmake-${CMAKE_VERSION}-linux-x86_64*
        
        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1
    
    if is_installed "cmake"; then
        echo -e "${GREEN}[OK] CMake installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("cmake")
        log_installation "cmake" "success" "$logfile"
        cleanup_old_logs "cmake"
        return 0
    else
        echo -e "${RED}[FAIL] CMake installation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("cmake")
        FAILED_INSTALL_LOGS["cmake"]="$logfile"
        log_installation "cmake" "failure" "$logfile"
        return 1
    fi
}

install_github_cli() {
    local logfile=$(create_tool_log "github_cli")
    
    {
        echo "=========================================="
        echo "Installing GitHub CLI"
        echo "Started: $(date)"
        echo "=========================================="
        
        mkdir -p "$HOME/opt/src"
        cd "$HOME/opt/src" || exit 1
        GH_CLI_VERSION="2.53.0"
        local filename="gh_${GH_CLI_VERSION}_linux_amd64.tar.gz"
        local url="https://github.com/cli/cli/releases/download/v${GH_CLI_VERSION}/${filename}"
        
        echo "Downloading GitHub CLI ${GH_CLI_VERSION}..."
        if ! download_file "$url" "$filename"; then
            echo "ERROR: Failed to download GitHub CLI"
            return 1
        fi
        
        if ! verify_file_exists "$filename" "GitHub CLI tarball"; then
            return 1
        fi
        
        echo "Extracting..."
        if ! tar -xzf "$filename"; then
            echo "ERROR: Failed to extract GitHub CLI"
            return 1
        fi
        
        local extracted_dir="gh_${GH_CLI_VERSION}_linux_amd64"
        if [ ! -d "$extracted_dir" ]; then
            echo "ERROR: Extracted directory not found"
            return 1
        fi
        
        echo "Installing to ~/.local/..."
        mkdir -p "$HOME/.local/bin"
        cp "$extracted_dir/bin/gh" "$HOME/.local/bin/" || return 1
        
        if [ -d "$extracted_dir/share/man/man1" ]; then
            mkdir -p "$HOME/.local/share/man/man1"
            cp "$extracted_dir/share/man/man1/"* "$HOME/.local/share/man/man1/" || return 1
        fi
        
        if [ -d "$extracted_dir/share/doc" ]; then
            mkdir -p "$HOME/.local/share/doc/gh"
            cp -r "$extracted_dir/share/doc/." "$HOME/.local/share/doc/gh" || return 1
        fi
        
        echo "Cleaning up..."
        rm -rf "$extracted_dir" "$filename"
        
        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1
    
    if is_installed "github_cli"; then
        echo -e "${GREEN}✓ GitHub CLI installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("github_cli")
        log_installation "github_cli" "success" "$logfile"
        cleanup_old_logs "github_cli"
        return 0
    else
        echo -e "${RED}✗ GitHub CLI installation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("github_cli")
        FAILED_INSTALL_LOGS["github_cli"]="$logfile"
        log_installation "github_cli" "failure" "$logfile"
        return 1
    fi
}

# Languages
install_go() {
    local logfile=$(create_tool_log "go")
    
    {
        echo "=========================================="
        echo "Installing Go"
        echo "Started: $(date)"
        echo "=========================================="
        
        mkdir -p "$HOME/opt"
        cd "$HOME/opt" || exit 1
        GO_VERSION="1.21.5"
        local filename="go${GO_VERSION}.linux-amd64.tar.gz"
        local url="https://go.dev/dl/${filename}"
        
        echo "Downloading Go ${GO_VERSION}..."
        if ! download_file "$url" "$filename"; then
            echo "ERROR: Failed to download Go"
            return 1
        fi
        
        if ! verify_file_exists "$filename" "Go tarball"; then
            return 1
        fi
        
        echo "Extracting..."
        if ! tar -xzf "$filename"; then
            echo "ERROR: Failed to extract Go"
            return 1
        fi
        
        echo "Cleaning up..."
        rm "$filename"
        
        echo "Setting up environment..."
        export GOROOT="$HOME/opt/go"
        export GOPATH="$HOME/opt/gopath"
        export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"
        mkdir -p "$GOPATH"
        
        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1
    
    if is_installed "go"; then
        echo -e "${GREEN}[OK] Go installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("go")
        log_installation "go" "success" "$logfile"
        cleanup_old_logs "go"
        # Set for current session
        export GOROOT="$HOME/opt/go"
        export GOPATH="$HOME/opt/gopath"
        export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"
        return 0
    else
        echo -e "${RED}[FAIL] Go installation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("go")
        FAILED_INSTALL_LOGS["go"]="$logfile"
        log_installation "go" "failure" "$logfile"
        return 1
    fi
}

install_nodejs() {
    local logfile=$(create_tool_log "nodejs")
    
    {
        echo "=========================================="
        echo "Installing Node.js"
        echo "Started: $(date)"
        echo "=========================================="
        
        mkdir -p "$HOME/opt"
        cd "$HOME/opt" || exit 1
        NODE_VERSION="20.10.0"
        local filename="node-v${NODE_VERSION}-linux-x64.tar.xz"
        local url="https://nodejs.org/dist/v${NODE_VERSION}/${filename}"
        
        echo "Downloading Node.js ${NODE_VERSION}..."
        if ! download_file "$url" "$filename"; then
            echo "ERROR: Failed to download Node.js"
            return 1
        fi
        
        if ! verify_file_exists "$filename" "Node.js tarball"; then
            return 1
        fi
        
        echo "Extracting..."
        if ! tar -xJf "$filename"; then
            echo "ERROR: Failed to extract Node.js"
            return 1
        fi
        
        mv "node-v${NODE_VERSION}-linux-x64" node
        
        echo "Cleaning up..."
        rm "$filename"
        
        echo "Setting up environment..."
        export PATH="$HOME/opt/node/bin:$PATH"
        
        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1
    
    if is_installed "nodejs"; then
        echo -e "${GREEN}[OK] Node.js installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("nodejs")
        log_installation "nodejs" "success" "$logfile"
        cleanup_old_logs "nodejs"
        export PATH="$HOME/opt/node/bin:$PATH"
        return 0
    else
        echo -e "${RED}[FAIL] Node.js installation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("nodejs")
        FAILED_INSTALL_LOGS["nodejs"]="$logfile"
        log_installation "nodejs" "failure" "$logfile"
        return 1
    fi
}

install_rust() {
    local logfile=$(create_tool_log "rust")
    
    echo -e "${YELLOW}Rust compilation takes 5-10 minutes...${NC}"
    
    {
        echo "=========================================="
        echo "Installing Rust"
        echo "Started: $(date)"
        echo "=========================================="
        
        echo "Downloading rustup..."
        if ! curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path; then
            echo "ERROR: Failed to install Rust"
            return 1
        fi
        
        echo "Setting up environment..."
        export CARGO_HOME="$HOME/.local/share/cargo"
        export RUSTUP_HOME="$HOME/.local/share/rustup"
        export PATH="$CARGO_HOME/bin:$PATH"
        
        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1
    
    if is_installed "rust"; then
        echo -e "${GREEN}[OK] Rust installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("rust")
        log_installation "rust" "success" "$logfile"
        cleanup_old_logs "rust"
        export CARGO_HOME="$HOME/.local/share/cargo"
        export RUSTUP_HOME="$HOME/.local/share/rustup"
        export PATH="$CARGO_HOME/bin:$PATH"
        return 0
    else
        echo -e "${RED}[FAIL] Rust installation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("rust")
        FAILED_INSTALL_LOGS["rust"]="$logfile"
        log_installation "rust" "failure" "$logfile"
        return 1
    fi
}

# Python Virtual Environment
install_python_venv() {
    local logfile=$(create_tool_log "python_venv")
    
    {
        echo "=========================================="
        echo "Creating Python Virtual Environment"
        echo "Started: $(date)"
        echo "=========================================="
        
        echo "Creating venv..."
        python3 -m venv "$XDG_DATA_HOME/virtualenvs/tools" || return 1
        
        echo "Activating venv..."
        source "$XDG_DATA_HOME/virtualenvs/tools/bin/activate" || return 1
        
        echo "Upgrading pip, wheel, setuptools..."
        pip install --upgrade pip wheel setuptools || return 1
        
        deactivate
        
        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1
    
    if is_installed "python_venv"; then
        echo -e "${GREEN}[OK] Python virtual environment created${NC}"
        SUCCESSFUL_INSTALLS+=("python_venv")
        log_installation "python_venv" "success" "$logfile"
        cleanup_old_logs "python_venv"
        return 0
    else
        echo -e "${RED}[FAIL] Python venv creation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("python_venv")
        FAILED_INSTALL_LOGS["python_venv"]="$logfile"
        log_installation "python_venv" "failure" "$logfile"
        return 1
    fi
}

# Helper function for Python tools
create_python_wrapper() {
    local tool=$1
    
    cat > "$HOME/.local/bin/$tool" << WRAPPER_EOF
#!/bin/bash
source \$XDG_DATA_HOME/virtualenvs/tools/bin/activate
$tool "\$@"
WRAPPER_EOF
    
    chmod +x "$HOME/.local/bin/$tool"
}

# Generic Python tool installer
install_python_tool() {
    local tool=$1
    local pip_package=$2
    local logfile=$(create_tool_log "$tool")
    
    {
        echo "=========================================="
        echo "Installing $tool"
        echo "Started: $(date)"
        echo "=========================================="
        
        source "$XDG_DATA_HOME/virtualenvs/tools/bin/activate" || return 1
        
        echo "Installing $pip_package..."
        pip install --quiet "$pip_package" || return 1
        
        deactivate
        
        echo "Creating wrapper script..."
        create_python_wrapper "$tool"
        
        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1
    
    if is_installed "$tool"; then
        echo -e "${GREEN}[OK] $tool installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("$tool")
        log_installation "$tool" "success" "$logfile"
        cleanup_old_logs "$tool"
        return 0
    else
        echo -e "${RED}[FAIL] $tool installation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("$tool")
        FAILED_INSTALL_LOGS["$tool"]="$logfile"
        log_installation "$tool" "failure" "$logfile"
        return 1
    fi
}

# Convenience wrappers for Python tools
install_sherlock() { install_python_tool "sherlock" "sherlock-project"; }
install_holehe() { install_python_tool "holehe" "holehe"; }
install_socialscan() { install_python_tool "socialscan" "socialscan"; }
install_h8mail() { install_python_tool "h8mail" "h8mail"; }
install_photon() { install_python_tool "photon" "photon-python"; }
install_sublist3r() { install_python_tool "sublist3r" "sublist3r"; }
install_shodan() { install_python_tool "shodan" "shodan"; }
install_censys() { install_python_tool "censys" "censys"; }
install_theHarvester() { install_python_tool "theHarvester" "theHarvester"; }
install_spiderfoot() { install_python_tool "spiderfoot" "spiderfoot"; }
install_wappalyzer() { install_python_tool "wappalyzer" "python-Wappalyzer"; }

# YARA with fallback
install_yara() {
    local logfile=$(create_tool_log "yara")
    
    {
        echo "=========================================="
        echo "Installing YARA"
        echo "Started: $(date)"
        echo "=========================================="
        
        source "$XDG_DATA_HOME/virtualenvs/tools/bin/activate" || return 1
        
        echo "Attempting to install yara-python..."
        pip install --quiet yara-python
        
        # Test if it works
        if ! python3 -c "import yara" 2>/dev/null; then
            echo "yara-python failed, building YARA C library..."
            
            mkdir -p "$HOME/opt/src"
            cd "$HOME/opt/src" || return 1
            
            local filename="v4.5.0.tar.gz"
            local url="https://github.com/VirusTotal/yara/archive/${filename}"
            
            if ! download_file "$url" "$filename"; then
                echo "ERROR: Failed to download YARA source"
                return 1
            fi
            
            tar -xzf "$filename" || return 1
            cd yara-4.5.0 || return 1
            ./bootstrap.sh || return 1
            ./configure --prefix="$HOME/.local" || return 1
            make || return 1
            make install || return 1
            
            cd "$HOME/opt/src" || return 1
            rm -rf yara-4.5.0 v4.5.0.tar.gz
            
            pip install --quiet yara-python || return 1
        fi
        
        deactivate
        
        echo "Creating wrapper script..."
        create_python_wrapper "yara"
        
        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1
    
    if is_installed "yara"; then
        echo -e "${GREEN}[OK] YARA installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("yara")
        log_installation "yara" "success" "$logfile"
        cleanup_old_logs "yara"
        return 0
    else
        echo -e "${RED}[FAIL] YARA installation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("yara")
        FAILED_INSTALL_LOGS["yara"]="$logfile"
        log_installation "yara" "failure" "$logfile"
        return 1
    fi
}

# Generic Go tool installer
install_go_tool() {
    local tool=$1
    local repo=$2
    local logfile=$(create_tool_log "$tool")
    
    {
        echo "=========================================="
        echo "Installing $tool"
        echo "Started: $(date)"
        echo "=========================================="
        
        export GOROOT="$HOME/opt/go"
        export GOPATH="$HOME/opt/gopath"
        export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"
        mkdir -p "$GOPATH"
        
        echo "Compiling $tool from source..."
        go install "$repo@latest" || return 1
        
        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1
    
    if is_installed "$tool"; then
        echo -e "${GREEN}[OK] $tool installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("$tool")
        log_installation "$tool" "success" "$logfile"
        cleanup_old_logs "$tool"
        return 0
    else
        echo -e "${RED}[FAIL] $tool installation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("$tool")
        FAILED_INSTALL_LOGS["$tool"]="$logfile"
        log_installation "$tool" "failure" "$logfile"
        return 1
    fi
}

# Convenience wrappers for Go tools
install_gobuster() { install_go_tool "gobuster" "github.com/OJ/gobuster/v3"; }
install_ffuf() { install_go_tool "ffuf" "github.com/ffuf/ffuf/v2"; }
install_httprobe() { install_go_tool "httprobe" "github.com/tomnomnom/httprobe"; }
install_waybackurls() { install_go_tool "waybackurls" "github.com/tomnomnom/waybackurls"; }
install_assetfinder() { install_go_tool "assetfinder" "github.com/tomnomnom/assetfinder"; }
install_subfinder() { install_go_tool "subfinder" "github.com/projectdiscovery/subfinder/v2/cmd/subfinder"; }
install_nuclei() { install_go_tool "nuclei" "github.com/projectdiscovery/nuclei/v3/cmd/nuclei"; }
install_virustotal() { install_go_tool "virustotal" "github.com/VirusTotal/vt-cli/vt"; }

# Node.js tool installer
install_node_tool() {
    local tool=$1
    local npm_package=$2
    local logfile=$(create_tool_log "$tool")
    
    {
        echo "=========================================="
        echo "Installing $tool"
        echo "Started: $(date)"
        echo "=========================================="
        
        export PATH="$HOME/opt/node/bin:$PATH"
        
        echo "Installing $npm_package..."
        npm install -g "$npm_package" || return 1
        
        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1
    
    if is_installed "$tool"; then
        echo -e "${GREEN}[OK] $tool installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("$tool")
        log_installation "$tool" "success" "$logfile"
        cleanup_old_logs "$tool"
        return 0
    else
        echo -e "${RED}[FAIL] $tool installation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("$tool")
        FAILED_INSTALL_LOGS["$tool"]="$logfile"
        log_installation "$tool" "failure" "$logfile"
        return 1
    fi
}

install_trufflehog() { install_node_tool "trufflehog" "@trufflesecurity/trufflehog"; }
install_git-hound() { install_node_tool "git-hound" "git-hound"; }
install_jwt-cracker() { install_node_tool "jwt-cracker" "jwt-cracker"; }

# Rust tool installer
install_rust_tool() {
    local tool=$1
    local crate=$2
    local logfile=$(create_tool_log "$tool")
    
    echo -e "${YELLOW}Compiling $tool (may take 5-10 minutes)...${NC}"
    
    {
        echo "=========================================="
        echo "Installing $tool"
        echo "Started: $(date)"
        echo "=========================================="
        
        export CARGO_HOME="$HOME/.local/share/cargo"
        export RUSTUP_HOME="$HOME/.local/share/rustup"
        export PATH="$CARGO_HOME/bin:$PATH"
        
        echo "Compiling $crate from source..."
        cargo install "$crate" || return 1
        
        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1
    
    if is_installed "$tool"; then
        echo -e "${GREEN}[OK] $tool installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("$tool")
        log_installation "$tool" "success" "$logfile"
        cleanup_old_logs "$tool"
        return 0
    else
        echo -e "${RED}[FAIL] $tool installation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("$tool")
        FAILED_INSTALL_LOGS["$tool"]="$logfile"
        log_installation "$tool" "failure" "$logfile"
        return 1
    fi
}

install_feroxbuster() { install_rust_tool "feroxbuster" "feroxbuster"; }
install_rustscan() { install_rust_tool "rustscan" "rustscan"; }
install_ripgrep() { install_rust_tool "ripgrep" "ripgrep"; }
install_fd() { install_rust_tool "fd" "fd-find"; }
install_bat() { install_rust_tool "bat" "bat"; }
install_sd() { install_rust_tool "sd" "sd"; }
install_tokei() { install_rust_tool "tokei" "tokei"; }
install_dog() { install_rust_tool "dog" "dog"; }

# ===== ORCHESTRATION =====

install_tool() {
    local tool=$1
    
    # Check if already installed
    if is_installed "$tool"; then
        echo -e "${GREEN}[OK] $tool already installed${NC}"
        return 0
    fi
    
    # Check dependencies
    if ! check_dependencies "$tool"; then
        echo -e "${RED}[FAIL] Failed to install dependencies for $tool${NC}"
        return 1
    fi
    
    # Install the tool
    echo -e "${CYAN}Installing $tool...${NC}"
    
    case "$tool" in
        cmake) install_cmake ;;
        github_cli) install_github_cli ;;
        go) install_go ;;
        nodejs) install_nodejs ;;
        rust) install_rust ;;
        python_venv) install_python_venv ;;
        sherlock) install_sherlock ;;
        holehe) install_holehe ;;
        socialscan) install_socialscan ;;
        h8mail) install_h8mail ;;
        photon) install_photon ;;
        sublist3r) install_sublist3r ;;
        shodan) install_shodan ;;
        censys) install_censys ;;
        theHarvester) install_theHarvester ;;
        spiderfoot) install_spiderfoot ;;
        yara) install_yara ;;
        wappalyzer) install_wappalyzer ;;
        gobuster) install_gobuster ;;
        ffuf) install_ffuf ;;
        httprobe) install_httprobe ;;
        waybackurls) install_waybackurls ;;
        assetfinder) install_assetfinder ;;
        subfinder) install_subfinder ;;
        nuclei) install_nuclei ;;
        virustotal) install_virustotal ;;
        trufflehog) install_trufflehog ;;
        git-hound) install_git-hound ;;
        jwt-cracker) install_jwt-cracker ;;
        feroxbuster) install_feroxbuster ;;
        rustscan) install_rustscan ;;
        ripgrep) install_ripgrep ;;
        fd) install_fd ;;
        bat) install_bat ;;
        sd) install_sd ;;
        tokei) install_tokei ;;
        dog) install_dog ;;
        *)
            echo -e "${RED}Unknown tool: $tool${NC}"
            return 1
            ;;
    esac
}

# ===== ORCHESTRATION - INSTALL ALL =====

install_all() {
    echo -e "${YELLOW}Installing ALL tools...${NC}"
    echo -e "${YELLOW}This will take 30-60 minutes and use ~2GB disk space${NC}"
    read -p "Continue? (yes/no): " confirm
    
    if [[ "$confirm" != "yes" ]]; then
        echo "Installation cancelled"
        return 1
    fi
    
    local all_tools=(
        "cmake" "github_cli" "go" "nodejs" "rust" "python_venv"
        "${ALL_PYTHON_TOOLS[@]}"
        "${ALL_GO_TOOLS[@]}"
        "${NODE_TOOLS[@]}"
        "${ALL_RUST_TOOLS[@]}"
    )
    
    for tool in "${all_tools[@]}"; do
        install_tool "$tool"
    done
}

# ===== MENU SYSTEM =====

show_menu() {
    clear
    print_shell_reload_reminder
    echo -e "${BLUE}=========================================="
    echo "Security Tools Installer v${SCRIPT_VERSION}"
    echo -e "==========================================${NC}"
    echo ""
    echo -e "${MAGENTA}BUILD TOOLS${NC}"
    echo "  [1] CMake"
    echo "  [2] GitHub CLI"
    echo ""
    echo -e "${MAGENTA}LANGUAGES & RUNTIMES${NC}"
    echo "  [3] Go"
    echo "  [4] Node.js"
    echo "  [5] Rust (compile time: 5-10 min)"
    echo ""
    echo -e "${MAGENTA}PYTHON TOOLS - OSINT${NC}"
    echo "  [6] Python Virtual Environment (required)"
    echo "  [7] sherlock - Username search"
    echo "  [8] holehe - Email verification"
    echo "  [9] socialscan - Username/email availability"
    echo "  [10] theHarvester - Multi-source OSINT"
    echo "  [11] spiderfoot - Automated OSINT"
    echo "  [12] All Python OSINT Tools"
    echo ""
    echo -e "${MAGENTA}PYTHON TOOLS - CTI${NC}"
    echo "  [13] shodan - Internet device intelligence"
    echo "  [14] censys - Certificate/service intelligence"
    echo "  [15] yara - Malware pattern matching"
    echo "  [16] All Python CTI Tools"
    echo ""
    echo -e "${MAGENTA}GO TOOLS - ACTIVE RECON${NC}"
    echo "  [17] gobuster - Directory/DNS bruteforcing"
    echo "  [18] ffuf - Fast web fuzzer"
    echo "  [19] subfinder - Subdomain discovery"
    echo "  [20] nuclei - Vulnerability scanner"
    echo "  [21] All Go Tools"
    echo ""
    echo -e "${MAGENTA}GO TOOLS - CTI${NC}"
    echo "  [22] virustotal - VirusTotal CLI"
    echo ""
    echo -e "${MAGENTA}NODE.JS TOOLS${NC}"
    echo "  [23] trufflehog - Secret scanning"
    echo "  [24] All Node.js Tools"
    echo ""
    echo -e "${MAGENTA}RUST TOOLS${NC}"
    echo "  [25] feroxbuster - Content discovery"
    echo "  [26] rustscan - Fast port scanner"
    echo "  [27] ripgrep - Fast grep"
    echo "  [28] All Rust Tools (long compile time)"
    echo ""
    echo -e "${MAGENTA}BULK OPTIONS${NC}"
    echo "  [30] Install Everything"
    echo ""
    echo -e "${MAGENTA}OTHER OPTIONS${NC}"
    echo "  [40] Show installed tools"
    echo "  [41] Show installation logs"
    echo "  [42] Exit"
    echo ""
    echo -n "Enter selection (comma-separated for multiple): "
}

process_menu_selection() {
    local selection=$1
    
    case "$selection" in
        1) install_tool "cmake" ;;
        2) install_tool "github_cli" ;;
        3) install_tool "go" ;;
        4) install_tool "nodejs" ;;
        5) install_tool "rust" ;;
        6) install_tool "python_venv" ;;
        7) install_tool "sherlock" ;;
        8) install_tool "holehe" ;;
        9) install_tool "socialscan" ;;
        10) install_tool "theHarvester" ;;
        11) install_tool "spiderfoot" ;;
        12)
            install_tool "python_venv"
            for tool in "${ALL_PYTHON_TOOLS[@]}"; do
                install_tool "$tool"
            done
            ;;
        13) install_tool "shodan" ;;
        14) install_tool "censys" ;;
        15) install_tool "yara" ;;
        16)
            install_tool "python_venv"
            for tool in shodan censys yara; do
                install_tool "$tool"
            done
            ;;
        17) install_tool "gobuster" ;;
        18) install_tool "ffuf" ;;
        19) install_tool "subfinder" ;;
        20) install_tool "nuclei" ;;
        21)
            install_tool "go"
            for tool in "${ALL_GO_TOOLS[@]}"; do
                install_tool "$tool"
            done
            ;;
        22) install_tool "virustotal" ;;
        23) install_tool "trufflehog" ;;
        24)
            install_tool "nodejs"
            for tool in "${NODE_TOOLS[@]}"; do
                install_tool "$tool"
            done
            ;;
        25) install_tool "feroxbuster" ;;
        26) install_tool "rustscan" ;;
        27) install_tool "ripgrep" ;;
        28)
            echo -e "${YELLOW}Warning: Rust tools take 15-30 minutes to compile${NC}"
            read -p "Continue? (yes/no): " confirm
            if [[ "$confirm" == "yes" ]]; then
                install_tool "rust"
                for tool in "${ALL_RUST_TOOLS[@]}"; do
                    install_tool "$tool"
                done
            fi
            ;;
        30) install_all ;;
        40) show_installed ;;
        41) show_logs ;;
        42) exit 0 ;;
        *)
            echo -e "${RED}Invalid selection: $selection${NC}"
            ;;
    esac
}

show_installed() {
    echo ""
    echo -e "${BLUE}=========================================="
    echo "Installed Tools"
    echo -e "==========================================${NC}"
    echo ""
    
    echo -e "${MAGENTA}BUILD TOOLS:${NC}"
    for tool in "${BUILD_TOOLS[@]}"; do
        if [[ "${INSTALLED_STATUS[$tool]}" == "true" ]]; then
            echo -e "  ${GREEN}[OK]${NC} $tool"
        else
            echo -e "  ${RED}[FAIL]${NC} $tool"
        fi
    done
    
    echo ""
    echo -e "${MAGENTA}LANGUAGES:${NC}"
    for tool in "${LANGUAGES[@]}"; do
        if [[ "${INSTALLED_STATUS[$tool]}" == "true" ]]; then
            echo -e "  ${GREEN}[OK]${NC} $tool"
        else
            echo -e "  ${RED}[FAIL]${NC} $tool"
        fi
    done
    
    echo ""
    echo -e "${MAGENTA}PYTHON TOOLS:${NC}"
    if [[ "${INSTALLED_STATUS[python_venv]}" == "true" ]]; then
        echo -e "  ${GREEN}[OK]${NC} python_venv"
    else
        echo -e "  ${RED}[FAIL]${NC} python_venv"
    fi
    for tool in "${ALL_PYTHON_TOOLS[@]}"; do
        if [[ "${INSTALLED_STATUS[$tool]}" == "true" ]]; then
            echo -e "  ${GREEN}[OK]${NC} $tool"
        else
            echo -e "  ${RED}[FAIL]${NC} $tool"
        fi
    done
    
    echo ""
    echo -e "${MAGENTA}GO TOOLS:${NC}"
    for tool in "${ALL_GO_TOOLS[@]}"; do
        if [[ "${INSTALLED_STATUS[$tool]}" == "true" ]]; then
            echo -e "  ${GREEN}[OK]${NC} $tool"
        else
            echo -e "  ${RED}[FAIL]${NC} $tool"
        fi
    done
    
    echo ""
    echo -e "${MAGENTA}NODE.JS TOOLS:${NC}"
    for tool in "${NODE_TOOLS[@]}"; do
        if [[ "${INSTALLED_STATUS[$tool]}" == "true" ]]; then
            echo -e "  ${GREEN}[OK]${NC} $tool"
        else
            echo -e "  ${RED}[FAIL]${NC} $tool"
        fi
    done
    
    echo ""
    echo -e "${MAGENTA}RUST TOOLS:${NC}"
    for tool in "${ALL_RUST_TOOLS[@]}"; do
        if [[ "${INSTALLED_STATUS[$tool]}" == "true" ]]; then
            echo -e "  ${GREEN}[OK]${NC} $tool"
        else
            echo -e "  ${RED}[FAIL]${NC} $tool"
        fi
    done
    
    echo ""
}

show_logs() {
    echo ""
    echo -e "${BLUE}=========================================="
    echo "Installation Logs"
    echo -e "==========================================${NC}"
    echo ""
    echo "Log directory: $LOG_DIR"
    echo "History: $HISTORY_LOG"
    echo ""
    echo "Recent logs:"
    ls -lt "$LOG_DIR" 2>/dev/null | head -10
    echo ""
}

show_installation_summary() {
    echo ""
    echo -e "${BLUE}=========================================="
    echo "Installation Summary"
    echo -e "==========================================${NC}"
    
    if [ ${#SUCCESSFUL_INSTALLS[@]} -gt 0 ]; then
        echo ""
        echo -e "${GREEN}Successfully installed:${NC}"
        for tool in "${SUCCESSFUL_INSTALLS[@]}"; do
            echo -e "  ${GREEN}[OK]${NC} $tool"
        done
    fi
    
    if [ ${#FAILED_INSTALLS[@]} -gt 0 ]; then
        echo ""
        echo -e "${RED}Failed installations:${NC}"
        for tool in "${FAILED_INSTALLS[@]}"; do
            local logfile="${FAILED_INSTALL_LOGS[$tool]}"
            echo -e "  ${RED}[FAIL]${NC} $tool"
            echo "    Log: $logfile"
            echo "    View: cat $logfile"
        done
        
        echo ""
        echo "To retry failed installations:"
        echo "  bash $0 ${FAILED_INSTALLS[*]}"
    fi
    
    echo ""
    echo "Installation history: $HISTORY_LOG"
    echo ""
}

# ===== CLI PARAMETER HANDLING =====

process_cli_args() {
    local args=("$@")
    
    # Handle special keywords
    if [[ "${args[0]}" == "all" ]]; then
        install_all
        return
    fi
    
    if [[ "${args[0]}" == "--python-tools" ]]; then
        install_tool "python_venv"
        for tool in "${ALL_PYTHON_TOOLS[@]}"; do
            install_tool "$tool"
        done
        return
    fi
    
    if [[ "${args[0]}" == "--go-tools" ]]; then
        install_tool "go"
        for tool in "${ALL_GO_TOOLS[@]}"; do
            install_tool "$tool"
        done
        return
    fi
    
    if [[ "${args[0]}" == "--node-tools" ]]; then
        install_tool "nodejs"
        for tool in "${NODE_TOOLS[@]}"; do
            install_tool "$tool"
        done
        return
    fi
    
    if [[ "${args[0]}" == "--rust-tools" ]]; then
        install_tool "rust"
        for tool in "${ALL_RUST_TOOLS[@]}"; do
            install_tool "$tool"
        done
        return
    fi
    
    # Handle individual tool names
    for tool in "${args[@]}"; do
        install_tool "$tool"
    done
}

# ===== DRY RUN =====

dry_run_install() {
    local tool=$1
    local indent="${2:-  }"
    
    echo "${indent}[DRY RUN] Would install: $tool"
    
    # Check dependencies
    local deps=${TOOL_DEPENDENCIES[$tool]}
    if [[ -n "$deps" ]]; then
        echo "${indent}  Prerequisites:"
        for dep in $deps; do
            if is_installed "$dep"; then
                echo "${indent}    [OK] $dep (already installed)"
            else
                echo "${indent}    -> $dep (would be installed)"
                dry_run_install "$dep" "${indent}      "
            fi
        done
    fi
    
    # Show details
    local info=${TOOL_INFO[$tool]}
    local size=${TOOL_SIZES[$tool]}
    local location=${TOOL_INSTALL_LOCATION[$tool]}
    
    echo "${indent}  Download size: $size"
    echo "${indent}  Install location: $location"
    echo ""
}

# ===== MAIN ENTRY POINT =====

main() {
    trap handle_interrupt INT
    # Parse flags
    for arg in "$@"; do
        case "$arg" in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --check-updates)
                CHECK_UPDATES=true
                shift
                ;;
        esac
    done
    
    # Remove flags from arguments
    args=()
    for arg in "$@"; do
        if [[ "$arg" != "--dry-run" ]] && [[ "$arg" != "--check-updates" ]]; then
            args+=("$arg")
        fi
    done
    
    # Prerequisites check
    echo -e "${YELLOW}Checking prerequisites...${NC}"
    
    if [ ! -d "$HOME/.local/share" ] || [ ! -d "$HOME/.config" ] || [ ! -d "$HOME/.cache" ]; then
        echo -e "${RED}[FAIL] XDG directories not found!${NC}"
        echo ""
        echo "Please run the XDG setup script first:"
        echo "  bash xdg_setup.sh"
        echo "  source ~/.bashrc"
        echo ""
        exit 1
    fi
    
    if [ -z "$XDG_DATA_HOME" ] || [ -z "$XDG_CONFIG_HOME" ] || [ -z "$XDG_CACHE_HOME" ]; then
        echo -e "${YELLOW}[WARN] XDG environment variables not set${NC}"
        echo "Loading from defaults..."
        export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
        export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
        export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
        export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
        echo -e "${YELLOW}Note: Run 'source ~/.bashrc' after xdg_setup.sh${NC}"
        echo ""
    fi
    
    echo -e "${GREEN}[OK] Prerequisites met${NC}"
    echo ""
    
    # Fix wget config if missing
    if [ -n "$WGETRC" ] && [ ! -f "$WGETRC" ]; then
        echo -e "${YELLOW}Creating missing wget config...${NC}"
        mkdir -p "$(dirname "$WGETRC")"
        cat > "$WGETRC" << 'WGETRC_EOF'
# XDG-compliant wget configuration
dir_prefix = ~/Downloads
timestamping = on
tries = 3
retry_connrefused = on
max_redirect = 5
WGETRC_EOF
        echo -e "${GREEN}[OK] wget config created${NC}"
        echo ""
    fi
    
    # Create necessary directories
    mkdir -p "$HOME/opt/src"
    mkdir -p "$HOME/opt/gopath"
    
    # Initialize
    init_logging
    define_tools
    scan_installed_tools
    
    # Dry run mode
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${CYAN}DRY RUN MODE${NC}"
        echo ""
        for tool in "${args[@]}"; do
            dry_run_install "$tool"
        done
        exit 0
    fi
    
    # Check updates mode
    if [[ "$CHECK_UPDATES" == "true" ]]; then
        echo -e "${CYAN}Checking for updates...${NC}"
        echo "This feature is coming soon!"
        exit 0
    fi
    
    # Determine mode
    if [ ${#args[@]} -eq 0 ]; then
        # Interactive menu mode
        while true; do
            show_menu
            read -r selection
            
            # Handle comma-separated selections
            IFS=',' read -ra SELECTIONS <<< "$selection"
            for sel in "${SELECTIONS[@]}"; do
                sel=$(echo "$sel" | xargs)  # Trim whitespace
                process_menu_selection "$sel"
            done
            
            show_installation_summary
            
            echo ""
            read -p "Press Enter to continue..."
        done
    else
        # CLI parameter mode
        process_cli_args "${args[@]}"
        show_installation_summary
        print_shell_reload_reminder
    fi
}

main "$@"
print_shell_reload_reminder() {
    echo -e "${YELLOW}Reminder:${NC} Run 'source ~/.bashrc' or open a new shell so newly installed tools are on your PATH."
}

handle_interrupt() {
    echo ""
    print_shell_reload_reminder
    echo -e "${RED}Installation interrupted by user.${NC}"
    exit 130
}
