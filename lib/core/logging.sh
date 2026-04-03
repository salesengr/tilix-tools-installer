#!/bin/bash
# Security Tools Installer - Logging Module
# Version: 1.4.1
# Purpose: Centralized logging operations for installation tracking and history
# shellcheck disable=SC2034  # FAILED_INSTALL_LOGS used in sourced installer modules

# ===== LOGGING FUNCTIONS =====

# Function: init_logging
# Purpose: Initialize logging directories and start installation session
# Returns: Always succeeds
init_logging() {
    mkdir -p "$LOG_DIR"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Installation session started" >> "$HISTORY_LOG"
}

# Function: create_tool_log
# Purpose: Generate timestamped log filename for a tool
# Parameters: $1 - tool name
# Returns: Path to log file
create_tool_log() {
    local tool=$1
    local timestamp
    timestamp=$(date +%Y%m%d_%H%M%S)
    echo "$LOG_DIR/${tool}-${timestamp}.log"
}

# Function: cleanup_old_logs
# Purpose: Keep only the 10 most recent logs per tool
# Parameters: $1 - tool name
# Returns: Always succeeds
cleanup_old_logs() {
    local tool=$1
    # Use absolute path to avoid cd-based directory side effects
    find "${LOG_DIR}" -maxdepth 1 -name "${tool}-*.log" -type f -printf '%T@ %p\n' 2>/dev/null | \
        sort -rn | tail -n +11 | cut -d' ' -f2- | xargs -r rm
}

# Function: log_installation
# Purpose: Record installation result to history log
# Parameters:
#   $1 - tool name
#   $2 - status (success/failure)
#   $3 - logfile path
# Returns: Always succeeds
# Function: _record_install_result
# Purpose: Record success/failure after an install block completes.
#          Centralizes SUCCESSFUL_INSTALLS / FAILED_INSTALLS bookkeeping.
# Parameters: $1 - tool name, $2 - logfile path
# Returns: 0 on success, 1 on failure (mirrors is_installed result)
_record_install_result() {
    local tool=$1 logfile=$2
    if is_installed "$tool"; then
        echo -e "${SUCCESS}${CHECK} ${tool} installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("$tool")
        log_installation "$tool" "success" "$logfile"
        cleanup_old_logs "$tool"
        return 0
    else
        echo -e "${ERROR}${CROSS} ${tool} installation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("$tool")
        FAILED_INSTALL_LOGS["$tool"]="$logfile"
        log_installation "$tool" "failure" "$logfile"
        return 1
    fi
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
