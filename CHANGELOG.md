# Changelog

All notable changes to the Security Tools Installer project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Supply-Chain Security:** SHA256 checksum verification for release binary fallbacks
  - Added checksum verification to `install_release_binary_with_log()` function
  - Checksums configured for trufflehog, git-hound, and dog release binaries
  - Aborts installation on checksum mismatch to prevent compromised downloads
  - Created `docs/CHECKSUM_VERIFICATION.md` with instructions to update checksums
- **AI Assistant Documentation:** Created comprehensive `CLAUDE.md` with full project context
  - Complete architecture overview and modular library structure
  - Code patterns, conventions, and error handling guidelines
  - Development workflows for adding tools, debugging, and validation
  - Security requirements and XDG compliance documentation
  - Agent usage guidelines and quick reference
- **Validation Documentation:** Created `docs/LIFECYCLE_SUMMARY_20260218.md`
  - Documents validation lifecycle gates and completion status
  - Records 36/36 tools passing on Intel architecture
  - Includes syntax and security quality gate results

### Changed
- **Code Quality:** Achieved 100% shellcheck compliance across all bash scripts
  - Fixed quoting issues in 18 active bash scripts (commits 6787866, 6cd929b, 2020516)
  - All scripts now pass `shellcheck` without errors or warnings
  - Enhanced code reliability and reduced potential runtime errors
- **Documentation Reorganization:** Improved clarity and accuracy
  - Renamed `AGENTS.md` → `VALIDATION_GUIDELINES.md` (better reflects content)
  - Removed `MODULARIZATION_SUMMARY.md` (historical documentation from v1.3.0)
  - Removed `.claude/` agent configurations from version control (workspace-specific)
- **AI Skills:** Refactored Claude Code skills for bash project
  - Removed 7 Python-specific skills (quality, run-tests, coverage, etc.)
  - Added 5 bash-focused skills (shellcheck, validate-install, diagnose, docker-validate, lint-bash)
  - Updated status skill to show bash-relevant metrics

### Fixed
- **Installer Reliability:** Added release-binary fallbacks for compile-heavy tools
  - `trufflehog`: Added GitHub release binary fallback (npm path can fail in restricted environments)
  - `git-hound`: Added GitHub release binary fallback (npm path can fail in restricted environments)
  - `dog`: Added GitHub release binary fallback (cargo compile can timeout on emulated architectures)
  - Improved installation success rate on diverse platform configurations

### Security
- **Enhanced Download Security:** Checksum verification prevents supply-chain attacks
  - ✅ **COMPLETE:** All SHA256 checksums verified from official GitHub releases (2026-02-19)
  - Detects man-in-the-middle (MITM) attacks on binary downloads
  - Verifies integrity of GitHub release downloads before installation
  - Clear error messages indicate potential compromise
  - Checksums documented in `docs/CHECKSUM_VERIFICATION.md`
  - Verified checksums:
    - trufflehog v3.93.3: `62af520...ce8545`
    - git-hound v3.2: `8d4ed72...345281`
    - dog v0.1.0: `6093525...5039a0`

### Validation
- **Complete Intel Architecture Validation:** All 36 tools passing on Intel/amd64
  - Validation results documented in `docs/VALIDATION_RESULTS_20260218_ARM64.md`
  - Docker-based validation matrix using `scripts/docker_validate_tools.sh`
  - Validation plan available in `docs/INTEL_VALIDATION_PLAN.md`

## [1.3.3] - 2026-01-15

### Changed
- **Menu Polish & Accessibility:** Improved visual clarity and accessibility
  - Removed "(python_venv required)" annotation - dependency handled automatically by `check_dependencies()`
  - Changed "Exit" to "Quit" with [q] option for single-keystroke exit (case-insensitive)
  - Replaced MAGENTA category headers with Bold Blue (`\033[1;34m`) for better contrast
  - Replaced YELLOW reminders with Bold Cyan (`\033[1;36m`) for light mode compatibility
  - Added Unicode symbols (✓ ✗ ⚠ ℹ) to all status messages for color-blind accessibility
  - Menu reduced from 23 lines to 22 lines

