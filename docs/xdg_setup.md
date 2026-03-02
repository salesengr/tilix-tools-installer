# XDG Setup Script Documentation

## Overview

`xdg_setup.sh` creates a complete XDG Base Directory Specification compliant environment for user-space installations without requiring sudo access.

## Purpose

This script sets up the foundation for installing and managing user-space tools by:
1. Creating standardized directory structures
2. Configuring environment variables
3. Setting up tool-specific configurations (pip, npm, etc.)
4. Providing convenience aliases

**Important:** This script does NOT install any tools. Use `install_security_tools.sh` after running this script to install actual software.

## What is XDG?

**XDG** (X Desktop Group, now freedesktop.org) defines standards for where applications should store files:

| Directory | Purpose | System Equivalent |
|-----------|---------|-------------------|
| `~/.local/bin/` | User executables | `/usr/bin/` |
| `~/.local/lib/` | User libraries | `/usr/lib/` |
| `~/.local/share/` | User data | `/usr/share/` |
| `~/.config/` | Configuration | `/etc/` |
| `~/.cache/` | Temporary cache | `/var/cache/` |
| `~/.local/state/` | Application state | `/var/lib/` |

## Usage

```bash
# Run the script (from the repository root)
bash xdg_setup.sh

# Reload environment to apply changes
source ~/.bashrc
```

The script attempts to reload `.bashrc` for you; if that is not possible (non-interactive shell, etc.) it prints a reminder so you know to run `source ~/.bashrc` manually afterward.

## What It Does

### 1. Creates Directory Structure

#### XDG Base Directories
```
~/.local/
â”œâ”€â”€ bin/                    # User executables
â”œâ”€â”€ lib/                    # User libraries
â”‚   â””â”€â”€ pkgconfig/         # Package config files
â”œâ”€â”€ include/                # Development headers
â”œâ”€â”€ share/                  # User data files
â”‚   â”œâ”€â”€ applications/      # Desktop application shortcuts
â”‚   â”œâ”€â”€ man/               # Manual pages
â”‚   â”‚   â””â”€â”€ man1/
â”‚   â””â”€â”€ virtualenvs/       # Python virtual environments
â””â”€â”€ state/                  # Application state data

~/.config/                  # Configuration files
â”œâ”€â”€ pip/
â”œâ”€â”€ npm/
â””â”€â”€ wget/

~/.cache/                   # Cache/temporary data
â”œâ”€â”€ pip/
â”œâ”€â”€ go-build/
â”œâ”€â”€ npm/
â””â”€â”€ python/
```

#### Additional Directories
```
~/opt/
â”œâ”€â”€ tools/                  # Standalone tools and binaries
â”œâ”€â”€ go/                     # Go language installation
â”œâ”€â”€ gopath/                 # Go workspace
â””â”€â”€ src/                    # Source code repositories
```

### 2. Configures Environment Variables

The script adds the following to your `~/.bashrc`:

#### XDG Base Directory Variables
```bash
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
```

**Note:** The `${VAR:-default}` syntax means "use existing value if set, otherwise use default". This respects system-set values while providing fallbacks.

#### User Binary and Library Paths
```bash
export PATH="$HOME/.local/bin:$PATH"
export LD_LIBRARY_PATH="$HOME/.local/lib:$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH="$HOME/.local/lib/pkgconfig:$HOME/.local/share/pkgconfig:$PKG_CONFIG_PATH"
export MANPATH="$HOME/.local/share/man:$MANPATH"
```

#### Python Configuration (XDG Compliant)
```bash
export PYTHONUSERBASE="$HOME/.local"
export PYTHON_HISTORY="$XDG_STATE_HOME/python/history"
export PYTHONPYCACHEPREFIX="$XDG_CACHE_HOME/python"
export PIP_CACHE_DIR="$XDG_CACHE_HOME/pip"
```

