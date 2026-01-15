#!/bin/bash
# Security Tools Installer - Verification Module
# Version: 1.3.0
# Purpose: Installation status checking and environment validation

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
# Purpose: Verify system Go is available before installing Go tools
# Returns: 0 if Go is available, 1 if not found
# Side effects: Prints Go version if found, error message if missing
verify_system_go() {
    if ! command -v go &>/dev/null; then
        echo -e "${RED}ERROR: Go is not installed on this system${NC}"
        echo "Go tools require a system Go installation (expected at /usr/local/go)"
        echo "Please ensure Go is installed before attempting to install Go tools."
        return 1
    fi

    local go_version
    go_version=$(go version 2>/dev/null | awk '{print $3}')
    echo -e "${GREEN}System Go found: ${go_version}${NC}"
    return 0
}
