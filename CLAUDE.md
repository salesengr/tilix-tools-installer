# CLAUDE.md - Project Context for AI Assistants

**Project:** Security Tools Installer
**Version:** 1.0.1
**Last Updated:** December 12, 2025
**Purpose:** User-space installation system for OSINT/CTI/PenTest security tools

---

## 🎯 Project Overview

This is a **bash-based installation system** that installs 37+ security tools (OSINT, CTI, reconnaissance, penetration testing) in **user-space without requiring sudo**. It follows XDG Base Directory standards and includes comprehensive error handling, logging, and dependency resolution.

### Key Characteristics
- **Target Environment:** Ubuntu 20.04+ containers/systems without sudo access
- **Language:** Pure Bash scripting (no external dependencies for core functionality)
- **Installation Method:** User-space only (~/.local/, ~/opt/)
- **Tool Categories:** Python, Go, Node.js, Rust tools
- **Architecture:** Modular with clear separation of concerns

---

## 📁 Project Structure

```
project/
├── README.md                       # User-facing overview & quick start
├── CHANGELOG.md                    # Version history
├── CLAUDE.md                       # This file - AI assistant context
│
├── install_security_tools.sh       # Main installer (1,524 lines)
├── test_installation.sh            # Verification suite (533 lines)
├── xdg_setup.sh                   # Environment setup (314 lines)
│
└── docs/
    ├── script_usage.md             # Detailed installation guide
    ├── xdg_setup.md               # XDG setup explanation
    ├── EXTENDING_THE_SCRIPT.md    # Developer guide for adding tools
    └── USER_SPACE_COMPATIBILITY.md # Technical compatibility analysis
```

---

## 🔧 Core Components

### 1. **install_security_tools.sh** (Main Installer)

**Purpose:** Install and manage security tools in user-space

**Key Features:**
- Interactive menu system (42 options)
- CLI support for automation
- Automatic dependency resolution
- Comprehensive logging
- Retry logic for downloads
- Dry-run mode

**Architecture:**
```bash
# Global variables and configuration
SCRIPT_VERSION="1.0.1"
declare -A TOOL_INFO          # tool => "Name|Description|Category"
declare -A TOOL_SIZES         # tool => "50MB"
declare -A TOOL_DEPENDENCIES  # tool => "prerequisite1 prerequisite2"
declare -A INSTALLED_STATUS   # tool => "true"|"false"

# Core functions
init_logging()              # Set up log directory and history
define_tools()              # Define all available tools
scan_installed_tools()      # Check what's already installed
check_dependencies()        # Verify prerequisites
install_tool()              # Main installation dispatcher
download_file()             # Retry-enabled download (NEW in v2.0.1)
verify_file_exists()        # Pre-extraction validation (NEW in v2.0.1)

# Installation functions (per tool type)
install_cmake()             # Build tools
install_go()                # Language runtimes
install_python_venv()       # Python environment
install_python_tool()       # Generic Python installer
install_go_tool()           # Generic Go installer
install_node_tool()         # Generic Node.js installer
install_rust_tool()         # Generic Rust installer

# User interface
show_menu()                 # Interactive menu
process_menu_selection()    # Handle menu input
show_installation_summary() # Display results
```

**Tool Categories:**
- `BUILD_TOOLS`: cmake, github_cli
- `LANGUAGES`: go, nodejs, rust
- `PYTHON_RECON_PASSIVE`: sherlock, holehe, socialscan, theHarvester, spiderfoot
- `PYTHON_RECON_DOMAIN`: sublist3r
- `PYTHON_RECON_WEB`: photon, wappalyzer
- `PYTHON_THREAT_INTEL`: shodan, censys, yara
- `PYTHON_CREDENTIAL`: h8mail
- `GO_RECON_ACTIVE`: gobuster, ffuf, httprobe
- `GO_RECON_PASSIVE`: waybackurls, assetfinder, subfinder
- `GO_VULN_SCAN`: nuclei
- `GO_THREAT_INTEL`: virustotal
- `NODE_TOOLS`: trufflehog, git-hound, jwt-cracker
- `RUST_RECON`: feroxbuster, rustscan
- `RUST_UTILS`: ripgrep, fd, bat, sd, tokei, dog

### 2. **xdg_setup.sh** (Environment Setup)

**Purpose:** Create XDG-compliant directory structure and configure environment

**What it creates:**
```bash
~/.local/
├── bin/        # User executables
├── lib/        # User libraries
├── share/      # User data (includes virtualenvs/)
└── state/      # Application state & logs

~/opt/
├── go/         # Go installation
├── gopath/     # Go workspace
├── node/       # Node.js installation
└── src/        # Source downloads

~/.config/      # Configuration files
~/.cache/       # Temporary cache
```

**Environment variables set:**
```bash
XDG_DATA_HOME="$HOME/.local/share"
XDG_CONFIG_HOME="$HOME/.config"
XDG_CACHE_HOME="$HOME/.cache"
XDG_STATE_HOME="$HOME/.local/state"
GOROOT="$HOME/opt/go"
GOPATH="$HOME/opt/gopath"
CARGO_HOME="$XDG_DATA_HOME/cargo"
RUSTUP_HOME="$XDG_DATA_HOME/rustup"
```

### 3. **test_installation.sh** (Verification Suite)