#### Go Configuration
```bash
export GOROOT="$HOME/opt/go"
export GOPATH="$HOME/opt/gopath"
export GOCACHE="$XDG_CACHE_HOME/go-build"
export PATH="$GOROOT/bin:$GOPATH/bin:$PATH"
```

#### npm Configuration (XDG Compliant)
```bash
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"
export NPM_CONFIG_PREFIX="$HOME/.local"
```

#### Rust/Cargo (Future-Proofing)
```bash
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
```

#### Other Tools
```bash
export LESSHISTFILE="$XDG_STATE_HOME/less/history"
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"
```

#### Build Configuration
```bash
export CMAKE_PREFIX_PATH="$HOME/.local"
export CFLAGS="-I$HOME/.local/include"
export CXXFLAGS="-I$HOME/.local/include"
export LDFLAGS="-L$HOME/.local/lib"
```

### 3. Creates Configuration Files

#### pip Configuration (`~/.config/pip/pip.conf`)
```ini
[global]
cache-dir = ~/.cache/pip

[install]
user = true
```

This ensures pip:
- Uses XDG cache directory
- Defaults to user installations (no sudo needed)

#### npm Configuration (`~/.config/npm/npmrc`)
```
prefix=${HOME}/.local
cache=${XDG_CACHE_HOME}/npm
init-module=${XDG_CONFIG_HOME}/npm/npm-init.js
```

This ensures npm:
- Installs packages to user space
- Uses XDG cache directory
- Stores initialization configs in XDG location

### 4. Creates Convenience Aliases

```bash
# Tool management
alias tools-venv='source $XDG_DATA_HOME/virtualenvs/tools/bin/activate'
alias tools-update='cd $HOME/opt/src && git pull --all'

# Quick XDG navigation
alias cdconfig='cd $XDG_CONFIG_HOME'
alias cddata='cd $XDG_DATA_HOME'
alias cdcache='cd $XDG_CACHE_HOME'
alias cdstate='cd $XDG_STATE_HOME'
alias cdlocal='cd $HOME/.local'
```

### 5. Creates Documentation

The script creates `~/.local/share/XDG_STRUCTURE.md` with comprehensive documentation about:
- Directory layout and purpose
- Environment variables
- Benefits of XDG compliance
- Quick navigation aliases
- Reference links

## Step-by-Step Execution

1. **Backup .bashrc** - Creates timestamped backup (e.g., `.bashrc.backup.20251210_143022`)
2. **Create directories** - All XDG and opt directories
3. **Configure .bashrc** - Appends environment configuration block
4. **Create cache directories** - pip, go-build, npm, python
5. **Create state directories** - python, less, bash
6. **Create config directories** - npm, pip, wget
7. **Configure pip** - Creates pip.conf
8. **Configure npm** - Creates npmrc
9. **Source .bashrc** - Loads new environment (for current session)
10. **Create documentation** - XDG_STRUCTURE.md

## Output Example

```
==========================================
XDG Base Directory Setup
==========================================

Creating XDG-compliant directory structure...
âœ“ Directory structure created

XDG Directory Structure:
  ~/.local/
    â”œâ”€â”€ bin/           â†’ User executables
    â”œâ”€â”€ lib/           â†’ User libraries
    â”‚   â””â”€â”€ pkgconfig/ â†’ Package config files
    ...

Backing up .bashrc...
âœ“ Backup created

Configuring environment variables...
âœ“ Environment variables configured

Creating cache directories...
âœ“ Cache directories created

Creating state directories...
âœ“ State directories created

Creating config directories...
âœ“ Config directories created

Configuring pip for XDG...
âœ“ Pip configured

Configuring npm for XDG...
âœ“ npm configured

Loading new environment...
âœ“ Environment loaded

âœ“ Documentation created

==========================================
XDG Base Directory Setup Complete!
==========================================

What was configured:
  âœ“ XDG directory structure created
  âœ“ Environment variables set in .bashrc
  âœ“ pip configured for XDG compliance
  âœ“ npm configured for XDG compliance
  âœ“ Cache, config, and state directories created

Next steps:
  1. Run: source ~/.bashrc
  2. Install tools: bash install_security_tools.sh
  3. Read documentation: cat ~/.local/share/XDG_STRUCTURE.md
```

