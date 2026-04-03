#!/bin/bash
# Security Tools Installer - Display Module
# Version: 1.4.1
# Purpose: Status and information display functions

# shellcheck disable=SC2012  # Using ls with timestamps is intentional for logs

# ===== DISPLAY FUNCTIONS =====

# Function: _tool_status_line
# Purpose: Print a status line for a single tool with three states:
#   [OK]   — binary found (installed)
#   [FAIL] — install was attempted this session and failed
#   [--]   — not installed, not attempted
# Parameters:
#   $1 - tool name
_tool_status_line() {
    local tool="$1"
    local in_failed=false
    local t
    if [ "${#FAILED_INSTALLS[@]}" -gt 0 ]; then
        for t in "${FAILED_INSTALLS[@]}"; do
            [[ "$t" == "$tool" ]] && in_failed=true && break
        done
    fi

    if [[ "${INSTALLED_STATUS[$tool]:-false}" == "true" ]]; then
        echo -e "  ${GREEN}[OK]${NC} $tool"
    elif $in_failed; then
        echo -e "  ${RED}[FAIL]${NC} $tool"
    else
        echo -e "  ${YELLOW}[--]${NC} $tool"
    fi
}

# Function: show_installed
# Purpose: Display installation status for all tools
# Returns: Always succeeds
show_installed() {
    echo ""
    echo -e "${BLUE}=========================================="
    echo "Installed Tools"
    echo -e "==========================================${NC}"
    echo ""

    echo -e "${MAGENTA}BUILD TOOLS:${NC}"
    for tool in "${BUILD_TOOLS[@]}"; do
        _tool_status_line "$tool"
    done

    echo ""
    echo -e "${MAGENTA}LANGUAGES:${NC}"
    for tool in "${LANGUAGES[@]}"; do
        _tool_status_line "$tool"
    done

    echo ""
    echo -e "${MAGENTA}PYTHON TOOLS:${NC}"
    _tool_status_line "python_venv"
    for tool in "${ALL_PYTHON_TOOLS[@]}"; do
        _tool_status_line "$tool"
    done

    echo ""
    echo -e "${MAGENTA}GO TOOLS:${NC}"
    for tool in "${ALL_GO_TOOLS[@]}"; do
        _tool_status_line "$tool"
    done

    echo ""
    echo -e "${MAGENTA}NODE.JS TOOLS:${NC}"
    for tool in "${NODE_TOOLS[@]}"; do
        _tool_status_line "$tool"
    done

    echo ""
    echo -e "${MAGENTA}RUST TOOLS:${NC}"
    for tool in "${ALL_RUST_TOOLS[@]}"; do
        _tool_status_line "$tool"
    done

    echo ""
}

# Function: show_logs
# Purpose: Display log locations and recent entries
# Returns: Always succeeds
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

# Function: show_installation_summary
# Purpose: Display post-install summary with success/failure counts
# Returns: Always succeeds
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
            local logfile="${FAILED_INSTALL_LOGS[$tool]:-}"
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