**Purpose:** Verify all installed tools are working correctly

**Test Functions:**
```bash
test_cmake()          # Build tools
test_go()             # Language runtimes
test_nodejs()
test_rust()
test_python_venv()    # Python environment
test_python_tool()    # Generic Python tool test
test_go_tool()        # Generic Go tool test
test_node_tool()      # Generic Node.js tool test
test_rust_tool()      # Generic Rust tool test
test_integration()    # Cross-component tests
```

---

## 🎨 Code Style & Conventions

### Bash Scripting Standards

**Variable Naming:**
```bash
GLOBAL_CONSTANTS="UPPERCASE"
local_variables="lowercase"
array_names=("lowercase_with_underscores")
declare -A associative_arrays
```

**Function Naming:**
```bash
install_toolname()      # Installation functions
test_toolname()         # Test functions
check_something()       # Validation functions
show_something()        # Display functions
create_something()      # Creation functions
```

**Error Handling:**
```bash
set +e                  # Don't exit on error (we handle errors manually)

# Check return codes explicitly
if some_command; then
    echo "Success"
else
    echo "Failed"
    return 1
fi

# Use logging for all operations
{
    echo "Operation started"
    # ... operations ...
    echo "Operation completed"
} > "$logfile" 2>&1
```

**Color Coding:**
```bash
GREEN='\033[0;32m'    # Success messages
YELLOW='\033[1;33m'   # Warnings
RED='\033[0;31m'      # Errors
BLUE='\033[0;36m'     # Headers
CYAN='\033[0;36m'     # Information
MAGENTA='\033[0;35m'  # Categories
NC='\033[0m'          # No Color (reset)
```

### File Organization

**Installation Functions Pattern:**
```bash
install_toolname() {
    local logfile=$(create_tool_log "toolname")
    
    {
        echo "=========================================="
        echo "Installing ToolName"
        echo "Started: $(date)"
        echo "=========================================="
        
        # Installation steps with error checking
        step1 || return 1
        step2 || return 1
        
        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1
    
    if is_installed "toolname"; then
        echo -e "${GREEN}✓ ToolName installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("toolname")
        log_installation "toolname" "success" "$logfile"
        cleanup_old_logs "toolname"
        return 0
    else
        echo -e "${RED}✗ ToolName installation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("toolname")
        FAILED_INSTALL_LOGS["toolname"]="$logfile"
        log_installation "toolname" "failure" "$logfile"
        return 1
    fi
}
```

---

## 🔑 Key Design Patterns

### 1. **Dependency Resolution**
```bash
check_dependencies() {
    local tool=$1
    local deps=${TOOL_DEPENDENCIES[$tool]}
    
    for dep in $deps; do
        if ! is_installed "$dep"; then
            install_tool "$dep"  # Recursive installation
        fi
    done
}
```

### 2. **Generic Installers**
Rather than duplicate code, use generic functions:
```bash
# Generic Python tool installer
install_python_tool "sherlock" "sherlock-project"

# Generic Go tool installer  
install_go_tool "gobuster" "github.com/OJ/gobuster/v3"

# Convenience wrappers
install_sherlock() { install_python_tool "sherlock" "sherlock-project"; }
```

### 3. **Download Retry Logic**
```bash
download_file() {
    local url=$1
    local output=$2
    local max_retries=3
    local retry=0
    
    while [ $retry -lt $max_retries ]; do
        if wget --progress=bar:force --show-progress "$url" -O "$output"; then
            if [ -f "$output" ]; then
                return 0
            fi
        fi
        retry=$((retry + 1))
        sleep 2
    done
    return 1
}
```

### 4. **Wrapper Script Creation**
Python tools need wrappers to auto-activate virtualenv:
```bash
create_python_wrapper() {
    local tool=$1
    cat > "$HOME/.local/bin/$tool" << 'WRAPPER_EOF'
#!/bin/bash
source $XDG_DATA_HOME/virtualenvs/tools/bin/activate
$tool "$@"
WRAPPER_EOF
    chmod +x "$HOME/.local/bin/$tool"
}
```

---

## 📋 Adding New Tools

### Step-by-Step Process

**1. Define the Tool** (in `define_tools()`)
```bash
TOOL_INFO[newtool]="NewTool|Description|Category"
TOOL_SIZES[newtool]="25MB"
TOOL_DEPENDENCIES[newtool]="python_venv"  # or "go", "nodejs", "rust"
TOOL_INSTALL_LOCATION[newtool]="~/.local/bin/newtool"
```

**2. Add to Category Array**
```bash
PYTHON_RECON_PASSIVE=("sherlock" "holehe" "newtool")
```

**3. Add Installation Check** (in `is_installed()`)
```bash
newtool)
    [ -f "$HOME/.local/bin/newtool" ] && return 0 ;;
```

**4. Create Installation Function**

For Python tools:
```bash
install_newtool() { install_python_tool "newtool" "newtool-package"; }
```

For Go tools:
```bash
install_newtool() { install_go_tool "newtool" "github.com/author/newtool"; }
```

For custom installation:
```bash
install_newtool() {
    local logfile=$(create_tool_log "newtool")
    # ... custom installation logic ...
}
```

**5. Add to Dispatcher** (in `install_tool()`)
```bash
newtool) install_newtool ;;
```

