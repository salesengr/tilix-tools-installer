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
        echo -e "${INFO}⬇ Downloading... (attempt $((retry + 1))/$max_retries)${NC}"

        if wget --progress=bar:force --show-progress "$url" -O "$output" 2>&1; then
            if [ -f "$output" ]; then
                # Verify file size (detect truncated/failed downloads)
                local filesize
                filesize=$(stat -f%z "$output" 2>/dev/null || stat -c%s "$output" 2>/dev/null || echo "0")

                if [ "$filesize" -eq 0 ]; then
                    echo -e "${ERROR}${CROSS} Downloaded file is empty${NC}"
                    rm -f "$output"
                    retry=$((retry + 1))
                    continue
                elif [ "$filesize" -lt 100 ]; then
                    echo -e "${WARNING}${WARN} Downloaded file suspiciously small: $filesize bytes${NC}"
                    echo -e "${WARNING}This may indicate an error page or failed download${NC}"
                    rm -f "$output"
                    retry=$((retry + 1))
                    continue
                fi

                echo -e "${SUCCESS}${CHECK} Download complete ($filesize bytes)${NC}"
                return 0
            fi
        fi

        retry=$((retry + 1))
        if [ $retry -lt $max_retries ]; then
            echo -e "${WARNING}${WARN} Download failed, retrying in 2 seconds...${NC}"
            sleep 2
        fi
    done

    echo -e "${ERROR}${CROSS} Failed to download after $max_retries attempts${NC}"
    echo "  URL: $url"
    return 1
}

# Function: verify_file_exists
# Purpose: Verify file exists and has valid size before processing
# Parameters:
#   $1 - filepath to check
#   $2 - description (for error message)
#   $3 - minimum size in bytes (optional, default: 1)
# Returns: 0 if file exists and meets size requirement, 1 otherwise
verify_file_exists() {
    local filepath=$1
    local description=$2
    local min_size=${3:-1}  # Default minimum size: 1 byte (not empty)

    if [ ! -f "$filepath" ]; then
        echo "ERROR: $description not found: $filepath"
        return 1
    fi

    # Check file size
    local filesize
    filesize=$(stat -f%z "$filepath" 2>/dev/null || stat -c%s "$filepath" 2>/dev/null || echo "0")

    if [ "$filesize" -lt "$min_size" ]; then
        echo "ERROR: $description is too small: $filesize bytes (minimum: $min_size bytes)"
        echo "  File: $filepath"
        return 1
    fi

    return 0
}
