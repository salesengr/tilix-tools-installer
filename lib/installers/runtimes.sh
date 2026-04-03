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
        cd "$HOME/opt/src" || return 1
        local CMAKE_VERSION="3.28.1"
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

        # CMake publishes SHA256 companion files alongside releases
        verify_sha256 "$filename" "${url}.sha256" || return 1

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

    _record_install_result "cmake" "$logfile"
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
        cd "$HOME/opt/src" || return 1
        local GH_CLI_VERSION="2.53.0"
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

        # gh CLI publishes a checksums.txt file per release with sha256 entries
        local checksums_url="https://github.com/cli/cli/releases/download/v${GH_CLI_VERSION}/gh_${GH_CLI_VERSION}_checksums.txt"
        local checksums_file="gh_checksums.txt"
        if curl --proto '=https' --tlsv1.2 -fsSL "$checksums_url" -o "$checksums_file" 2>/dev/null && [ -s "$checksums_file" ]; then
            local expected actual
            expected=$(grep -w "$filename" "$checksums_file" | awk '{print $1}')
            actual=$(sha256sum "$filename" | awk '{print $1}')
            rm -f "$checksums_file"
            if [ -n "$expected" ] && [ "$expected" != "$actual" ]; then
                echo "ERROR: SHA256 verification FAILED for $filename"
                echo "  Expected: $expected"
                echo "  Got:      $actual"
                return 1
            fi
            [ -n "$expected" ] && echo "SHA256 verified OK"
        else
            rm -f "$checksums_file" 2>/dev/null || true
            echo "WARNING: Could not fetch gh CLI checksums — skipping SHA256 verification"
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

    _record_install_result "github_cli" "$logfile"
}

# ===== LANGUAGE RUNTIMES =====

