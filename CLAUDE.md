# CLAUDE.md - Project Context for AI Assistants

**Project:** Security Tools Installer
**Version:** 1.3.0
**Last Updated:** January 15, 2026
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
├── installer.sh                    # Bootstrap installer (one-command setup)
├── install_security_tools.sh       # Main installer orchestrator (196 lines)
├── xdg_setup.sh                   # Environment setup (314 lines)
│
├── lib/                           # Modular library (11 modules, 1,357 lines)
│   ├── core/                      # Core utilities (4 modules)
│   ├── data/                      # Data definitions (1 module)
│   ├── installers/                # Installation functions (3 modules)
│   └── ui/                        # User interface (3 modules)
│
├── scripts/                        # Supporting utilities
│   ├── test_installation.sh            # Verification suite (533 lines)
│   └── diagnose_installation.sh        # Diagnostics & maintenance (1,145 lines)
│
└── docs/
    ├── script_usage.md             # Detailed installation guide
    ├── xdg_setup.md               # XDG setup explanation
    ├── EXTENDING_THE_SCRIPT.md    # Developer guide for adding tools
    └── USER_SPACE_COMPATIBILITY.md # Technical compatibility analysis
```

### Modular Architecture (v1.3.0)

**Main Script Reduction:** 1,581 lines → 196 lines (87% reduction)
**Focused Modules:** 11 specialized modules (50-310 lines each)
**Clear Separation:** Core utilities, installers, UI, and data

**Benefits:**
- Individual modules can be tested independently
- Multiple developers can work on different modules
- Core functions available for other scripts
- Easier code review with focused diffs

📖 **Detailed module documentation:** See `lib/README.md`

---

## 🔧 Core Components

### 1. installer.sh (Bootstrap Installer)

**Purpose:** One-command setup that clones repository, runs xdg_setup.sh, and launches interactive menu

**Key Features:**
- Automatic repository cloning (if not already present)
- Shell detection (bash/zsh) and configuration reload
- 3-step automated setup process
- Error handling with exit codes

**Usage:**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/tilix-tools-installer/main/installer.sh)
```

**Flow:**
1. Clone/update repository → `~/Documents/tilix-tools-installer`
2. Run `xdg_setup.sh` → Create directories, set environment
3. Launch `install_security_tools.sh` → Interactive menu

---

### 2. install_security_tools.sh (Main Orchestrator)

**Purpose:** Thin orchestration layer that sources library modules and coordinates installation

**Key Features:**
- Interactive menu system (42 options)
- CLI support for automation
- Automatic dependency resolution
- Comprehensive logging with retry logic
- Dry-run mode for previewing installations

**Architecture:**
```bash
# Global variables
SCRIPT_VERSION="1.3.0"
declare -A TOOL_INFO          # tool => "Name|Description|Category"
declare -A TOOL_SIZES         # tool => "50MB"
declare -A TOOL_DEPENDENCIES  # tool => "prerequisite1 prerequisite2"
declare -A INSTALLED_STATUS   # tool => "true"|"false"

# Source library modules (in dependency order)
source "${SCRIPT_DIR}/lib/core/logging.sh"
source "${SCRIPT_DIR}/lib/core/download.sh"
source "${SCRIPT_DIR}/lib/core/verification.sh"
source "${SCRIPT_DIR}/lib/core/dependencies.sh"
source "${SCRIPT_DIR}/lib/data/tool-definitions.sh"
source "${SCRIPT_DIR}/lib/installers/generic.sh"
source "${SCRIPT_DIR}/lib/installers/runtimes.sh"
source "${SCRIPT_DIR}/lib/installers/tools.sh"
source "${SCRIPT_DIR}/lib/ui/display.sh"
source "${SCRIPT_DIR}/lib/ui/menu.sh"
source "${SCRIPT_DIR}/lib/ui/orchestration.sh"
```

---

### 3. Library Modules (lib/)

**11 focused modules organized by concern:**

