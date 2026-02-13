# Library Modules

**Version:** 1.3.0

This directory contains 11 focused library modules that implement the core functionality of the Security Tools Installer. The modular architecture (introduced in v1.3.0) separates concerns and makes the codebase more maintainable, testable, and extensible.

## Directory Structure

```
lib/
├── core/                      # Core utilities (4 modules)
│   ├── logging.sh            # Log management
│   ├── download.sh           # Retry-enabled downloads
│   ├── verification.sh       # Installation checks
│   └── dependencies.sh       # Dependency resolution
│
├── data/                      # Data definitions (1 module)
│   └── tool-definitions.sh   # Tool metadata (222 lines)
│
├── installers/                # Installation functions (3 modules)
│   ├── generic.sh            # Generic installers (219 lines)
│   ├── runtimes.sh           # Runtime installers (310 lines)
│   └── tools.sh              # Tool-specific wrappers (123 lines)
│
└── ui/                        # User interface (3 modules)
    ├── menu.sh               # Interactive menu (156 lines)
    ├── display.sh            # Status displays (137 lines)
    └── orchestration.sh      # Installation coordination (190 lines)
```

**Total:** 11 modules, 1,357 lines (down from 1,581 lines in monolithic v1.2.0)

## Module Overview

### lib/core/ (Core Utilities)

These modules provide fundamental functionality used throughout the system.

#### logging.sh
**Purpose:** Centralized log management

**Functions:**
- `init_logging()` - Create log directories and initialize logging system
- `create_tool_log(tool_name)` - Generate timestamped log filename for a tool
- `cleanup_old_logs(tool_name)` - Retain only 10 most recent logs per tool
- `log_installation(tool, status, logfile)` - Record installation to history log

**Dependencies:** None (foundational module)

**Usage:**
```bash
source lib/core/logging.sh
init_logging
logfile=$(create_tool_log "sherlock")
log_installation "sherlock" "success" "$logfile"
cleanup_old_logs "sherlock"
```

---

#### download.sh
**Purpose:** Reliable downloads with retry logic and validation

**Functions:**
- `download_file(url, output, [max_retries])` - Download with retries (default 3)
- `verify_file_exists(file_path)` - Validate file exists and is non-empty

**Dependencies:** `wget` (system command)

**Usage:**
```bash
source lib/core/download.sh
download_file "https://example.com/file.tar.gz" "/tmp/file.tar.gz" || return 1
verify_file_exists "/tmp/file.tar.gz" || return 1
```

---

#### verification.sh
**Purpose:** Installation status checking and environment validation

**Functions:**
- `is_installed(tool_name)` - Check if tool exists in PATH or expected location
- `scan_installed_tools()` - Populate INSTALLED_STATUS array for all tools
- `verify_system_go()` - Check for system Go installation
- `verify_xdg_environment()` - Validate XDG setup completion

**Dependencies:** Global arrays (`TOOL_INFO`, `INSTALLED_STATUS`)

**Usage:**
```bash
source lib/core/verification.sh
verify_xdg_environment || { echo "Run xdg_setup.sh first"; exit 1; }
scan_installed_tools
if is_installed "sherlock"; then
    echo "Sherlock already installed"
fi
```

---

#### dependencies.sh
**Purpose:** Automatic prerequisite resolution

**Functions:**
- `check_dependencies(tool_name)` - Resolve and install dependencies recursively

**Dependencies:**
- Global array `TOOL_DEPENDENCIES`
- `is_installed()` from verification.sh
- `install_tool()` from orchestration.sh

**Usage:**
```bash
source lib/core/dependencies.sh
check_dependencies "gobuster"  # Auto-installs 'go' if needed
```

---

### lib/data/ (Data Definitions)

#### tool-definitions.sh (222 lines)
**Purpose:** Centralized tool metadata and category definitions

**Data Structures:**
- Category arrays: `BUILD_TOOLS`, `LANGUAGES`, `PYTHON_RECON_PASSIVE`, etc. (14 total)
- `define_tools()` function that initializes:
  - `TOOL_INFO[tool]="Name|Description|Category"`
  - `TOOL_SIZES[tool]="50MB"`
  - `TOOL_DEPENDENCIES[tool]="prerequisite1 prerequisite2"`
  - `TOOL_INSTALL_LOCATION[tool]="~/.local/bin/tool"`

**Dependencies:** Global associative arrays (declared in main script)

**Usage:**
```bash
source lib/data/tool-definitions.sh
define_tools
echo "${TOOL_INFO[sherlock]}"  # "Sherlock|Username search...|Python OSINT"
echo "${TOOL_SIZES[sherlock]}"  # "10 MB"
echo "${TOOL_DEPENDENCIES[sherlock]}"  # "python_venv"
```

**To Add a New Tool:**
1. Add metadata in `define_tools()` function
2. Add to appropriate category array (e.g., `PYTHON_RECON_PASSIVE+=("newtool")`)

---

### lib/installers/ (Installation Functions)

#### generic.sh (219 lines)
**Purpose:** Reusable generic installers for each language ecosystem

