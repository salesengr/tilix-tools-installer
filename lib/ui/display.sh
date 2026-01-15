#!/bin/bash
# Security Tools Installer - Display Module
# Version: 1.3.0
# Purpose: Status and information display functions

# ===== DISPLAY FUNCTIONS =====

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
