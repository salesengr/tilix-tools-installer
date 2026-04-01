#!/bin/bash
# Bootstrap Installer for Security Tools
# Version: 1.3.0
# Usage: bash installer.sh

set -e

# Check if running in an interactive terminal
if [ ! -t 0 ]; then
    echo "=========================================="
    echo "Security Tools Installer - Bootstrap"
    echo "=========================================="
    echo ""
    echo "WARNING: stdin is not connected to a terminal."
    echo ""
    echo "The interactive menu requires a terminal. Options:"
    echo ""
    echo "1. Run in a proper terminal (not piped from curl)"
    echo "2. Run the main script directly after setup:"
    echo "   bash xdg_setup.sh"
    echo "   source ~/.bashrc"
    echo "   bash install_security_tools.sh"
    echo ""
    echo "3. Use CLI mode to skip the menu:"
    echo "   bash install_security_tools.sh <tool-name>"
    echo ""
    read -p "Continue with bootstrap anyway? (y/n): " -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        exit 1
    fi
    echo ""
fi

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
    # Redirect stdin from /dev/null to prevent consuming stdin needed for interactive menu
    source "$SHELL_CONFIG" </dev/null
else
    echo "Warning: $SHELL_CONFIG not found. Environment may not be fully configured."
fi

echo ""
echo "Step 3/3: Launching installation menu..."
echo ""

# Launch interactive installer
# Use exec to replace this process and explicitly connect to terminal
if [ -t 0 ]; then
    # stdin is a TTY, use exec normally
    exec bash install_security_tools.sh
else
    # stdin is not a TTY, try to connect to the controlling terminal
    if [ -c /dev/tty ]; then
        exec bash install_security_tools.sh < /dev/tty
    else
        echo "ERROR: Cannot connect to terminal for interactive menu."
        echo "Please run: bash install_security_tools.sh"
        exit 1
    fi
fi