### Benefits
- **Better accessibility:** Color-blind friendly with redundant symbol encoding
- **Light/dark mode support:** Bold Cyan works well on both terminal backgrounds
- **Cleaner interface:** Removed confusing prerequisite annotation
- **Better UX:** Single keystroke quit (q) instead of typing 52
- **Professional appearance:** High-contrast bold colors and clear status symbols
- **WCAG AA compliance:** Bold colors pass accessibility contrast ratios

## [1.3.2] - 2026-01-15

### Changed
- **Menu Organization:** Streamlined menu with continuous numbering and automatic dependency handling
  - Consolidated all "All [Category]" options into BULK INSTALL section
  - Continuous numbering scheme for better UX:
    - BUILD & LANGUAGES: 1-4
    - PYTHON TOOLS: 5-16
    - GO TOOLS: 17-24
    - NODE.JS: 25-27
    - RUST: 28-32
    - BULK INSTALL: 33-36 (All Python, All Go, All Node, All Rust)
    - INFO: 50-52
  - Menu reduced from 27 lines to 23 lines (15% reduction)

### Removed
- **Redundant Manual Options:** Removed menu options that are handled automatically
  - Removed [40] "Install Everything" - users can install all via CLI or select multiple bulk options
  - Removed [45] "Python venv" prerequisite - automatically installed when any Python tool is selected
  - System now handles all prerequisites via automatic dependency resolution

### Benefits
- **Simplified UX:** Users don't need to manually install prerequisites first
- **Continuous numbering:** Individual tools (1-32) flow directly into bulk operations (33-36)
- **Automatic dependency handling:** Python venv installed automatically when needed
- **Cleaner menu:** Removed redundant options that confused users
- **Professional design:** Follows package manager conventions (apt, yum, npm)

## [1.3.1] - 2026-01-15

### Changed
- **Menu Redesign:** Condensed interactive menu to fit standard 24-line terminals
  - Reduced menu from 54-60 lines to 25 lines (58% reduction)
  - Multi-column layout for tool listings
  - Removed excessive blank line separators
  - Consolidated category headers for space efficiency
  - All tools now visible without scrolling

### Added
- **Tool Discoverability:** Exposed 13 previously hidden tools in interactive menu
  - Python: `sublist3r`, `photon`, `wappalyzer`, `h8mail` (4 tools)
  - Go: `httprobe`, `waybackurls`, `assetfinder` (3 tools)
  - Node.js: `git-hound`, `jwt-cracker` (2 tools)
  - Rust: `fd`, `bat` (2 tools)
  - Added "Python venv only" quick install option [41]
- **Improved Numbering:** Continuous numbering scheme (1-36 for tools, 40-41 for bulk, 50-52 for info)

### Fixed
- **stdin Connection Issues:** Enhanced terminal detection and reconnection
  - Added `/dev/tty` reconnection fallback in both `installer.sh` and `install_security_tools.sh`
  - Protected stdin during `source ~/.bashrc` operations (`</dev/null`)
  - Added clear error messages when stdin unavailable (e.g., piped from curl)
  - Documented two-step installation method for interactive menu

## [1.3.0] - 2026-01-15

### Changed
- **Architecture:** Modularized monolithic installer into focused library modules
  - Restructured `install_security_tools.sh` from 1,581 lines into 11 focused modules (87.6% reduction)
  - Main script reduced to 196 lines - now a thin orchestration layer
  - Created `lib/` directory structure with 4 subdirectories (core, data, installers, ui)
  - Separated concerns: logging, downloads, verification, dependencies, tool definitions, installers, UI
  - All functionality preserved - 100% backward compatible