**Functions:**
- `install_python_tool(tool, package)` - Install Python package via pip with wrapper
- `install_go_tool(tool, module_path)` - Install Go tool via `go install`
- `install_node_tool(tool, package)` - Install Node.js package via npm globally
- `install_rust_tool(tool, crate)` - Install Rust tool via cargo
- `create_python_wrapper(tool)` - Generate wrapper script for venv activation

**Dependencies:**
- Logging functions from logging.sh
- Download functions from download.sh
- Verification functions from verification.sh
- Language runtimes (python_venv, nodejs, rust)

**Usage:**
```bash
source lib/installers/generic.sh
install_python_tool "sherlock" "sherlock-project"
install_go_tool "gobuster" "github.com/OJ/gobuster/v3"
install_node_tool "trufflehog" "@trufflesecurity/trufflehog"
install_rust_tool "ripgrep" "ripgrep"
```

**Key Features:**
- Automatic environment setup (PATH, GOPATH, npm prefix, etc.)
- Comprehensive error handling with return codes
- Per-tool log files
- Wrapper script creation for Python tools

---

#### runtimes.sh (310 lines)
**Purpose:** Language runtime and build tool installation

**Functions:**
- `install_cmake()` - CMake 3.28.1 from source
- `install_github_cli()` - GitHub CLI 2.53.0 from tarball
- `install_nodejs()` - Node.js 20.10.0 from tarball
- `install_rust()` - Rust via rustup
- `install_python_venv()` - Python virtual environment for tools

**Dependencies:**
- Logging functions from logging.sh
- Download functions from download.sh
- Verification functions from verification.sh
- System compilers (gcc, make for cmake)

**Usage:**
```bash
source lib/installers/runtimes.sh
install_python_venv  # Prerequisites for Python tools
install_nodejs       # Prerequisites for Node.js tools
install_rust         # Prerequisites for Rust tools
```

**Important:**
- These are typically installed as dependencies, not directly by users
- Each runtime sets up environment variables for its ecosystem
- Runtimes are installed once and shared by all tools in that ecosystem

---

#### tools.sh (123 lines)
**Purpose:** Tool-specific installation wrappers

**Functions:**
- 25+ tool-specific wrapper functions (one-liners calling generic installers)
- `install_yara()` - Custom YARA installer with fallback logic (special case)

**Examples:**
```bash
# Simple wrappers (one-liners)
install_sherlock() { install_python_tool "sherlock" "sherlock-project"; }
install_gobuster() { install_go_tool "gobuster" "github.com/OJ/gobuster/v3"; }
install_nuclei() { install_go_tool "nuclei" "github.com/projectdiscovery/nuclei/v3/cmd/nuclei"; }

# Custom installer (YARA needs special handling)
install_yara() {
    # Custom build logic with fallback to pip
}
```

**Dependencies:**
- Generic installers from generic.sh
- Logging functions from logging.sh

**To Add a New Tool:**
1. Add simple wrapper: `install_newtool() { install_python_tool "newtool" "package-name"; }`
2. Or write custom logic if tool needs special handling

---

### lib/ui/ (User Interface)

#### menu.sh (156 lines)
**Purpose:** Interactive menu system

**Functions:**
- `show_menu()` - Display categorized tool menu with 42 options
- `process_menu_selection(choice)` - Handle menu input and route to installers
- `print_shell_reload_reminder()` - Display post-install guidance

**Dependencies:**
- Verification functions from verification.sh
- Orchestration functions from orchestration.sh
- Display functions from display.sh
- Global arrays (`TOOL_INFO`, `INSTALLED_STATUS`)

**Usage:**
```bash
source lib/ui/menu.sh
show_menu  # Display interactive menu
read -p "Enter choice: " choice
process_menu_selection "$choice"
```

**Menu Structure:**
- Individual tools (1-29)
- Bulk options (30-42): all, categories, show status, logs, exit

---

#### display.sh (137 lines)
**Purpose:** Status and information display

**Functions:**
- `show_installed()` - Display installation status with color coding
- `show_logs()` - Show log file locations
- `show_installation_summary()` - Post-install summary with statistics

**Dependencies:**
- Verification functions from verification.sh
- Logging variables (`LOG_DIR`, `HISTORY_LOG`)
- Global arrays (`SUCCESSFUL_INSTALLS`, `FAILED_INSTALLS`, `FAILED_INSTALL_LOGS`)

**Usage:**
```bash
source lib/ui/display.sh
show_installed  # Show all tools with install status
show_logs       # Show log locations
show_installation_summary  # Post-install report
```

**Display Features:**
- Color-coded status: ✓ (green) installed, ✗ (gray) not installed
- Tool sizes and descriptions
- Log file locations
- Success/failure statistics

---

#### orchestration.sh (190 lines)
**Purpose:** High-level installation coordination

**Functions:**
- `install_tool(tool_name)` - Master dispatcher routing tools to installers
- `install_all()` - Bulk installer for all tools in correct order
- `dry_run_install(tool_name)` - Preview installation without executing

**Dependencies:**
- All installer functions from installers/
- Dependency resolution from dependencies.sh
- Verification functions from verification.sh
- Logging functions from logging.sh

