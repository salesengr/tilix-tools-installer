# Security Tools Installer - Agent Configuration

A specialized set of 7 subagents tailored for bash-based security tool installation and maintenance. This configuration is optimized for the specific needs of this project: user-space installations, shellcheck compliance, security auditing, and systematic testing.

## Agents Included

| Agent | Purpose | Tools | Status |
|-------|---------|-------|--------|
| **planner** | Task decomposition & delegation | Read-only | Orchestration agent - use for complex multi-step tasks |
| **bash-script-developer** | Bash scripting specialist | Full | NEW - replaces generic fullstack-developer with bash expertise |
| **test-automation-engineer** | Test generation & validation | Full | NEW - creates tests following project patterns |
| **security-auditor** | Security review & vulnerability scanning | Read + WebSearch | NEW - bash security & download verification |
| **code-reviewer** | Code quality analysis | Read-only | ENHANCED - added bash & security criteria |
| **debugger** | Bug investigation & fixing | Full | Systematic hypothesis testing |
| **documentation-engineer** | Docs & technical writing | Full + Web | Updates README, CHANGELOG, guides |

### Agent Status

**Active Agents:** 7 (in .claude/agents/)
**Disabled Agents:** 1 (in .claude/agents/disabled/)
- fullstack-developer (generic web dev - not needed for bash project)

## Project-Specific Workflows

### Workflow 1: Adding a New Security Tool

**Use case:** Adding httpx reconnaissance tool from ProjectDiscovery

```
Step 1: Planning
> Use planner to create a plan for adding httpx tool

Step 2: Implementation
> Use bash-script-developer to implement install_httpx() function

Step 3: Testing
> Use test-automation-engineer to create test_httpx() function

Step 4: Security Review
> Use security-auditor to check download mechanism and user-space compliance

Step 5: Code Review
> Use code-reviewer to verify bash best practices

Step 6: Documentation
> Use documentation-engineer to update README.md and CHANGELOG.md
```

**Expected Time Savings:** ~60% compared to manual process
**Quality Improvements:** Catches shellcheck issues, security vulnerabilities, missing tests

### Workflow 2: Debugging Installation Failure

**Use case:** nuclei installation failing with 'command not found'

```
Step 1: Investigation
> Use debugger to investigate nuclei installation failure

Step 2: Validation
> Use test-automation-engineer to run test_nuclei() after fix

Step 3: Review
> Use code-reviewer to ensure fix doesn't introduce regressions
```

**Expected Time Savings:** ~50% compared to trial-and-error
**Learning:** Root cause documented for future similar issues

### Workflow 3: Security Audit Before Release

**Use case:** Preparing v2.1.0 release

```
Step 1: Security Scan
> Use security-auditor to audit codebase before v2.1.0 release

Step 2: Code Quality Review
> Use code-reviewer to check bash best practices compliance

Step 3: Test Coverage
> Use test-automation-engineer to verify all tools have tests

Step 4: Documentation Review
> Use documentation-engineer to check CHANGELOG and version sync
```

**Expected Time Savings:** ~70% compared to manual review
**Risk Reduction:** Catches security issues before public release

## Agent Specializations

### bash-script-developer

**When to use:**
- Adding new tool installation functions
- Refactoring existing bash code
- Implementing generic installers
- Creating utility functions

**Specializations:**
- Shellcheck compliance (SC2086, SC2155, SC2046)
- Proper quoting and word splitting
- Error handling (set -e vs set +e, return codes)
- Portable scripting
- XDG Base Directory compliance
- User-space only patterns

**Example invocations:**
- "Add a bash function to install httpx"
- "Refactor the download_file function"
- "Create a generic Rust tool installer"

### test-automation-engineer

**When to use:**
- Generating test functions for new tools
- Creating integration tests
- Validating error scenarios
- Checking test coverage

**Specializations:**
- Follows project test patterns (test_result function)
- Generic test functions (test_python_tool, test_go_tool)
- Integration testing
- Dry-run validation

**Example invocations:**
- "Create tests for httpx tool"
- "Generate integration tests for Go dependencies"
- "Check which tools are missing tests"

### security-auditor

**When to use:**
- Before releases
- After adding download mechanisms
- When modifying credential handling
- Security review of new code

**Specializations:**
- Download verification (HTTPS, file existence)
- Secret detection (API keys, tokens)
- Privilege escalation prevention (no sudo)
- Supply chain security
- Hardcoded path detection

**Example invocations:**
- "Security audit the install_httpx function"
- "Check for hardcoded credentials in all scripts"
- "Verify all downloads use HTTPS"

### code-reviewer (Enhanced for Bash)

**When to use:**
- After implementing new features
- Before merging code
- Proactively after changes

**New bash-specific checks:**
- Shellcheck compliance
- Proper quoting
- Error handling
- XDG compliance
- No sudo usage
- HTTPS-only downloads
- Project pattern adherence

**Example invocations:**
- "Review the install_httpx function"
- "Check install_security_tools.sh for bash anti-patterns"

## Installation

This configuration is already installed in this project at `.claude/agents/`.

### Enabling Disabled Agents

If you need fullstack-developer for other projects:

```bash
mv .claude/agents/disabled/fullstack-developer.md .claude/agents/
```

### Creating Custom Agents

Create a new `.md` file in `.claude/agents/`:

