#!/bin/bash
# Security Tools Installer - Generic Installers Module
# Version: 1.4.0
# Purpose: Reusable generic installers for each language ecosystem

# shellcheck disable=SC2034  # FAILED_INSTALL_LOGS used in parent script
# shellcheck disable=SC1091  # Source files in virtualenvs (dynamic paths)

# ===== HELPER FUNCTIONS =====

# Function: _get_python_bin
# Purpose: Resolve best available Python binary (prefers 3.13+)
# Returns: python binary name via stdout
_get_python_bin() {
    if [ -f "$HOME/.local/share/.python_bin" ]; then
        cat "$HOME/.local/share/.python_bin"
        return
    fi
    for py in python3.13 python3.11 python3.10 python3.9 python3; do
        if command -v "$py" &>/dev/null; then echo "$py"; return; fi
    done
    echo "python3"
}

# Function: create_python_wrapper
# Purpose: Create a thin wrapper in ~/.local/bin that invokes the user-installed tool.
#          With pip --user, tools install their entry points to ~/.local/bin directly.
#          This wrapper is a fallback for tools that don't create entry points.
# Parameters: $1 - tool name
# Returns: Always succeeds
create_python_wrapper() {
    local tool=$1
    local python_bin
    python_bin=$(_get_python_bin)

    # If pip --user already placed an entry point, nothing to do
    if [ -x "$HOME/.local/bin/$tool" ]; then
        return 0
    fi

    # Create a minimal wrapper that invokes the module directly
    cat > "$HOME/.local/bin/$tool" << WRAPPER_EOF
#!/usr/bin/env bash
exec "$(_get_python_bin)" -m "${tool}" "\$@"
WRAPPER_EOF

    chmod +x "$HOME/.local/bin/$tool"
}

# ===== GENERIC INSTALLERS =====

