# Diagnostic Script Usage Guide

**Script:** `diagnose_installation.sh`
**Version:** 1.0.0
**Purpose:** Analyze, optimize, and troubleshoot security tools installation

---

## Overview

The diagnostic script provides comprehensive analysis of your security tools installation, helping you:

- 📊 **Inventory** - See what's installed and check versions
- 💾 **Disk Analysis** - Identify space usage and recovery opportunities
- 🧹 **Cleanup** - Safely remove build artifacts and caches (~1-1.5 GB recoverable)
- ✅ **Compliance** - Verify XDG Base Directory specification adherence
- 🔍 **Troubleshooting** - Diagnose test failures and environment issues

**System Requirements:**
- Bash 4.0+ (available in Docker environments)
- Standard Unix utilities: `find`, `du`, `grep`, `awk`, `sed`

---

## Quick Start

### Generate Full Report (Default)

```bash
bash diagnose_installation.sh
```

This displays a comprehensive report covering:
- Installation inventory (37 tools)
- Disk usage by category
- Build artifacts that can be cleaned
- XDG compliance status
- Safe cleanup recommendations

### View Specific Sections

```bash
# List installed tools and versions
bash diagnose_installation.sh --inventory

# Analyze disk space usage
bash diagnose_installation.sh --disk-usage

# Find cleanable artifacts
bash diagnose_installation.sh --build-artifacts

# Check XDG compliance
bash diagnose_installation.sh --xdg-check

# Show cleanup commands (dry-run)
bash diagnose_installation.sh --cleanup-plan
```

### Execute Cleanup

```bash
# Clean up artifacts with confirmation prompts
bash diagnose_installation.sh --cleanup
```

This will:
1. Show estimated recoverable space (~1-1.5 GB)
2. List what will be removed
3. Ask for confirmation (type "yes" to proceed)
4. Remove artifacts safely
5. Verify tools still work

---

## Command Reference

### Options

| Option | Description | Output Type |
|--------|-------------|-------------|
| `--help` | Show help message and usage | Text |
| `--inventory` | List all tools with status and versions | Table |
| `--disk-usage` | Analyze disk space by category | Table + Summary |
| `--build-artifacts` | Detect cleanable build artifacts | Table + Safety info |
| `--xdg-check` | Verify XDG Base Directory compliance | Report |
| `--migration-plan` | Show XDG migration commands | Commands |
| `--cleanup-plan` | Show safe cleanup commands (dry-run) | Commands |
| `--test-diagnosis` | Run test suite and diagnose failures | Analysis |
| `--full-report` | Generate comprehensive report (default) | Complete report |
| `--cleanup` | Execute safe cleanup (requires confirmation) | Interactive |

### Examples

```bash
# Generate full report and save to file
bash diagnose_installation.sh > report.txt

# Quick status check
bash diagnose_installation.sh --inventory

# Identify cleanup opportunities
bash diagnose_installation.sh --cleanup-plan

# Execute cleanup
bash diagnose_installation.sh --cleanup

# Diagnose test failures
bash diagnose_installation.sh --test-diagnosis
```

---

## Report Sections Explained

### 1. Installation Inventory

Shows status and version for all 37 tools:

```
Tool                 Status           Version
-------------------- ---------------- --------------------
cmake                ✓ Installed      3.28.1
github_cli           ✓ Installed      2.53.0
go                   ✓ Installed      go1.21.5
sherlock             ✓ Installed      installed
gobuster             ✓ Not Installed  N/A
```

**Interpretation:**
- ✓ Installed (green) - Tool is available and working
- ✗ Not Installed (red) - Tool is not installed

### 2. Disk Usage Analysis

Breaks down space usage by category:

```
Category                  Size          % of Total  Cleanable?
------------------------- ------------- ----------- ------------
Binaries                  450 MB        21.7%       No (required)
Build Artifacts           450 MB        19.6%       Yes (safe)
Caches                    200 MB        8.7%        Yes (safe)
Python/Node/Go Runtime    720 MB        31.3%       No (required)
Logs                      12 MB         0.5%        Partial
Downloaded Archives       48 MB         2.1%        Yes (safe)
Other                     190 MB        8.3%        No (required)
------------------------- ------------- ----------- ------------
TOTAL                     2.07 GB       100%
RECOVERABLE               698 MB        33.7%       ~700MB can be safely removed
```

