#!/bin/bash
# Security Tools Installer - Download Module
# Version: 1.4.1
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

        if wget --https-only --secure-protocol=TLSv1_2 --progress=bar:force --show-progress "$url" -O "$output" 2>&1; then
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

# Function: verify_sha256
# Purpose: Verify a downloaded file against a SHA256 companion URL.
# Parameters:
#   $1 - local filename to verify
#   $2 - URL of the .sha256 companion file (or empty to skip)
# Returns:
#   0 — verified OK
#   1 — hash mismatch (file is corrupt or tampered — abort install)
#   2 — companion unavailable (upstream doesn't publish one — caller decides)
#
# Callers where the companion SHOULD always exist (Go, CMake) use || return 1
# so rc=2 is treated as fatal. Callers where it MAY not exist (rustscan, sd,
# qtox) check [ $? -eq 1 ] so rc=2 is non-fatal.
verify_sha256() {
    local filename=$1
    local sha256_url=${2:-}
    local sha256_file="${filename}.sha256"

    if [[ -z "$sha256_url" ]]; then
        echo "WARNING: No SHA256 URL provided for ${filename} — skipping checksum verification"
        return 2
    fi

    if curl --proto '=https' --tlsv1.2 -fsSL "$sha256_url" -o "$sha256_file" 2>/dev/null && [ -s "$sha256_file" ]; then
        local expected actual
        expected=$(awk '{print $1}' "$sha256_file")
        actual=$(sha256sum "$filename" | awk '{print $1}')
        rm -f "$sha256_file"
        if [ "$expected" != "$actual" ]; then
            echo "ERROR: SHA256 verification FAILED for $filename"
            echo "  Expected: $expected"
            echo "  Got:      $actual"
            return 1
        fi
        echo "SHA256 verified OK"
        return 0
    fi

    rm -f "$sha256_file" 2>/dev/null || true
    echo "WARNING: SHA256 companion not available at ${sha256_url} — skipping checksum verification"
    return 2
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
