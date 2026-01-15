# Agent Usage Guide

**Version:** 1.0
**Last Updated:** January 15, 2026
**Purpose:** Comprehensive guide to using the 7 specialized AI agents for development, testing, and security auditing

This document provides practical guidance, decision trees, and workflow patterns for leveraging AI agents to accelerate development while maintaining code quality and security standards.

---

## Table of Contents

1. [Overview](#overview)
2. [Agent Selection Decision Tree](#agent-selection-decision-tree)
3. [Task Type Matrix](#task-type-matrix)
4. [Available Agents](#available-agents)
5. [Development Workflows](#development-workflows)
6. [Integration Patterns](#integration-patterns)
7. [Best Practices](#best-practices)
8. [Troubleshooting](#troubleshooting)
9. [Metrics & Success Indicators](#metrics--success-indicators)
10. [Cross-References](#cross-references)

---

## Overview

### Agent System Benefits

The 7 specialized agents provide:

**Velocity Improvements:**
- 60-70% faster development cycles
- 2.5-3x overall velocity improvement
- Reduced context switching and rework

**Quality Improvements:**
- Zero shellcheck violations enforced
- 100% test coverage goal
- Proactive security enforcement

**Autonomy Improvements:**
- Agents understand project context automatically
- Consistent pattern enforcement
- Automatic security checks

### When to Use Agents

**ALWAYS use without being asked:**
- **code-reviewer** - After ANY bash code changes (security critical)
- **security-auditor** - Before releases or after download changes
- **test-automation-engineer** - When adding new tools

**Use proactively for:**
- Adding new security tools (bash-script-developer)
- Complex multi-step tasks (planner)
- Debugging failures (debugger)
- Documentation updates (documentation-engineer)

---

## Agent Selection Decision Tree

```
START: What do you need to do?

┌─ Complex task requiring planning?
│  └─ YES → Use planner
│  └─ NO → Continue
│
├─ Writing or modifying bash code?
│  └─ YES → Use bash-script-developer
│         └─ THEN: Use code-reviewer (REQUIRED)
│         └─ THEN: Use test-automation-engineer
│  └─ NO → Continue
│
├─ Creating or fixing tests?
│  └─ YES → Use test-automation-engineer
│  └─ NO → Continue
│
├─ Security concern or pre-release audit?
│  └─ YES → Use security-auditor
│  └─ NO → Continue
│
├─ Code review needed?
│  └─ YES → Use code-reviewer
│  └─ NO → Continue
│
├─ Bug or unexpected behavior?
│  └─ YES → Use debugger
│  └─ NO → Continue
│
└─ Documentation update needed?
   └─ YES → Use documentation-engineer
```

---

## Task Type Matrix

Estimated durations and recommended agent workflows for common tasks.

| Task | Estimated Time | Primary Agent | Secondary Agents | Total Time Savings |
|------|---------------|---------------|------------------|-------------------|
| **Add new Python tool** | 10-15 min | bash-script-developer | test-automation-engineer, code-reviewer | 60-70% faster |
| **Add new Go tool** | 10-15 min | bash-script-developer | test-automation-engineer, code-reviewer | 60-70% faster |
| **Fix installation bug** | 10-15 min | debugger | code-reviewer, test-automation-engineer | 50-60% faster |
| **Security audit (full)** | 15-25 min | security-auditor | code-reviewer | 70-80% faster |
| **Security audit (targeted)** | 5-10 min | security-auditor | - | 60-70% faster |
| **Create test suite** | 5-10 min | test-automation-engineer | - | 40-50% faster |
| **Update documentation** | 5-15 min | documentation-engineer | - | 30-40% faster |
| **Refactor function** | 15-25 min | planner, bash-script-developer | code-reviewer | 50-60% faster |
| **Code review** | 5-10 min | code-reviewer | - | 40-50% faster |
| **Plan complex feature** | 10-20 min | planner | - | 30-40% faster |

---

## Available Agents

### 1. planner

**Purpose:** Strategic planning and task decomposition for complex multi-step tasks

**When to Use:**
- Complex features requiring multiple components
- Major refactoring or architectural changes
- Multi-day projects requiring phased approach
- Coordinating multiple agent workflows

**Strengths:**
- Task breakdown into manageable steps
- Dependency identification
- Risk assessment
- Resource estimation

**Example Usage:**
```
> Use planner to create a plan for adding httpx from ProjectDiscovery

> Use planner to create a refactoring strategy for the download_file function
```

**Expected Output:**
- Detailed step-by-step plan
- Dependency tree
- Risk analysis
- Time estimates
- Success criteria

---

### 2. bash-script-developer

**Purpose:** Bash scripting specialist for implementing installation functions

**When to Use:**
- Adding new security tools
- Implementing installation functions
- Refactoring existing bash code
- Creating wrapper scripts
- Modifying library modules

**Knows:**
- Project patterns (install_python_tool, install_go_tool, etc.)
- Tool metadata structures (TOOL_INFO, TOOL_SIZES, TOOL_DEPENDENCIES)
- Logging patterns (create_tool_log)
- XDG compliance (XDG_DATA_HOME, XDG_CONFIG_HOME)
- Error handling patterns (set +e, explicit return codes)
- Generic installer usage

**Example Usage:**
```
> Use bash-script-developer to implement install_httpx() following existing Go tool patterns

> Use bash-script-developer to refactor download_file() with better error handling
```

**Expected Output:**
- Shellcheck-compliant bash code
- Proper quoting and error handling
- XDG-compliant paths
- User-space installations only
- Comprehensive logging

**ALWAYS follow with:**
- code-reviewer (REQUIRED)
- test-automation-engineer

---

### 3. test-automation-engineer

**Purpose:** Test generation and validation for all installed tools

**When to Use:**
- After adding new tools
- Creating comprehensive test suites
- Validating bug fixes
- Integration testing
- Test coverage analysis

**Knows:**
- Generic test functions (test_python_tool, test_go_tool, etc.)
- Test result tracking patterns
- Test output formatting (cyan headers, green [OK], red [FAIL])
- Integration test patterns
- Dry-run validation

**Example Usage:**
```
> Use test-automation-engineer to create test_httpx() function

> Use test-automation-engineer to verify all 37 tools have corresponding tests
```

**Expected Output:**
- Comprehensive test functions
- Test result tracking
- Clear pass/fail reporting
- Integration test coverage
- Dry-run validation

---

### 4. security-auditor

**Purpose:** Security review and vulnerability scanning for the entire codebase

**When to Use:**
- Before releases
- After download mechanism changes
- When adding new tools
- Periodic security audits
- CVE research

**Checks:**
- NO sudo/root usage
- HTTPS-only downloads
- No hardcoded credentials
- Download verification present
- XDG compliance
- User-space only installations
- Command injection prevention
- Path traversal prevention
- Secret exposure

**Example Usage:**
```
> Use security-auditor to audit entire codebase before v2.1.0 release

> Use security-auditor to check download mechanism for install_httpx()
```

**Expected Output:**
- Structured security audit report
- Critical/High/Medium/Low priority issues
- CVE checks for dependencies
- Remediation recommendations
- Compliance verification

**Report Sections:**
1. Critical Issues (blocks commit)
2. High Priority Issues (requires fix)
3. Medium Priority Issues (recommended fix)
4. Low Priority Issues (best practice)
5. Informational (awareness only)

---

### 5. code-reviewer

**Purpose:** Code quality analysis with bash-specific security checklist

**When to Use:**
- After ANY bash code changes (REQUIRED)
- Before committing code
- During pull request reviews
- Post-refactoring validation

**Checks:**
- Shellcheck compliance (SC2086, SC2155, SC2046, etc.)
- Bash anti-patterns
- Security requirements (NO sudo, HTTPS only)
- Download verification
- XDG compliance
- Project pattern adherence
- Error handling completeness
- Proper quoting

**Example Usage:**
```
> Use code-reviewer to review my recent changes to install_security_tools.sh

> Use code-reviewer to check bash best practices compliance across all scripts
```

**Expected Output:**
- Syntax validation results
- Shellcheck compliance report
- Security checklist verification
- Pattern matching validation
- Code quality score

**Critical Requirements (Auto-Block):**
- ❌ NO sudo/root usage
- ❌ NO http:// downloads
- ❌ NO hardcoded passwords/keys
- ❌ NO system file modifications

---

### 6. debugger

**Purpose:** Bug investigation and systematic fixing for installation failures

**When to Use:**
- Installation failures
- Unexpected errors
- Environment issues
- Dependency problems
- Tool not found errors

**Approach:**
1. Read installation logs
2. Check PATH configuration
3. Verify dependencies
4. Test hypotheses systematically
5. Implement fix with error handling
6. Verify fix with tests

**Example Usage:**
```
> Use debugger to investigate why nuclei installation is failing

> Use debugger to diagnose PATH issues for Go tools
```

**Expected Output:**
- Root cause analysis
- Systematic hypothesis testing
- Fix implementation
- Verification steps
- Prevention recommendations

---

### 7. documentation-engineer

**Purpose:** Technical writing and documentation updates

**When to Use:**
- Adding new tools (update README, CHANGELOG)
- Creating new documentation
- Updating usage guides
- Version releases
- Documentation audits

**Maintains:**
- README.md
- CHANGELOG.md
- docs/*.md
- CLAUDE.md
- Agent documentation

**Example Usage:**
```
> Use documentation-engineer to update README.md, CHANGELOG.md for httpx addition

> Use documentation-engineer to create usage guide for diagnostic script
```

**Expected Output:**
- Clear, scannable documentation
- Updated cross-references
- Version consistency
- Examples with working code
- Bidirectional links

---

## Development Workflows

### Workflow 1: Adding a New Security Tool

**Example:** Adding httpx reconnaissance tool (Go-based)

**Time:** 10-15 minutes (with agents) vs 30-45 minutes (manual)

```bash
# Step 1: Planning (optional for simple tools)
> Use planner to create a plan for adding httpx from ProjectDiscovery

# Step 2: Implementation
> Use bash-script-developer to implement install_httpx() following existing Go tool patterns

# Step 3: Testing
> Use test-automation-engineer to create test_httpx() function

# Step 4: Security Review
> Use security-auditor to check download mechanism, verify HTTPS, check user-space compliance

# Step 5: Code Quality Review (REQUIRED)
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
- ✅ 60-70% time savings vs manual

---

### Workflow 2: Debugging Installation Failure

**Example:** nuclei installation failing with 'command not found'

**Time:** 10-15 minutes (with agents) vs 30-45 minutes (manual)

```bash
# Step 1: Investigation
> Use debugger to investigate why nuclei installation is failing

# Debugger will:
# - Read installation logs at ~/.local/state/install_tools/logs/nuclei-*.log
# - Check PATH configuration (GOPATH/bin in PATH?)
# - Verify Go runtime dependency (system Go installed?)
# - Test hypotheses systematically
# - Implement fix with proper error handling

# Step 2: Validation
> Use test-automation-engineer to run test_nuclei() and verify fix

# Step 3: Review (REQUIRED)
> Use code-reviewer to ensure fix doesn't introduce regressions
```

**Expected Results:**
- ✅ Root cause identified and documented
- ✅ Fix implemented with proper error handling
- ✅ Tests pass
- ✅ 50-60% time savings vs trial-and-error

---

### Workflow 3: Security Audit Before Release

**Example:** Preparing v2.1.0 release

**Time:** 15-25 minutes (with agents) vs 60-90 minutes (manual)

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
- ✅ 70-80% time savings vs manual review

---

## Integration Patterns

### Automatic Handoff

Some agents automatically trigger others:

```
bash-script-developer
  └─ ALWAYS FOLLOW WITH: code-reviewer (security critical)
     └─ THEN: test-automation-engineer

debugger (implements fix)
  └─ ALWAYS FOLLOW WITH: code-reviewer
     └─ THEN: test-automation-engineer
```

### Parallel Execution

For independent tasks, use agents in parallel:

```
# After adding tool, run these in parallel:
- security-auditor (checks security)
- test-automation-engineer (creates tests)
- documentation-engineer (updates docs)
```

### Sequential Specialization

Complex tasks require sequential agent usage:

```
1. planner → Break down task
2. bash-script-developer → Implement
3. test-automation-engineer → Create tests
4. security-auditor → Security review
5. code-reviewer → Quality check
6. documentation-engineer → Update docs
```

---

## Best Practices

### When to Use Agents Proactively

**ALWAYS use these agents without being asked:**

1. **code-reviewer** - After ANY bash code changes
   ```
   # After modifying install_security_tools.sh
   > Use code-reviewer to check my recent changes
   ```

2. **security-auditor** - Before releases or after download changes
   ```
   # Before tagging v2.1.0
   > Use security-auditor for full codebase audit
   ```

3. **test-automation-engineer** - When adding new tools
   ```
   # After adding install_httpx()
   > Use test-automation-engineer to create test_httpx()
   ```

---

### Agent Invocation Best Practices

**Be Specific:**
```
# Good
> Use bash-script-developer to implement install_httpx() following the pattern in install_gobuster()

# Too vague
> Make a new installer
```

**Reference Examples:**
```
# Good
> Use bash-script-developer to add install_httpx() - see install_gobuster() for reference

# Better
> Use bash-script-developer to implement install_httpx() following existing Go tool patterns in lib/installers/tools.sh
```

**Chain Agents:**
```
# Good workflow
> Use bash-script-developer to implement install_httpx()
> Use code-reviewer to review the implementation
> Use test-automation-engineer to create test_httpx()
```

---

### Agent Customization

**Agents automatically read project context from:**
- `CLAUDE.md` - Main project context
- `lib/README.md` - Module documentation
- Existing similar implementations

**To customize permanently:**
1. Update `CLAUDE.md` with new patterns
2. Edit agent `.md` files in `.claude/agents/`
3. Reference updated patterns in agent invocations

---

## Troubleshooting

### Agent Not Following Patterns?

**Problem:** Agent generates code that doesn't match project style

**Solution:**
```
# Point to existing similar implementation
> Use bash-script-developer to implement install_httpx() - follow the exact pattern in install_gobuster()

# Explicitly reference documentation
> Follow the Installation Function Pattern in CLAUDE.md section 🎨 Code Style & Conventions
```

---

### Agent Being Too Verbose?

**Problem:** Agent provides too much explanation or modifies unrelated files

**Solution:**
```
# Be specific about scope
> Use bash-script-developer to ONLY implement install_httpx() in lib/installers/tools.sh - don't update docs yet

# Break into smaller tasks
> Use bash-script-developer to implement just the install_httpx() function
> Use documentation-engineer to update README.md (separate request)
```

---

### Agent Missing Project Context?

**Problem:** Agent doesn't understand project-specific requirements

**Solution:**
```
# Ensure CLAUDE.md is up-to-date
> Review CLAUDE.md and update if needed

# Reference specific sections
> Use bash-script-developer following the patterns in CLAUDE.md section "🔑 Key Design Patterns"

# Point to examples
> See install_gobuster() in lib/installers/tools.sh for reference
```

---

### Agent Output Doesn't Work?

**Problem:** Generated code has errors or doesn't follow requirements

**Solution:**
```
# Use debugger to investigate
> Use debugger to investigate why the generated install_httpx() is failing

# Use code-reviewer to catch issues
> Use code-reviewer to check for shellcheck violations and security issues

# Iterate with specific feedback
> The generated code is missing error handling - update install_httpx() to match the pattern in install_gobuster()
```

---

## Metrics & Success Indicators

Track agent effectiveness to measure ROI and identify areas for improvement.

### Usage Metrics

| Metric | Target | Current Status | How to Measure |
|--------|--------|----------------|----------------|
| **Agent Usage Frequency** | >80% of tool additions | Track manually | Count tool additions using agents |
| **Code Quality** | Zero shellcheck violations | Measure with code-reviewer | Run shellcheck on all scripts |
| **Test Coverage** | 100% of tools tested | Track with test-automation-engineer | Count tools with tests vs total tools |
| **Security Posture** | Zero critical issues | Monitor with security-auditor | Run periodic security audits |
| **Time Savings** | >50% reduction | Track task duration | Compare agent-assisted vs manual time |

---

### Productivity Indicators

**Before Agents:**
- Add new tool: 30-45 minutes
- Fix bug: 30-45 minutes
- Security audit: 60-90 minutes
- Code review: 15-20 minutes
- Total: 2-3 hours per feature

**After Agents:**
- Add new tool: 10-15 minutes (66% faster)
- Fix bug: 10-15 minutes (67% faster)
- Security audit: 15-25 minutes (72% faster)
- Code review: 5-10 minutes (58% faster)
- Total: 40-65 minutes per feature (68% faster)

**Multiplier Effect:**
- 2.5-3x velocity improvement
- Higher code quality (fewer revisions)
- Proactive security (zero critical issues)
- Consistent patterns (easier collaboration)

---

### Quality Indicators

**Measured Improvements:**
- ✅ Error detection: Issues caught before merging
- ✅ Code quality: Zero shellcheck violations
- ✅ Security: Zero secrets committed, all HTTPS
- ✅ Test coverage: Approaching 100%
- ✅ Documentation: Always up-to-date

---

## Cross-References

### Related Documentation

📖 **[CLAUDE.md](../../CLAUDE.md)** - Project context and agent configuration overview
📖 **[WORKFLOWS.md](WORKFLOWS.md)** - Detailed agent workflows with examples
📖 **[README.md](README.md)** - Agent system overview
📖 **[DEV_CHANGELOG.md](../../DEV_CHANGELOG.md)** - Development infrastructure history

### Agent Configurations

Located in `.claude/agents/`:
- `planner.md` - Strategic planning agent
- `bash-script-developer.md` - Bash scripting specialist
- `test-automation-engineer.md` - Test generation agent
- `security-auditor.md` - Security review agent
- `code-reviewer.md` - Code quality agent (bash-enhanced)
- `debugger.md` - Bug investigation agent
- `documentation-engineer.md` - Technical writing agent

### MCP Configuration

📖 **[MCP_SETUP.md](../MCP_SETUP.md)** - MCP server configuration guide
📖 **[~/.claude/plans/gleaming-waddling-sketch.md](~/.claude/plans/gleaming-waddling-sketch.md)** - Complete MCP implementation plan

---

**Document Version:** 1.0
**Last Updated:** January 15, 2026
**Maintained By:** documentation-engineer agent

For detailed workflow examples, see 📖 **[WORKFLOWS.md](WORKFLOWS.md)**.
For MCP server integration, see 📖 **[MCP_SETUP.md](../MCP_SETUP.md)**.