| Module | Lines | Purpose | Key Functions |
|--------|-------|---------|---------------|
| **core/logging.sh** | 50 | Log management | `init_logging()`, `create_tool_log()`, `cleanup_old_logs()` |
| **core/download.sh** | 45 | Retry downloads | `download_file()`, `verify_file_exists()` |
| **core/verification.sh** | 100 | Install checks | `is_installed()`, `scan_installed_tools()`, `verify_xdg_environment()` |
| **core/dependencies.sh** | 25 | Dependency resolution | `check_dependencies()` |
| **data/tool-definitions.sh** | 222 | Tool metadata | `define_tools()`, category arrays |
| **installers/generic.sh** | 219 | Generic installers | `install_python_tool()`, `install_go_tool()`, `install_node_tool()`, `install_rust_tool()` |
| **installers/runtimes.sh** | 310 | Runtime installers | `install_cmake()`, `install_nodejs()`, `install_rust()`, `install_python_venv()` |
| **installers/tools.sh** | 123 | Tool wrappers | 25+ tool-specific wrapper functions |
| **ui/menu.sh** | 156 | Interactive menu | `show_menu()`, `process_menu_selection()` |
| **ui/display.sh** | 137 | Status displays | `show_installed()`, `show_logs()`, `show_installation_summary()` |
| **ui/orchestration.sh** | 190 | Installation coordination | `install_tool()`, `install_all()`, `dry_run_install()` |

📖 **Complete module documentation with usage examples:** See `lib/README.md`

---

### 4. xdg_setup.sh (Environment Setup)

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

---

### 5. scripts/test_installation.sh (Verification Suite)

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

### 6. scripts/diagnose_installation.sh (Diagnostics & Maintenance)

**Purpose:** Comprehensive diagnostics for troubleshooting, space analysis, and maintenance

**Key Capabilities:**
1. **Installation Inventory** (`--inventory`) - What's installed, versions, status
2. **Disk Usage Analysis** (`--disk-usage`) - Space breakdown by category
3. **Build Artifacts Detection** (`--build-artifacts`) - Recoverable space identification
4. **XDG Compliance Check** (`--xdg-check`) - Verify standards compliance
5. **Test Diagnosis** (`--test-diagnosis`) - Run tests and diagnose failures
6. **Cleanup Operations** (`--cleanup`) - Safe space recovery

**Common Usage:**
```bash
# Full diagnostic report
bash scripts/diagnose_installation.sh

# Check what's installed
bash scripts/diagnose_installation.sh --inventory

# Show safe cleanup commands
bash scripts/diagnose_installation.sh --cleanup-plan

# Execute cleanup (with confirmation)
bash scripts/diagnose_installation.sh --cleanup
```

**AI Usage Patterns:**
- Debugger agent uses `--test-diagnosis` for root cause analysis
- Security auditor uses `--xdg-check` for compliance verification
- All agents reference diagnostic output for troubleshooting

📖 **Complete usage guide:** Run with `--help` or see inline documentation

---

## 🎨 Code Style & Conventions

### Bash Scripting Standards

**Variable Naming:**
- `GLOBAL_CONSTANTS="UPPERCASE"`
- `local_variables="lowercase"`
- `declare -A associative_arrays`

**Function Naming:**
- `install_toolname()` - Installation functions
- `test_toolname()` - Test functions
- `check_something()` - Validation functions
- `show_something()` - Display functions

**Error Handling:**
- Use `set +e` - Manual error handling (explicit return code checks)
- Check all return codes: `command || return 1`
- Log all operations: `{ commands... } > "$logfile" 2>&1`

**Color Coding:**
- GREEN (`\033[0;32m`) - Success
- YELLOW (`\033[1;33m`) - Warnings
- RED (`\033[0;31m`) - Errors
- BLUE/CYAN (`\033[0;36m`) - Headers/Info
- NC (`\033[0m`) - Reset

### Installation Functions Pattern

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
        FAILED_INSTALLS+=("toolname")
        FAILED_INSTALL_LOGS["toolname"]="$logfile"
        log_installation "toolname" "failure" "$logfile"
        return 1
    fi
}
```

---

## 🔑 Key Design Patterns

### 1. Dependency Resolution
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

### 2. Generic Installers
```bash
# Generic Python tool installer
install_python_tool "sherlock" "sherlock-project"

# Generic Go tool installer
install_go_tool "gobuster" "github.com/OJ/gobuster/v3"