# Function: install_python_tool
# Purpose: Generic Python tool installer using pip install --user (no venv)
#          Installs directly into user-space: ~/.local/lib/pythonX.Y/site-packages/
#          Entry points go to ~/.local/bin/ automatically.
# Parameters:
#   $1 - tool name
#   $2 - pip package name
# Returns: 0 on success, 1 on failure
install_python_tool() {
    local tool=$1
    local pip_package=$2
    local logfile
    logfile=$(create_tool_log "$tool")

    echo -e "${INFO}⚙ Installing $tool via pip --user...${NC}"

    {
        echo "=========================================="
        echo "Installing $tool"
        echo "Started: $(date)"
        echo "=========================================="

        local python_bin
        python_bin=$(_get_python_bin)
        echo "Using Python: $python_bin"

        mkdir -p "$HOME/.local/bin"
        export PATH="$HOME/.local/bin:$PATH"

        echo "Installing $pip_package..."
        "$python_bin" -m pip install --user --quiet "$pip_package" || return 1

        # Create wrapper if entry point wasn't placed by pip
        if [ ! -x "$HOME/.local/bin/$tool" ]; then
            echo "Creating wrapper script..."
            create_python_wrapper "$tool"
        fi

        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1

    if is_installed "$tool"; then
        echo -e "${SUCCESS}${CHECK} $tool installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("$tool")
        log_installation "$tool" "success" "$logfile"
        cleanup_old_logs "$tool"
        return 0
    else
        echo -e "${ERROR}${CROSS} $tool installation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("$tool")
        FAILED_INSTALL_LOGS["$tool"]="$logfile"
        log_installation "$tool" "failure" "$logfile"
        return 1
    fi
}

# Function: install_go_tool
# Purpose: Generic Go tool installer using system Go and user-space GOPATH
# Parameters:
#   $1 - tool name
#   $2 - Go repository path (e.g., "github.com/OJ/gobuster/v3")
# Returns: 0 on success, 1 on failure
# Dependencies: Requires system Go to be installed
install_go_tool() {
    local tool=$1
    local repo=$2
    local logfile
    logfile=$(create_tool_log "$tool")

    # Verify system Go is available
    if ! verify_system_go; then
        echo -e "${ERROR}${CROSS} Cannot install $tool: System Go not found${NC}"
        FAILED_INSTALLS+=("$tool")
        return 1
    fi

    echo -e "${INFO}🔨 Compiling from Go source...${NC}"

    {
        echo "=========================================="
        echo "Installing $tool"
        echo "Started: $(date)"
        echo "=========================================="

        # Use system Go, set user-space GOPATH
        export GOPATH="$HOME/opt/gopath"
        export PATH="$GOPATH/bin:$PATH"
        mkdir -p "$GOPATH"

        echo "Using system Go: $(go version)"
        echo "GOPATH: $GOPATH"
        echo ""
        echo "Compiling $tool from source..."
        go install "$repo@latest" || return 1

        # Symlink all binaries in GOPATH/bin to ~/.local/bin so they are on PATH
        mkdir -p "$HOME/.local/bin"
        for gobin in "$GOPATH"/bin/*; do
            [ -f "$gobin" ] && ln -sf "$gobin" "$HOME/.local/bin/$(basename "$gobin")"
        done
        echo "Symlinked GOPATH binaries to ~/.local/bin/"

        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1

    if is_installed "$tool"; then
        echo -e "${SUCCESS}${CHECK} $tool installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("$tool")
        log_installation "$tool" "success" "$logfile"
        cleanup_old_logs "$tool"
        return 0
    else
        echo -e "${ERROR}${CROSS} $tool installation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("$tool")
        FAILED_INSTALL_LOGS["$tool"]="$logfile"
        log_installation "$tool" "failure" "$logfile"
        return 1
    fi
}

# Function: install_node_tool
# Purpose: Generic Node.js tool installer using npm
# Parameters:
#   $1 - tool name
#   $2 - npm package name
# Returns: 0 on success, 1 on failure
install_node_tool() {
    local tool=$1
    local npm_package=$2
    local logfile
    logfile=$(create_tool_log "$tool")

    echo -e "${INFO}📦 Installing via npm...${NC}"

    {
        echo "=========================================="
        echo "Installing $tool"
        echo "Started: $(date)"
        echo "=========================================="

        # Prefer system npm; fall back to ~/opt/node/bin if needed
        if ! command -v npm &>/dev/null; then
            export PATH="$HOME/opt/node/bin:$PATH"
        fi

        # Install globally to ~/.local to keep out of system dirs
        npm install -g --prefix "$HOME/.local" "$npm_package" || return 1

        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1

    if is_installed "$tool"; then
        echo -e "${SUCCESS}${CHECK} $tool installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("$tool")
        log_installation "$tool" "success" "$logfile"
        cleanup_old_logs "$tool"
        return 0
    else
        echo -e "${ERROR}${CROSS} $tool installation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("$tool")
        FAILED_INSTALL_LOGS["$tool"]="$logfile"
        log_installation "$tool" "failure" "$logfile"
        return 1
    fi
}

# Function: install_rust_tool
# Purpose: Generic Rust tool installer using cargo
# Parameters:
#   $1 - tool name
#   $2 - crate name
# Returns: 0 on success, 1 on failure
# Function: install_prebuilt_binary
# Purpose: Download a pre-built binary from GitHub releases and install to ~/.local/bin
# Parameters:
#   $1 - tool name (used for logging and destination binary name)
#   $2 - GitHub repo (e.g. "BurntSushi/ripgrep")
#   $3 - asset name pattern (grep regex to match the asset filename)
#   $4 - binary name inside archive (defaults to tool name if omitted)
#   $5 - archive type: "tar.gz", "zip", or "binary" (defaults to tar.gz)
# Returns: 0 on success, 1 on failure
install_prebuilt_binary() {
    local tool=$1
    local repo=$2
    local asset_pattern=$3
    local binary_name="${4:-$tool}"
    local archive_type="${5:-tar.gz}"
    local logfile
    logfile=$(create_tool_log "$tool")

    echo -e "${INFO}⬇ Downloading pre-built $tool binary...${NC}"

    {
        echo "=========================================="
        echo "Installing $tool (pre-built binary)"
        echo "Started: $(date)"
        echo "=========================================="

        mkdir -p "$HOME/.local/bin" "$HOME/opt/src"

        # Fetch latest release asset URL
        local api_url="https://api.github.com/repos/${repo}/releases/latest"
        local asset_url
        asset_url=$(curl -fsSL "$api_url" 2>/dev/null \
            | grep -oP '"browser_download_url":\s*"\K[^"]+' \
            | grep -iE "$asset_pattern" \
            | grep -v "\.sha256\|\.sig\|\.minisig" \
            | head -1)

        if [[ -z "$asset_url" ]]; then
            echo "ERROR: Could not find release asset matching '$asset_pattern' in $repo"
            return 1
        fi

        echo "Downloading: $asset_url"
        local filename
        filename=$(basename "$asset_url")
        cd "$HOME/opt/src" || return 1
        curl -fsSL "$asset_url" -o "$filename" || return 1

        # Attempt SHA256 verification if companion file is published
        local sha256_url="${asset_url}.sha256"
        local sha256_file="${filename}.sha256"
        if curl -fsSL "$sha256_url" -o "$sha256_file" 2>/dev/null && [ -s "$sha256_file" ]; then
            echo "Verifying SHA256 checksum..."
            local expected_hash actual_hash
            expected_hash=$(awk '{print $1}' "$sha256_file")
            actual_hash=$(sha256sum "$filename" | awk '{print $1}')
            if [ "$expected_hash" != "$actual_hash" ]; then
                echo "ERROR: SHA256 verification FAILED for $filename"
                echo "  Expected: $expected_hash"
                echo "  Got:      $actual_hash"
                rm -f "$filename" "$sha256_file"
                return 1
            fi
            echo "SHA256 verified OK"
            rm -f "$sha256_file"
        else
            echo "WARNING: No SHA256 companion file at ${sha256_url} — skipping checksum verification"
            rm -f "$sha256_file" 2>/dev/null || true
        fi

        echo "Extracting..."
        case "$archive_type" in
            tar.gz)
                tar -xzf "$filename" 2>/dev/null || true
                # Find binary in extracted contents
                local found_bin
                found_bin=$(find . -name "$binary_name" -type f ! -name "*.md" ! -name "*.txt" 2>/dev/null | head -1)
                if [[ -z "$found_bin" ]]; then
                    # Try the tool name as a fallback
                    found_bin=$(find . -maxdepth 3 -executable -type f -name "$tool" 2>/dev/null | head -1)
                fi
                if [[ -n "$found_bin" ]]; then
                    cp "$found_bin" "$HOME/.local/bin/$binary_name"
                    chmod +x "$HOME/.local/bin/$binary_name"
                    # If tool name differs from binary name, create an alias symlink
                    [[ "$tool" != "$binary_name" ]] && ln -sf "$HOME/.local/bin/$binary_name" "$HOME/.local/bin/$tool"
                else
                    echo "ERROR: Could not find binary '$binary_name' in extracted archive"
                    return 1
                fi
                ;;
            zip)
                unzip -q "$filename" 2>/dev/null || true
                local found_bin
                found_bin=$(find . -name "$binary_name" -type f 2>/dev/null | head -1)
                if [[ -n "$found_bin" ]]; then
                    cp "$found_bin" "$HOME/.local/bin/$binary_name"
                    chmod +x "$HOME/.local/bin/$binary_name"
                    [[ "$tool" != "$binary_name" ]] && ln -sf "$HOME/.local/bin/$binary_name" "$HOME/.local/bin/$tool"
                else
                    echo "ERROR: Could not find binary '$binary_name' in zip"
                    return 1
                fi
                ;;
            binary)
                cp "$filename" "$HOME/.local/bin/$binary_name"
                chmod +x "$HOME/.local/bin/$binary_name"
                [[ "$tool" != "$binary_name" ]] && ln -sf "$HOME/.local/bin/$binary_name" "$HOME/.local/bin/$tool"
                ;;
        esac

        rm -f "$filename"

        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1

    if [ -x "$HOME/.local/bin/$tool" ]; then
        return 0
    else
        return 1
    fi
}

install_rust_tool() {
    local tool=$1
    local crate=$2
    local version=${3:-}   # optional pinned version; empty = latest
    local logfile
    logfile=$(create_tool_log "$tool")

    echo -e "${WARNING}${WARN} Compiling $tool from Rust source (may take 5-10 minutes)...${NC}"
    echo -e "${INFO}🦀 This is normal - Rust compiles from source for optimization${NC}"

    {
        echo "=========================================="
        echo "Installing $tool"
        echo "Started: $(date)"
        echo "=========================================="

        export CARGO_HOME="$HOME/.local/share/cargo"
        export RUSTUP_HOME="$HOME/.local/share/rustup"
        export PATH="$CARGO_HOME/bin:$PATH"

        # cargo requires a C linker (gcc). Some images strip gcc in cleanup
        # layers — restore it if missing before attempting compilation.
        if ! command -v gcc &>/dev/null; then
            echo "gcc not found — attempting to install via apt..."
            if command -v apt-get &>/dev/null; then
                apt-get update -qq 2>/dev/null || true
                apt-get install -y --no-install-recommends gcc 2>/dev/null || true
            fi
            if ! command -v gcc &>/dev/null; then
                echo "ERROR: gcc is required for cargo builds but could not be installed."
                return 1
            fi
            echo "gcc installed successfully"
        fi

        if [[ -n "$version" ]]; then
            echo "Compiling $crate==${version} from source..."
            cargo install "$crate" --version "$version" || return 1
        else
            echo "Compiling $crate from source (unpinned)..."
            cargo install "$crate" || return 1
        fi

        # Symlink all new cargo binaries to ~/.local/bin so they are on PATH
        mkdir -p "$HOME/.local/bin"
        for cargobin in "$CARGO_HOME"/bin/*; do
            [ -f "$cargobin" ] && ln -sf "$cargobin" "$HOME/.local/bin/$(basename "$cargobin")"
        done
        echo "Symlinked cargo binaries to ~/.local/bin/"

        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1

    if is_installed "$tool"; then
        echo -e "${SUCCESS}${CHECK} $tool installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("$tool")
        log_installation "$tool" "success" "$logfile"
        cleanup_old_logs "$tool"
        return 0
    else
        echo -e "${ERROR}${CROSS} $tool installation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("$tool")
        FAILED_INSTALL_LOGS["$tool"]="$logfile"
        log_installation "$tool" "failure" "$logfile"
        return 1
    fi
}