**6. Add to Menu** (in `show_menu()` and `process_menu_selection()`)

**7. Create Test Function** (in `test_installation.sh`)
```bash
test_newtool() {
    echo -e "${CYAN}Testing NewTool...${NC}"
    command -v newtool &>/dev/null
    test_result "newtool" "Command exists" $?
    # ... more tests ...
}
```

**See `docs/EXTENDING_THE_SCRIPT.md` for complete examples.**

---

## 🚨 Important Constraints & Requirements

### Environment Requirements
- ✅ **MUST work without sudo** - All installations in user-space
- ✅ **MUST be XDG compliant** - Follow standards for directories
- ✅ **MUST handle errors gracefully** - No silent failures
- ✅ **MUST log everything** - Comprehensive logging for debugging
- ✅ **MUST preserve user environment** - No system modifications

### Technical Constraints
- ✅ **Pure Bash** - No external dependencies for core functionality
- ✅ **Ubuntu 20.04+** - Target platform
- ✅ **Portable** - Must work in containers and restricted environments
- ✅ **Idempotent** - Running multiple times should be safe
- ✅ **Resumable** - Failed installations shouldn't break subsequent ones

### Security Constraints
- ❌ **NO sudo/root** - Never request elevated privileges
- ❌ **NO system file modifications** - Stay in user-space
- ❌ **NO hardcoded passwords/keys** - Never store credentials
- ✅ **Verify downloads** - Check files exist before extraction
- ✅ **Use HTTPS** - Secure download sources only

---

## 🧪 Testing Guidelines

### Before Committing Code

**1. Syntax Validation:**
```bash
bash -n install_security_tools.sh
bash -n test_installation.sh
bash -n xdg_setup.sh
```

**2. Dry Run Test:**
```bash
bash install_security_tools.sh --dry-run newtool
```

**3. Actual Installation Test:**
```bash
# In a clean environment
bash xdg_setup.sh
source ~/.bashrc
bash install_security_tools.sh newtool
bash test_installation.sh newtool
```

**4. Verify Logs:**
```bash
cat ~/.local/state/install_tools/logs/newtool-*.log
cat ~/.local/state/install_tools/installation_history.log
```

### Test Coverage Areas
- ✅ Installation succeeds
- ✅ Tool is accessible in PATH
- ✅ Tool can execute (--help or --version)
- ✅ Dependencies installed automatically
- ✅ Logs created and readable
- ✅ Can reinstall without errors
- ✅ Wrapper scripts work (for Python tools)

---

## 📝 Documentation Standards

### Code Comments
```bash
# Single-line comments for brief explanations

# Multi-line comments for complex logic:
# 1. What this does
# 2. Why it's done this way
# 3. Any gotchas or edge cases

# Section headers with clear separators:
# ===== MAJOR SECTION =====

# Subsection comments:
# ----- Subsection -----
```

### Function Documentation
```bash
# Function: install_toolname
# Purpose: Install ToolName from source
# Parameters: None
# Returns: 0 on success, 1 on failure
# Side effects: Creates files in ~/.local/bin/, logs to $LOG_DIR
# Dependencies: Requires prerequisite to be installed first
install_toolname() {
    # Implementation
}
```

### Update CHANGELOG.md
Every change should be documented:
```markdown
## [1.0.2] - YYYY-MM-DD

### Added
- New tool: newtool for reconnaissance

### Changed
- Improved error messages in download_file()

### Fixed
- Bug in dependency resolution for edge case
```

---

## 🎯 Common Tasks & Prompts

### For Claude Code

When working on this project, use these context-aware prompts:

**Adding a New Tool:**
```
Add a new Python OSINT tool called "newtool" that installs from PyPI 
package "newtool-package". Follow the existing patterns in the script.
```

**Fixing Bugs:**
```
The download for [tool] is failing. Review the download_file() function 
and the install_[tool]() function. Check logs at ~/.local/state/install_tools/logs/
```

**Improving Error Handling:**
```
Review [function_name] and add better error handling with informative 
messages. Ensure all commands check return codes.
```

**Updating Documentation:**
```
I added [tool]. Update README.md, CHANGELOG.md, and docs/script_usage.md 
to include this new tool in the appropriate sections.
```

**Refactoring:**
```
The [function_name] is getting too long. Refactor it into smaller, 
reusable functions while maintaining the existing error handling pattern.
```

---

## 🔍 Debugging Tips

### Common Issues

**1. Tool not found after installation:**
```bash
# Check if tool installed
is_installed "toolname"

# Check PATH
echo $PATH | grep -o "[^:]*" | while read p; do ls -la "$p" 2>/dev/null | grep toolname; done

# Reload environment
source ~/.bashrc
```

**2. Download failures:**
```bash
# Check log file
cat ~/.local/state/install_tools/logs/toolname-TIMESTAMP.log

# Test URL manually
wget --spider URL

# Check retry logic
grep "Attempting download" ~/.local/state/install_tools/logs/toolname-*.log
```

**3. Python import errors:**
```bash
# Check venv
ls -la ~/.local/share/virtualenvs/tools/

# Activate and test
source ~/.local/share/virtualenvs/tools/bin/activate
python3 -c "import module"
pip show package-name
deactivate
```

