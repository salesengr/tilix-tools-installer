#!/bin/bash
# Bootstrap Installer for Security Tools
# Version: 1.3.0
# Usage: bash installer.sh

set -e

echo "=========================================="
echo "Security Tools Installer - Bootstrap"
echo "=========================================="
echo ""

# Detect if we're already in the repository
if [ ! -f "xdg_setup.sh" ] || [ ! -f "install_security_tools.sh" ]; then
    echo "Repository files not found. Cloning..."
    REPO_URL="https://github.com/salesengr/tilix-tools-installer.git"
    INSTALL_DIR="${HOME}/tilix-tools-installer"

    if [ -d "$INSTALL_DIR" ]; then
        echo "Directory $INSTALL_DIR already exists. Updating..."
        cd "$INSTALL_DIR" || exit 1
        git pull
    else
        git clone "$REPO_URL" "$INSTALL_DIR" || exit 1
        cd "$INSTALL_DIR" || exit 1
    fi
fi

# Ensure we're in the right directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR" || exit 1

echo "Step 1/3: Setting up XDG environment..."
bash xdg_setup.sh

echo ""
echo "Step 2/3: Reloading shell configuration..."

# Detect shell and source appropriate config
if [ -n "$ZSH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.zshrc"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_CONFIG="$HOME/.bashrc"
else
    SHELL_CONFIG="$HOME/.bashrc"  # Default to bash
fi

if [ -f "$SHELL_CONFIG" ]; then
    echo "Sourcing $SHELL_CONFIG..."
    # shellcheck disable=SC1090
    source "$SHELL_CONFIG"
else
    echo "Warning: $SHELL_CONFIG not found. Environment may not be fully configured."
fi

echo ""
echo "Step 3/3: Launching installation menu..."
echo ""

# Launch interactive installer
bash install_security_tools.sh