```markdown
---
name: my-custom-agent
description: What this agent does
tools: Read, Glob, Grep
---

You are a [role]. Your job is to [purpose].

[Instructions, checklists, patterns...]
```

## Usage Patterns

### Pattern 1: New Tool (Full Workflow)

```
1. > Use planner to plan adding [tool]
2. > Use bash-script-developer to implement
3. > Use test-automation-engineer to create tests
4. > Use security-auditor to audit
5. > Use code-reviewer to review
6. > Use documentation-engineer to update docs
```

### Pattern 2: Quick Fix (Minimal Workflow)

```
1. > Use bash-script-developer to fix [issue]
2. > Use code-reviewer to verify fix
```

### Pattern 3: Release Prep (Quality Gates)

```
1. > Use security-auditor for full audit
2. > Use code-reviewer for quality check
3. > Use test-automation-engineer to verify coverage
4. > Use documentation-engineer to prep release notes
```

## Project-Specific Guidelines

### Always Use These Agents Proactively

1. **code-reviewer** - After ANY bash code changes (security critical)
2. **security-auditor** - Before releases or after download mechanism changes
3. **test-automation-engineer** - When adding new tools (test coverage critical)

### Agent Priority for Common Tasks

**Adding a tool:**
1. planner (plan the addition)
2. bash-script-developer (implement)
3. test-automation-engineer (test)
4. security-auditor (secure)
5. code-reviewer (quality)
6. documentation-engineer (document)

**Fixing a bug:**
1. debugger (investigate & fix)
2. code-reviewer (verify fix)

**Refactoring:**
1. planner (strategy)
2. bash-script-developer (implement)
3. code-reviewer (verify)
4. test-automation-engineer (ensure tests pass)

## Critical Project Constraints

All agents are aware of these constraints:

1. **NO sudo/root** - All installations must be user-space only
2. **HTTPS only** - All downloads must use HTTPS
3. **XDG compliance** - Use XDG Base Directory variables
4. **Error handling** - Explicit return code checking (set +e project style)
5. **Logging** - All operations logged to ~/.local/state/install_tools/logs/
6. **Testing** - All tools must have corresponding test functions
7. **Security** - No hardcoded credentials, verify downloads

## Tool Permissions Explained

- **Read-only agents** (planner, code-reviewer, security-auditor)
  - Cannot modify code
  - Safe to use liberally
  - Good for analysis and recommendations

- **Full access agents** (bash-script-developer, test-automation-engineer, debugger, documentation-engineer)
  - Can read, write, edit, and execute
  - Use for implementation and fixes
  - Review changes before committing

## Integration with Project Tools

### Shellcheck Integration

code-reviewer and bash-script-developer are aware of shellcheck rules:

```bash
# Run shellcheck before committing
shellcheck install_security_tools.sh test_installation.sh xdg_setup.sh
```

### Test Execution

test-automation-engineer creates tests compatible with:

```bash
# Run all tests
bash test_installation.sh

# Run specific test
bash test_installation.sh toolname
```

### Security Scanning

security-auditor recommendations align with project security model:

```bash
# Quick security check
grep -n "sudo\|http://\|API_KEY.*=" *.sh
```

## Tips for This Project

1. **Use planner first** - Complex tasks benefit from planning
2. **Security is critical** - Always run security-auditor before releases
3. **Test everything** - Use test-automation-engineer for all new tools
4. **Follow patterns** - bash-script-developer knows project conventions
5. **Document changes** - documentation-engineer maintains consistency

## Metrics & Success Indicators

Track agent effectiveness:

- **Usage Frequency:** Agents used in >80% of tool additions
- **Error Detection:** Issues caught before merging
- **Time Savings:** >50% reduction in development time
- **Quality:** Zero shellcheck violations, 100% test coverage
- **Security:** Zero secrets committed, all downloads HTTPS

## Troubleshooting

### Agent Not Following Project Patterns

**Issue:** Agent generates code that doesn't match existing style

**Solution:**
- Agents read CLAUDE.md for project context
- Point agent to similar existing implementations
- Use bash-script-developer for bash-specific patterns

### Security Agent False Positives

**Issue:** security-auditor flags valid patterns

**Solution:**
- Review finding context
- Explain why pattern is safe
- Update security-auditor.md if needed

### Test Agent Over-Testing

**Issue:** test-automation-engineer creates too many tests

**Solution:**
- Focus on critical paths: "Test only command existence and --help"
- Reference existing simple tests as examples

## Future Enhancements

Potential additions:

1. **Pre-commit hook agent** - Automate shellcheck and security checks
2. **CI/CD agent** - Generate GitHub Actions workflows
3. **Release automation agent** - Handle version bumps and changelogs

## Documentation

- **Project context:** See CLAUDE.md (comprehensive AI assistant guide)
- **Development guide:** See docs/EXTENDING_THE_SCRIPT.md
- **Usage guide:** See docs/script_usage.md
- **Agent details:** Each agent has detailed instructions in its .md file

## Contributing

When modifying agents:

1. Test changes on actual tasks
2. Update this README with new patterns
3. Document specializations added
4. Share effective workflows with team

---

**Agent Configuration Version:** 2.0
**Last Updated:** December 12, 2025
**Project:** Security Tools Installer v1.0.1
**Based on:** [VoltAgent awesome-claude-code-subagents](https://github.com/VoltAgent/awesome-claude-code-subagents), heavily customized for bash security tool development
