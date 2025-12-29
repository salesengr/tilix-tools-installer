#!/bin/bash
# XDG Base Directory Setup Script
# Version: 1.0.1
# For Ubuntu 20.04+ container without sudo access
# 
# This script creates a fully XDG Base Directory Specification compliant
# environment with proper directory structure, environment variables, and
# configuration files. It does NOT install tools - use install_security_tools.sh for that.
#
# Usage: bash xdg_setup.sh
# Note: Run from anywhere - uses absolute paths

set -e  # Exit on error

echo "=========================================="
echo "XDG Base Directory Setup"
echo "=========================================="
echo ""

# Color codes for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;36m'
NC='\033[0m'

print_shell_reload_reminder() {
    echo -e "${YELLOW}Reminder:${NC} Run 'source ~/.bashrc' or open a new shell to load the updated environment."
}

# Create complete XDG directory structure
echo -e "${YELLOW}Creating XDG-compliant directory structure...${NC}"

# XDG Base Directories
mkdir -p ~/.local/bin
mkdir -p ~/.local/lib
mkdir -p ~/.local/lib/pkgconfig
mkdir -p ~/.local/include
mkdir -p ~/.local/share
mkdir -p ~/.local/share/applications
mkdir -p ~/.local/share/man/man1
mkdir -p ~/.local/share/virtualenvs
mkdir -p ~/.local/state
mkdir -p ~/.config
mkdir -p ~/.cache

# Additional tool directories
mkdir -p ~/opt/tools
mkdir -p ~/opt/gopath
mkdir -p ~/opt/src

echo -e "${GREEN}[OK] Directory structure created${NC}"
echo ""

# Show what was created
echo -e "${BLUE}XDG Directory Structure:${NC}"
echo "  ~/.local/"
echo "    |-- bin/           -> User executables"
echo "    |-- lib/           -> User libraries"
echo "    |   \-- pkgconfig/ -> Package config files"
echo "    |-- include/       -> Development headers"
echo "    |-- share/         -> User data"
echo "    |   |-- applications/ -> .desktop files"
echo "    |   |-- man/       -> Manual pages"
echo "    |   \-- virtualenvs/ -> Python environments"
echo "    \-- state/         -> Application state data"
echo "  ~/.config/           -> Configuration files"
echo "  ~/.cache/            -> Cache/temporary data"
echo ""
echo "  ~/opt/"
echo "    |-- tools/         -> Standalone tools"
echo "    |-- go/            -> Go installation"
echo "    |-- gopath/        -> Go workspace"
echo "    \-- src/           -> Source code"
echo ""

# Backup existing .bashrc
echo -e "${YELLOW}Backing up .bashrc...${NC}"
cp ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d_%H%M%S)
echo -e "${GREEN}[OK] Backup created${NC}"
echo ""

# Add comprehensive environment configuration to .bashrc
echo -e "${YELLOW}Configuring environment variables...${NC}"
cat >> ~/.bashrc << 'BASHRC_EOF'

# ===== XDG Base Directory Specification =====
# https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html

# XDG directories (set if not already set by system)
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

# User binary and library paths
export PATH="$HOME/.local/bin:$PATH"
export LD_LIBRARY_PATH="$HOME/.local/lib:$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH="$HOME/.local/lib/pkgconfig:$HOME/.local/share/pkgconfig:$PKG_CONFIG_PATH"
export MANPATH="$HOME/.local/share/man:$MANPATH"

# Python configuration (XDG compliant)
export PYTHONUSERBASE="$HOME/.local"
export PYTHON_HISTORY="$XDG_STATE_HOME/python/history"
export PYTHONPYCACHEPREFIX="$XDG_CACHE_HOME/python"

# Go configuration (using system Go at /usr/local/go)
export GOROOT="/usr/local/go"
export GOPATH="$HOME/opt/gopath"
export GOCACHE="$XDG_CACHE_HOME/go-build"
export PATH="/usr/local/go/bin:$GOPATH/bin:$PATH"

# Pip configuration (use XDG cache)
export PIP_CACHE_DIR="$XDG_CACHE_HOME/pip"

# npm configuration (XDG compliant)
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export NPM_CONFIG_PREFIX="$HOME/.local"

# Rust/Cargo (if installed later)
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"

# Less history (if you use less pager)
export LESSHISTFILE="$XDG_STATE_HOME/less/history"

# Wget configuration
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"

# Build configuration
export CMAKE_PREFIX_PATH="$HOME/.local"
export CFLAGS="-I$HOME/.local/include"
export CXXFLAGS="-I$HOME/.local/include"
export LDFLAGS="-L$HOME/.local/lib"

# AppImage support
export APPIMAGE_EXTRACT_AND_RUN=0

# ===== Tool-specific paths =====
export PATH="$HOME/opt/tools:$PATH"

# ===== Aliases =====
alias tools-venv='source $XDG_DATA_HOME/virtualenvs/tools/bin/activate'
alias tools-update='cd $HOME/opt/src && git pull --all'

# Quick XDG navigation
alias cdconfig='cd $XDG_CONFIG_HOME'
alias cddata='cd $XDG_DATA_HOME'
alias cdcache='cd $XDG_CACHE_HOME'
alias cdstate='cd $XDG_STATE_HOME'
alias cdlocal='cd $HOME/.local'

# ===== End XDG Configuration =====
BASHRC_EOF

echo -e "${GREEN}[OK] Environment variables configured${NC}"
echo ""

# Create XDG-aware cache directories
echo -e "${YELLOW}Creating cache directories...${NC}"
mkdir -p "$HOME/.cache/pip"
mkdir -p "$HOME/.cache/go-build"
mkdir -p "$HOME/.cache/npm"
mkdir -p "$HOME/.cache/python"
echo -e "${GREEN}[OK] Cache directories created${NC}"
echo ""

