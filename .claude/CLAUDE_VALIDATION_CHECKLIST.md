# CLAUDE.md Validation Checklist

**Version:** 1.0
**Last Updated:** January 15, 2026
**Purpose:** Maintain accuracy and consistency of CLAUDE.md project context document

This checklist ensures CLAUDE.md remains accurate, up-to-date, and valuable for AI assistants working on this project. Use this before releases, after major changes, or monthly for maintenance.

---

## Table of Contents

1. [Quick Validation (5 minutes)](#quick-validation-5-minutes)
2. [Comprehensive Validation (20 minutes)](#comprehensive-validation-20-minutes)
3. [Section-by-Section Validation](#section-by-section-validation)
4. [Code Example Validation](#code-example-validation)
5. [Cross-Reference Validation](#cross-reference-validation)
6. [Automation Opportunities](#automation-opportunities)
7. [Common Issues & Fixes](#common-issues--fixes)
8. [Pre-Commit Hook Examples](#pre-commit-hook-examples)
9. [Monthly Maintenance Checklist](#monthly-maintenance-checklist)

---

## Quick Validation (5 minutes)

Essential checks before any commit that modifies CLAUDE.md or related files.

### Critical Metadata

```bash
# ✓ Check version matches current release
grep "Version:" CLAUDE.md
# Should match: install_security_tools.sh SCRIPT_VERSION

# ✓ Check last updated date
grep "Last Updated:" CLAUDE.md
# Should be today's date if modified

# ✓ Check project name consistency
grep "Project:" CLAUDE.md
# Should be: Security Tools Installer
```

**Validation Script:**
```bash
#!/bin/bash
# quick-validate-claude.sh

VERSION_CLAUDE=$(grep -m1 "^**Version:**" CLAUDE.md | sed 's/[^0-9.]//g')
VERSION_SCRIPT=$(grep "SCRIPT_VERSION=" install_security_tools.sh | head -1 | sed 's/[^0-9.]//g')

if [ "$VERSION_CLAUDE" != "$VERSION_SCRIPT" ]; then
    echo "❌ Version mismatch: CLAUDE.md ($VERSION_CLAUDE) vs script ($VERSION_SCRIPT)"
    exit 1
else
    echo "✓ Versions match: $VERSION_CLAUDE"
fi
```

---

### Tool Count Accuracy

```bash
# ✓ Count tools in README.md
grep -c "^-" README.md | head -1
# Should be: 37+

# ✓ Count tools in lib/data/tool-definitions.sh
grep "TOOL_INFO\[" lib/data/tool-definitions.sh | wc -l
# Should match README count

# ✓ Check CLAUDE.md mentions correct count
grep "37+ tools" CLAUDE.md
# Should appear in Overview section
```

**Quick Fix:**
If counts don't match, tools were added without updating all documentation.

---

### File Path Validation

```bash
# ✓ Check all referenced files exist
grep -o '\`[^`]*.sh\`' CLAUDE.md | sed 's/`//g' | while read file; do
    [ -f "$file" ] || echo "❌ Missing: $file"
done

# ✓ Check all referenced directories exist
grep -o '\`[^`]*/\`' CLAUDE.md | sed 's/`//g' | while read dir; do
    [ -d "$dir" ] || echo "❌ Missing: $dir"
done
```

---

### Cross-Reference Links

```bash
# ✓ Check all markdown links are valid
grep -o '\[.*\](.*\.md)' CLAUDE.md | sed 's/.*(\(.*\))/\1/' | while read file; do
    [ -f "$file" ] || [ -f "$(dirname CLAUDE.md)/$file" ] || echo "❌ Broken link: $file"
done
```

---

### Last Updated Freshness

```bash
# ✓ If CLAUDE.md was modified, Last Updated should be recent
LAST_COMMIT=$(git log -1 --format="%ai" CLAUDE.md | cut -d' ' -f1)
LAST_UPDATED=$(grep "Last Updated:" CLAUDE.md | grep -o "[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}" || echo "YYYY-MM-DD")

if [ "$LAST_COMMIT" != "" ] && [ "$LAST_UPDATED" != "YYYY-MM-DD" ]; then
    # Convert dates to seconds for comparison
    COMMIT_SECONDS=$(date -j -f "%Y-%m-%d" "$LAST_COMMIT" "+%s" 2>/dev/null || echo 0)
    UPDATED_SECONDS=$(date -j -f "%Y-%m-%d" "$LAST_UPDATED" "+%s" 2>/dev/null || echo 0)

    if [ $COMMIT_SECONDS -gt $UPDATED_SECONDS ]; then
        echo "⚠️ CLAUDE.md modified but Last Updated not refreshed"
    fi
fi
```

---

## Comprehensive Validation (20 minutes)

Monthly or before major releases. Checks document accuracy, completeness, and consistency.

### 1. Version Consistency Check

**Locations to verify:**
```bash
# All should match current version (e.g., 1.3.0)
grep "Version:" CLAUDE.md
grep "SCRIPT_VERSION=" install_security_tools.sh
grep "^**Version:**" README.md
head -n 5 lib/core/logging.sh  # Module version headers
head -n 5 lib/data/tool-definitions.sh
head -n 5 lib/installers/generic.sh
```

**Validation:**
- [ ] CLAUDE.md version matches `install_security_tools.sh`
- [ ] README.md version matches
- [ ] All `lib/` modules show correct version in headers
- [ ] CHANGELOG.md has entry for current version

---

### 2. Architecture Accuracy Check

**Current architecture (v1.3.0):**
- Main script: 196 lines (orchestrator only)
- 11 library modules in `lib/` directory
- 4 subdirectories: `core/`, `data/`, `installers/`, `ui/`

**Validation:**
```bash
# ✓ Check main script line count
wc -l install_security_tools.sh
# Should be: ~196 lines

# ✓ Count library modules
find lib -name "*.sh" -type f | wc -l
# Should be: 11 modules

# ✓ Check subdirectories exist
[ -d lib/core ] && [ -d lib/data ] && [ -d lib/installers ] && [ -d lib/ui ]
# All should exist

# ✓ Verify module line counts mentioned in CLAUDE.md
wc -l lib/core/*.sh lib/data/*.sh lib/installers/*.sh lib/ui/*.sh
# Compare with CLAUDE.md "Project Structure" section
```

**Document sections to update if mismatch:**
- [ ] "📁 Project Structure" section
- [ ] "### Modular Architecture Benefits" section
- [ ] "## 🔧 Core Components" section

---

### 3. Tool Inventory Accuracy

**Complete tool list validation:**

```bash
# Generate tool list from definitions
grep "TOOL_INFO\[" lib/data/tool-definitions.sh | sed 's/.*TOOL_INFO\[\(.*\)\]=.*/\1/' | sort > /tmp/tools-defined.txt

# Extract tools from CLAUDE.md category lists
grep -A 50 "^- \`BUILD_TOOLS\`:" CLAUDE.md | grep "^- \`" | sed 's/.*`\(.*\)`.*/\1/' | sort > /tmp/tools-claude.txt

# Compare
diff /tmp/tools-defined.txt /tmp/tools-claude.txt
# Should be empty (no differences)
```

**Checklist:**
- [ ] All tools in `tool-definitions.sh` documented in CLAUDE.md
- [ ] Category counts match (Python: 12, Go: 8, Node.js: 3, Rust: 8)
- [ ] Total tool count is 37+ (including build tools and runtimes)
- [ ] No deprecated tools mentioned

---

### 4. File Path & Location Accuracy

**Key locations to verify:**

```bash
# ✓ Main scripts
[ -f install_security_tools.sh ] && echo "✓ Main installer"
[ -f xdg_setup.sh ] && echo "✓ XDG setup"
[ -f installer.sh ] && echo "✓ Bootstrap"

# ✓ Library modules
[ -d lib/core ] && echo "✓ Core utilities"
[ -d lib/data ] && echo "✓ Data definitions"
[ -d lib/installers ] && echo "✓ Installers"
[ -d lib/ui ] && echo "✓ UI modules"

# ✓ Supporting scripts
[ -f scripts/test_installation.sh ] && echo "✓ Test suite"
[ -f scripts/diagnose_installation.sh ] && echo "✓ Diagnostics"

# ✓ Documentation
[ -d docs/ ] && echo "✓ Docs directory"
[ -f CHANGELOG.md ] && echo "✓ Changelog"
```

**CLAUDE.md sections to verify:**
- [ ] "📁 Project Structure" ASCII tree matches reality
- [ ] All script paths in examples are correct
- [ ] File locations after installation are accurate

---

### 5. Code Example Validation

**Test all code examples actually work:**

```bash
# Extract and test bash code blocks from CLAUDE.md
# (See "Code Example Validation" section below for full automation)

# Manual spot checks:
# - Installation function pattern (lines ~297-319)
# - Dependency resolution pattern (lines ~327-337)
# - Generic installer usage (lines ~341-351)
# - Download retry logic (lines ~354-372)
# - Wrapper script creation (lines ~375-386)
```

**Checklist:**
- [ ] Installation function pattern is current
- [ ] All function signatures are accurate
- [ ] Variable names match actual code
- [ ] No obsolete patterns (e.g., old pre-modular code)

---

### 6. Agent Configuration Accuracy

**Current agent count: 7**

```bash
# ✓ Count active agents
find .claude/agents -maxdepth 1 -name "*.md" ! -name "README.md" ! -name "WORKFLOWS.md" | wc -l
# Should be: 7

# ✓ List agents
ls -1 .claude/agents/*.md | grep -v README | grep -v WORKFLOWS
# Should include: planner, bash-script-developer, test-automation-engineer,
#                 security-auditor, code-reviewer, debugger, documentation-engineer

# ✓ Check disabled agents
[ -d .claude/agents/disabled ] && ls -1 .claude/agents/disabled/
# Should list: fullstack-developer.md (or similar)
```

**CLAUDE.md sections to verify:**
- [ ] Agent table lists all 7 agents with correct purposes
- [ ] Agent descriptions match actual configurations
- [ ] Workflow examples reference existing agents
- [ ] MCP compatibility section reflects current agents

---

### 7. Documentation Cross-References

**Verify all referenced documents exist:**

```bash
# Extract all markdown links from CLAUDE.md
grep -o '\[.*\](.*\.md)' CLAUDE.md | sed 's/.*(\(.*\))/\1/' > /tmp/claude-links.txt

# Check each link
while read link; do
    # Handle relative paths
    if [[ $link == ../* ]]; then
        filepath="${link#../}"
    elif [[ $link == docs/* ]]; then
        filepath="$link"
    else
        filepath="$link"
    fi

    [ -f "$filepath" ] || echo "❌ Broken link: $link → $filepath"
done < /tmp/claude-links.txt
```

**Expected references:**
- [ ] README.md
- [ ] CHANGELOG.md
- [ ] docs/script_usage.md
- [ ] docs/xdg_setup.md
- [ ] docs/EXTENDING_THE_SCRIPT.md
- [ ] docs/USER_SPACE_COMPATIBILITY.md
- [ ] .claude/agents/WORKFLOWS.md
- [ ] ~/.claude/plans/gleaming-waddling-sketch.md (external)

---

### 8. Constraint & Requirement Verification

**Security constraints must be current:**

```bash
# ✓ Verify NO sudo usage in codebase
grep -r "sudo" *.sh lib/ scripts/ 2>/dev/null
# Should be empty (or only in comments explaining what NOT to do)

# ✓ Verify all downloads use HTTPS
grep -r "http://" *.sh lib/ scripts/ 2>/dev/null | grep -v "https://"
# Should be empty (no plain HTTP)

# ✓ Verify XDG compliance
grep -r "/tmp" *.sh lib/ scripts/ 2>/dev/null
# Should be minimal/justified (prefer $XDG_CACHE_HOME)

# ✓ Verify user-space paths
grep -r "~/.local\|~/opt\|\$HOME/.local\|\$HOME/opt" *.sh lib/ scripts/ | head
# Should be abundant (user-space installations)
```

**CLAUDE.md section to verify:**
- [ ] "🚨 Important Constraints & Requirements" matches current practices
- [ ] Security constraints reflect actual enforcement
- [ ] Technical constraints are achievable
- [ ] Environment requirements are accurate

---

## Section-by-Section Validation

Detailed validation for each major section of CLAUDE.md.

### Section: 🎯 Project Overview

**Checklist:**
- [ ] Tool count is current (37+)
- [ ] Key characteristics match reality:
  - [ ] Target environment: Ubuntu 20.04+
  - [ ] Language: Pure Bash
  - [ ] Installation method: User-space only
  - [ ] Architecture: Modular
- [ ] Description is accurate and compelling

**Validation:**
```bash
# Tool count
grep "37+ security tools" CLAUDE.md
# Key characteristics
grep "Ubuntu 20.04+" CLAUDE.md
grep "Pure Bash" CLAUDE.md
grep "User-space only" CLAUDE.md
grep "Modular" CLAUDE.md
```

---

### Section: 📁 Project Structure

**Checklist:**
- [ ] ASCII tree matches actual directory structure
- [ ] Line counts are accurate for key files:
  - [ ] Main script: ~196 lines
  - [ ] Library modules: 11 modules, 1,357 total lines
  - [ ] Core utilities: 221 lines
  - [ ] Data definitions: 222 lines
  - [ ] Installers: 652 lines
  - [ ] UI modules: 483 lines
- [ ] File descriptions are current

**Validation:**
```bash
# Verify directory structure
tree -L 2 -I "__pycache__|*.pyc" .

# Check line counts
wc -l install_security_tools.sh
wc -l lib/core/*.sh | tail -1
wc -l lib/data/*.sh | tail -1
wc -l lib/installers/*.sh | tail -1
wc -l lib/ui/*.sh | tail -1
```

**Update if mismatch:**
```bash
# Regenerate accurate ASCII tree
tree -L 3 --dirsfirst -I "__pycache__|*.pyc|.git" . > /tmp/tree.txt
# Manually update CLAUDE.md with accurate structure
```

---

### Section: 🔧 Core Components

**Checklist:**
- [ ] Module descriptions match actual module purposes
- [ ] Function signatures are accurate
- [ ] File locations are correct
- [ ] Tool categories list is current

**Validation for each module:**
```bash
# Example: lib/core/logging.sh
# 1. Check it exists
[ -f lib/core/logging.sh ] || echo "❌ Missing"

# 2. Check functions exist
grep "^init_logging()" lib/core/logging.sh
grep "^create_tool_log()" lib/core/logging.sh
grep "^cleanup_old_logs()" lib/core/logging.sh
grep "^log_installation()" lib/core/logging.sh

# 3. Verify function count
grep "^[a-z_]*() {" lib/core/logging.sh | wc -l
# Should match CLAUDE.md description
```

**Repeat for:**
- [ ] lib/core/logging.sh
- [ ] lib/core/download.sh
- [ ] lib/core/verification.sh
- [ ] lib/core/dependencies.sh
- [ ] lib/data/tool-definitions.sh
- [ ] lib/installers/generic.sh
- [ ] lib/installers/runtimes.sh
- [ ] lib/installers/tools.sh
- [ ] lib/ui/menu.sh
- [ ] lib/ui/display.sh
- [ ] lib/ui/orchestration.sh

---

### Section: 🎨 Code Style & Conventions

**Checklist:**
- [ ] Variable naming conventions match actual code
- [ ] Function naming conventions match actual code
- [ ] Error handling patterns match actual code
- [ ] Color codes are current (check for updates)

**Validation:**
```bash
# Check if UPPERCASE globals are used
grep "^[A-Z_]*=" install_security_tools.sh | head -5

# Check if lowercase locals are used
grep "local [a-z_]*=" lib/core/logging.sh | head -5

# Check associative arrays
grep "declare -A" install_security_tools.sh

# Check error handling pattern
grep "set +e" install_security_tools.sh
grep "|| return 1" lib/installers/generic.sh | head -3

# Check color codes
grep "GREEN=" install_security_tools.sh
grep "RED=" install_security_tools.sh
```

---

### Section: 🔑 Key Design Patterns

**Checklist:**
- [ ] All 4 patterns are documented and accurate:
  - [ ] Dependency Resolution
  - [ ] Generic Installers
  - [ ] Download Retry Logic
  - [ ] Wrapper Script Creation
- [ ] Code examples work when copy-pasted
- [ ] Patterns match current implementations

**Validation:**
```bash
# 1. Dependency Resolution
grep -A 10 "check_dependencies()" lib/core/dependencies.sh

# 2. Generic Installers
grep -A 5 "install_python_tool()" lib/installers/generic.sh
grep -A 5 "install_go_tool()" lib/installers/generic.sh

# 3. Download Retry Logic
grep -A 20 "download_file()" lib/core/download.sh

# 4. Wrapper Script Creation
grep -A 15 "create_python_wrapper()" lib/installers/generic.sh
```

**Test patterns work:**
```bash
# Extract pattern from CLAUDE.md
# Copy-paste into test script
# Execute and verify it works
```

---

### Section: 📋 Adding New Tools

**Checklist:**
- [ ] 6-step process is accurate for v1.3.0 modular architecture
- [ ] File locations match actual structure
- [ ] Examples reference existing tools
- [ ] Benefits list is current

**Validation:**
```bash
# Verify the 6 steps match actual workflow
# 1. Define metadata in tool-definitions.sh
grep "define_tools()" lib/data/tool-definitions.sh

# 2. Add installation check in verification.sh
grep "is_installed()" lib/core/verification.sh

# 3. Create wrapper in tools.sh
ls -la lib/installers/tools.sh

# 4. Add to dispatcher in orchestration.sh
grep "install_tool()" lib/ui/orchestration.sh

# 5. Update menu in menu.sh
grep "show_menu()" lib/ui/menu.sh

# 6. Add test in test_installation.sh
grep "run_all_tests()" scripts/test_installation.sh
```

---

### Section: 🤖 Agent Configuration & Workflows

**Checklist:**
- [ ] Agent count is accurate (7 agents)
- [ ] Agent table lists all agents with correct purposes
- [ ] Agent descriptions match actual `.claude/agents/*.md` files
- [ ] Development flow examples are realistic
- [ ] Workflow references are valid

**Validation:**
```bash
# Count agents
find .claude/agents -maxdepth 1 -name "*.md" ! -name "README.md" ! -name "WORKFLOWS.md" | wc -l

# List agents
ls -1 .claude/agents/ | grep ".md$" | grep -v README | grep -v WORKFLOWS

# Check each agent file exists
for agent in planner bash-script-developer test-automation-engineer security-auditor code-reviewer debugger documentation-engineer; do
    [ -f ".claude/agents/$agent.md" ] || echo "❌ Missing: $agent.md"
done

# Verify WORKFLOWS.md exists
[ -f .claude/agents/WORKFLOWS.md ] || echo "❌ Missing WORKFLOWS.md"
```

---

### Section: 🔌 MCP Server Configuration

**Checklist:**
- [ ] MCP count is accurate (8 recommended)
- [ ] Tier 1 MCPs listed correctly
- [ ] Implementation status is current
- [ ] Plan location is accurate

**Validation:**
```bash
# Check if MCP plan exists
[ -f ~/.claude/plans/gleaming-waddling-sketch.md ] || echo "⚠️ MCP plan not found"

# Verify CLAUDE.md mentions correct MCPs
grep "Filesystem" CLAUDE.md
grep "Sequential Thinking" CLAUDE.md
grep "GitHub Official" CLAUDE.md
```

**Update if status changes:**
- [ ] MCP servers enabled/disabled
- [ ] Phase completion status
- [ ] Performance measurements

---

### Section: 📚 Key Documentation Files

**Checklist:**
- [ ] All listed files exist
- [ ] Descriptions match file purposes
- [ ] Categories are accurate (Users/Developers/Agent Configuration)

**Validation:**
```bash
# User documentation
[ -f README.md ] && echo "✓"
[ -f docs/script_usage.md ] && echo "✓"
[ -f docs/xdg_setup.md ] && echo "✓"

# Developer documentation
[ -f CLAUDE.md ] && echo "✓"
[ -f .claude/agents/WORKFLOWS.md ] && echo "✓"
[ -f docs/EXTENDING_THE_SCRIPT.md ] && echo "✓"
[ -f docs/USER_SPACE_COMPATIBILITY.md ] && echo "✓"
[ -f CHANGELOG.md ] && echo "✓"

# Agent configuration
[ -f ~/.claude/plans/gleaming-waddling-sketch.md ] || echo "⚠️ External file"
```

---

## Code Example Validation

Automated validation of all code examples in CLAUDE.md.

### Extract Code Blocks

```bash
#!/bin/bash
# extract-code-blocks.sh
# Extract all bash code blocks from CLAUDE.md

awk '/```bash/,/```/' CLAUDE.md | grep -v "^```" > /tmp/claude-code-examples.sh

echo "Extracted code blocks to /tmp/claude-code-examples.sh"
```

---

### Syntax Validation

```bash
#!/bin/bash
# validate-syntax.sh
# Check syntax of all bash code blocks

echo "=== Syntax Validation ==="

# Extract code blocks
awk '/```bash/,/```/' CLAUDE.md | grep -v "^```" > /tmp/claude-code-temp.sh

# Split by blank lines into individual examples
awk 'BEGIN{i=1} /^$/{i++; next} {print > "/tmp/example-"i".sh"}' /tmp/claude-code-temp.sh

# Validate each example
for example in /tmp/example-*.sh; do
    echo -n "Checking $example... "
    if bash -n "$example" 2>/dev/null; then
        echo "✓"
    else
        echo "❌"
        bash -n "$example" 2>&1
    fi
done

# Cleanup
rm -f /tmp/example-*.sh /tmp/claude-code-temp.sh
```

---

### Function Signature Validation

```bash
#!/bin/bash
# validate-function-signatures.sh
# Verify function signatures in CLAUDE.md match actual code

echo "=== Function Signature Validation ==="

# List of functions mentioned in CLAUDE.md
FUNCTIONS=(
    "init_logging"
    "create_tool_log"
    "cleanup_old_logs"
    "log_installation"
    "download_file"
    "verify_file_exists"
    "is_installed"
    "scan_installed_tools"
    "verify_system_go"
    "verify_xdg_environment"
    "check_dependencies"
    "define_tools"
    "install_python_tool"
    "install_go_tool"
    "install_node_tool"
    "install_rust_tool"
    "create_python_wrapper"
    "show_menu"
    "process_menu_selection"
    "show_installed"
    "show_logs"
    "show_installation_summary"
    "install_tool"
    "install_all"
    "dry_run_install"
)

for func in "${FUNCTIONS[@]}"; do
    echo -n "Checking $func()... "

    # Search for function definition in codebase
    if grep -rq "^${func}()" . 2>/dev/null; then
        echo "✓ Found"
    else
        echo "❌ Not found in codebase"
    fi
done
```

---

### Variable Name Validation

```bash
#!/bin/bash
# validate-variables.sh
# Check if variables mentioned in CLAUDE.md exist in code

echo "=== Variable Validation ==="

# Key variables mentioned in CLAUDE.md
VARIABLES=(
    "SCRIPT_VERSION"
    "TOOL_INFO"
    "TOOL_SIZES"
    "TOOL_DEPENDENCIES"
    "INSTALLED_STATUS"
    "XDG_DATA_HOME"
    "XDG_CONFIG_HOME"
    "XDG_CACHE_HOME"
    "XDG_STATE_HOME"
    "GOPATH"
    "CARGO_HOME"
    "RUSTUP_HOME"
)

for var in "${VARIABLES[@]}"; do
    echo -n "Checking $var... "

    if grep -rq "$var" install_security_tools.sh lib/ 2>/dev/null; then
        echo "✓ Found"
    else
        echo "❌ Not found"
    fi
done
```

---

## Cross-Reference Validation

Ensure all cross-references between documents are accurate.

### Internal Links (within CLAUDE.md)

```bash
#!/bin/bash
# validate-internal-links.sh
# Check internal section links in CLAUDE.md

echo "=== Internal Link Validation ==="

# Extract internal links (format: [text](#section))
grep -o '\[.*\](#[^)]*)' CLAUDE.md | sed 's/.*(\(#.*\))/\1/' > /tmp/internal-links.txt

# Extract section headers (format: ## Header)
grep "^##" CLAUDE.md | sed 's/## //; s/ /-/g; s/[^a-zA-Z0-9-]//g' | tr '[:upper:]' '[:lower:]' > /tmp/section-headers.txt

# Check each link
while read link; do
    link_clean=$(echo "$link" | sed 's/#//')

    if grep -q "^$link_clean$" /tmp/section-headers.txt; then
        echo "✓ $link"
    else
        echo "❌ Broken: $link"
    fi
done < /tmp/internal-links.txt
```

---

### External Links (to other docs)

```bash
#!/bin/bash
# validate-external-links.sh
# Check links to other documentation files

echo "=== External Link Validation ==="

# Extract file links (format: [text](file.md))
grep -o '\[.*\]([^)]*\.md[^)]*)' CLAUDE.md | sed 's/.*(\([^)]*\)).*/\1/' > /tmp/external-links.txt

while read link; do
    # Handle different link formats
    if [[ $link == http* ]]; then
        echo "⊗ Skip URL: $link"
        continue
    fi

    # Resolve relative paths
    if [[ $link == docs/* ]]; then
        filepath="$link"
    elif [[ $link == .claude/* ]]; then
        filepath="$link"
    elif [[ $link == ../* ]]; then
        filepath="${link#../}"
    elif [[ $link == ~/* ]]; then
        echo "⊗ Skip home dir: $link"
        continue
    else
        filepath="$link"
    fi

    if [ -f "$filepath" ]; then
        echo "✓ $link"
    else
        echo "❌ Missing: $link → $filepath"
    fi
done < /tmp/external-links.txt
```

---

### Bidirectional Link Validation

```bash
#!/bin/bash
# validate-bidirectional-links.sh
# Ensure referenced documents also reference CLAUDE.md back

echo "=== Bidirectional Link Validation ==="

DOCS_TO_CHECK=(
    "README.md"
    "CHANGELOG.md"
    "docs/EXTENDING_THE_SCRIPT.md"
    ".claude/agents/WORKFLOWS.md"
)

for doc in "${DOCS_TO_CHECK[@]}"; do
    if [ ! -f "$doc" ]; then
        echo "⊗ Skip missing: $doc"
        continue
    fi

    echo -n "Checking $doc... "
    if grep -q "CLAUDE.md" "$doc"; then
        echo "✓ References CLAUDE.md"
    else
        echo "⚠️ No reference to CLAUDE.md"
    fi
done
```

---

## Automation Opportunities

Scripts and tools to automate CLAUDE.md validation.

### Comprehensive Validation Script

```bash
#!/bin/bash
# validate-claude-full.sh
# Run all validation checks

set -e

echo "==============================================="
echo "CLAUDE.md Comprehensive Validation"
echo "==============================================="
echo ""

# 1. Quick validation
echo "=== Quick Validation ==="
bash .claude/scripts/quick-validate-claude.sh
echo ""

# 2. Syntax validation
echo "=== Code Syntax Validation ==="
bash .claude/scripts/validate-syntax.sh
echo ""

# 3. Function signatures
echo "=== Function Signature Validation ==="
bash .claude/scripts/validate-function-signatures.sh
echo ""

# 4. Variable names
echo "=== Variable Validation ==="
bash .claude/scripts/validate-variables.sh
echo ""

# 5. Internal links
echo "=== Internal Link Validation ==="
bash .claude/scripts/validate-internal-links.sh
echo ""

# 6. External links
echo "=== External Link Validation ==="
bash .claude/scripts/validate-external-links.sh
echo ""

# 7. Bidirectional links
echo "=== Bidirectional Link Validation ==="
bash .claude/scripts/validate-bidirectional-links.sh
echo ""

echo "==============================================="
echo "Validation Complete"
echo "==============================================="
```

---

### CI/CD Integration

**GitHub Actions Example:**

```yaml
# .github/workflows/validate-docs.yml
name: Validate Documentation

on:
  pull_request:
    paths:
      - 'CLAUDE.md'
      - '*.sh'
      - 'lib/**/*.sh'

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Quick Validation
        run: bash .claude/scripts/quick-validate-claude.sh

      - name: Code Example Syntax
        run: bash .claude/scripts/validate-syntax.sh

      - name: Link Validation
        run: |
          bash .claude/scripts/validate-internal-links.sh
          bash .claude/scripts/validate-external-links.sh

      - name: Report
        run: echo "✓ CLAUDE.md validation passed"
```

---

### Pre-Commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit
# Validate CLAUDE.md before allowing commit

# Check if CLAUDE.md is being committed
if git diff --cached --name-only | grep -q "CLAUDE.md"; then
    echo "Validating CLAUDE.md..."

    # Quick validation
    if ! bash .claude/scripts/quick-validate-claude.sh; then
        echo "❌ CLAUDE.md validation failed"
        echo "Fix errors before committing"
        exit 1
    fi

    echo "✓ CLAUDE.md validation passed"
fi

exit 0
```

**Installation:**
```bash
# Copy to git hooks directory
cp .claude/scripts/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

---

### Scheduled Maintenance

**Cron job for monthly validation:**

```bash
# Add to crontab: crontab -e
# Run on 1st of every month at 9am
0 9 1 * * cd /path/to/tilix-tools-installer && bash .claude/scripts/validate-claude-full.sh > /tmp/claude-validation.log 2>&1
```

---

## Common Issues & Fixes

### Issue 1: Version Mismatch

**Symptom:**
```
❌ Version mismatch: CLAUDE.md (1.2.0) vs script (1.3.0)
```

**Fix:**
```bash
# Update CLAUDE.md header
sed -i '' 's/Version: 1.2.0/Version: 1.3.0/' CLAUDE.md

# Update Last Updated date
sed -i '' "s/Last Updated:.*/Last Updated: $(date +%B\ %d,\ %Y)/" CLAUDE.md
```

---

### Issue 2: Tool Count Mismatch

**Symptom:**
```
❌ Tool count: CLAUDE.md says 37, but 38 defined in tool-definitions.sh
```

**Fix:**
```bash
# Count actual tools
actual_count=$(grep "TOOL_INFO\[" lib/data/tool-definitions.sh | wc -l | tr -d ' ')

# Update CLAUDE.md
sed -i '' "s/37+ tools/${actual_count}+ tools/g" CLAUDE.md
```

---

### Issue 3: Broken File Path

**Symptom:**
```
❌ Referenced file doesn't exist: lib/installers/old-module.sh
```

**Fix:**
1. Check if file was renamed or moved
2. Update CLAUDE.md with correct path
3. Or remove reference if obsolete

```bash
# Find where file might be
find . -name "old-module.sh"

# If found, update path in CLAUDE.md
# If not found, remove reference
```

---

### Issue 4: Outdated Code Example

**Symptom:**
```
⚠️ Function pattern in CLAUDE.md doesn't match actual implementation
```

**Fix:**
```bash
# Extract current function from codebase
grep -A 20 "^install_example_tool()" lib/installers/tools.sh > /tmp/current-function.txt

# Compare with CLAUDE.md example
# Manually update CLAUDE.md to match current implementation
```

---

### Issue 5: Missing Cross-Reference

**Symptom:**
```
⚠️ docs/script_usage.md doesn't reference CLAUDE.md
```

**Fix:**
```bash
# Add cross-reference to docs/script_usage.md
echo "" >> docs/script_usage.md
echo "For AI assistant context, see 📖 [CLAUDE.md](../CLAUDE.md)." >> docs/script_usage.md
```

---

## Pre-Commit Hook Examples

### Minimal Pre-Commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit (minimal version)

if git diff --cached --name-only | grep -q "CLAUDE.md"; then
    # Version check only
    VERSION_CLAUDE=$(grep -m1 "^**Version:**" CLAUDE.md | sed 's/[^0-9.]//g')
    VERSION_SCRIPT=$(grep "SCRIPT_VERSION=" install_security_tools.sh | head -1 | sed 's/[^0-9.]//g')

    if [ "$VERSION_CLAUDE" != "$VERSION_SCRIPT" ]; then
        echo "❌ Version mismatch in CLAUDE.md"
        echo "   CLAUDE.md: $VERSION_CLAUDE"
        echo "   Script:    $VERSION_SCRIPT"
        exit 1
    fi

    echo "✓ CLAUDE.md validation passed"
fi
```

---

### Comprehensive Pre-Commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit (comprehensive version)

set -e

MODIFIED_FILES=$(git diff --cached --name-only)

# Check if CLAUDE.md or related files modified
if echo "$MODIFIED_FILES" | grep -q -E "CLAUDE.md|\.sh$|lib/"; then
    echo "=== Validating CLAUDE.md ==="

    # 1. Version consistency
    VERSION_CLAUDE=$(grep -m1 "^**Version:**" CLAUDE.md | sed 's/[^0-9.]//g')
    VERSION_SCRIPT=$(grep "SCRIPT_VERSION=" install_security_tools.sh | head -1 | sed 's/[^0-9.]//g')

    if [ "$VERSION_CLAUDE" != "$VERSION_SCRIPT" ]; then
        echo "❌ Version mismatch"
        exit 1
    fi
    echo "✓ Version consistency"

    # 2. Tool count
    TOOLS_DEFINED=$(grep "TOOL_INFO\[" lib/data/tool-definitions.sh | wc -l | tr -d ' ')
    if ! grep -q "${TOOLS_DEFINED}+" CLAUDE.md; then
        echo "⚠️ Tool count may be outdated (found ${TOOLS_DEFINED} tools)"
    fi
    echo "✓ Tool count check"

    # 3. File path validation (quick check)
    if grep -o '\`[^`]*.sh\`' CLAUDE.md | sed 's/`//g' | while read file; do
        [ -f "$file" ] || { echo "❌ Missing file: $file"; exit 1; }
    done; then
        echo "✓ File paths valid"
    fi

    # 4. Last updated date
    LAST_MODIFIED=$(git log -1 --format="%ai" CLAUDE.md 2>/dev/null | cut -d' ' -f1)
    LAST_UPDATED=$(grep "Last Updated:" CLAUDE.md | grep -o "[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}" || echo "")

    if [ -n "$LAST_MODIFIED" ] && [ "$LAST_MODIFIED" != "$LAST_UPDATED" ]; then
        echo "⚠️ Consider updating 'Last Updated' date in CLAUDE.md"
    fi

    echo "✓ CLAUDE.md validation complete"
fi

exit 0
```

**Installation:**
```bash
chmod +x .git/hooks/pre-commit
```

---

## Monthly Maintenance Checklist

Use this checklist once per month to keep CLAUDE.md accurate.

### Month: _____________ | Year: _______

**Prepared by:** _________________ | **Date:** _________

---

#### 1. Metadata & Version Check

- [ ] CLAUDE.md version matches `install_security_tools.sh`
- [ ] Last Updated date is recent (within 30 days if changes made)
- [ ] Project name consistent throughout
- [ ] Contact/maintainer info current

---

#### 2. Project Structure Validation

- [ ] ASCII directory tree matches reality
- [ ] Line counts accurate for all modules
- [ ] File descriptions current
- [ ] No references to deleted/moved files

---

#### 3. Tool Inventory Accuracy

- [ ] Total tool count current (37+)
- [ ] All tools in `tool-definitions.sh` documented
- [ ] Category counts accurate (Python: 12, Go: 8, Node: 3, Rust: 8)
- [ ] No deprecated tools mentioned

---

#### 4. Code Examples Validation

- [ ] All bash code blocks have valid syntax
- [ ] Function signatures match actual code
- [ ] Variable names match actual code
- [ ] Installation patterns current

---

#### 5. Architecture Documentation

- [ ] Module descriptions accurate
- [ ] Function lists complete for each module
- [ ] Design patterns reflect current implementation
- [ ] No obsolete patterns documented

---

#### 6. Agent Configuration Accuracy

- [ ] Agent count correct (7 agents)
- [ ] All agent files exist in `.claude/agents/`
- [ ] Agent descriptions match configurations
- [ ] Workflow examples realistic

---

#### 7. Cross-References Validation

- [ ] All internal links work
- [ ] All external document links valid
- [ ] Bidirectional references exist where appropriate
- [ ] No broken markdown links

---

#### 8. Constraints & Requirements

- [ ] Security constraints reflect current enforcement
- [ ] Technical constraints achievable
- [ ] Environment requirements accurate
- [ ] Constraints section matches actual practices

---

#### 9. Documentation Links

- [ ] All referenced docs exist
- [ ] Doc descriptions accurate
- [ ] New docs added if created
- [ ] Obsolete docs removed

---

#### 10. Final Review

- [ ] Ran quick validation script
- [ ] Ran comprehensive validation script
- [ ] Fixed all identified issues
- [ ] Updated Last Updated date
- [ ] Committed changes with appropriate message

---

**Notes:**
```
(Add any issues found, fixes applied, or improvement suggestions)




```

---

## Cross-References

### Related Documentation

📖 **[CLAUDE.md](../CLAUDE.md)** - The document being validated
📖 **[CHANGELOG.md](../CHANGELOG.md)** - Product version history
📖 **[DEV_CHANGELOG.md](../DEV_CHANGELOG.md)** - Infrastructure change history
📖 **[.claude/agents/WORKFLOWS.md](agents/WORKFLOWS.md)** - Agent usage patterns

### Validation Scripts Location

All validation scripts should be stored in:
📖 **`.claude/scripts/`** - Validation automation scripts

Recommended structure:
```
.claude/
├── scripts/
│   ├── quick-validate-claude.sh
│   ├── validate-syntax.sh
│   ├── validate-function-signatures.sh
│   ├── validate-variables.sh
│   ├── validate-internal-links.sh
│   ├── validate-external-links.sh
│   ├── validate-bidirectional-links.sh
│   └── validate-claude-full.sh
├── CLAUDE_VALIDATION_CHECKLIST.md (this file)
└── agents/
```

---

**Document Version:** 1.0
**Last Updated:** January 15, 2026
**Maintained By:** documentation-engineer agent

For development infrastructure changes, see 📖 [DEV_CHANGELOG.md](../DEV_CHANGELOG.md).