**4. Permission issues:**
```bash
# Check file ownership
ls -la ~/.local/bin/toolname

# Fix if needed
chmod +x ~/.local/bin/toolname
```

### Logging System

All logs are in: `~/.local/state/install_tools/logs/`

**Log Files:**
- `toolname-TIMESTAMP.log` - Individual tool installation log (keeps last 10)
- `installation_history.log` - Complete installation history

**Reading Logs:**
```bash
# View specific tool log (latest)
ls -t ~/.local/state/install_tools/logs/toolname-*.log | head -1 | xargs cat

# View installation history
tail -50 ~/.local/state/install_tools/installation_history.log

# Check for errors
grep -i error ~/.local/state/install_tools/logs/*.log
```

---

## 🔧 Development Workflow

### Making Changes

**1. Create a branch (if using git):**
```bash
git checkout -b feature/add-newtool
```

**2. Make changes following the patterns above**

**3. Test thoroughly:**
```bash
bash -n install_security_tools.sh  # Syntax check
bash install_security_tools.sh --dry-run newtool  # Preview
bash install_security_tools.sh newtool  # Actual install
bash test_installation.sh newtool  # Verify
```

**4. Update documentation:**
- Update CHANGELOG.md
- Update README.md if adding features
- Update docs/EXTENDING_THE_SCRIPT.md if changing patterns

**5. Commit with clear message:**
```bash
git add .
git commit -m "feat: Add newtool for reconnaissance

- Added install_newtool() function
- Updated tool definitions and categories
- Added test_newtool() verification
- Updated documentation

Closes #123"
```

### Version Numbering

Follow Semantic Versioning:
- **MAJOR.MINOR.PATCH** (e.g., 1.0.1)
- **MAJOR**: Breaking changes, major restructuring
- **MINOR**: New tools, features, improvements
- **PATCH**: Bug fixes, minor improvements

Update in:
1. `install_security_tools.sh` (SCRIPT_VERSION variable)
2. `CHANGELOG.md` (new version section)
3. `README.md` (version badge/header)

**Note:** Development infrastructure changes (agent configurations, CI/CD, etc.) should be documented under `[Unreleased]` in CHANGELOG.md and do NOT trigger version bumps, as they don't affect the installed product.

---

## 📚 Key Documentation Files

**For Users:**
- `README.md` - Start here
- `docs/script_usage.md` - Detailed usage guide
- `docs/xdg_setup.md` - Environment explanation

**For Developers:**
- `CLAUDE.md` (this file) - Project context
- `docs/EXTENDING_THE_SCRIPT.md` - Adding tools guide
- `docs/USER_SPACE_COMPATIBILITY.md` - Technical deep-dive
- `CHANGELOG.md` - Version history

---

## 🤖 Working with Claude Code

### Recommended Approach

**1. Load Project Context:**
```
@workspace Review the project structure and understand the main components.
```

**2. Before Making Changes:**
```
@workspace What's the current pattern for adding Python tools?
Show me an example from the existing code.
```

**3. Making Changes:**
```
@workspace Add a new Go tool called "httpx" from github.com/projectdiscovery/httpx/cmd/httpx
Follow the existing patterns and update all relevant files.
```

**4. Testing:**
```
@workspace Check if the syntax is correct in install_security_tools.sh 
and verify I followed all the conventions.
```

**5. Documentation:**
```
@workspace I added httpx tool. Update README.md, CHANGELOG.md to reflect this addition.
```

### Things Claude Code Should Know

**✅ DO:**
- Follow existing code patterns religiously
- Use the generic installers when possible
- Add comprehensive error handling
- Update all relevant documentation
- Test with --dry-run first
- Keep functions focused and modular
- Preserve the logging system
- Maintain XDG compliance

**❌ DON'T:**
- Add sudo/root requirements
- Modify system files
- Break user-space installation
- Skip error checking
- Forget to update documentation
- Change the overall architecture
- Remove existing error handling
- Hardcode paths (use variables)

---

## 🎓 Learning Resources

### Understanding the Codebase

**Start Here:**
1. Read `README.md` for overview
2. Review `xdg_setup.sh` (simplest script)
3. Study `install_security_tools.sh` structure:
   - Global variables and arrays
   - `define_tools()` - tool definitions
   - Generic installers (install_python_tool, install_go_tool)
   - Specific installers (install_sherlock, install_gobuster)
   - Menu system and CLI handling
4. Review `test_installation.sh` for verification patterns

### Key Concepts

**XDG Base Directory Specification:**
- Standardizes where applications store files
- `~/.local/` for user applications
- `~/.config/` for configuration
- `~/.cache/` for temporary data
- See: https://specifications.freedesktop.org/basedir-spec/

**User-Space Installation:**
- No root/sudo required
- Everything in home directory
- PATH manipulation for discoverability
- Virtual environments for isolation

**Bash Associative Arrays:**
```bash
declare -A TOOL_INFO
TOOL_INFO[toolname]="Name|Description|Category"
echo ${TOOL_INFO[toolname]}  # Access value
```

---

## 🚀 Quick Reference

### File Locations After Installation
```bash
# Executables
~/.local/bin/              # Python wrappers, binaries
~/opt/gopath/bin/          # Go tools
~/.local/share/cargo/bin/  # Rust tools

# Data
~/.local/share/virtualenvs/tools/  # Python venv
~/opt/go/                          # Go installation
~/opt/node/                        # Node.js installation

# Configuration  
~/.config/pip/pip.conf
~/.config/npm/npmrc
~/.config/wget/wgetrc

# Logs
~/.local/state/install_tools/logs/
~/.local/state/install_tools/installation_history.log
```