# Create state directories
echo -e "${YELLOW}Creating state directories...${NC}"
mkdir -p "$HOME/.local/state/python"
mkdir -p "$HOME/.local/state/less"
mkdir -p "$HOME/.local/state/bash"
echo -e "${GREEN}[OK] State directories created${NC}"
echo ""

# Create config directories
echo -e "${YELLOW}Creating config directories...${NC}"
mkdir -p "$HOME/.config/npm"
mkdir -p "$HOME/.config/pip"
mkdir -p "$HOME/.config/wget"
echo -e "${GREEN}[OK] Config directories created${NC}"
echo ""

# Create pip config for XDG compliance
echo -e "${YELLOW}Configuring pip for XDG...${NC}"
cat > "$HOME/.config/pip/pip.conf" << 'PIPCONF_EOF'
[global]
cache-dir = ~/.cache/pip


# Note: "user = true" is NOT set here as it conflicts with virtual environments
# When installing outside venv, use: pip install --user package_name
PIPCONF_EOF
echo -e "${GREEN}[OK] Pip configured${NC}"
echo ""

# Create npm config for XDG compliance
echo -e "${YELLOW}Configuring npm for XDG...${NC}"
cat > "$HOME/.config/npm/npmrc" << 'NPMRC_EOF'
prefix=${HOME}/.local
cache=${XDG_CACHE_HOME}/npm
init-module=${XDG_CONFIG_HOME}/npm/npm-init.js
NPMRC_EOF
echo -e "${GREEN}[OK] npm configured${NC}"
echo ""

# Source the new configuration
echo -e "${YELLOW}Loading new environment...${NC}"
if source ~/.bashrc 2>/dev/null; then
    echo -e "${GREEN}[OK] Environment loaded${NC}"
else
    echo -e "${YELLOW}Could not reload shell automatically.${NC}"
    print_shell_reload_reminder
fi
echo ""

# Create XDG info documentation
cat > ~/.local/share/XDG_STRUCTURE.md << 'XDG_DOC_EOF'
# XDG Directory Structure

This installation follows the XDG Base Directory Specification.

## Directory Layout

### ~/.local/ (User Applications)
- `bin/` - User executables (like /usr/bin)
- `lib/` - User libraries (like /usr/lib)
- `include/` - Development headers (like /usr/include)
- `share/` - User data files (like /usr/share)
  - `applications/` - Desktop application shortcuts
  - `man/` - Manual pages
  - `virtualenvs/` - Python virtual environments
- `state/` - Application state data (logs, history, etc.)

### ~/.config/ (Configuration)
- Application configuration files
- Examples: npm/npmrc, pip/pip.conf, git/config

### ~/.cache/ (Temporary Data)
- pip/ - Python package cache
- npm/ - Node package cache
- go-build/ - Go build cache
- python/ - Python bytecode cache

### ~/opt/ (Large Self-Contained Installations)
- `tools/` - Standalone tools and binaries
- `go/` - Go language installation
- `gopath/` - Go workspace
- `src/` - Source code repositories

## Environment Variables

These are automatically set in your .bashrc:

- `XDG_DATA_HOME=$HOME/.local/share`
- `XDG_CONFIG_HOME=$HOME/.config`
- `XDG_CACHE_HOME=$HOME/.cache`
- `XDG_STATE_HOME=$HOME/.local/state`

## Benefits

1. **Organization** - Everything has a logical place
2. **Backup** - Easy to backup entire environments
3. **Clean** - Home directory stays uncluttered
4. **Portable** - Standard layout works across systems
5. **No sudo** - All user-space installations

## Quick Navigation Aliases

- `cdconfig` - Go to config directory
- `cddata` - Go to data directory
- `cdcache` - Go to cache directory
- `cdstate` - Go to state directory
- `cdlocal` - Go to .local directory

## Installing Tools

After setting up the XDG environment, use the companion script to install tools:
```bash
bash install_security_tools.sh
```

## Reference

XDG Base Directory Specification:
https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html
XDG_DOC_EOF

echo -e "${GREEN}[OK] Documentation created${NC}"
echo ""

echo "=========================================="
echo -e "${GREEN}XDG Base Directory Setup Complete!${NC}"
echo "=========================================="
echo ""
echo -e "${BLUE}What was configured:${NC}"
echo "  [OK] XDG directory structure created"
echo "  [OK] Environment variables set in .bashrc"
echo "  [OK] pip configured for XDG compliance"
echo "  [OK] npm configured for XDG compliance"
echo "  [OK] Cache, config, and state directories created"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "  1. Run: source ~/.bashrc"
echo "  2. Install tools: bash install_security_tools.sh"
echo "  3. Read documentation: cat ~/.local/share/XDG_STRUCTURE.md"
echo ""
echo -e "${BLUE}Quick navigation aliases:${NC}"
echo "  cdconfig  -> Go to ~/.config"
echo "  cddata    -> Go to ~/.local/share"
echo "  cdcache   -> Go to ~/.cache"
echo "  cdlocal   -> Go to ~/.local"
echo ""
echo -e "${BLUE}Directory structure:${NC}"
echo "  ~/.local/bin/       -> User executables"
echo "  ~/.local/lib/       -> User libraries"
echo "  ~/.local/share/     -> User data"
echo "  ~/.config/          -> Configuration files"
echo "  ~/.cache/           -> Temporary cache"
echo "  ~/opt/              -> Large installations"
echo ""
print_shell_reload_reminder