# Convenience wrappers
install_sherlock() { install_python_tool "sherlock" "sherlock-project"; }
```

### 3. Download Retry Logic
```bash
download_file() {
    local url=$1
    local output=$2
    local max_retries=3

    for retry in $(seq 0 $((max_retries - 1))); do
        if wget --progress=bar:force "$url" -O "$output"; then
            [ -f "$output" ] && return 0
        fi
        sleep 2
    done
    return 1
}
```

---

## 📋 Adding New Tools

### 6-Step Process (v1.3.0 Modular Architecture)

1. **Define tool metadata** in `lib/data/tool-definitions.sh`
   - Add `TOOL_INFO[]`, `TOOL_SIZES[]`, `TOOL_DEPENDENCIES[]`, `TOOL_INSTALL_LOCATION[]`
   - Add to appropriate category array

2. **Add installation check** in `lib/core/verification.sh`
   - Update `is_installed()` function

3. **Create installation wrapper** in `lib/installers/tools.sh`
   - Python: `install_newtool() { install_python_tool "newtool" "package-name"; }`
   - Go: `install_newtool() { install_go_tool "newtool" "github.com/author/newtool"; }`
   - Custom: Write `install_newtool()` with proper logging and error handling

4. **Add to dispatcher** in `lib/ui/orchestration.sh`
   - Add case statement entry in `install_tool()`

5. **Update menu** in `lib/ui/menu.sh`
   - Add to `show_menu()` and `process_menu_selection()`

6. **Create test function** in `scripts/test_installation.sh`
   - Verify installation works

**Benefits:**
- No changes needed to main script
- Clear file locations for each task
- Easier to review changes (focused diffs)
- Multiple developers can work on different modules

📖 **Complete examples and code patterns:** See `docs/EXTENDING_THE_SCRIPT.md` and `lib/README.md`

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

## 🧪 Testing & Debugging

### Before Committing Code

**1. Syntax Validation:**
```bash
bash -n install_security_tools.sh
bash -n scripts/test_installation.sh
```

**2. Dry Run Test:**
```bash
bash install_security_tools.sh --dry-run newtool
```

**3. Actual Installation Test:**
```bash
bash install_security_tools.sh newtool
bash scripts/test_installation.sh newtool
```

**4. Verify Logs:**
```bash
cat ~/.local/state/install_tools/logs/newtool-*.log
```

### Troubleshooting Decision Tree

```
START: What's the problem?

┌─ Tool not found after installation?
│  ├─ Check: source ~/.bashrc (reload environment)
│  ├─ Check: which toolname (verify PATH)
│  └─ Fix: Add to PATH or check TOOL_INSTALL_LOCATION
│
├─ Installation failed?
│  ├─ Check: ~/.local/state/install_tools/logs/toolname-*.log
│  ├─ Look for: Download errors (check URL, retry count)
│  ├─ Look for: Build errors (missing dependencies)
│  └─ Fix: Install dependencies, verify source URL
│
├─ Tests failing?
│  ├─ Check: GOPATH set? (echo $GOPATH)
│  ├─ Check: XDG variables set? (env | grep XDG)
│  ├─ Check: Tool binary location matches test expectation
│  └─ Fix: Run xdg_setup.sh, source ~/.bashrc
│
└─ Need disk space?
   ├─ Run: bash scripts/diagnose_installation.sh --disk-usage
   ├─ Check: Recoverable space in build artifacts, caches
   └─ Execute: bash scripts/diagnose_installation.sh --cleanup
```

### Common Issues & Quick Fixes

| Issue | Check | Solution |
|-------|-------|----------|
| **Tool not found** | `which toolname` | `source ~/.bashrc` |
| **Download failures** | Check logs | Verify URL, check retries |
| **Python import errors** | `ls ~/.local/share/virtualenvs/tools/` | Reinstall python_venv |
| **Permission denied** | `ls -la ~/.local/bin/toolname` | `chmod +x ~/.local/bin/toolname` |
| **Go tools missing** | `echo $GOPATH` | Run xdg_setup.sh, reload shell |

### Logging System

**Location:** `~/.local/state/install_tools/logs/`

**Files:**
- `toolname-TIMESTAMP.log` - Individual tool logs (last 10 kept)
- `installation_history.log` - Complete history

**Quick Commands:**
```bash
# View latest tool log
ls -t ~/.local/state/install_tools/logs/toolname-*.log | head -1 | xargs cat

