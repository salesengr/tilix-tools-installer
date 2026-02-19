#!/bin/bash
# Security Tools Installer (OSINT/CTI/PenTest)
# Version: 1.3.0
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

# shellcheck disable=SC2034  # Variables used in sourced library modules
# shellcheck disable=SC1091  # Source files not specified (modular architecture)

# Disable exit on error for better error handling
set +e

# ===== SCRIPT DIRECTORY =====
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# ===== COLOR CODES =====
# Base colors for status
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;36m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'

# Semantic colors for UI (accessibility-enhanced)
BOLD='\033[1m'
HEADER='\033[1;36m'      # Bold cyan - header separator
CATEGORY='\033[1;34m'    # Bold blue - category headers (replaces MAGENTA)
INFO='\033[1;36m'        # Bold cyan - info/reminders (replaces YELLOW)
SUCCESS='\033[1;32m'     # Bold green - success messages
WARNING='\033[1;33m'     # Bold yellow - warnings
ERROR='\033[1;31m'       # Bold red - errors
NC='\033[0m'             # Reset

# Unicode symbols for redundant encoding (accessibility)
CHECK='\u2713'           # ✓
CROSS='\u2717'           # ✗
WARN='\u26a0'            # ⚠
INFOSYM='\u2139'         # ℹ

# ===== GLOBAL VARIABLES =====
SCRIPT_VERSION="1.3.3"
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

# ===== SOURCE LIBRARY MODULES =====

# Source in dependency order
source "${SCRIPT_DIR}/lib/core/logging.sh"
source "${SCRIPT_DIR}/lib/core/download.sh"
source "${SCRIPT_DIR}/lib/core/verification.sh"
source "${SCRIPT_DIR}/lib/core/dependencies.sh"
source "${SCRIPT_DIR}/lib/data/tool-definitions.sh"
source "${SCRIPT_DIR}/lib/installers/generic.sh"
source "${SCRIPT_DIR}/lib/installers/runtimes.sh"
source "${SCRIPT_DIR}/lib/installers/tools.sh"
source "${SCRIPT_DIR}/lib/ui/display.sh"
source "${SCRIPT_DIR}/lib/ui/menu.sh"
source "${SCRIPT_DIR}/lib/ui/orchestration.sh"

# ===== TARGETED FALLBACKS (legacy tool compatibility) =====

