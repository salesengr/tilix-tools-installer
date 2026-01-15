#!/bin/bash
# Security Tools Installer - Logging Module
# Version: 1.3.0
# Purpose: Centralized logging operations for installation tracking and history

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
    local timestamp=$(date +%Y%m%d_%H%M%S)
    echo "$LOG_DIR/${tool}-${timestamp}.log"
}

# Function: cleanup_old_logs
# Purpose: Keep only the 10 most recent logs per tool
# Parameters: $1 - tool name
# Returns: Always succeeds
cleanup_old_logs() {
    local tool=$1
    cd "$LOG_DIR" 2>/dev/null || return
    ls -t ${tool}-*.log 2>/dev/null | tail -n +11 | xargs -r rm
}

# Function: log_installation
# Purpose: Record installation result to history log
# Parameters:
#   $1 - tool name
#   $2 - status (success/failure)
#   $3 - logfile path
# Returns: Always succeeds
log_installation() {
    local tool=$1
    local status=$2
    local logfile=$3

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $tool - $status" >> "$HISTORY_LOG"

    if [[ "$status" == "failure" ]]; then
        echo "  Log: $logfile" >> "$HISTORY_LOG"
    fi
}
