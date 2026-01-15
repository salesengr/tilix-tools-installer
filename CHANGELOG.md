# Changelog

All notable changes to the Security Tools Installer project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.3.0] - 2026-01-15

### Changed
- **Architecture:** Modularized monolithic installer into 11 focused library modules
  - Main script reduced from 1,581 lines → 196 lines (87% reduction)
  - Created `lib/` directory with core, data, installers, and ui subdirectories
  - All functionality preserved - 100% backward compatible
  - See `lib/README.md` for module documentation

### Added
- **Modular Library Structure:**
  - `lib/core/` - Logging, downloads, verification, dependencies (4 modules)
  - `lib/data/` - Tool definitions and metadata (1 module)
  - `lib/installers/` - Generic, runtime, and tool-specific installers (3 modules)
  - `lib/ui/` - Menu, display, and orchestration (3 modules)
- **installer.sh** - One-command bootstrap script
  - Auto-clones repository, executes xdg_setup.sh, launches menu
  - Supports both bash and zsh

### Benefits
- Improved maintainability (50-310 line focused modules)
- Enhanced testability (independent module testing)
- Simplified tool additions (changes to only 3-4 files)
- Better collaboration and code reviews

## [1.2.0] - 2026-01-15

### Changed
- **Project Organization:** Reorganized scripts into logical directory structure
  - Moved `test_installation.sh` → `scripts/test_installation.sh`
  - Moved `diagnose_installation.sh` → `scripts/diagnose_installation.sh`
  - Core installation scripts remain in root: `xdg_setup.sh`, `install_security_tools.sh`
  - Updated all documentation with new script paths (11 files)

### Migration Guide
Update any scripts or aliases to use new paths:
- `bash test_installation.sh` → `bash scripts/test_installation.sh`
- `bash diagnose_installation.sh` → `bash scripts/diagnose_installation.sh`

### Benefits
- Cleaner root directory with clear separation between core and supporting scripts
- Establishes pattern for future script additions (supporting tools go in `scripts/`)
- Improved project organization following industry standards

## [1.1.0] - 2025-12-16

### Changed
- **BREAKING:** Removed user-space Go installation capability
  - Go is now expected to be pre-installed system-wide at `/usr/local/go`
  - Script verifies system Go availability before installing Go tools
  - Go removed from interactive menu (menu items renumbered 1-42 → 1-41)
  - LANGUAGES array now contains only Node.js and Rust
  - `install_go()` function removed (64 lines)
  - `install_go_tool()` updated to use system Go with user-space GOPATH
  - `test_go()` renamed to `test_system_go()` with system verification

### Removed
- Go installation functionality from main installer
- Go from LANGUAGES array and tool definitions
- Menu option [3] for Go installation (all subsequent options renumbered)
- `~/opt/go` directory creation from xdg_setup.sh
- GOROOT override in environment configuration

### Added
- `verify_system_go()` function to check system Go availability before tool installations
- Clear error messages when system Go is not found
- System prerequisites documentation

### Fixed
- GOPATH properly set to user-space `~/opt/gopath` without overriding system GOROOT
- Environment configuration no longer conflicts with system Go installation

### Migration Notes
- **Docker users:** No action needed if using Dockerfile with Go pre-installed
- **Manual installations:** Ensure Go is installed at `/usr/local/go` before installing Go tools
- **Existing installations:** User-installed Go at `~/opt/go` will be ignored; system Go will be used
- **Menu navigation:** Go option removed; all menu numbers shifted down by one

## [Unreleased]

### Development Infrastructure

Development infrastructure changes (agent configurations, CI/CD, tooling) are now tracked separately in 📖 **[DEV_CHANGELOG.md](DEV_CHANGELOG.md)**.

**Recent Infrastructure Updates:**
- AI agent system (7 specialized agents, 60% faster development)
- MCP server configuration planning complete
- Project organization improvements

See DEV_CHANGELOG.md for complete details on development tooling and workflows.

## [1.0.3] - 2025-12-18

### Changed
- **Go Environment Configuration** - Updated to support system-wide Go installation
  - **xdg_setup.sh** (4 changes):
    - Updated GOROOT to point to system Go at `/usr/local/go` instead of `~/opt/go`
    - Updated PATH to use `/usr/local/go/bin` directly for Go binaries
    - Removed unnecessary `~/opt/go` directory creation
    - Added documentation comment about system Go usage
  - **test_installation.sh** (3 changes):
    - Made test_go() location check flexible to detect both system (`/usr/local/go`) and user-space (`~/opt/go`) Go installations
    - Added GOPATH auto-detection to test_go_tool() with fallback to `~/opt/gopath` if not set
    - Enhanced test_integration() with GOPATH validation and helpful error messages

### Benefits
- **Flexibility:** Tests now work with both system-installed and user-installed Go
- **Better Errors:** Clear error messages guide users to run `source ~/.bashrc` if GOPATH not set
- **No Wasted Space:** Removes unnecessary `~/opt/go` directory that was never used
- **Correctness:** GOROOT now points to actual Go installation location