install_release_binary_with_log() {
    local tool="$1"
    local url="$2"
    local archive_name="$3"
    local extract_cmd="$4"
    local extracted_binary="$5"
    local output_binary="$6"
    local expected_sha256="${7:-}"  # Optional checksum parameter

    local logfile
    logfile=$(create_tool_log "$tool")

    {
        echo "=========================================="
        echo "Installing $tool (release fallback)"
        echo "Started: $(date)"
        echo "=========================================="

        local tmpdir
        tmpdir=$(mktemp -d)

        cd "$tmpdir" || return 1
        echo "Downloading: $url"
        download_file "$url" "$archive_name" || return 1
        verify_file_exists "$archive_name" "$tool archive" || return 1

        # Verify checksum if provided (supply-chain security)
        if [ -n "$expected_sha256" ]; then
            echo "Verifying SHA256 checksum for supply-chain security..."
            local actual_sha256
            actual_sha256=$(sha256sum "$archive_name" | awk '{print $1}')

            if [ "$actual_sha256" != "$expected_sha256" ]; then
                echo "ERROR: Checksum mismatch!"
                echo "  Expected: $expected_sha256"
                echo "  Actual:   $actual_sha256"
                echo "  This may indicate a compromised download."
                rm -rf "$tmpdir"
                return 1
            fi
            echo "Checksum verified: ${expected_sha256:0:16}..."
        else
            echo "WARNING: No checksum provided - supply-chain verification skipped"
        fi

        echo "Extracting..."
        eval "$extract_cmd" || return 1
        verify_file_exists "$extracted_binary" "$tool binary" || return 1

        mkdir -p "$HOME/.local/bin"
        install -m 0755 "$extracted_binary" "$HOME/.local/bin/$output_binary" || return 1

        rm -rf "$tmpdir"

        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1

    if command -v "$output_binary" >/dev/null 2>&1 || [ -x "$HOME/.local/bin/$output_binary" ]; then
        echo -e "${SUCCESS}${CHECK} $tool installed successfully (fallback)${NC}"
        SUCCESSFUL_INSTALLS+=("$tool")
        log_installation "$tool" "success" "$logfile"
        cleanup_old_logs "$tool"
        return 0
    fi

    echo -e "${ERROR}${CROSS} $tool fallback installation failed${NC}"
    echo "  See log: $logfile"
    FAILED_INSTALLS+=("$tool")
    FAILED_INSTALL_LOGS["$tool"]="$logfile"
    log_installation "$tool" "failure" "$logfile"
    return 1
}

# CHECKSUMS: Verify these SHA256 hashes against official release pages before deployment
# trufflehog v3.93.3:  https://github.com/trufflesecurity/trufflehog/releases/tag/v3.93.3
# git-hound v3.2:      https://github.com/tillson/git-hound/releases/tag/v3.2
# dog v0.1.0:          https://github.com/ogham/dog/releases/tag/v0.1.0
#
# To update checksums:
#   curl -sL <release-url> | sha256sum
#
# NOTE: Replace these placeholder values with actual checksums from official releases
CHECKSUM_TRUFFLEHOG="VERIFY_FROM_OFFICIAL_RELEASE"
CHECKSUM_GIT_HOUND="VERIFY_FROM_OFFICIAL_RELEASE"
CHECKSUM_DOG="VERIFY_FROM_OFFICIAL_RELEASE"

install_trufflehog() {
    # Preserve existing behavior first.
    install_node_tool "trufflehog" "@trufflesecurity/trufflehog" && return 0

    echo -e "${WARNING}${WARN} npm install failed for trufflehog; using release fallback${NC}"
    install_release_binary_with_log \
        "trufflehog" \
        "https://github.com/trufflesecurity/trufflehog/releases/download/v3.93.3/trufflehog_3.93.3_linux_amd64.tar.gz" \
        "trufflehog.tar.gz" \
        "tar -xzf trufflehog.tar.gz" \
        "trufflehog" \
        "trufflehog" \
        "$CHECKSUM_TRUFFLEHOG"
}

install_git-hound() {
    # Preserve existing behavior first.
    install_node_tool "git-hound" "git-hound" && return 0

    echo -e "${WARNING}${WARN} npm install failed for git-hound; using release fallback${NC}"
    install_release_binary_with_log \
        "git-hound" \
        "https://github.com/tillson/git-hound/releases/download/v3.2/git-hound_linux_amd64.zip" \
        "git-hound.zip" \
        "unzip -o git-hound.zip" \
        "git-hound" \
        "git-hound" \
        "$CHECKSUM_GIT_HOUND"
}

install_dog() {
    # Preserve existing behavior first.
    install_rust_tool "dog" "dog" && return 0

    echo -e "${WARNING}${WARN} cargo install failed for dog; using release fallback${NC}"
    install_release_binary_with_log \
        "dog" \
        "https://github.com/ogham/dog/releases/download/v0.1.0/dog-v0.1.0-x86_64-unknown-linux-gnu.zip" \
        "dog.zip" \
        "unzip -o dog.zip" \
        "bin/dog" \
        "dog" \
        "$CHECKSUM_DOG"
}

# ===== SIGNAL HANDLERS =====

# Function: handle_interrupt
# Purpose: Handle Ctrl+C gracefully
handle_interrupt() {
    echo ""
    print_shell_reload_reminder
    echo -e "${RED}Installation interrupted by user.${NC}"
    exit 130
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
        echo -e "${YELLOW}Note: Run 'source ~/.bashrc' after xdg_setup.sh${NC}"
        echo ""
    fi

    # Ensure sane runtime defaults for non-interactive shells too
    export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
    export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
    export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
    export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

    export GOPATH="${GOPATH:-$HOME/opt/gopath}"
    export CARGO_HOME="${CARGO_HOME:-$XDG_DATA_HOME/cargo}"
    export RUSTUP_HOME="${RUSTUP_HOME:-$XDG_DATA_HOME/rustup}"
    export WGETRC="${WGETRC:-$XDG_CONFIG_HOME/wget/wgetrc}"

    export PATH="$HOME/.local/bin:$HOME/opt/node/bin:$GOPATH/bin:$CARGO_HOME/bin:$PATH"

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
        # Verify stdin is connected to a terminal
        if [ ! -t 0 ]; then
            # Try to reconnect to /dev/tty
            if [ -c /dev/tty ]; then
                echo -e "${YELLOW}Note: Reconnecting stdin to /dev/tty for interactive menu${NC}"
                exec bash "$0" < /dev/tty
            fi

            echo -e "${RED}Error: stdin is not connected to a terminal${NC}"
            echo ""
            echo "This script requires an interactive terminal to run the menu."
            echo ""
            echo "Solutions:"
            echo "  1. Run directly: bash install_security_tools.sh"
            echo "  2. Use CLI mode: bash install_security_tools.sh <tool-name>"
            echo "  3. If piping via curl, save and run: curl -O URL && bash install_security_tools.sh"
            echo ""
            exit 1
        fi

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
            read -r -p "Press Enter to continue..."
        done
    else
        # CLI parameter mode
        process_cli_args "${args[@]}"
        show_installation_summary
        print_shell_reload_reminder
    fi
}

main "$@"
