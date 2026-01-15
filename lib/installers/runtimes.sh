#!/bin/bash
# Security Tools Installer - Runtimes Module
# Version: 1.3.0
# Purpose: Language runtime and build tool installation

# ===== BUILD TOOLS =====

# Function: install_cmake
# Purpose: Install CMake from GitHub releases
# Returns: 0 on success, 1 on failure
install_cmake() {
    local logfile=$(create_tool_log "cmake")

    {
        echo "=========================================="
        echo "Installing CMake"
        echo "Started: $(date)"
        echo "=========================================="

        mkdir -p "$HOME/opt/src"
        cd "$HOME/opt/src" || exit 1
        CMAKE_VERSION="3.28.1"
        local filename="cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz"
        local url="https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/${filename}"

        echo "Downloading CMake ${CMAKE_VERSION}..."
        if ! download_file "$url" "$filename"; then
            echo "ERROR: Failed to download CMake"
            return 1
        fi

        if ! verify_file_exists "$filename" "CMake tarball"; then
            return 1
        fi

        echo "Extracting..."
        if ! tar -xzf "$filename"; then
            echo "ERROR: Failed to extract CMake"
            return 1
        fi

        echo "Installing to ~/.local/..."
        if [ ! -d "cmake-${CMAKE_VERSION}-linux-x86_64" ]; then
            echo "ERROR: Extracted directory not found"
            return 1
        fi

        cp -r cmake-${CMAKE_VERSION}-linux-x86_64/bin/* "$HOME/.local/bin/" || return 1
        cp -r cmake-${CMAKE_VERSION}-linux-x86_64/share/* "$HOME/.local/share/" || return 1

        echo "Cleaning up..."
        rm -rf cmake-${CMAKE_VERSION}-linux-x86_64*

        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1

    if is_installed "cmake"; then
        echo -e "${GREEN}[OK] CMake installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("cmake")
        log_installation "cmake" "success" "$logfile"
        cleanup_old_logs "cmake"
        return 0
    else
        echo -e "${RED}[FAIL] CMake installation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("cmake")
        FAILED_INSTALL_LOGS["cmake"]="$logfile"
        log_installation "cmake" "failure" "$logfile"
        return 1
    fi
}

# Function: install_github_cli
# Purpose: Install GitHub CLI from releases
# Returns: 0 on success, 1 on failure
install_github_cli() {
    local logfile=$(create_tool_log "github_cli")

    {
        echo "=========================================="
        echo "Installing GitHub CLI"
        echo "Started: $(date)"
        echo "=========================================="

        mkdir -p "$HOME/opt/src"
        cd "$HOME/opt/src" || exit 1
        GH_CLI_VERSION="2.53.0"
        local filename="gh_${GH_CLI_VERSION}_linux_amd64.tar.gz"
        local url="https://github.com/cli/cli/releases/download/v${GH_CLI_VERSION}/${filename}"

        echo "Downloading GitHub CLI ${GH_CLI_VERSION}..."
        if ! download_file "$url" "$filename"; then
            echo "ERROR: Failed to download GitHub CLI"
            return 1
        fi

        if ! verify_file_exists "$filename" "GitHub CLI tarball"; then
            return 1
        fi

        echo "Extracting..."
        if ! tar -xzf "$filename"; then
            echo "ERROR: Failed to extract GitHub CLI"
            return 1
        fi

        local extracted_dir="gh_${GH_CLI_VERSION}_linux_amd64"
        if [ ! -d "$extracted_dir" ]; then
            echo "ERROR: Extracted directory not found"
            return 1
        fi

        echo "Installing to ~/.local/..."
        mkdir -p "$HOME/.local/bin"
        cp "$extracted_dir/bin/gh" "$HOME/.local/bin/" || return 1

        if [ -d "$extracted_dir/share/man/man1" ]; then
            mkdir -p "$HOME/.local/share/man/man1"
            cp "$extracted_dir/share/man/man1/"* "$HOME/.local/share/man/man1/" || return 1
        fi

        if [ -d "$extracted_dir/share/doc" ]; then
            mkdir -p "$HOME/.local/share/doc/gh"
            cp -r "$extracted_dir/share/doc/." "$HOME/.local/share/doc/gh" || return 1
        fi

        echo "Cleaning up..."
        rm -rf "$extracted_dir" "$filename"

        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1

    if is_installed "github_cli"; then
        echo -e "${GREEN}✓ GitHub CLI installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("github_cli")
        log_installation "github_cli" "success" "$logfile"
        cleanup_old_logs "github_cli"
        return 0
    else
        echo -e "${RED}✗ GitHub CLI installation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("github_cli")
        FAILED_INSTALL_LOGS["github_cli"]="$logfile"
        log_installation "github_cli" "failure" "$logfile"
        return 1
    fi
}

# ===== LANGUAGE RUNTIMES =====

# Function: install_nodejs
# Purpose: Install Node.js from official tarball
# Returns: 0 on success, 1 on failure
install_nodejs() {
    local logfile=$(create_tool_log "nodejs")

    {
        echo "=========================================="
        echo "Installing Node.js"
        echo "Started: $(date)"
        echo "=========================================="

        mkdir -p "$HOME/opt"
        cd "$HOME/opt" || exit 1
        NODE_VERSION="20.10.0"
        local filename="node-v${NODE_VERSION}-linux-x64.tar.xz"
        local url="https://nodejs.org/dist/v${NODE_VERSION}/${filename}"

        echo "Downloading Node.js ${NODE_VERSION}..."
        if ! download_file "$url" "$filename"; then
            echo "ERROR: Failed to download Node.js"
            return 1
        fi

        if ! verify_file_exists "$filename" "Node.js tarball"; then
            return 1
        fi

        echo "Extracting..."
        if ! tar -xJf "$filename"; then
            echo "ERROR: Failed to extract Node.js"
            return 1
        fi

        mv "node-v${NODE_VERSION}-linux-x64" node

        echo "Cleaning up..."
        rm "$filename"

        echo "Setting up environment..."
        export PATH="$HOME/opt/node/bin:$PATH"

        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1

    if is_installed "nodejs"; then
        echo -e "${GREEN}[OK] Node.js installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("nodejs")
        log_installation "nodejs" "success" "$logfile"
        cleanup_old_logs "nodejs"
        export PATH="$HOME/opt/node/bin:$PATH"
        return 0
    else
        echo -e "${RED}[FAIL] Node.js installation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("nodejs")
        FAILED_INSTALL_LOGS["nodejs"]="$logfile"
        log_installation "nodejs" "failure" "$logfile"
        return 1
    fi
}

# Function: install_rust
# Purpose: Install Rust via rustup
# Returns: 0 on success, 1 on failure
install_rust() {
    local logfile=$(create_tool_log "rust")

    echo -e "${YELLOW}Rust compilation takes 5-10 minutes...${NC}"

    {
        echo "=========================================="
        echo "Installing Rust"
        echo "Started: $(date)"
        echo "=========================================="

        echo "Downloading rustup..."
        if ! curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path; then
            echo "ERROR: Failed to install Rust"
            return 1
        fi

        echo "Setting up environment..."
        export CARGO_HOME="$HOME/.local/share/cargo"
        export RUSTUP_HOME="$HOME/.local/share/rustup"
        export PATH="$CARGO_HOME/bin:$PATH"

        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1

    if is_installed "rust"; then
        echo -e "${GREEN}[OK] Rust installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("rust")
        log_installation "rust" "success" "$logfile"
        cleanup_old_logs "rust"
        export CARGO_HOME="$HOME/.local/share/cargo"
        export RUSTUP_HOME="$HOME/.local/share/rustup"
        export PATH="$CARGO_HOME/bin:$PATH"
        return 0
    else
        echo -e "${RED}[FAIL] Rust installation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("rust")
        FAILED_INSTALL_LOGS["rust"]="$logfile"
        log_installation "rust" "failure" "$logfile"
        return 1
    fi
}

# Function: install_python_venv
# Purpose: Create Python virtual environment for tools
# Returns: 0 on success, 1 on failure
install_python_venv() {
    local logfile=$(create_tool_log "python_venv")

    {
        echo "=========================================="
        echo "Creating Python Virtual Environment"
        echo "Started: $(date)"
        echo "=========================================="

        echo "Creating venv..."
        python3 -m venv "$XDG_DATA_HOME/virtualenvs/tools" || return 1

        echo "Activating venv..."
        source "$XDG_DATA_HOME/virtualenvs/tools/bin/activate" || return 1

        echo "Upgrading pip, wheel, setuptools..."
        pip install --upgrade pip wheel setuptools || return 1

        deactivate

        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1

    if is_installed "python_venv"; then
        echo -e "${GREEN}[OK] Python virtual environment created${NC}"
        SUCCESSFUL_INSTALLS+=("python_venv")
        log_installation "python_venv" "success" "$logfile"
        cleanup_old_logs "python_venv"
        return 0
    else
        echo -e "${RED}[FAIL] Python venv creation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("python_venv")
        FAILED_INSTALL_LOGS["python_venv"]="$logfile"
        log_installation "python_venv" "failure" "$logfile"
        return 1
    fi
}