## Benefits

### 1. **Organization**
- Everything has a logical, predictable location
- No more cluttered home directory with dozens of dot-directories
- Follows Linux Filesystem Hierarchy Standard (FHS) principles

### 2. **Easy Backup/Restore**
```bash
# Backup entire user environment
tar -czf backup.tar.gz ~/.local ~/.config

# Restore
tar -xzf backup.tar.gz -C ~/
```

### 3. **Clean Uninstall**
```bash
# Remove all user-installed applications
rm -rf ~/.local

# Remove all configuration
rm -rf ~/.config
```

### 4. **No Conflicts with System**
```bash
# System Python: /usr/bin/python3
# Your Python: ~/.local/bin/python3
# No conflicts - PATH priority determines which runs
```

### 5. **Portable**
```bash
# Move environment to another machine
tar -czf my-env.tar.gz ~/.local ~/.config ~/.cache
# Transfer and extract on new system
```

### 6. **Standards Compliant**
- Modern tools automatically check XDG directories
- Compatible with desktop environments (GNOME, KDE, etc.)
- Future-proof as more tools adopt XDG

## Troubleshooting

### Environment variables not set after running script

**Problem:** Variables like `$XDG_DATA_HOME` are empty

**Solution:**
```bash
source ~/.bashrc
```

The script sources .bashrc at the end, but this only affects the script's session. You need to reload your current shell.

### Directories not created

**Problem:** Permission denied errors

**Solution:**
Check home directory is writable:
```bash
touch ~/.test && rm ~/.test && echo "Writable" || echo "Not writable"
```

### .bashrc modifications conflict with existing setup

**Problem:** Duplicate or conflicting PATH entries

**Solution:**
1. Check the backup created by the script: `~/.bashrc.backup.TIMESTAMP`
2. Review what was added (look for `===== XDG Configuration =====` block)
3. Manually edit if needed

### Tools still install to wrong locations after setup

**Problem:** Tools ignore XDG variables

**Solution:**
1. Ensure you sourced .bashrc: `source ~/.bashrc`
2. Verify variables are set: `env | grep XDG`
3. Some legacy tools may not support XDG (this is normal)

## Advanced Usage

### Customizing Directories

Edit the script before running to use different locations:

```bash
# Example: Use ~/user-space/ instead of ~/.local/
mkdir -p ~/user-space/{bin,lib,share}
export PATH="$HOME/user-space/bin:$PATH"
# ... etc
```

### Selective Configuration

If you only want certain parts of the XDG setup, you can:
1. Copy specific sections from the script
2. Run them manually in your shell
3. Add only what you need to .bashrc

### Integration with Existing Setup

If you already have a custom .bashrc setup:
1. Review the script's output sections
2. Manually merge only non-conflicting parts
3. Adjust PATH priorities as needed

## What This Script Does NOT Do

- âŒ Install any software or tools
- âŒ Modify system directories (requires sudo)
- âŒ Change system-wide configurations
- âŒ Install package managers
- âŒ Configure network settings
- âŒ Set up containerization

For tool installation workflows, see [README.md](../README.md)

## Related Documentation

- [README](../README.md) - Installation and usage workflows after XDG setup
- [Tool Installation Summary](tool_installation_summary.md) - Verify where tools are installed
- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html) - Official specification

## Version History

- **v1.1.0** - ASCII-only status output and refreshed cross-references
- **v1.0** - Initial release with complete XDG setup
  - All XDG base directories
  - Environment variables for Python, Go, npm, pip, Rust
  - Configuration files for pip and npm
  - Navigation aliases
  - Documentation generation
