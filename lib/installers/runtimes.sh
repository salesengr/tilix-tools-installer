#!/bin/bash
# Security Tools Installer - Runtimes Module
# Version: 1.4.0
# Purpose: Language runtime and build tool installation

# shellcheck disable=SC2034  # FAILED_INSTALL_LOGS used in parent script
# shellcheck disable=SC1091  # Source files in virtualenvs (dynamic paths)

# ===== BUILD TOOLS =====

# Function: install_cmake
# Purpose: Install CMake from GitHub releases
# Returns: 0 on success, 1 on failure
install_cmake() {
    local logfile
    logfile=$(create_tool_log "cmake")

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
    local logfile
    logfile=$(create_tool_log "github_cli")

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
    local logfile
    logfile=$(create_tool_log "nodejs")

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

# Function: install_go_runtime
# Purpose: Install Go runtime to ~/opt/go (user-space, no root required)
#          Required by all Go tools. Mirrors what /usr/local/go provides.
# Returns: 0 on success, 1 on failure
install_go_runtime() {
    local logfile
    logfile=$(create_tool_log "go_runtime")

    echo -e "${INFO}⬇ Downloading Go runtime...${NC}"

    {
        echo "=========================================="
        echo "Installing Go Runtime"
        echo "Started: $(date)"
        echo "=========================================="

        # Detect architecture
        local arch
        case "$(uname -m)" in
            x86_64)  arch="amd64" ;;
            aarch64) arch="arm64" ;;
            armv6l)  arch="armv6l" ;;
            *)
                echo "ERROR: Unsupported architecture: $(uname -m)"
                return 1
                ;;
        esac

        # Fetch latest stable Go version
        local go_version
        go_version=$(curl -fsSL "https://go.dev/VERSION?m=text" 2>/dev/null | head -1)
        if [[ -z "$go_version" ]]; then
            echo "ERROR: Could not determine latest Go version"
            return 1
        fi

        echo "Latest Go: $go_version (arch: $arch)"

        local filename="${go_version}.linux-${arch}.tar.gz"
        local url="https://go.dev/dl/${filename}"
        local install_dir="$HOME/opt/go"

        mkdir -p "$HOME/opt/src"
        cd "$HOME/opt/src" || return 1

        echo "Downloading $url..."
        if ! curl -fsSL "$url" -o "$filename"; then
            echo "ERROR: Failed to download Go"
            return 1
        fi

        echo "Extracting to $install_dir..."
        rm -rf "$install_dir"
        mkdir -p "$HOME/opt"
        tar -xzf "$filename" -C "$HOME/opt/" || return 1
        # Go extracts to a 'go' directory
        [ -d "$HOME/opt/go" ] || { echo "ERROR: Go directory not found after extract"; return 1; }

        rm -f "$filename"

        # Add to PATH in .bashrc if not already present
        if ! grep -q 'opt/go/bin' "$HOME/.bashrc" 2>/dev/null; then
            echo '' >> "$HOME/.bashrc"
            echo '# Go runtime (user-space install)' >> "$HOME/.bashrc"
            echo 'export GOROOT="$HOME/opt/go"' >> "$HOME/.bashrc"
            echo 'export GOPATH="$HOME/opt/gopath"' >> "$HOME/.bashrc"
            echo 'export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"' >> "$HOME/.bashrc"
        fi

        # Export for current session
        export GOROOT="$HOME/opt/go"
        export GOPATH="$HOME/opt/gopath"
        export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"
        mkdir -p "$GOPATH"

        echo "Go installed: $("$HOME/opt/go/bin/go" version)"

        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1

    if [ -f "$HOME/opt/go/bin/go" ]; then
        local ver
        ver=$("$HOME/opt/go/bin/go" version 2>/dev/null)
        echo -e "${SUCCESS}${CHECK} Go runtime installed ($ver)${NC}"
        SUCCESSFUL_INSTALLS+=("go_runtime")
        log_installation "go_runtime" "success" "$logfile"
        cleanup_old_logs "go_runtime"
        export GOROOT="$HOME/opt/go"
        export GOPATH="$HOME/opt/gopath"
        export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"
        mkdir -p "$GOPATH"
        return 0
    else
        echo -e "${ERROR}${CROSS} Go runtime installation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("go_runtime")
        FAILED_INSTALL_LOGS["go_runtime"]="$logfile"
        log_installation "go_runtime" "failure" "$logfile"
        return 1
    fi
}

# Function: install_rust
# Purpose: Install Rust via rustup
# Returns: 0 on success, 1 on failure
install_rust() {
    local logfile
    logfile=$(create_tool_log "rust")

    echo -e "${YELLOW}Rust compilation takes 5-10 minutes...${NC}"

    {
        echo "=========================================="
        echo "Installing Rust"
        echo "Started: $(date)"
        echo "=========================================="

        echo "Downloading rustup installer script..."
        local rustup_script
        rustup_script=$(mktemp)

        if ! curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o "$rustup_script"; then
            echo "ERROR: Failed to download rustup installer"
            rm -f "$rustup_script"
            return 1
        fi

        chmod +x "$rustup_script"
        if ! sh "$rustup_script" -y --no-modify-path; then
            echo "ERROR: Failed to install Rust"
            rm -f "$rustup_script"
            return 1
        fi

        rm -f "$rustup_script"

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
# Purpose: Configure user-space pip install (no venv — uses system Python directly).
#          In a container-per-session architecture a venv adds 400MB+ of bloat with
#          no benefit. pip install --user installs to ~/.local/lib/pythonX.Y/site-packages
#          which is already isolated by the container.
# Returns: 0 on success, 1 on failure
install_python_venv() {
    local logfile
    logfile=$(create_tool_log "python_venv")

    {
        echo "=========================================="
        echo "Configuring Python user-space install"
        echo "Started: $(date)"
        echo "=========================================="

        # Resolve best available Python (prefer 3.13 for tool compatibility)
        local python_bin
        if command -v python3.13 &>/dev/null; then
            python_bin="python3.13"
        elif command -v python3.11 &>/dev/null; then
            python_bin="python3.11"
        elif command -v python3.10 &>/dev/null; then
            python_bin="python3.10"
        elif command -v python3.9 &>/dev/null; then
            python_bin="python3.9"
        else
            python_bin="python3"
        fi

        echo "Using Python: $python_bin ($($python_bin --version 2>&1))"

        # Ensure ~/.local/bin is on PATH for user-installed scripts
        mkdir -p "$HOME/.local/bin"
        if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
            export PATH="$HOME/.local/bin:$PATH"
        fi

        # Store resolved python binary for use by install_python_tool
        echo "$python_bin" > "$HOME/.local/share/.python_bin"

        # Upgrade pip and setuptools in user space
        "$python_bin" -m pip install --user --quiet --upgrade pip "setuptools<81" wheel 2>/dev/null || true

        echo "Python user-space install configured: $python_bin"
        echo "Install target: $HOME/.local/lib/$(${python_bin} -c 'import sys; print(f"python{sys.version_info.major}.{sys.version_info.minor}")')/site-packages/"

        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1

    # python_venv is "installed" if we can resolve a python binary
    if command -v python3 &>/dev/null; then
        echo -e "${GREEN}[OK] Python user-space install configured${NC}"
        SUCCESSFUL_INSTALLS+=("python_venv")
        log_installation "python_venv" "success" "$logfile"
        cleanup_old_logs "python_venv"
        return 0
    else
        echo -e "${RED}[FAIL] No Python found${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("python_venv")
        FAILED_INSTALL_LOGS["python_venv"]="$logfile"
        log_installation "python_venv" "failure" "$logfile"
        return 1
    fi
}