### Added
- **lib/core/** - Core utilities (4 modules, 221 lines total)
  - `logging.sh` - Log management functions (53 lines)
  - `download.sh` - Download with retry logic (57 lines)
  - `verification.sh` - Installation status checks (80 lines)
  - `dependencies.sh` - Dependency resolution (31 lines)
- **lib/data/** - Data definitions (1 module, 222 lines)
  - `tool-definitions.sh` - All tool metadata and 14 category arrays
- **lib/installers/** - Installation functions (3 modules, 652 lines total)
  - `generic.sh` - Generic installers for Python, Go, Node.js, Rust (219 lines)
  - `runtimes.sh` - Language runtime installers (310 lines)
  - `tools.sh` - 25 tool wrapper functions + YARA (123 lines)
- **lib/ui/** - User interface (3 modules, 483 lines total)
  - `menu.sh` - Interactive menu system (156 lines)
  - `display.sh` - Status and information display (137 lines)
  - `orchestration.sh` - Installation coordination (190 lines)
- **installer.sh** - One-command bootstrap script for fresh installations
  - Auto-clones repository if needed
  - Executes `xdg_setup.sh` automatically
  - Detects and sources appropriate shell config (.bashrc or .zshrc)
  - Launches interactive installation menu
  - Supports both bash and zsh
- **lib/README.md** - Comprehensive library documentation (400+ lines)
- **MODULARIZATION_SUMMARY.md** - Detailed summary of changes and patterns

### Benefits
- **Improved Maintainability:** Focused 50-310 line modules vs single 1,581-line script
- **Enhanced Testability:** Each module can be tested independently
- **Better Collaboration:** Clear module ownership, easier code reviews
- **Easier Debugging:** Clear separation of concerns simplifies troubleshooting
- **Simplified Extensions:** Adding new tools requires changes to only 3-4 files
- **Industry Standard:** Follows common patterns (lib/core, lib/ui, lib/data)

### Documentation
- Updated README.md with three installation methods (bootstrap, manual, step-by-step)
- Updated CLAUDE.md with complete architecture documentation
- Updated docs/EXTENDING_THE_SCRIPT.md with modular file locations
- Created lib/README.md with comprehensive module documentation

### Technical Details
- Module sourcing order carefully designed for dependency management
- Global variables remain in main script for cross-module access
- All 38 tools supported with no functional changes
- Syntax validation: All 13 files pass bash -n checks
- Version headers: All modules labeled 1.3.0

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

### Added - Development Infrastructure

**AI Agent Configurations** (not part of product versioning)

**New AI Agent Configurations (4)**
- **bash-script-developer.md** - Bash scripting specialist agent replacing generic fullstack-developer
  - Shellcheck compliance, proper quoting, error handling patterns
  - XDG compliance verification, user-space installation patterns
  - Project-specific patterns discovery workflow
  - Installation function templates and generic installers
  - Integration with test-automation-engineer and security-auditor
- **test-automation-engineer.md** - Comprehensive test generation and validation
  - Generic test functions (test_python_tool, test_go_tool, test_node_tool, test_rust_tool)
  - Test result tracking with consistent reporting format
  - Integration testing patterns and dry-run validation
  - Test coverage analysis tools
- **security-auditor.md** - Security review and vulnerability scanning specialist
  - HTTPS download verification, secret detection, sudo prevention
  - Download retry logic validation, XDG compliance checks
  - Structured security audit report generation
  - Command injection and path traversal prevention
  - Supply chain security and CVE checks via WebSearch

**Enhanced Existing Agent (1)**
- **code-reviewer.md** - Enhanced with comprehensive bash-specific security checklist
  - Project-critical security requirements (NO sudo, HTTPS only, user-space installations)
  - Bash-specific vulnerability patterns (command injection, path traversal, secret exposure)
  - Download verification checks and retry logic validation
  - XDG compliance and hardcoded path detection

**Development Workflow Documentation**
- Added comprehensive "Agent Configuration & Workflows" section to CLAUDE.md (287 lines)
  - 3 detailed workflow examples: adding tools, fixing bugs, conducting security audits
  - Agent specialization documentation and integration patterns
  - Expected productivity improvements: 60% faster development, 100% test coverage goal
  - Clear responsibilities and handoff procedures between agents

**Project Organization**
- Created `.gitignore` with comprehensive exclusions
  - Excludes `.claude/plans/` (temporary planning files)
  - Includes `.claude/agents/` (version-controlled agent configs)
  - Standard exclusions: OS files, IDE files, credentials, backups
- Moved `fullstack-developer.md` to `.claude/agents/disabled/`
  - Preserved for potential future use but not applicable to pure bash project
- Updated `.claude/agents/README.md` with project-specific agent workflows

### Changed
- Agent system now bash-focused rather than generic web development
- Security requirements are agent-enforced (blocks code with sudo, http://, hardcoded secrets)
- Development workflow explicitly integrated with agent specializations
- All agents now perform project pattern discovery before working (CRITICAL step)

### Benefits
- **Faster Development:** Agent specialization reduces context switching and rework
- **Higher Quality:** bash-script-developer ensures shellcheck compliance and project patterns
- **Complete Testing:** test-automation-engineer provides 100% test coverage for new tools
- **Security Hardening:** security-auditor catches vulnerabilities before they're committed
- **Consistent Reviews:** code-reviewer blocks common bash anti-patterns automatically

### Impact
This major update transforms the development process by introducing specialized AI agents for bash script development, testing, and security auditing. The agent system enforces project conventions automatically and significantly reduces development time for new features.

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
- Interactive menu system for tool selection
- CLI support for automation and scripting
- Comprehensive logging system with rotation
- Automatic dependency resolution
- Dry-run mode for preview installations
- Installation status tracking
- Support for comma-separated menu selections
- Download retry logic with automatic error recovery
- XDG Base Directory Specification compliance

#### Tools Included (37+ tools)

**Build Tools & Runtimes (4)**
- CMake 3.28.1
- Go 1.21.5
- Node.js 20.10.0
- Rust (latest)

**Python Tools (16)**
- sherlock - Username search across social networks
- holehe - Email verification
- socialscan - Username/email availability checker
- theHarvester - Multi-source OSINT gathering
- spiderfoot - Automated OSINT collection
- sublist3r - Subdomain enumeration
- photon - Web crawler
- h8mail - Email OSINT and breach hunting
- shodan - Internet device search engine CLI
- censys - Internet-wide scanning data
- yara - Malware pattern matching
- wappalyzer - Technology profiler

**Go Tools (8)**
- gobuster - Directory/DNS/vhost bruteforcing
- ffuf - Fast web fuzzer
- httprobe - HTTP/HTTPS service probe
- waybackurls - Wayback Machine URL fetcher
- assetfinder - Domain/subdomain finder
- subfinder - Subdomain discovery
- nuclei - Vulnerability scanner
- virustotal - VirusTotal CLI

**Node.js Tools (3)**
- trufflehog - Secret scanning
- git-hound - GitHub reconnaissance
- jwt-cracker - JWT token analysis

**Rust Tools (8)**
- feroxbuster - Content discovery
- rustscan - Fast port scanner
- ripgrep - Fast recursive grep
- fd - Fast file finder
- bat - Cat with syntax highlighting
- sd - Intuitive find & replace
- tokei - Code statistics analyzer
- dog - Modern DNS client

#### Installation System
- User-space only (no sudo required)
- Automatic environment variable configuration
- Virtual environment management for Python tools
- Wrapper script creation for seamless tool execution
- Robust error handling with retry logic
- Detailed logging with automatic log rotation

#### Documentation
- Comprehensive README with usage examples
- Script extension guide (EXTENDING_THE_SCRIPT.md)
- User-space compatibility analysis (USER_SPACE_COMPATIBILITY.md)
- Detailed tool documentation (script_usage.md, xdg_setup.md)
- Developer guide (CLAUDE.md)

---