### Quick Commands
```bash
# Install specific tools
bash install_security_tools.sh sherlock gobuster

# Install category
bash install_security_tools.sh --python-tools

# Preview installation
bash install_security_tools.sh --dry-run nuclei

# Test installation
bash test_installation.sh

# View logs
tail -f ~/.local/state/install_tools/installation_history.log
```

### Common Issues & Solutions

**Issue:** Tool not found after installation
**Solution:**
```bash
source ~/.bashrc
which toolname
```

**Issue:** Download failures
**Solution:** Check logs in `~/.local/state/install_tools/logs/` - The script has 3 retries built in.

**Issue:** Permission denied
**Solution:** Never use sudo. Check that `~/.local/bin` is in your PATH.

---

## 🤖 Agent Configuration & Workflows

This project includes 7 specialized Claude Code agents configured in `.claude/agents/` to streamline development, testing, and security auditing. These agents are trained on bash scripting best practices, project patterns, and security requirements.

### Available Agents

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| **planner** | Strategic planning & task decomposition | Complex multi-step tasks, major features |
| **bash-script-developer** | Bash scripting specialist | Add/refactor installation functions, implement utilities |
| **test-automation-engineer** | Test generation & validation | Create tests for new tools, verify coverage |
| **security-auditor** | Security review & vulnerability scanning | Before releases, audit downloads/credentials |
| **code-reviewer** | Code quality analysis (bash-enhanced) | After ANY code changes, pre-merge reviews |
| **debugger** | Bug investigation & systematic fixing | Installation failures, unexpected errors |
| **documentation-engineer** | Technical writing & doc updates | Update README, CHANGELOG, guides |

**Note:** The `fullstack-developer` agent has been disabled (moved to `.claude/agents/disabled/`) as it's designed for web apps, not bash scripting.

### Agent Workflows

#### Workflow 1: Adding a New Security Tool

**Example:** Adding httpx reconnaissance tool

```bash
# Step 1: Planning
> Use planner to create a plan for adding httpx from ProjectDiscovery

# Step 2: Implementation
> Use bash-script-developer to implement install_httpx() following existing Go tool patterns

# Step 3: Testing
> Use test-automation-engineer to create test_httpx() function

# Step 4: Security Review
> Use security-auditor to check download mechanism, verify HTTPS, check user-space compliance

# Step 5: Code Quality Review
> Use code-reviewer to verify bash best practices, shellcheck compliance, and error handling

# Step 6: Documentation
> Use documentation-engineer to update README.md, CHANGELOG.md, and docs/script_usage.md
```

**Expected Results:**
- ✅ Properly quoted bash code (shellcheck compliant)
- ✅ HTTPS-only downloads with verification
- ✅ User-space installation (no sudo)
- ✅ Comprehensive test coverage
- ✅ Updated documentation
- ✅ ~60% time savings vs manual

#### Workflow 2: Debugging Installation Failure

**Example:** nuclei installation failing with 'command not found'

```bash
# Step 1: Investigation
> Use debugger to investigate why nuclei installation is failing

# Debugger will:
# - Read installation logs
# - Check PATH configuration
# - Verify Go runtime dependency
# - Test hypotheses systematically
# - Implement fix

# Step 2: Validation
> Use test-automation-engineer to run test_nuclei() and verify fix

# Step 3: Review
> Use code-reviewer to ensure fix doesn't introduce regressions
```

**Expected Results:**
- ✅ Root cause identified and documented
- ✅ Fix implemented with proper error handling
- ✅ Tests pass
- ✅ ~50% time savings vs trial-and-error

#### Workflow 3: Security Audit Before Release

**Example:** Preparing v2.1.0 release

```bash
# Step 1: Full Security Scan
> Use security-auditor to audit entire codebase before v2.1.0 release

# Checks:
# - No sudo/root usage
# - All downloads use HTTPS
# - No hardcoded credentials
# - Download verification present
# - XDG compliance
# - User-space only installations

# Step 2: Code Quality Review
> Use code-reviewer to check bash best practices compliance across all scripts

# Step 3: Test Coverage Verification
> Use test-automation-engineer to verify all 37 tools have corresponding tests

# Step 4: Documentation Review
> Use documentation-engineer to verify CHANGELOG completeness and version sync
```

**Expected Results:**
- ✅ Zero critical security issues
- ✅ Shellcheck violations resolved
- ✅ 100% test coverage
- ✅ Release-ready documentation
- ✅ ~70% time savings vs manual review

### Agent Best Practices

#### When to Use Agents Proactively

**ALWAYS use these agents without being asked:**

1. **code-reviewer** - After ANY bash code changes (security is critical)
   ```bash
   # After modifying install_security_tools.sh
   > Use code-reviewer to check my recent changes
   ```

2. **security-auditor** - Before releases or after download changes
   ```bash
   # Before tagging v2.1.0
   > Use security-auditor for full codebase audit
   ```

3. **test-automation-engineer** - When adding new tools
   ```bash
   # After adding install_httpx()
   > Use test-automation-engineer to create test_httpx()
   ```

