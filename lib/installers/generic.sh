#!/bin/bash
# Security Tools Installer - Generic Installers Module
# Version: 1.3.0
# Purpose: Reusable generic installers for each language ecosystem

# ===== HELPER FUNCTIONS =====

# Function: create_python_wrapper
# Purpose: Create wrapper script for Python tools to auto-activate virtualenv
# Parameters: $1 - tool name
# Returns: Always succeeds
create_python_wrapper() {
    local tool=$1

    cat > "$HOME/.local/bin/$tool" << WRAPPER_EOF
#!/bin/bash
XDG_DATA_HOME="\${XDG_DATA_HOME:-\$HOME/.local/share}"
TOOL_BIN="\$XDG_DATA_HOME/virtualenvs/tools/bin/$tool"

if [ ! -x "\$TOOL_BIN" ]; then
    echo "Error: $tool is not installed in \$XDG_DATA_HOME/virtualenvs/tools/bin" >&2
    echo "Run: bash install_security_tools.sh $tool" >&2
    exit 1
fi

exec "\$TOOL_BIN" "\$@"
WRAPPER_EOF

    chmod +x "$HOME/.local/bin/$tool"
}

# ===== GENERIC INSTALLERS =====

# Function: install_python_tool
# Purpose: Generic Python tool installer using pip
# Parameters:
#   $1 - tool name
#   $2 - pip package name
# Returns: 0 on success, 1 on failure
install_python_tool() {
    local tool=$1
    local pip_package=$2
    local logfile=$(create_tool_log "$tool")

    echo -e "${INFO}⚙ Activating Python environment...${NC}"

    {
        echo "=========================================="
        echo "Installing $tool"
        echo "Started: $(date)"
        echo "=========================================="

        source "$XDG_DATA_HOME/virtualenvs/tools/bin/activate" || return 1

        echo "Installing $pip_package..."
        pip install --quiet "$pip_package" || return 1

        deactivate

        echo "Creating wrapper script..."
        create_python_wrapper "$tool"

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
    local logfile=$(create_tool_log "$tool")

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
    local logfile=$(create_tool_log "$tool")

    echo -e "${INFO}📦 Installing via npm...${NC}"

    {
        echo "=========================================="
        echo "Installing $tool"
        echo "Started: $(date)"
        echo "=========================================="

        export PATH="$HOME/opt/node/bin:$PATH"

        echo "Installing $npm_package..."
        npm install -g "$npm_package" || return 1

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
install_rust_tool() {
    local tool=$1
    local crate=$2
    local logfile=$(create_tool_log "$tool")

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

        echo "Compiling $crate from source..."
        cargo install "$crate" || return 1

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
