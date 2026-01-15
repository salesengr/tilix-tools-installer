#!/bin/bash
# Security Tools Installer - Download Module
# Version: 1.3.0
# Purpose: Reliable file downloads with retry logic and verification

# ===== DOWNLOAD FUNCTIONS =====

# Function: download_file
# Purpose: Download file with retry and verification
# Parameters:
#   $1 - url to download from
#   $2 - output file path
# Returns: 0 on success, 1 on failure
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

# Function: verify_file_exists
# Purpose: Verify file exists before processing
# Parameters:
#   $1 - filepath to check
#   $2 - description (for error message)
# Returns: 0 if file exists, 1 otherwise
verify_file_exists() {
    local filepath=$1
    local description=$2

    if [ ! -f "$filepath" ]; then
        echo "ERROR: $description not found: $filepath"
        return 1
    fi

    return 0
}