# Find errors
grep -i error ~/.local/state/install_tools/logs/*.log

# Use diagnostic script
bash scripts/diagnose_installation.sh --test-diagnosis
```

---

## 📝 Documentation Standards

### Code Comments
```bash
# Single-line comments for brief explanations

# Multi-line comments for complex logic:
# 1. What this does
# 2. Why it's done this way
# 3. Any gotchas or edge cases
```

### Update CHANGELOG.md
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

## 🔧 Development Workflow

### Agent Usage

This project includes 7 specialized agents for different development tasks.

**Common patterns:**
- **planner** - Complex multi-step tasks
- **bash-script-developer** - Installation function implementation
- **code-reviewer** - ALWAYS use after code changes (REQUIRED)
- **security-auditor** - Before releases, CVE checks
- **test-automation-engineer** - Test creation and validation
- **debugger** - Bug investigation and root cause analysis
- **documentation-engineer** - Documentation updates

📖 **Complete workflows, examples, and agent-MCP compatibility:**
   See `.claude/agents/AGENT_USAGE.md`

### MCP Integration

Docker MCP servers extend agent capabilities (60-70% faster task completion).

**Essential MCPs (Tier 1):**
- **Filesystem** - File operations for all agents (60% faster I/O)
- **Sequential Thinking** - Structured reasoning (40% better decisions)
- **GitHub Official** - Issue/PR automation (critical for releases)

**Additional MCPs (Tier 2-3):**
- **Git** - Automated git operations (50% fewer errors)
- **Brave Search** - CVE research, security bulletins (70% faster)
- **Fetch** - Download docs and security advisories
- **Context7** - Inject accurate shellcheck/bash docs
- **Obsidian** - Project memory across sessions

📖 **Full setup guide, 8 recommended servers, and implementation plan:**
   See `.claude/MCP_SETUP.md`

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

## 🚀 Quick Reference

### Essential Commands
```bash
# Bootstrap setup (one command)
bash installer.sh

# Install specific tools
bash install_security_tools.sh sherlock gobuster

# Install category
bash install_security_tools.sh --python-tools

# Preview installation
bash install_security_tools.sh --dry-run nuclei

# Test installation
bash scripts/test_installation.sh

# Diagnose issues
bash scripts/diagnose_installation.sh

# View logs
tail -f ~/.local/state/install_tools/installation_history.log
```

### Key Locations
```bash
# Executables
~/.local/bin/              # Python wrappers, binaries
~/opt/gopath/bin/          # Go tools
~/.local/share/cargo/bin/  # Rust tools

# Logs
~/.local/state/install_tools/logs/
~/.local/state/install_tools/installation_history.log
```

---

## 🤖 Working with Claude Code

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

### XDG Base Directory Concept

Standardizes file locations:
- `~/.local/` (user apps)
- `~/.config/` (config)
- `~/.cache/` (temp)

See https://specifications.freedesktop.org/basedir-spec/

### Bash Associative Arrays

```bash
declare -A TOOL_INFO
TOOL_INFO[tool]="Name|Desc|Category"
echo ${TOOL_INFO[tool]}  # Access value
```

---

## 📚 Key Documentation Files

**For Users:**
- `README.md` - Start here
- `docs/script_usage.md` - Detailed usage guide
- `docs/xdg_setup.md` - Environment explanation

**For Developers:**
- `CLAUDE.md` (this file) - Project context
- `docs/EXTENDING_THE_SCRIPT.md` - Adding tools guide
- `lib/README.md` - Module documentation
- `CHANGELOG.md` - Version history

**For AI Assistants:**
- `.claude/agents/AGENT_USAGE.md` - Agent workflows & usage patterns
- `.claude/MCP_SETUP.md` - MCP server setup guide
- `~/.claude/plans/gleaming-waddling-sketch.md` - MCP implementation plan

---

**Last Updated:** January 15, 2026
**Maintainer Context:** This file provides AI assistants (like Claude Code) with essential project context.

**Modular Architecture (v1.3.0):** 11 focused library modules in `lib/` directory. See `lib/README.md` for detailed module documentation.

**Agent Configuration:** 7 specialized agents in `.claude/agents/`. See 📖 `.claude/agents/AGENT_USAGE.md` for complete workflows and examples.

**MCP Configuration:** 8 recommended MCP servers. See 📖 `.claude/MCP_SETUP.md` for setup guide and 📖 `~/.claude/plans/gleaming-waddling-sketch.md` for full implementation plan.