**Categories:**
- **Binaries** - Compiled executables (required)
- **Build Artifacts** - Go pkg/src, Cargo registry/git (safe to remove)
- **Caches** - pip, npm, go-build caches (safe to remove)
- **Runtimes** - Go, Node.js installations (required)
- **Logs** - Installation history (partially cleanable)
- **Archives** - Downloaded .tar.gz files (safe to remove)

### 3. Build Artifacts Detection

Lists specific artifacts with safety ratings:

```
Artifact Path                              Size          Safety
------------------------------------------ ------------- ------------------------
~/opt/gopath/pkg                           234 MB        Safe to remove
~/opt/gopath/src                           123 MB        Safe to remove
~/.local/share/cargo/registry              456 MB        Safe (will re-download)
~/.local/share/cargo/git                   178 MB        Safe (will re-download)
~/.cache/pip                               87 MB         Safe to remove
~/.cache/npm                               52 MB         Safe to remove
~/.cache/go-build                          43 MB         Safe to remove
~/opt/src/*.tar.*                          48 MB         Safe to remove (5 files)
```

**Safety Ratings:**
- **Safe to remove** - No impact on functionality, rebuilt automatically
- **Safe (will re-download)** - Will re-download if needed (Cargo artifacts)
- **Conservative** - May slow down future builds but safe to remove

### 4. XDG Compliance Report

Verifies installation follows XDG Base Directory specification:

```
XDG Base Directory Specification Compliance

✅ Compliant Locations: 5/5 (100%)

Location                       Status
------------------------------ --------------------
~/.local/bin/                  [COMPLIANT]
~/.local/share/                [COMPLIANT]
~/.local/state/                [COMPLIANT]
~/.config/                     [COMPLIANT]
~/.cache/                      [COMPLIANT]

⚠️  User-Space Runtimes: 3 (Acceptable pattern)
   ~/opt/go, ~/opt/gopath, ~/opt/node
   Note: User-space runtimes in ~/opt/ are acceptable. XDG doesn't mandate
         all user files go in ~/.local/. System directories (/opt/, /usr/local/)
         are avoided correctly.
```

**Interpretation:**
- ✅ Compliant - Follows XDG specification
- ⚠️ User-Space Runtimes - Acceptable pattern for user-space installations
- ❌ Non-Compliant - Would require migration (use `--migration-plan`)

### 5. Cleanup Recommendations

Provides safe commands to recover disk space:

```
Safe Cleanup Commands

# Immediate Safe Cleanup (No impact on functionality)

# Remove downloaded archives
rm -f ~/opt/src/*.tar.gz ~/opt/src/*.tar.xz

# Remove Go build artifacts (will be rebuilt if needed)
rm -rf ~/opt/gopath/pkg/* ~/opt/gopath/src/*

# Clear pip cache
rm -rf ~/.cache/pip/*

# Clear npm cache
npm cache clean --force

# Clear Go build cache
go clean -cache -modcache 2>/dev/null || true

# Conservative Cleanup (May slow down future builds)

# Remove Cargo registry (will re-download if needed)
rm -rf ~/.local/share/cargo/registry/*

# Remove Cargo git checkouts
rm -rf ~/.local/share/cargo/git/*

Expected space recovery: 698 MB

To execute cleanup, run: ./diagnose_installation.sh --cleanup
```

---

## Cleanup Operations

### What Gets Cleaned

