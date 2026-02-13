#!/bin/bash
# Security Tools Installer - Dependencies Module
# Version: 1.3.0
# Purpose: Automated prerequisite handling and dependency resolution

# ===== DEPENDENCY RESOLUTION =====

# Function: check_dependencies
# Purpose: Resolve and install prerequisites for a tool
# Parameters: $1 - tool name
# Returns: 0 if all dependencies satisfied, 1 on failure
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
