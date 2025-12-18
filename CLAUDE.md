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

## 🎯 Common Tasks

**Adding a New Tool:** Add tools using generic installers (`install_python_tool`, `install_go_tool`, `install_node_tool`, `install_rust_tool`) and follow the pattern in the "Adding New Tools" section.

**Fixing Bugs:** Check logs at `~/.local/state/install_tools/logs/` and review the relevant `install_[tool]()` function and `download_file()` for download issues.

---

## 🔍 Debugging Tips

**Tool not found after installation:** Run `source ~/.bashrc` to reload environment. Check if tool is in PATH using `which toolname`.

**Logging System:**

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

### Agent Best Practices

**Proactive Agent Use:**
- Use **code-reviewer** after ANY bash code changes (security is critical)
- Use **security-auditor** before releases or after download changes
- Use **test-automation-engineer** when adding new tools
- All agents automatically read this CLAUDE.md file for project context

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

---

## 🔌 MCP Server Configuration

This project uses **Docker MCP (Model Context Protocol) servers** to enhance agent capabilities, reduce manual operations, and improve development velocity. MCP servers run in isolated Docker containers and provide specialized tools that agents can use.

**Recommended MCP Servers:**

This project benefits from 8 Docker MCP servers that enhance agent capabilities:
- **Tier 1 (Essential):** Filesystem, Sequential Thinking, GitHub Official
- **Tier 2 (High Value):** Brave Search, Git, Fetch
- **Tier 3 (Optional):** Context7, Obsidian

**Quick Start:** Enable MCPs with `docker mcp server enable <server-name>` (requires Docker Desktop 4.48+)

**Full Configuration Details:** See `~/.claude/plans/gleaming-waddling-sketch.md` for:
- Complete server descriptions and capabilities
- Implementation plan with phases and timelines
- Agent-MCP compatibility matrix
- Setup guides and configuration examples
- Expected impact metrics (60-70% faster, 2.5-3x velocity)
- Reusable framework for other projects

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