### Technical Details
- GOROOT: Changed from `$HOME/opt/go` to `/usr/local/go`
- GOPATH: Remains at `$HOME/opt/gopath` (user workspace unchanged)
- GOCACHE: Remains at `~/.cache/go-build` (XDG-compliant)
- PATH: Now includes `/usr/local/go/bin:$GOPATH/bin`

## [1.0.2] - 2025-12-18

### Added
- **New `diagnose_installation.sh` script** for installation analysis and optimization
  - **Installation Inventory:** Lists all 37 tools with status and version detection
  - **Disk Usage Analysis:** Shows space usage by category (binaries, artifacts, caches, data)
  - **Build Artifact Detection:** Identifies ~1-1.5 GB of recoverable space
    - Go build artifacts (~/opt/gopath/pkg, ~/opt/gopath/src)
    - Cargo registry and git caches (~700 MB)
    - pip, npm, go-build caches (~150 MB)
    - Downloaded archives (~50 MB)
  - **XDG Compliance Check:** Verifies directory structure follows XDG Base Directory specification
  - **Test Diagnosis:** Analyzes test_installation.sh failures and suggests fixes
  - **Safe Cleanup Execution:** Removes artifacts with confirmation prompts
  - **Migration Planning:** Generates commands for XDG compliance improvements
- **Documentation:** `docs/DIAGNOSTIC_USAGE.md` - Comprehensive diagnostic script guide

### Technical Details
- **Tool Count Fixed:** Added missing 'go' tool to diagnostic tool list (now 37 tools)
- **Function Wiring:** Connected all main() switch cases to their implemented functions
  - xdg-check mode → generate_xdg_report()
  - migration-plan mode → generate_migration_plan()
  - cleanup-plan mode → generate_cleanup_commands()
  - full-report mode → comprehensive report with all sections
  - cleanup mode → execute_cleanup()
- **Safety Features:**
  - All operations read-only by default
  - Cleanup requires explicit --cleanup flag + confirmation
  - Tool verification after cleanup
  - Bash 4.0+ requirement check
- **Report Modes:**
  - --inventory: Tool status and versions
  - --disk-usage: Space analysis by category
  - --build-artifacts: Cleanable files with safety ratings
  - --xdg-check: XDG compliance report
  - --migration-plan: Show migration commands
  - --cleanup-plan: Show safe cleanup commands (dry-run)
  - --full-report: Comprehensive report (default)
  - --cleanup: Execute cleanup with confirmation
  - --test-diagnosis: Diagnose test failures

### Benefits
- **Space Recovery:** Can safely recover 1-1.5 GB of disk space
- **Visibility:** Clear view of installation status and disk usage
- **Troubleshooting:** Helps diagnose environment and test issues
- **Maintenance:** Easy identification of cleanup opportunities

## [1.0.1] - 2026-01-05

### Added
- `docs/script_usage.md` – single reference for running `xdg_setup.sh`, `install_security_tools.sh`, and `test_installation.sh`.
- `docs/tool_installation_summary.md` – per-tool mapping of installation steps to resulting files for auditors.

### Changed
- Replaced all Unicode glyphs in shell scripts with ASCII equivalents so status output renders correctly in minimal terminals.
- Simplified `docs/EXTENDING_THE_SCRIPT.md` to a concise checklist covering metadata, categories, installers, and tests.
- Updated cross-references (README, `xdg_setup.md`, `CLAUDE.md`, `CHANGELOG.md`) to point to the new documentation set.
- Bumped script version strings and README badge to `1.0.1`.
- Added consistent “reload your shell” reminders to both `install_security_tools.sh` and `xdg_setup.sh`, with docs/README guidance telling users to `source ~/.bashrc` after installs.

### Removed
- Deleted the outdated `docs/install_tools.md` documentation that duplicated README content.

## [1.0.0] - 2025-12-11

### Initial Release

A comprehensive user-space installation system for OSINT/CTI/PenTest security tools that requires no sudo access.

#### Core Features
- Interactive menu system and CLI support
- 37+ security tools (Python, Go, Node.js, Rust)
- Automatic dependency resolution
- Comprehensive logging with rotation
- XDG Base Directory Specification compliance
- Download retry logic with error recovery
- Dry-run mode for preview installations

#### Tools Included
- **Build Tools & Runtimes (5):** CMake, GitHub CLI, Go, Node.js, Rust
- **Python Tools (12):** sherlock, holehe, theHarvester, sublist3r, spiderfoot, photon, h8mail, shodan, censys, yara, wappalyzer, socialscan
- **Go Tools (8):** gobuster, ffuf, httprobe, waybackurls, assetfinder, subfinder, nuclei, virustotal
- **Node.js Tools (3):** trufflehog, git-hound, jwt-cracker
- **Rust Tools (8):** feroxbuster, rustscan, ripgrep, fd, bat, sd, tokei, dog

For complete tool descriptions, see 📖 **[Security Tools Reference](docs/TOOLS_REFERENCE.md)**.

#### Installation System
- User-space only (no sudo required)
- Automatic environment configuration
- Virtual environment management for Python tools
- Wrapper script creation for seamless execution
- Robust error handling with retry logic

#### Documentation
- Comprehensive README and usage guides
- Developer guide (CLAUDE.md, EXTENDING_THE_SCRIPT.md)
- Compatibility analysis (USER_SPACE_COMPATIBILITY.md)

---
