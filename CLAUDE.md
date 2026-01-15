# CLAUDE.md - Project Context for AI Assistants

**Project:** Security Tools Installer
**Version:** 1.1.0
**Last Updated:** December 16, 2025
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
SCRIPT_VERSION="1.1.0"
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
- `GLOBAL_CONSTANTS="UPPERCASE"`
- `local_variables="lowercase"`
- `array_names=("lowercase_with_underscores")`
- `declare -A associative_arrays`

**Function Naming:**
- `install_toolname()` - Installation functions
- `test_toolname()` - Test functions
- `check_something()` - Validation functions
- `show_something()` - Display functions
- `create_something()` - Creation functions

**Error Handling:**
- Use `set +e` - Manual error handling (explicit return code checks)
- Check all return codes: `command || return 1`
- Log all operations: `{ commands... } > "$logfile" 2>&1`

**Color Coding:**
- GREEN (`\033[0;32m`) - Success | YELLOW (`\033[1;33m`) - Warnings | RED (`\033[0;31m`) - Errors
- BLUE/CYAN (`\033[0;36m`) - Headers/Info | MAGENTA (`\033[0;35m`) - Categories | NC (`\033[0m`) - Reset

### File Organization

**Installation Functions Pattern:**
```bash
install_toolname() {
    local logfile=$(create_tool_log "toolname")
    {
        echo "Installing ToolName | Started: $(date)"
        step1 || return 1  # Installation steps with error checking
        step2 || return 1
        echo "Completed: $(date)"
    } > "$logfile" 2>&1

    if is_installed "toolname"; then
        echo -e "${GREEN}✓ ToolName installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("toolname")
        log_installation "toolname" "success" "$logfile"
        cleanup_old_logs "toolname"
        return 0
    else
        echo -e "${RED}✗ ToolName installation failed. See: $logfile${NC}"
        FAILED_INSTALLS+=("toolname"); FAILED_INSTALL_LOGS["toolname"]="$logfile"
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

### 7-Step Process

1. **Define tool metadata** in `define_tools()` - Add `TOOL_INFO[]`, `TOOL_SIZES[]`, `TOOL_DEPENDENCIES[]`, `TOOL_INSTALL_LOCATION[]`
2. **Add to category array** - e.g., `PYTHON_RECON_PASSIVE=("sherlock" "holehe" "newtool")`
3. **Add installation check** in `is_installed()` - Check if binary exists
4. **Create installation function**:
   - Python: `install_newtool() { install_python_tool "newtool" "package-name"; }`
   - Go: `install_newtool() { install_go_tool "newtool" "github.com/author/newtool"; }`
   - Custom: Write `install_newtool()` with proper logging and error handling
5. **Add to dispatcher** in `install_tool()` - Add case statement entry
6. **Add to menu** in `show_menu()` and `process_menu_selection()`
7. **Create test function** in `test_installation.sh` - Verify installation works

**Complete examples and code patterns:** See `docs/EXTENDING_THE_SCRIPT.md`

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

### Context-Aware Prompts for Claude Code

**Adding a tool:** "Add [Python/Go/Node/Rust] tool '[name]' from [source]. Follow existing patterns."

**Fixing bugs:** "The [tool] installation is failing. Review install_[tool]() and logs at ~/.local/state/install_tools/logs/"

**Improving error handling:** "Review [function] and add better error handling with return code checks."

**Updating docs:** "I added [tool]. Update README.md, CHANGELOG.md, and docs/script_usage.md."

**Refactoring:** "Refactor [function] into smaller functions while maintaining error handling patterns."

---

## 🔍 Debugging Tips

### Common Issues

**Tool not found:** Check installation (`is_installed "toolname"`), verify PATH, reload environment (`source ~/.bashrc`)

**Download failures:** Check logs at `~/.local/state/install_tools/logs/toolname-*.log`, test URL (`wget --spider URL`), verify 3 retries in logs

**Python import errors:** Verify venv exists (`ls ~/.local/share/virtualenvs/tools/`), activate and test imports, check `pip show package-name`

**Permission issues:** Check ownership (`ls -la ~/.local/bin/toolname`), fix with `chmod +x` if needed

### Logging System

**Location:** `~/.local/state/install_tools/logs/`

**Files:**
- `toolname-TIMESTAMP.log` - Individual tool logs (last 10 kept)
- `installation_history.log` - Complete history

**Quick Commands:**
```bash
# View latest tool log
ls -t ~/.local/state/install_tools/logs/toolname-*.log | head -1 | xargs cat

# View history
tail -50 ~/.local/state/install_tools/installation_history.log

# Find errors
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
- `.claude/agents/WORKFLOWS.md` - Agent workflows & usage patterns
- `docs/EXTENDING_THE_SCRIPT.md` - Adding tools guide
- `docs/USER_SPACE_COMPATIBILITY.md` - Technical deep-dive
- `CHANGELOG.md` - Version history

**For Agent Configuration:**
- `~/.claude/plans/gleaming-waddling-sketch.md` - MCP server configuration plan

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

1. **README.md** - Project overview
2. **xdg_setup.sh** - Simplest script, environment setup
3. **install_security_tools.sh** - Main installer: global variables/arrays, `define_tools()`, generic installers (`install_python_tool`, `install_go_tool`), menu system
4. **test_installation.sh** - Verification patterns

### Key Concepts

**XDG Base Directory:** Standardizes file locations - `~/.local/` (user apps), `~/.config/` (config), `~/.cache/` (temp). See https://specifications.freedesktop.org/basedir-spec/

**User-Space Installation:** No sudo, everything in home directory, PATH manipulation, virtual environment isolation