**Immediate Safe Cleanup (No Impact):**
- Downloaded archives (~/opt/src/*.tar.*)
- Go build artifacts (~/opt/gopath/pkg/, ~/opt/gopath/src/)
- pip cache (~/.cache/pip/)
- npm cache (~/.cache/npm/)
- Go build cache (~/.cache/go-build/)

**Conservative Cleanup (May Require Re-download):**
- Cargo registry (~/.local/share/cargo/registry/)
- Cargo git checkouts (~/.local/share/cargo/git/)
- Python bytecode cache (~/.cache/python/)

### What NEVER Gets Cleaned

- Compiled binaries (tools you use)
- Python virtual environments
- Language runtimes (Go, Node.js, Rust)
- Installation logs (keeps history)
- Configuration files

### Cleanup Process

```bash
bash diagnose_installation.sh --cleanup
```

**Steps:**
1. Calculates recoverable space
2. Shows detailed list of what will be removed
3. Displays safety warning
4. Prompts for confirmation (must type "yes")
5. Removes artifacts safely
6. Verifies tools still work
7. Reports completion status

**Example Output:**
```
Execute Safe Cleanup

Estimated recoverable space: 698 MB

This will remove:
  • Downloaded archives (~/opt/src/*.tar.*)
  • Go build artifacts (~/opt/gopath/pkg, ~/opt/gopath/src)
  • pip cache (~/.cache/pip)
  • npm cache (~/.cache/npm)
  • Go build cache (~/.cache/go-build)

⚠ This action cannot be undone easily!

Continue with cleanup? (yes/no): yes

Executing cleanup...
Removing archives... done
Removing Go pkg... done
Removing Go src... done
Clearing pip cache... done
Clearing npm cache... done
Clearing Go cache... done

✓ Cleanup completed!

Verifying tools still work...
  ✓ cmake is accessible
  ✓ node is accessible
  ✓ go is accessible
  ✓ cargo is accessible

✓ All tools verified - cleanup successful!
```

---

## Test Diagnosis

### Purpose

Analyzes test_installation.sh failures and suggests fixes.

### Usage

```bash
bash diagnose_installation.sh --test-diagnosis
```

### Example Output

```
Test Suite Diagnosis

Test Results Summary
--------------------
Total Tests: 14
Passed: 10 (71%)
Failed: 4 (29%)

Environment Variables Check
---------------------------
✗ Environment issues detected:
  • GOPATH not set
  • ~/opt/gopath/bin not in PATH

Failed Test Analysis
--------------------
Go Tests:
  ✗ GOPATH environment variable set
     Cause: GOPATH environment variable not loaded
     Fix: Run 'source ~/.bashrc' or start new shell session
     Verify: echo $GOPATH (should show ~/opt/gopath)

  ✗ Can compile simple program
     Cause: Prerequisite failure (GOPATH not set)
     Fix: Resolve GOPATH issue first

Recommendations
---------------
Root Cause: Test script expects system paths (/usr/bin, /usr/local/bin)
Reality: Tools installed in user-space paths (~/opt/, ~/.local/)
Conclusion: Installation is CORRECT - test script needs updating for user-space

Suggested Actions:
  1. Run 'source ~/.bashrc' to load environment variables
  2. Verify GOPATH: echo $GOPATH
  3. Consider updating test_installation.sh to check user-space paths
```

### Common Issues & Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| GOPATH not set | Environment not loaded | `source ~/.bashrc` |
| Tool not in PATH | Shell not reloaded | Start new shell or `source ~/.bashrc` |
| Binary location test fails | Test checks system paths | Expected for user-space install |
| Compilation test fails | GOPATH prerequisite | Fix GOPATH first |

---

## Migration Planning

### Purpose

Generates commands to migrate non-compliant locations to XDG-compliant paths.

### Usage

```bash
bash diagnose_installation.sh --migration-plan
```

### Example Output

```
XDG Compliance Migration Plan

The following commands will migrate non-compliant locations:
⚠ WARNING: These commands are shown for reference. Review carefully before executing!

# Migrate ~/opt/gopath
mkdir -p ~/.local/share
mv ~/opt/gopath ~/.local/share/gopath
# Update GOPATH in ~/.bashrc
sed -i 's|~/opt/gopath|~/.local/share/gopath|g' ~/.bashrc
source ~/.bashrc

# Migrate ~/opt/node
mkdir -p ~/.local/opt
mv ~/opt/node ~/.local/opt/node
# Update PATH in ~/.bashrc
sed -i 's|~/opt/node|~/.local/opt/node|g' ~/.bashrc
source ~/.bashrc

⚠ Note: Test tools after migration to ensure everything works
```

**Important:**
- Commands are shown for reference only
- Review and test in non-production environment first
- Backup data before migration
- Test all tools after migration

---

## Troubleshooting

### Script Won't Run

**Error:** `Error: Bash 4.0 or higher is required`

**Cause:** System bash is too old (macOS system bash is 3.2)

**Fix:**
- Run in Docker environment (has Bash 4+)
- Install newer bash: `brew install bash` (if on macOS)
- Use explicit path: `/usr/local/bin/bash diagnose_installation.sh`

### Cleanup Doesn't Remove Files

**Cause:** Cleanup requires explicit confirmation

**Fix:** Type "yes" exactly when prompted (not "y" or "Yes")

### Tools Broken After Cleanup

**Cause:** This shouldn't happen if using default cleanup

**Diagnosis:**
```bash
# Check if tools are accessible
command -v go
command -v node
command -v cargo

# Check environment
echo $GOPATH
echo $PATH
```

**Fix:**
```bash
# Reload environment
source ~/.bashrc

# Reinstall affected tool
bash install_security_tools.sh <tool_name>
```

### No Artifacts Found

**Cause:** Either already cleaned or minimal installation

**Diagnosis:**
```bash
# Check if directories exist
ls -lh ~/opt/gopath/pkg
ls -lh ~/.cache/pip
ls -lh ~/.local/share/cargo/registry
```

**Interpretation:** If directories don't exist or are empty, artifacts were already cleaned or tools haven't been compiled yet.

---

## Best Practices

### When to Run Diagnostic Script

- ✅ After full installation to review disk usage
- ✅ Before committing to production use
- ✅ When experiencing test failures
- ✅ Monthly to identify cleanup opportunities
- ✅ When running low on disk space

### Recommended Workflow

1. **After Installation:**
   ```bash
   bash diagnose_installation.sh --full-report > report.txt
   ```
   Save baseline report for reference

2. **Monthly Maintenance:**
   ```bash
   bash diagnose_installation.sh --cleanup-plan
   ```
   Review cleanup opportunities

3. **Before Major Changes:**
   ```bash
   bash diagnose_installation.sh --inventory > inventory-before.txt
   ```
   Document current state

4. **Troubleshooting:**
   ```bash
   bash diagnose_installation.sh --test-diagnosis
   ```
   Identify and fix environment issues

### Safety Tips

- ✅ **Always review** cleanup commands before executing
- ✅ **Use --cleanup-plan** first to preview changes
- ✅ **Test in non-production** environment first
- ✅ **Keep installation logs** for troubleshooting
- ⚠️ **Don't panic** if cleanup seems to remove a lot - it's designed to be safe

---

## Advanced Usage

### Saving Reports

```bash
# Save full report with timestamp
bash diagnose_installation.sh --full-report > "diagnostic-$(date +%Y%m%d-%H%M%S).txt"

# Save specific section
bash diagnose_installation.sh --disk-usage > disk-usage.txt

# Redirect to file and display
bash diagnose_installation.sh --full-report | tee report.txt
```

### Automating Cleanup

```bash
# Scheduled cleanup (add to cron)
0 0 1 * * bash /path/to/diagnose_installation.sh --cleanup-plan | mail -s "Cleanup Opportunities" admin@example.com

# Automated cleanup with confirmation bypass (use with caution)
echo "yes" | bash diagnose_installation.sh --cleanup
```

### Integrating with CI/CD

```bash
# Pre-deployment check
bash diagnose_installation.sh --inventory > inventory.txt
bash diagnose_installation.sh --disk-usage > disk-usage.txt

# Fail if disk usage exceeds threshold
disk_usage=$(bash diagnose_installation.sh --disk-usage | grep "TOTAL" | awk '{print $2}')
if [ "$disk_usage" -gt 3000000000 ]; then
    echo "ERROR: Disk usage too high"
    exit 1
fi
```

---

## FAQ

**Q: Is cleanup safe?**
A: Yes, the script only removes artifacts that can be rebuilt automatically (Go builds) or re-downloaded if needed (Cargo caches). It never touches your compiled tools.

**Q: Will I need to reinstall tools after cleanup?**
A: No. Cleanup removes temporary build artifacts and caches, not the installed tools themselves.

**Q: How much space will I recover?**
A: Typically 1-1.5 GB, depending on what you've installed. Rust tools (Cargo) are the largest component.

**Q: Can I undo cleanup?**
A: Artifacts are permanently deleted, but they'll be recreated automatically when needed (Go builds) or re-downloaded (Cargo). No reinstallation required.

**Q: Why does my Mac say Bash 3.2?**
A: macOS ships with ancient Bash. The script needs Bash 4+, available in Docker or via `brew install bash`.

**Q: What if cleanup breaks something?**
A: The cleanup is designed to be safe. If something breaks, run `source ~/.bashrc` to reload environment, or reinstall the specific tool.

**Q: Should I clean Cargo artifacts?**
A: It's safe but conservative. They take 700+ MB but will be re-downloaded if you reinstall Rust tools. Consider cleaning if space is tight.

**Q: How often should I run this?**
A: Monthly for maintenance, or when running low on disk space.

---

## Support

For issues or questions:

1. Check the [troubleshooting section](#troubleshooting) above
2. Review logs at `~/.local/state/install_tools/logs/`
3. Run test diagnosis: `bash diagnose_installation.sh --test-diagnosis`
4. Check main documentation: [README.md](../README.md)
5. Open an issue with your diagnostic report attached

---

**Last Updated:** December 18, 2025
**Script Version:** 1.0.0