**Usage:**
```bash
source lib/ui/orchestration.sh
install_tool "sherlock"  # Install single tool
install_all              # Install everything
dry_run_install "nuclei" # Preview installation
```

**Key Features:**
- Central dispatch point for all installations
- Dependency resolution before installation
- Dry-run mode support
- Bulk installation with category support

---

## Dependency Relationships

```
Main Script (install_security_tools.sh)
    ↓ sources in order:
    ├─ lib/core/logging.sh              (no dependencies)
    ├─ lib/core/download.sh             (no dependencies)
    ├─ lib/core/verification.sh         (uses global arrays)
    ├─ lib/core/dependencies.sh         (uses verification.sh)
    ├─ lib/data/tool-definitions.sh     (uses global arrays)
    ├─ lib/installers/generic.sh        (uses core modules)
    ├─ lib/installers/runtimes.sh       (uses core modules)
    ├─ lib/installers/tools.sh          (uses generic.sh)
    ├─ lib/ui/display.sh                (uses verification.sh)
    ├─ lib/ui/menu.sh                   (uses orchestration.sh, display.sh)
    └─ lib/ui/orchestration.sh          (uses installers/, dependencies.sh)
```

**Critical:** Modules must be sourced in this order due to function dependencies.

---

## Development Guidelines

### Adding a New Tool

1. **Define metadata** in `lib/data/tool-definitions.sh`
2. **Add installation check** in `lib/core/verification.sh`
3. **Create wrapper** in `lib/installers/tools.sh`
4. **Register in dispatcher** in `lib/ui/orchestration.sh`
5. **Update menu** in `lib/ui/menu.sh`
6. **Add test** in `scripts/test_installation.sh`

See `docs/EXTENDING_THE_SCRIPT.md` for detailed instructions.

### Modifying Existing Modules

**Best Practices:**
- Keep modules focused (single responsibility)
- Maintain clear function interfaces
- Document function parameters and return codes
- Add error handling with explicit return codes
- Update module comments when adding functions
- Test module independently when possible

**Testing Individual Modules:**
```bash
# Syntax check
bash -n lib/core/logging.sh

# Source and test (in a test script)
source lib/core/logging.sh
init_logging
echo "Log directory: $LOG_DIR"
```

### Code Style

Follow project conventions documented in `CLAUDE.md`:
- Lowercase function names with underscores: `install_tool()`
- Local variables lowercase: `local logfile="..."`
- Global variables uppercase: `SCRIPT_VERSION="1.3.0"`
- Return 0 on success, 1 on failure
- Use `set +e` with explicit return code checks
- Comprehensive logging for all operations

---

## Module Statistics

| Module | Lines | Functions | Purpose |
|--------|-------|-----------|---------|
| **lib/core/logging.sh** | ~50 | 4 | Log management |
| **lib/core/download.sh** | ~45 | 2 | Download with retry |
| **lib/core/verification.sh** | ~100 | 4 | Installation checks |
| **lib/core/dependencies.sh** | ~25 | 1 | Dependency resolution |
| **lib/data/tool-definitions.sh** | 222 | 1 | Tool metadata |
| **lib/installers/generic.sh** | 219 | 5 | Generic installers |
| **lib/installers/runtimes.sh** | 310 | 5 | Runtime installers |
| **lib/installers/tools.sh** | 123 | 26 | Tool wrappers |
| **lib/ui/menu.sh** | 156 | 3 | Interactive menu |
| **lib/ui/display.sh** | 137 | 3 | Status displays |
| **lib/ui/orchestration.sh** | 190 | 3 | Installation coordination |
| **TOTAL** | **1,357** | **57** | **11 modules** |

**Comparison to v1.2.0:**
- v1.2.0: 1,581 lines in monolithic script
- v1.3.0: 196 lines (main) + 1,357 lines (modules) = 1,553 lines total
- **Result:** 87% reduction in main script size, improved maintainability

---

## Benefits of Modular Architecture

### For Developers
- **Easier to navigate:** Find functions quickly in focused modules
- **Safer to modify:** Changes isolated to specific modules
- **Faster to test:** Test individual modules independently
- **Simpler to review:** Focused pull requests on specific modules

### For Maintainers
- **Clear ownership:** Each module has a specific purpose
- **Better organization:** Related functions grouped together
- **Easier onboarding:** Smaller files to understand
- **Reusable components:** Core modules used by other scripts

### For Users
- **No interface changes:** All commands work exactly the same
- **Same functionality:** Installation behavior unchanged
- **Better reliability:** Improved error handling and testing

---

## Future Enhancements

Potential improvements to the modular architecture:

1. **Unit testing framework** for individual modules
2. **Module versioning** for compatibility tracking
3. **Plugin system** for third-party tool definitions
4. **Parallel installation** of independent tools
5. **Rollback mechanism** for failed installations

---

**Version:** 1.3.0
**Last Updated:** January 15, 2026
**Related Documentation:** See `docs/EXTENDING_THE_SCRIPT.md`, `CLAUDE.md`
