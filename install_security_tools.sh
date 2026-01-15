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

# Disable exit on error for better error handling
set +e

# ===== SCRIPT DIRECTORY =====
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# ===== COLOR CODES =====
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;36m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# ===== GLOBAL VARIABLES =====
SCRIPT_VERSION="1.3.2"
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