**Bash Associative Arrays:**
```bash
declare -A TOOL_INFO; TOOL_INFO[tool]="Name|Desc|Category"
echo ${TOOL_INFO[tool]}  # Access value
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

7 specialized agents in `.claude/agents/` streamline development, testing, and security auditing.

### Available Agents

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| **planner** | Planning & task decomposition | Complex multi-step tasks |
| **bash-script-developer** | Bash scripting specialist | Add/refactor installation functions |
| **test-automation-engineer** | Test generation & validation | Create tests for new tools |
| **security-auditor** | Security review & vulnerability scanning | Before releases, audit downloads |
| **code-reviewer** | Code quality analysis (bash-enhanced) | After ANY code changes (REQUIRED) |
| **debugger** | Bug investigation & systematic fixing | Installation failures, unexpected errors |
| **documentation-engineer** | Technical writing & doc updates | Update README, CHANGELOG, guides |

**Detailed workflows, examples, and agent-MCP compatibility:** See `.claude/agents/WORKFLOWS.md`

### Quick Usage

```bash
# Planning
"Use planner to create a plan for [complex task]"

# Implementation
"Use bash-script-developer to implement install_X()"

# Testing
"Use test-automation-engineer to create test_X()"

# Security audit
"Use security-auditor to audit [component/entire codebase]"

# Code review (ALWAYS after code changes)
"Use code-reviewer to review [file/recent changes]"

# Bug fixing
"Use debugger to investigate [error/issue]"

# Documentation
"Use documentation-engineer to update [docs]"
```

### Development Flow

**Normal Development:**
1. Understand task → planner (for complex tasks)
2. Implement → bash-script-developer
3. Test → test-automation-engineer
4. Audit → security-auditor
5. Review → code-reviewer (REQUIRED)
6. Document → documentation-engineer

**Bug Fix:**
1. Investigate → debugger
2. Review fix → code-reviewer
3. Validate → test-automation-engineer

**Release:**
1. Security audit → security-auditor
2. Quality check → code-reviewer
3. Test coverage → test-automation-engineer
4. Docs sync → documentation-engineer

### Proactive Agent Usage

**ALWAYS use without being asked:**
- **code-reviewer** - After ANY bash code changes (security critical)
- **security-auditor** - Before releases or after download changes
- **test-automation-engineer** - When adding new tools

### Agent Configuration

Located in `.claude/agents/`:
- Individual agent configs: `planner.md`, `bash-script-developer.md`, etc.
- Detailed workflows: `WORKFLOWS.md`
- Agent documentation: `README.md`
- Disabled agents: `disabled/` subdirectory

**To modify:** Edit corresponding `.md` file
**To disable:** Move to `disabled/` subdirectory

---

## 🔌 MCP Server Configuration

**Docker MCP servers** extend agent capabilities through containerized tools for filesystem ops, GitHub automation, sequential thinking, and more. Benefits include 60-70% faster task completion, 2.5-3x velocity improvement, and increased agent autonomy.

### Essential MCPs (Tier 1)

| Server | Purpose | Impact |
|--------|---------|--------|
| **Filesystem** | File read/write/search for ALL agents | 60% faster file I/O |
| **Sequential Thinking** | Structured reasoning for planner/debugger | 40% better decisions |
| **GitHub Official** | Issue/PR management, dependency checks | Critical for releases |

**Additional MCPs (Tier 2-3):**
- **Git** - Automated git operations (50% fewer errors)
- **Brave Search** - CVE research, security bulletins (70% faster)
- **Fetch** - Download docs and security advisories
- **Context7** - Inject accurate shellcheck/bash docs
- **Obsidian** - Project memory across sessions

### Full Documentation

**Complete MCP analysis & implementation plan:**
- Location: `~/.claude/plans/gleaming-waddling-sketch.md`
- Includes: 8 recommended servers, 4-phase rollout, agent-MCP compatibility matrix, cost-benefit analysis, reusable framework for other projects

**Docker MCP Resources:**
- [Docker MCP Catalog](https://hub.docker.com/mcp) - Browse 270+ servers
- [6 Must-Have MCP Servers (2025)](https://www.docker.com/blog/top-mcp-servers-2025/)
- [MCP Gateway Documentation](https://docs.docker.com/ai/mcp-catalog-and-toolkit/mcp-gateway/)

### Quick Setup

**Prerequisites:** Docker Desktop 4.48+ with MCP Toolkit

```bash
# Enable Tier 1 MCPs
docker mcp server enable filesystem
docker mcp server enable sequentialthinking
docker mcp server enable github-official

# Configure filesystem allowed paths in Docker Desktop MCP Toolkit
# Add project path: /Users/mikeb/Documents/GitHub/tilix-tools-installer
```

**Enhanced workflows and examples:** See `.claude/agents/WORKFLOWS.md`

### Current Status

**Implementation Status:** Planning complete, ready for Phase 1 deployment

**Next Steps:**
1. Enable Tier 1 MCPs (Filesystem, Sequential Thinking, GitHub)
2. Test with security-auditor for automated CVE checks
3. Enable Tier 2 servers as needed
4. Measure velocity improvements

**Agent Integration:** All 7 agents configured to use MCPs when available. See agent `.md` files for MCP-specific tools and usage patterns.

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

**Last Updated:** December 16, 2025
**Maintainer Context:** This file provides AI assistants (like Claude Code) with essential project context. For detailed workflows and examples, see `.claude/agents/WORKFLOWS.md`.

**Agent Configuration:** 7 specialized agents in `.claude/agents/` - See "🤖 Agent Configuration & Workflows" section. Detailed workflows in `WORKFLOWS.md`.

**MCP Configuration:** 8 recommended MCP servers - See "🔌 MCP Server Configuration" section. Full implementation plan: `~/.claude/plans/gleaming-waddling-sketch.md`.