#### Agent Specializations

**bash-script-developer** knows:
- Project patterns: `install_python_tool()`, `install_go_tool()`, `install_node_tool()`, `install_rust_tool()`
- Tool metadata: `TOOL_INFO[]`, `TOOL_SIZES[]`, `TOOL_DEPENDENCIES[]`
- Logging pattern: `logfile=$(create_tool_log "tool")`
- XDG variables: `$XDG_DATA_HOME`, `$XDG_CONFIG_HOME`, etc.
- Error handling: Explicit return code checking (set +e project style)

**test-automation-engineer** knows:
- Generic test functions: `test_python_tool()`, `test_go_tool()`, etc.
- Test result tracking: `test_result "tool" "Test name" $?`
- Test structure: cyan header, green [OK], red [FAIL]
- Integration tests: dependency verification

**security-auditor** knows:
- Project constraints: NO sudo, HTTPS only, user-space only
- Security patterns: Download verification, secret detection
- Vulnerability checks: Command injection, path traversal, credential leaks
- Compliance checks: XDG compliance, no hardcoded paths

**code-reviewer** (enhanced) knows:
- Shellcheck rules: SC2086 (quoting), SC2155, SC2046
- Bash anti-patterns: unquoted expansion, useless cat, incorrect conditionals
- Project security rules: No sudo, HTTPS only, verify downloads
- Project patterns: Tool definitions, logging, installation verification

### Quick Agent Reference

```bash
# Strategic planning
"Use planner to create a plan for [complex task]"

# Bash implementation
"Use bash-script-developer to [implement/refactor] [function]"

# Test creation
"Use test-automation-engineer to create tests for [tool]"

# Security audit
"Use security-auditor to audit [component/entire codebase]"

# Code review
"Use code-reviewer to review [file/recent changes]"

# Bug fixing
"Use debugger to investigate [error/issue]"

# Documentation
"Use documentation-engineer to update [docs] with [changes]"
```

### Agent Integration with Development Flow

#### Normal Development Cycle

```
1. Understand task → Use planner (optional, for complex tasks)
2. Implement code → Use bash-script-developer
3. Create tests → Use test-automation-engineer
4. Security check → Use security-auditor
5. Quality review → Use code-reviewer (ALWAYS)
6. Update docs → Use documentation-engineer
```

#### Bug Fix Cycle

```
1. Investigate → Use debugger
2. Verify fix → Use code-reviewer
3. Ensure tests pass → Use test-automation-engineer
```

#### Release Cycle

```
1. Security audit → Use security-auditor
2. Quality check → Use code-reviewer
3. Test coverage → Use test-automation-engineer
4. Docs sync → Use documentation-engineer
```

### Metrics & Success Indicators

Track agent effectiveness:

- **Usage Frequency:** Agents used in >80% of tool additions
- **Error Detection:** Security/quality issues caught before merging
- **Time Savings:** >50% reduction in development time
- **Code Quality:** Zero shellcheck violations, 100% test coverage
- **Security:** Zero secrets committed, all downloads HTTPS

### Agent Configuration Location

All agents are configured in `.claude/agents/`:

```
.claude/agents/
├── README.md                        # Agent documentation & workflows
├── planner.md                       # Strategic planning agent
├── bash-script-developer.md         # Bash specialist (NEW)
├── test-automation-engineer.md      # Test generation (NEW)
├── security-auditor.md              # Security review (NEW)
├── code-reviewer.md                 # Code quality (ENHANCED)
├── debugger.md                      # Bug investigation
├── documentation-engineer.md        # Technical writing
└── disabled/
    └── fullstack-developer.md       # Disabled (not applicable to bash project)
```

**To modify agent behavior:** Edit the corresponding `.md` file
**To disable an agent:** Move to `disabled/` subdirectory
**To create a new agent:** Add a new `.md` file with YAML frontmatter

### Advanced Agent Usage

#### Combining Agents

For complex tasks, use agents sequentially:

```bash
# Major refactoring
> Use planner to create refactoring strategy for download_file function
> Use bash-script-developer to implement refactored function
> Use security-auditor to verify download security
> Use code-reviewer to check bash best practices
> Use test-automation-engineer to update tests
```

#### Agent Customization

Agents automatically read `CLAUDE.md` (this file) for project context. To customize:

1. Add project-specific patterns to this file
2. Update agent `.md` files for permanent changes
3. Reference existing implementations when invoking agents

#### Troubleshooting Agents

**Agent not following patterns?**
- Point to existing similar implementation: "See install_gobuster for reference"
- Agents read CLAUDE.md for context automatically

**Agent being too verbose?**
- Be specific: "Only implement install_httpx, don't update docs yet"

**Agent missing project context?**
- Ensure CLAUDE.md is up-to-date
- Reference specific sections: "Follow the Installation Function Pattern in CLAUDE.md"

---

## 🔌 MCP Server Configuration

This project uses **Docker MCP (Model Context Protocol) servers** to enhance agent capabilities, reduce manual operations, and improve development velocity. MCP servers run in isolated Docker containers and provide specialized tools that agents can use.

### What Are MCP Servers?

