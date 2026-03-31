#!/bin/bash
# Security Tools Installer - Verification Module
# Version: 1.3.0
# Purpose: Installation status checking and environment validation

# shellcheck disable=SC2034  # INSTALLED_STATUS used in parent script
# shellcheck disable=SC2004  # Array indices require $ for variable expansion

# ===== INSTALLATION STATUS CHECKS =====

# Function: is_installed
# Purpose: Check if a tool is installed
# Parameters: $1 - tool name
# Returns: 0 if installed, 1 otherwise
is_installed() {
    local tool=$1

    case "$tool" in
        cmake)
            [ -f "$HOME/.local/bin/cmake" ] && return 0 ;;
        github_cli)
            [ -f "$HOME/.local/bin/gh" ] && return 0 ;;
        go_runtime)
            [ -f "$HOME/opt/go/bin/go" ] && return 0
            [ -f "/usr/local/go/bin/go" ] && return 0 ;;
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
            [ -f "$HOME/opt/node/bin/$tool" ] && return 0 ;;
        # Rust tools
        feroxbuster|rustscan|sd|tokei|dog)
            command -v "$tool" &>/dev/null && return 0 ;;
        ripgrep)
            command -v rg &>/dev/null && return 0 ;;
        fd)
            command -v fd &>/dev/null && return 0 ;;
        bat)
            command -v bat &>/dev/null && return 0 ;;
        # Utility tools
        aria2)
            [ -f "$HOME/.local/bin/aria2c" ] && return 0 ;;
    esac

    return 1
}

# Function: scan_installed_tools
# Purpose: Populate INSTALLED_STATUS array with current installation state
# Returns: Always succeeds
scan_installed_tools() {
    for tool in "${!TOOL_INFO[@]}"; do
        if is_installed "$tool"; then
            INSTALLED_STATUS[$tool]="true"
        else
            INSTALLED_STATUS[$tool]="false"
        fi
    done
}

# Function: verify_system_go
# Purpose: Verify Go is available (system or user-space install)
#          Auto-installs user-space Go runtime if not found.
# Returns: 0 if Go is available, 1 if not found and install failed
verify_system_go() {
    # Check user-space install first
    if [ -f "$HOME/opt/go/bin/go" ]; then
        export GOROOT="$HOME/opt/go"
        export GOPATH="$HOME/opt/gopath"
        export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"
        mkdir -p "$GOPATH"
    fi

    if command -v go &>/dev/null; then
        local go_version
        go_version=$(go version 2>/dev/null | awk '{print $3}')
        echo -e "${GREEN}Go found: ${go_version}${NC}"
        return 0
    fi

    # Go not found — auto-install user-space runtime
    echo -e "${WARNING}${WARN} Go not found. Installing Go runtime automatically...${NC}"
    if install_go_runtime; then
        return 0
    fi

    echo -e "${ERROR}${CROSS} Go is not available and automatic install failed.${NC}"
    echo "Install Go manually or run: bash install_security_tools.sh go_runtime"
    return 1
}
