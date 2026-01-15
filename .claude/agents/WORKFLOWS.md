# Agent Workflows & Usage Patterns

This document provides detailed workflows, examples, and best practices for using the 7 specialized agents configured for this project. For agent descriptions and quick reference, see the main `CLAUDE.md` file.

---

## Table of Contents

1. [Agent Workflows](#agent-workflows)
2. [Agent Best Practices](#agent-best-practices)
3. [Agent Specializations](#agent-specializations)
4. [Development Flow Integration](#development-flow-integration)
5. [Agent-MCP Compatibility](#agent-mcp-compatibility)
6. [Enhanced Workflows with MCPs](#enhanced-workflows-with-mcps)
7. [Advanced Agent Usage](#advanced-agent-usage)
8. [Metrics & Success Indicators](#metrics--success-indicators)

---

## Agent Workflows

### Workflow 1: Adding a New Security Tool

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

---

### Workflow 2: Debugging Installation Failure

**Example:** nuclei installation failing with 'command not found'

```bash
# Step 1: Investigation
> Use debugger to investigate why nuclei installation is failing

# Debugger will:
# - Read installation logs
# - Check PATH configuration
# - Verify Go runtime dependency
# - Test hypotheses systematically
# - Implement fix

# Step 2: Validation
> Use test-automation-engineer to run test_nuclei() and verify fix

# Step 3: Review
> Use code-reviewer to ensure fix doesn't introduce regressions
```

**Expected Results:**
- ✅ Root cause identified and documented
- ✅ Fix implemented with proper error handling
- ✅ Tests pass
- ✅ ~50% time savings vs trial-and-error

---

### Workflow 3: Security Audit Before Release

**Example:** Preparing v2.1.0 release

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
- ✅ ~70% time savings vs manual review

---

## Agent Best Practices

### When to Use Agents Proactively

**ALWAYS use these agents without being asked:**

1. **code-reviewer** - After ANY bash code changes (security is critical)
   ```bash
   # After modifying install_security_tools.sh
   > Use code-reviewer to check my recent changes
   ```

2. **security-auditor** - Before releases or after download changes
   ```bash
   # Before tagging v2.1.0
   > Use security-auditor for full codebase audit
   ```

3. **test-automation-engineer** - When adding new tools
   ```bash
   # After adding install_httpx()
   > Use test-automation-engineer to create test_httpx()
   ```

---

## Agent Specializations

### bash-script-developer

**Knows:**
- Project patterns: `install_python_tool()`, `install_go_tool()`, `install_node_tool()`, `install_rust_tool()`
- Tool metadata: `TOOL_INFO[]`, `TOOL_SIZES[]`, `TOOL_DEPENDENCIES[]`
- Logging pattern: `logfile=$(create_tool_log "tool")`
- XDG variables: `$XDG_DATA_HOME`, `$XDG_CONFIG_HOME`, etc.
- Error handling: Explicit return code checking (set +e project style)

### test-automation-engineer

**Knows:**
- Generic test functions: `test_python_tool()`, `test_go_tool()`, etc.
- Test result tracking: `test_result "tool" "Test name" $?`
- Test structure: cyan header, green [OK], red [FAIL]
- Integration tests: dependency verification

### security-auditor

**Knows:**
- Project constraints: NO sudo, HTTPS only, user-space only
- Security patterns: Download verification, secret detection
- Vulnerability checks: Command injection, path traversal, credential leaks
- Compliance checks: XDG compliance, no hardcoded paths

### code-reviewer

**(enhanced for bash)** **Knows:**
- Shellcheck rules: SC2086 (quoting), SC2155, SC2046
- Bash anti-patterns: unquoted expansion, useless cat, incorrect conditionals
- Project security rules: No sudo, HTTPS only, verify downloads
- Project patterns: Tool definitions, logging, installation verification

---

## Development Flow Integration

### Normal Development Cycle

```
1. Understand task → Use planner (optional, for complex tasks)
2. Implement code → Use bash-script-developer
3. Create tests → Use test-automation-engineer
4. Security check → Use security-auditor
5. Quality review → Use code-reviewer (ALWAYS)
6. Update docs → Use documentation-engineer
```

### Bug Fix Cycle

```
1. Investigate → Use debugger
2. Verify fix → Use code-reviewer
3. Ensure tests pass → Use test-automation-engineer
```

### Release Cycle

```
1. Security audit → Use security-auditor
2. Quality check → Use code-reviewer
3. Test coverage → Use test-automation-engineer
4. Docs sync → Use documentation-engineer
```

---

## Agent-MCP Compatibility

How each agent benefits from MCP servers:

| Agent | Filesystem | Sequential Thinking | GitHub | Git | Brave Search | Fetch |
|-------|-----------|---------------------|--------|-----|--------------|-------|
| **bash-script-developer** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| **test-automation-engineer** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐ |
| **security-auditor** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **code-reviewer** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐ |
| **debugger** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| **documentation-engineer** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **planner** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐ |

**Legend:** ⭐⭐⭐⭐⭐ = Essential | ⭐⭐⭐⭐ = High Value | ⭐⭐⭐ = Medium | ⭐⭐ = Low | ⭐ = Minimal

---

## Enhanced Workflows with MCPs

When MCP servers are enabled, agents gain significant velocity and autonomy improvements.

### Example: Adding httpx reconnaissance tool (WITH MCPs)

```
Time: 10-15 min (was 30-45 min without MCPs)

Step 1: planner (with Sequential Thinking + Filesystem + GitHub)
  → Uses Sequential Thinking to decompose task
  → Uses Filesystem to read existing tool patterns
  → Uses GitHub to check for open issues

Step 2: bash-script-developer (with Filesystem + Brave Search)
  → Uses Filesystem to edit install_security_tools.sh
  → Uses Brave Search for ProjectDiscovery/httpx docs

Step 3: test-automation-engineer (with Filesystem + Git)
  → Uses Filesystem to write test_httpx()
  → Uses Git to stage changes

Step 4: security-auditor (with Filesystem + Brave + Fetch)
  → Uses Filesystem to search for "sudo" in code
  → Uses Brave to check "ProjectDiscovery httpx CVE"
  → Uses Fetch to download security advisories

Step 5: code-reviewer (with Filesystem + GitHub)
  → Uses Filesystem to generate git-style diff
  → Validates against checklist

Step 6: documentation-engineer (with Filesystem + Git)
  → Uses Filesystem to edit README.md, CHANGELOG.md
  → Uses Git to commit with proper message

Result: 70% time savings, 80% error reduction
```

### Example: Security Audit Before Release (WITH MCPs)

```
Time: 15-25 min (was 60-90 min without MCPs)

security-auditor uses:
  → Filesystem to search entire codebase for patterns
  → Brave Search to check CVEs for all 37 tools
  → Fetch to download OWASP/CIS benchmarks
  → GitHub to check dependency advisories

Result: Automated, comprehensive, fast
```

**See** `~/.claude/plans/gleaming-waddling-sketch.md` for complete MCP configuration plan.

---

## Advanced Agent Usage

### Combining Agents

For complex tasks, use agents sequentially:

```bash
# Major refactoring
> Use planner to create refactoring strategy for download_file function
> Use bash-script-developer to implement refactored function
> Use security-auditor to verify download security
> Use code-reviewer to check bash best practices
> Use test-automation-engineer to update tests
```

### Agent Customization

Agents automatically read `CLAUDE.md` for project context. To customize:

1. Add project-specific patterns to CLAUDE.md
2. Update agent `.md` files in `.claude/agents/` for permanent changes
3. Reference existing implementations when invoking agents

### Troubleshooting Agents

**Agent not following patterns?**
- Point to existing similar implementation: "See install_gobuster for reference"
- Agents read CLAUDE.md for context automatically

**Agent being too verbose?**
- Be specific: "Only implement install_httpx, don't update docs yet"

**Agent missing project context?**
- Ensure CLAUDE.md is up-to-date
- Reference specific sections: "Follow the Installation Function Pattern in CLAUDE.md"

---

## Metrics & Success Indicators

Track agent effectiveness:

- **Usage Frequency:** Agents used in >80% of tool additions
- **Error Detection:** Security/quality issues caught before merging
- **Time Savings:** >50% reduction in development time
- **Code Quality:** Zero shellcheck violations, 100% test coverage
- **Security:** Zero secrets committed, all downloads HTTPS

---

## Quick Agent Reference

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

---

**Last Updated:** December 16, 2025
**Related Files:**
- `CLAUDE.md` - Main project context
- `.claude/agents/*.md` - Individual agent configurations
- `~/.claude/plans/gleaming-waddling-sketch.md` - MCP configuration plan