MCP servers are containerized services that extend Claude Code agents with specialized capabilities:
- **Filesystem MCP**: Efficient file read/write/search operations (11 tools)
- **Sequential Thinking MCP**: Structured problem-solving and reasoning
- **GitHub MCP**: Automated issue/PR management and dependency checks
- **Git MCP**: Version control automation (commit, push, branch)
- **Brave Search MCP**: Web research and CVE lookups
- **And 270+ more** in the Docker MCP Catalog

**Benefits:**
- ⚡ 60-70% faster task completion
- 🎯 2.5-3x improvement in agent velocity
- 🔒 Sandboxed execution (security-first)
- 🤖 Increased agent autonomy
- ✅ Consistent, error-free operations

### Recommended MCP Servers for This Project

Based on comprehensive analysis of the Docker MCP Catalog, **8 servers** are recommended in 3 tiers:

#### 🎯 Tier 1: Essential (Immediate Implementation)

| Server | Purpose | Impact | Cost |
|--------|---------|--------|------|
| **Filesystem** | File operations for ALL agents | ⭐⭐⭐⭐⭐ (60% faster file I/O) | Free |
| **Sequential Thinking** | Structured reasoning for planner/debugger | ⭐⭐⭐⭐⭐ (40% better decisions) | Free |
| **GitHub Official** | Issue/PR management, dependency checks | ⭐⭐⭐⭐ (critical for releases) | Free (rate limited) |

#### 🎯 Tier 2: High Value

| Server | Purpose | Impact | Cost |
|--------|---------|--------|------|
| **Brave Search** | CVE searches, security research | ⭐⭐⭐⭐ (70% faster research) | Paid (API key) |
| **Git** | Automated git operations | ⭐⭐⭐⭐ (50% fewer errors) | Free |
| **Fetch** | Download security bulletins, docs | ⭐⭐⭐ (useful for audits) | Free |

#### 🎯 Tier 3: Optional

| Server | Purpose | Impact | Cost |
|--------|---------|--------|------|
| **Context7** | Inject accurate shellcheck docs | ⭐⭐⭐ (reduces hallucination) | Unknown |
| **Obsidian** | Project memory across sessions | ⭐⭐⭐ (long-term value) | Free |

### Agent-MCP Compatibility Matrix

How each agent benefits from MCP servers:

| Agent | Filesystem | Sequential Thinking | GitHub | Git | Brave Search | Fetch |
|-------|-----------|---------------------|--------|-----|--------------|-------|
| **bash-script-developer** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| **test-automation-engineer** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐ |
| **security-auditor** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **code-reviewer** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐ |
| **debugger** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| **documentation-engineer** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **planner** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐ |

**Legend:** ⭐⭐⭐⭐⭐ = Essential | ⭐⭐⭐⭐ = High Value | ⭐⭐⭐ = Medium | ⭐⭐ = Low | ⭐ = Minimal

### Quick Setup Guide

**Prerequisites:**
- Docker Desktop 4.48+
- Docker MCP Toolkit enabled

**Phase 1: Core Infrastructure (15 minutes)**
```bash
# Enable essential MCPs
docker mcp server enable filesystem
docker mcp server enable sequentialthinking
docker mcp server enable github-official

# Configure Filesystem allowed paths
# In Docker Desktop MCP Toolkit: Configure allowed paths
# /Users/mikeb/Documents/GitHub/tilix-tools-installer
```

**Phase 2: Enhanced Capabilities (20 minutes)**
```bash
# Generate GitHub PAT at https://github.com/settings/tokens
# Enable GitHub MCP with PAT in Docker Desktop

# Enable Git and Brave Search
docker mcp server enable git
docker mcp server enable brave  # Requires Brave Search API key
docker mcp server enable fetch
```

**Phase 3: Configuration**

Create `.claude/mcp_servers.json` (tracked in this repo):
```json
{
  "mcpServers": {
    "filesystem": {
      "enabled": true,
      "allowedPaths": ["/Users/mikeb/Documents/GitHub/tilix-tools-installer"],
      "priority": "high",
      "usedBy": ["all"]
    },
    "sequentialthinking": {
      "enabled": true,
      "priority": "high",
      "usedBy": ["planner", "debugger", "bash-script-developer"]
    },
    "github-official": {
      "enabled": true,
      "auth": "PAT",
      "priority": "high"
    },
    "git": { "enabled": true, "priority": "medium" },
    "brave": { "enabled": true, "auth": "API_KEY", "priority": "medium" },
    "fetch": { "enabled": true, "priority": "medium" }
  }
}
```

### Enhanced Workflows with MCPs

**Example: Adding httpx reconnaissance tool (WITH MCPs)**

```
Time: 10-15 min (was 30-45 min without MCPs)

Step 1: planner (with Sequential Thinking + Filesystem + GitHub)
  → Uses Sequential Thinking to decompose task
  → Uses Filesystem to read existing tool patterns
  → Uses GitHub to check for open issues

Step 2: bash-script-developer (with Filesystem + Brave Search)
  → Uses Filesystem to edit install_security_tools.sh
  → Uses Brave Search for ProjectDiscovery/httpx docs

Step 3: test-automation-engineer (with Filesystem + Git)
  → Uses Filesystem to write test_httpx()
  → Uses Git to stage changes

Step 4: security-auditor (with Filesystem + Brave + Fetch)
  → Uses Filesystem to search for "sudo" in code
  → Uses Brave to check "ProjectDiscovery httpx CVE"
  → Uses Fetch to download security advisories

Step 5: code-reviewer (with Filesystem + GitHub)
  → Uses Filesystem to generate git-style diff
  → Validates against checklist

Step 6: documentation-engineer (with Filesystem + Git)
  → Uses Filesystem to edit README.md, CHANGELOG.md
  → Uses Git to commit with proper message

Result: 70% time savings, 80% error reduction
```