# Function: install_nodejs
# Purpose: Verify system Node.js is available. The Tilix image ships Node 22
#          system-wide — no separate install needed. Falls back to downloading
#          the official tarball only if system Node is absent.
# Returns: 0 on success, 1 on failure
install_nodejs() {
    local logfile
    logfile=$(create_tool_log "nodejs")

    # Use system Node if available — saves 169MB from session archive
    if command -v node &>/dev/null; then
        local node_ver
        node_ver=$(node --version 2>/dev/null)
        echo -e "${GREEN}[OK] Using system Node.js ${node_ver}${NC}"
        SUCCESSFUL_INSTALLS+=("nodejs")
        log_installation "nodejs" "success" "$logfile"
        return 0
    fi

    # Fallback: download tarball if system Node is not present
    echo -e "${WARNING}${WARN} System Node.js not found — downloading tarball...${NC}"
    {
        echo "=========================================="
        echo "Installing Node.js (tarball fallback)"
        echo "Started: $(date)"
        echo "=========================================="

        mkdir -p "$HOME/opt"
        cd "$HOME/opt" || return 1
        local NODE_VERSION="20.10.0"
        local filename="node-v${NODE_VERSION}-linux-x64.tar.xz"
        local url="https://nodejs.org/dist/v${NODE_VERSION}/${filename}"

        echo "Downloading Node.js ${NODE_VERSION}..."
        if ! download_file "$url" "$filename"; then
            echo "ERROR: Failed to download Node.js"
            return 1
        fi

        # Node.js publishes SHA256 sums at SHASUMS256.txt — multi-entry file,
        # so grep for the specific filename rather than using verify_sha256()
        local shasums_url="https://nodejs.org/dist/v${NODE_VERSION}/SHASUMS256.txt"
        local shasums_file="node_SHASUMS256.txt"
        if curl --proto '=https' --tlsv1.2 -fsSL "$shasums_url" -o "$shasums_file" 2>/dev/null \
                && [ -s "$shasums_file" ]; then
            local expected actual
            expected=$(grep -w "$filename" "$shasums_file" | awk '{print $1}')
            actual=$(sha256sum "$filename" | awk '{print $1}')
            rm -f "$shasums_file"
            if [ -n "$expected" ] && [ "$expected" != "$actual" ]; then
                echo "ERROR: SHA256 verification FAILED for $filename"
                echo "  Expected: $expected"
                echo "  Got:      $actual"
                return 1
            fi
            [ -n "$expected" ] && echo "SHA256 verified OK"
        else
            rm -f "$shasums_file" 2>/dev/null || true
            echo "WARNING: Could not fetch Node.js SHASUMS256.txt — skipping SHA256 verification"
        fi

        tar -xJf "$filename" || return 1
        mv "node-v${NODE_VERSION}-linux-x64" node
        rm -f "$filename"
        export PATH="$HOME/opt/node/bin:$PATH"

        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1

    _record_install_result "nodejs" "$logfile" || return 1
    export PATH="$HOME/opt/node/bin:$PATH"
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
        go_version=$(curl --proto '=https' --tlsv1.2 -fsSL "https://go.dev/VERSION?m=text" 2>/dev/null | head -1)
        if [[ -z "$go_version" ]]; then
            echo "ERROR: Could not determine latest Go version"
            return 1
        fi
        # Validate format before using in a URL — reject unexpected responses
        if [[ ! "$go_version" =~ ^go[0-9]+\.[0-9]+(\.[0-9]+)?(rc[0-9]+)?$ ]]; then
            echo "ERROR: Unexpected Go version format: $go_version"
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

        # Go publishes SHA256 companion files at the same URL + .sha256
        verify_sha256 "$filename" "${url}.sha256" || return 1

        echo "Extracting to $install_dir..."
        rm -rf "$install_dir"
        mkdir -p "$HOME/opt"
        tar -xzf "$filename" -C "$HOME/opt/" || return 1
        # Go extracts to a 'go' directory
        [ -d "$HOME/opt/go" ] || { echo "ERROR: Go directory not found after extract"; return 1; }

        rm -f "$filename"

        # Add to PATH in .bashrc if not already present
        if ! grep -q 'opt/go/bin' "$HOME/.bashrc" 2>/dev/null; then
            # shellcheck disable=SC2016  # Single quotes intentional: $HOME expands at shell startup, not write time
            {
                echo ''
                echo '# Go runtime (user-space install)'
                echo 'export GOROOT="$HOME/opt/go"'
                echo 'export GOPATH="$HOME/opt/gopath"'
                echo 'export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"'
            } >> "$HOME/.bashrc"
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

        # GPG is required for signature verification
        if ! command -v gpg &>/dev/null; then
            echo "ERROR: gpg not found — required for rustup-init signature verification"
            return 1
        fi

        # Resolve target triple for this host
        local arch
        arch=$(uname -m)
        local arch_triple
        case "$arch" in
            x86_64)  arch_triple="x86_64-unknown-linux-gnu" ;;
            aarch64) arch_triple="aarch64-unknown-linux-gnu" ;;
            *)
                echo "ERROR: Unsupported architecture for rustup: $arch"
                return 1
                ;;
        esac

        # Import Rust release signing key if not already in keyring
        # Fingerprint: 108F66205EAEB0AAA8DD5E1C85AB96E6FA1BE5FE (rust-lang.org)
        local RUST_KEY_FP="108F66205EAEB0AAA8DD5E1C85AB96E6FA1BE5FE"
        if ! gpg --list-keys "${RUST_KEY_FP}" &>/dev/null; then
            echo "Importing Rust signing key ${RUST_KEY_FP}..."
            # Import from canonical source only — no third-party fallback
            curl --proto '=https' --tlsv1.2 -sSf \
                "https://static.rust-lang.org/rust-key.gpg.asc" | gpg --import 2>&1 || {
                echo "ERROR: Could not import Rust signing key from static.rust-lang.org"
                return 1
            }
            if ! gpg --list-keys "${RUST_KEY_FP}" &>/dev/null; then
                echo "ERROR: Imported key fingerprint does not match ${RUST_KEY_FP}"
                return 1
            fi
        fi

        # Download rustup-init binary and detached signature directly
        # This bypasses the sh.rustup.rs shell script middleman
        local base_url="https://static.rust-lang.org/rustup/dist/${arch_triple}"
        local rustup_init
        rustup_init=$(mktemp)

        echo "Downloading rustup-init for ${arch_triple}..."
        curl --proto '=https' --tlsv1.2 -sSf "${base_url}/rustup-init" -o "${rustup_init}" || {
            echo "ERROR: Failed to download rustup-init"
            rm -f "${rustup_init}"
            return 1
        }
        curl --proto '=https' --tlsv1.2 -sSf "${base_url}/rustup-init.asc" -o "${rustup_init}.asc" || {
            echo "ERROR: Failed to download rustup-init signature"
            rm -f "${rustup_init}" "${rustup_init}.asc"
            return 1
        }

        # Verify detached GPG signature before executing
        echo "Verifying rustup-init GPG signature..."
        if ! gpg --verify "${rustup_init}.asc" "${rustup_init}" 2>&1; then
            echo "ERROR: GPG signature verification FAILED — aborting Rust installation"
            rm -f "${rustup_init}" "${rustup_init}.asc"
            return 1
        fi
        echo "GPG signature OK"
        rm -f "${rustup_init}.asc"

        chmod +x "${rustup_init}"
        if ! "${rustup_init}" -y --no-modify-path; then
            echo "ERROR: Failed to install Rust"
            rm -f "${rustup_init}"
            return 1
        fi

        rm -f "${rustup_init}"

        echo "Setting up environment..."
        export CARGO_HOME="$HOME/.local/share/cargo"
        export RUSTUP_HOME="$HOME/.local/share/rustup"
        export PATH="$CARGO_HOME/bin:$PATH"

        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1

    _record_install_result "rust" "$logfile" || return 1
    export CARGO_HOME="$HOME/.local/share/cargo"
    export RUSTUP_HOME="$HOME/.local/share/rustup"
    export PATH="$CARGO_HOME/bin:$PATH"
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
        python_bin=$(_get_python_bin)

        echo "Using Python: $python_bin ($($python_bin --version 2>&1))"

        # Ensure ~/.local/bin is on PATH for user-installed scripts
        mkdir -p "$HOME/.local/bin"
        if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
            export PATH="$HOME/.local/bin:$PATH"
        fi

        # Store resolved python binary for use by install_python_tool
        echo "$python_bin" > "$HOME/.local/share/.python_bin"

        # Upgrade pip and setuptools in user space
        "$python_bin" -m pip install --user --quiet --upgrade pip "setuptools<81" wheel 2>/dev/null \
            || echo "WARNING: pip/setuptools/wheel upgrade failed (non-fatal — continuing)"

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
