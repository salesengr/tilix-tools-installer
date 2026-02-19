# Validation Guidelines

Guidelines for validation, testing, and quality assurance in the tilix-tools-installer project.

## Current Working Branch
- Use `recovery/tool-install-validation` unless explicitly directed otherwise.

## Validation Status (2026-02-18)
- ✅ **Intel validation complete:** 36/36 tools passing on Intel/amd64
- ✅ **Shellcheck compliance:** 100% (18/18 active bash scripts)
- ✅ **Security gates:** No sudo usage, HTTPS-only, no hardcoded secrets
- ✅ **Syntax validation:** All scripts pass `bash -n` checks

## Validation Constraints
- Keep changes minimal and behavior-preserving during validation.
- Preserve legacy tool coverage; do not remove existing tool install paths.
- All code changes must pass quality gates before merge.

## Docker Validation Mode
- Prefer fresh-container per tool (`docker run --rm`) for repeatability.
- Use `scripts/manifests/legacy_tools_d870fee.tsv` as source-of-truth tool list.
- Use `scripts/docker_validate_tools.sh` for matrix execution.
- Before testing each remaining failing tool on Intel, create a prereq snapshot image that includes all required prerequisites for that tool.

## Prereq Snapshot Rule
- If a tool needs multiple prerequisites (example: Rust + Node), install all of them before committing the snapshot.
- Snapshot naming pattern:
  - `tilix-app:intel-precheck-<tool>-<YYYYMMDD>`

## Environment Notes
- arm64 host + amd64 image emulation can cause compile-heavy Go/Rust tools to timeout or appear stalled.
- Definitive validation for remaining failures should be done on native Intel/amd64 Docker host.

## Quality Gates

All code changes must pass these gates before merge:

### 1. Shellcheck Compliance
```bash
shellcheck installer.sh install_security_tools.sh xdg_setup.sh \
    lib/**/*.sh scripts/*.sh
```
**Standard:** Zero errors, zero warnings

### 2. Syntax Validation
```bash
bash -n installer.sh install_security_tools.sh xdg_setup.sh \
    scripts/*.sh lib/**/*.sh
```
**Standard:** All scripts must pass

### 3. Security Scans
```bash
# No sudo usage
grep -RInE 'sudo' -- *.sh lib/ scripts/

# HTTPS-only downloads
grep -RInE 'http://' -- *.sh lib/ scripts/

# No hardcoded secrets
grep -RIniE 'AKIA[0-9A-Z]{16}|aws_secret_access_key|secret[_-]?key\s*[=:]' -- *.sh lib/ scripts/
```
**Standard:** Zero matches in executable code paths

### 4. Validation Testing
```bash
bash scripts/docker_validate_tools.sh \
    --manifest scripts/manifests/legacy_tools_d870fee.tsv
```
**Standard:** 36/36 tools passing

## Code Quality Best Practices

### Required Patterns
- ✅ Quote all variable expansions: `"$var"` not `$var`
- ✅ Use explicit error checking: `if ! command; then ... fi`
- ✅ Return codes: 0 for success, 1 for failure
- ✅ User-space only: All paths under `~/` or `~/.local/`
- ✅ XDG compliance: Use `$XDG_*` variables
- ✅ Comprehensive logging: All operations logged to files

### Prohibited Patterns
- ❌ No `sudo` or root operations
- ❌ No `http://` URLs (HTTPS only)
- ❌ No hardcoded credentials
- ❌ No unquoted variable expansions
- ❌ No `set -e` (use explicit error checking)
- ❌ No system path modifications (`/usr/*`, `/opt/*`, `/etc/*`)

## Required References
- Validation plan: `docs/INTEL_VALIDATION_PLAN.md`
- Validation results: `docs/VALIDATION_RESULTS_20260218_ARM64.md`
- Lifecycle summary: `docs/LIFECYCLE_SUMMARY_20260218.md`
- Tool manifest: `scripts/manifests/legacy_tools_d870fee.tsv`