**Example: Security Audit Before Release (WITH MCPs)**

```
Time: 15-25 min (was 60-90 min without MCPs)

security-auditor uses:
  → Filesystem to search entire codebase for patterns
  → Brave Search to check CVEs for all 37 tools
  → Fetch to download OWASP/CIS benchmarks
  → GitHub to check dependency advisories

Result: Automated, comprehensive, fast
```

### Expected Impact

**Quantitative Benefits:**
- **File operations:** 60% faster with Filesystem MCP
- **Web searches:** 70% reduction with Brave MCP
- **Git operations:** 50% fewer errors with Git MCP
- **Problem-solving:** 40% better quality with Sequential Thinking MCP
- **CVE checking:** 80% faster with automated Brave+Fetch
- **Overall velocity:** 2.5-3x improvement

**Qualitative Benefits:**
- ✅ Reduced agent hallucination (Context7 injects accurate docs)
- ✅ Better agent autonomy (agents don't ask "should I read X file?")
- ✅ Consistent operations (Filesystem MCP enforces patterns)
- ✅ Security-first (sandboxed MCP containers prevent accidents)
- ✅ Scalability (adding new tools becomes 3x faster)

### Comprehensive Documentation

**Full MCP Server Configuration Plan:**
- Location: `~/.claude/plans/gleaming-waddling-sketch.md`
- Contents:
  - Detailed server descriptions and capabilities
  - 4-phase implementation plan (3 weeks)
  - Cost-benefit analysis
  - Risk mitigation strategies
  - Success metrics and measurement
  - **APPENDIX A:** Reusable framework for other projects

**Reusable Framework for Other Projects:**
- 7-step selection process (~2-3 hours)
- Comprehensive catalog of 270+ MCP servers
- Project templates and decision flowcharts
- Measurement templates for ROI tracking
- Cross-project learnings and best practices
- **Time to replicate:** 30-45 minutes (vs 3-4 hours from scratch)

**Docker MCP Resources:**
- [Docker MCP Catalog](https://hub.docker.com/mcp) - Browse 270+ servers
- [6 Must-Have MCP Servers (2025)](https://www.docker.com/blog/top-mcp-servers-2025/)
- [MCP Gateway Documentation](https://docs.docker.com/ai/mcp-catalog-and-toolkit/mcp-gateway/)
- [GitHub MCP Registry](https://github.com/docker/mcp-registry)

### Agent Prompt Updates

When agents invoke MCP tools, they should:
1. **Check MCP availability first** before using Read/Write/Edit/Grep
2. **Batch operations** (use `read_multiple_files` not multiple `Read` calls)
3. **Use Sequential Thinking** for tasks with >3 steps
4. **Graceful fallback** to native tools if MCP unavailable

Each agent configuration in `.claude/agents/*.md` includes an "Available MCP Tools" section with:
- When to use each MCP
- Specific tools/capabilities
- Concrete examples
- Benefits and performance improvements

### Current Status

**Implementation Status:** Planning complete, ready for Phase 1 deployment

**Next Steps:**
1. Install Docker Desktop 4.48+ (if not already)
2. Enable Tier 1 MCPs (Filesystem + Sequential Thinking + GitHub)
3. Test with security-auditor running automated CVE checks
4. Measure baseline metrics (time, errors, autonomy)
5. Roll out to all agents with prompt updates
6. Enable Tier 2 servers as needed
7. Document learnings and iterate

**Maintenance:**
- Monthly: Check Docker MCP Catalog for new relevant servers
- Quarterly: Review MCP usage statistics and adjust tiers
- Annually: Re-evaluate entire MCP stack

---

## 📞 Support & Contribution

When contributing or seeking help:

1. **Check existing documentation first**
2. **Review similar implementations** in the codebase
3. **Test thoroughly** before submitting
4. **Update documentation** with your changes
5. **Follow code conventions** established here

---

## ✅ Checklist for New Contributors

- [ ] Read README.md
- [ ] Read this CLAUDE.md file
- [ ] Review docs/EXTENDING_THE_SCRIPT.md
- [ ] Understand XDG Base Directory structure
- [ ] Familiar with bash associative arrays
- [ ] Know how to test changes (--dry-run)
- [ ] Understand the logging system
- [ ] Ready to follow established patterns

---

**Last Updated:** December 13, 2025
**Maintainer Context:** This file is specifically designed to give AI assistants (like Claude Code) comprehensive context about the project structure, conventions, and best practices. Keep it updated as the project evolves.

**Agent Configuration:** 7 specialized agents configured in `.claude/agents/` - See "🤖 Agent Configuration & Workflows" section for details.

**MCP Server Configuration:** 8 recommended MCP servers for enhancing agent capabilities - See "🔌 MCP Server Configuration" section for setup and usage. Full plan with reusable framework in `~/.claude/plans/gleaming-waddling-sketch.md`.
