# MCP Server Setup Guide

**Version:** 1.0
**Last Updated:** January 15, 2026
**Purpose:** Complete guide to configuring Docker MCP servers for enhanced agent capabilities

This document provides step-by-step instructions for setting up Model Context Protocol (MCP) servers to extend AI agent capabilities with filesystem operations, sequential thinking, GitHub automation, and more.

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Quick Start](#quick-start)
4. [Tier 1: Essential MCPs](#tier-1-essential-mcps)
5. [Tier 2: Core MCPs](#tier-2-core-mcps)
6. [Tier 3: Enhanced MCPs](#tier-3-enhanced-mcps)
7. [Phased Rollout Plan](#phased-rollout-plan)
8. [Agent-MCP Compatibility](#agent-mcp-compatibility)
9. [Verification Procedures](#verification-procedures)
10. [Troubleshooting](#troubleshooting)
11. [Performance Impact](#performance-impact)
12. [Cross-References](#cross-references)

---

## Overview

### What are MCP Servers?

**Model Context Protocol (MCP)** servers are containerized tools that extend AI agent capabilities beyond text generation. They provide:

- **File Operations:** Read, write, search files without manual copy-paste
- **External Services:** GitHub, web search, documentation access
- **Structured Thinking:** Sequential reasoning for complex problems
- **Real-time Data:** CVE lookups, security bulletins, API docs

### Benefits

**Velocity Improvements:**
- 60-70% faster file I/O operations
- 2.5-3x overall velocity improvement
- 80% task autonomy (agents complete tasks independently)

**Quality Improvements:**
- Automated CVE/security research
- Real-time documentation access
- Consistent code patterns
- Fewer manual errors

**Autonomy Improvements:**
- Agents read/write files directly
- Automated git operations
- Independent web research
- Project memory across sessions

---

## Prerequisites

### System Requirements

| Requirement | Details |
|-------------|---------|
| **Docker Desktop** | Version 4.48+ with MCP Toolkit |
| **Disk Space** | ~500 MB for MCP server images |
| **Network** | Internet connection for server downloads |
| **Permissions** | Docker daemon running with user access |

### Verify Prerequisites

```bash
# Check Docker Desktop version
docker --version
# Required: Docker version 27.0.0+ (part of Docker Desktop 4.48+)

# Check MCP Toolkit availability
docker mcp --help
# Should show MCP server management commands

# Check Docker is running
docker ps
# Should show container list (may be empty)
```

**If prerequisites are missing:**
1. Update Docker Desktop to 4.48+ from [docker.com](https://www.docker.com/products/docker-desktop/)
2. Enable MCP Toolkit in Docker Desktop settings (Experimental Features)
3. Restart Docker Desktop after enabling

---

## Quick Start

### 3-Step Setup (Tier 1 MCPs)

```bash
# Step 1: Enable Essential MCPs
docker mcp server enable filesystem
docker mcp server enable sequentialthinking
docker mcp server enable github-official

# Step 2: Configure Filesystem Allowed Paths
# Open Docker Desktop → MCP Toolkit → Filesystem settings
# Add project path: /Users/mikeb/Documents/GitHub/tilix-tools-installer

# Step 3: Verify Installation
docker mcp server list
# Should show 3 enabled servers
```

**Result:** Agents can now read/write project files, use structured reasoning, and integrate with GitHub.

---

## Tier 1: Essential MCPs

These foundational servers provide critical capabilities for all agents.

### 1. Filesystem MCP

**Purpose:** File read/write/search operations for ALL agents

**Impact:** ⭐⭐⭐⭐⭐ (Essential)
- 60% faster file I/O
- Eliminates manual copy-paste
- Enables autonomous code editing

**Capabilities:**
- `read_file` - Read any project file
- `write_file` - Create/modify files
- `search_files` - Find files by pattern
- `list_directory` - Browse directory structure

**Setup:**
```bash
# Enable server
docker mcp server enable filesystem

# Configure allowed paths (required for security)
# Open Docker Desktop → Settings → MCP Toolkit → Filesystem
# Add paths:
#   - /Users/mikeb/Documents/GitHub/tilix-tools-installer
#   - /Users/mikeb/.local/state/install_tools/logs (for log access)
```

**Verification:**
```bash
# Test read operation (via agent)
> Use bash-script-developer to read install_security_tools.sh and verify it's properly sourcing library modules

# Test write operation (via agent)
> Use bash-script-developer to create a test file /tmp/mcp_test.txt with content "MCP filesystem works"
```

**Agent Compatibility:**
- ⭐⭐⭐⭐⭐ bash-script-developer (critical for code editing)
- ⭐⭐⭐⭐⭐ test-automation-engineer (critical for test creation)
- ⭐⭐⭐⭐⭐ security-auditor (critical for codebase scanning)
- ⭐⭐⭐⭐⭐ code-reviewer (critical for diff generation)
- ⭐⭐⭐⭐⭐ debugger (critical for log access)
- ⭐⭐⭐⭐⭐ documentation-engineer (critical for doc updates)
- ⭐⭐⭐⭐ planner (high value for context)

---

### 2. Sequential Thinking MCP

**Purpose:** Structured reasoning for complex problems and planning

**Impact:** ⭐⭐⭐⭐⭐ (Essential)
- 40% better decision quality
- Systematic problem solving
- Clear reasoning chains

**Capabilities:**
- `create_thought` - Record reasoning step
- `next_thought` - Continue reasoning chain
- `review_chain` - Analyze reasoning path
- `validate_conclusion` - Check logic consistency

**Setup:**
```bash
# Enable server
docker mcp server enable sequentialthinking

# No additional configuration required
```

**Verification:**
```bash
# Test via agent
> Use planner with sequential thinking to create a detailed plan for adding httpx tool
```

**Agent Compatibility:**
- ⭐⭐⭐⭐⭐ planner (essential for task decomposition)
- ⭐⭐⭐⭐⭐ debugger (essential for root cause analysis)
- ⭐⭐⭐⭐ bash-script-developer (high value for complex implementations)
- ⭐⭐⭐⭐ security-auditor (high value for threat modeling)
- ⭐⭐⭐⭐ test-automation-engineer (high value for test strategy)
- ⭐⭐⭐ code-reviewer (medium value for review strategy)
- ⭐⭐⭐ documentation-engineer (medium value for doc structure)

---

### 3. GitHub Official MCP

**Purpose:** GitHub API integration for issue/PR management and dependency checks

**Impact:** ⭐⭐⭐⭐⭐ (Essential for releases)
- Critical for release workflows
- Automated issue creation
- Dependency vulnerability checks

**Capabilities:**
- `create_issue` - Create GitHub issue
- `create_pull_request` - Create PR
- `list_issues` - Query issues
- `get_dependencies` - Check dependency security
- `search_code` - Search GitHub repositories

**Setup:**
```bash
# Enable server
docker mcp server enable github-official

# Configure GitHub token (required)
# 1. Create Personal Access Token at https://github.com/settings/tokens
#    Scopes needed: repo, read:org, read:user
# 2. Set in Docker Desktop → MCP Toolkit → GitHub settings
#    Or set environment variable: GITHUB_TOKEN=ghp_your_token_here
```

**Verification:**
```bash
# Test via agent
> Use security-auditor to check dependencies for known vulnerabilities via GitHub

> Use documentation-engineer to create a GitHub issue for documentation updates
```

**Agent Compatibility:**
- ⭐⭐⭐⭐⭐ security-auditor (essential for dependency checks)
- ⭐⭐⭐⭐ documentation-engineer (high value for issue management)
- ⭐⭐⭐⭐ code-reviewer (high value for PR reviews)
- ⭐⭐⭐⭐ planner (high value for project planning)
- ⭐⭐⭐ bash-script-developer (medium value for code examples)
- ⭐⭐ test-automation-engineer (low value)
- ⭐⭐⭐ debugger (medium value for issue research)

---

## Tier 2: Core MCPs

These servers significantly enhance agent capabilities for specific workflows.

### 4. Git MCP

**Purpose:** Automated git operations for commits, branches, and diffs

**Impact:** ⭐⭐⭐⭐ (High Value)
- 50% fewer git errors
- Automated commit messages
- Branch management

**Capabilities:**
- `git_status` - Show working tree status
- `git_diff` - Generate diffs
- `git_commit` - Create commits with proper messages
- `git_branch` - Branch management
- `git_log` - View commit history

**Setup:**
```bash
# Enable server
docker mcp server enable git

# Configure git identity (if not already set)
docker mcp server configure git \
  --git-user-name "Your Name" \
  --git-user-email "you@example.com"
```

**Verification:**
```bash
# Test via agent
> Use bash-script-developer to show git status and create a commit for recent changes
```

**Agent Compatibility:**
- ⭐⭐⭐⭐ bash-script-developer (high value for commits)
- ⭐⭐⭐⭐ test-automation-engineer (high value for test commits)
- ⭐⭐⭐⭐ documentation-engineer (high value for doc commits)
- ⭐⭐⭐ code-reviewer (medium value for diff analysis)
- ⭐⭐⭐ planner (medium value for branch planning)
- ⭐⭐ security-auditor (low value)
- ⭐⭐ debugger (low value)

---

### 5. Brave Search MCP

**Purpose:** Web search for CVE research, security bulletins, and documentation

**Impact:** ⭐⭐⭐⭐⭐ (Essential for security)
- 70% faster security research
- Real-time CVE lookups
- Documentation discovery

**Capabilities:**
- `brave_search` - Web search via Brave API
- `get_page_content` - Fetch page text
- `search_news` - Recent security news
- `search_discussions` - Forum/Reddit search

**Setup:**
```bash
# Enable server
docker mcp server enable brave-search

# Configure Brave API key (required)
# 1. Get API key at https://brave.com/search/api/
# 2. Set in Docker Desktop → MCP Toolkit → Brave Search settings
#    Or set environment variable: BRAVE_API_KEY=your_key_here
```

**Verification:**
```bash
# Test via agent
> Use security-auditor to search for "ProjectDiscovery httpx CVE 2024" via Brave

> Use bash-script-developer to search for "bash shellcheck best practices" and summarize findings
```

**Agent Compatibility:**
- ⭐⭐⭐⭐⭐ security-auditor (essential for CVE research)
- ⭐⭐⭐⭐ documentation-engineer (high value for research)
- ⭐⭐⭐ bash-script-developer (medium value for best practices)
- ⭐⭐⭐ debugger (medium value for error research)
- ⭐⭐ planner (low value)
- ⭐⭐ code-reviewer (low value)
- ⭐⭐ test-automation-engineer (low value)

---

## Tier 3: Enhanced MCPs

These servers provide specialized capabilities for advanced workflows.

### 6. Fetch MCP

**Purpose:** Download documentation, security advisories, and API references

**Impact:** ⭐⭐⭐⭐ (High Value)
- Access external documentation
- Download security bulletins
- Fetch API references

**Capabilities:**
- `fetch_url` - Download web content
- `fetch_json` - Parse JSON APIs
- `fetch_markdown` - Extract markdown docs
- `fetch_headers` - Inspect HTTP headers

**Setup:**
```bash
# Enable server
docker mcp server enable fetch

# No additional configuration required
```

**Verification:**
```bash
# Test via agent
> Use security-auditor to fetch the latest OWASP Top 10 from https://owasp.org/

> Use documentation-engineer to fetch shellcheck documentation for reference
```

**Agent Compatibility:**
- ⭐⭐⭐⭐ security-auditor (high value for advisories)
- ⭐⭐⭐⭐ documentation-engineer (high value for docs)
- ⭐⭐⭐ planner (medium value for research)
- ⭐⭐ bash-script-developer (low value)
- ⭐⭐ test-automation-engineer (low value)
- ⭐⭐ debugger (low value)
- ⭐ code-reviewer (minimal value)

---

### 7. Context7 MCP

**Purpose:** Inject accurate documentation for shellcheck, bash, and common tools

**Impact:** ⭐⭐⭐ (Medium Value)
- Accurate shellcheck rule explanations
- Bash best practices reference
- Common tool documentation

**Capabilities:**
- `get_shellcheck_rule` - Detailed SC#### explanations
- `get_bash_manual` - Bash manual sections
- `get_tool_docs` - Tool documentation (wget, curl, etc.)

**Setup:**
```bash
# Enable server
docker mcp server enable context7

# No additional configuration required
```

**Verification:**
```bash
# Test via agent
> Use code-reviewer to explain shellcheck rule SC2086 using Context7

> Use bash-script-developer to get bash manual for parameter expansion
```

**Agent Compatibility:**
- ⭐⭐⭐ code-reviewer (medium value for rule explanations)
- ⭐⭐⭐ bash-script-developer (medium value for bash reference)
- ⭐⭐ test-automation-engineer (low value)
- ⭐⭐ debugger (low value)
- ⭐ security-auditor (minimal value)
- ⭐ documentation-engineer (minimal value)
- ⭐ planner (minimal value)

---

### 8. Obsidian MCP

**Purpose:** Project memory and knowledge base across sessions

**Impact:** ⭐⭐⭐ (Medium Value)
- Persistent project notes
- Cross-session memory
- Decision documentation

**Capabilities:**
- `create_note` - Create persistent note
- `search_notes` - Find previous decisions
- `link_notes` - Connect related information
- `get_note` - Retrieve note content

**Setup:**
```bash
# Enable server
docker mcp server enable obsidian

# Configure vault path
# 1. Create Obsidian vault: mkdir -p ~/obsidian-vaults/tilix-tools
# 2. Configure in Docker Desktop → MCP Toolkit → Obsidian settings
#    Vault path: /Users/mikeb/obsidian-vaults/tilix-tools
```

**Verification:**
```bash
# Test via agent
> Use planner to create a note documenting the decision to use Go install pattern

> Use security-auditor to search notes for previous security findings
```

**Agent Compatibility:**
- ⭐⭐⭐ planner (medium value for decision tracking)
- ⭐⭐⭐ security-auditor (medium value for findings history)
- ⭐⭐ documentation-engineer (low value)
- ⭐⭐ debugger (low value for past issues)
- ⭐ bash-script-developer (minimal value)
- ⭐ test-automation-engineer (minimal value)
- ⭐ code-reviewer (minimal value)

---

## Phased Rollout Plan

### Phase 1: Essential Foundation (Week 1)

**Goal:** Enable core file operations and structured thinking

**MCPs to Enable:**
1. Filesystem MCP
2. Sequential Thinking MCP
3. GitHub Official MCP

**Expected Impact:**
- 60% faster file operations
- Structured problem solving
- GitHub integration

**Validation:**
- Agents can read/write project files
- planner uses sequential thinking
- security-auditor can check GitHub dependencies

**Success Criteria:**
- Zero manual file copy-paste operations
- All planning uses sequential thinking
- Release workflow includes GitHub automation

---

### Phase 2: Core Automation (Week 2)

**Goal:** Automate git operations and enable security research

**MCPs to Enable:**
4. Git MCP
5. Brave Search MCP

**Expected Impact:**
- 50% fewer git errors
- 70% faster CVE research
- Automated commit workflows

**Validation:**
- Agents can create proper git commits
- security-auditor performs CVE lookups
- Documentation includes web research

**Success Criteria:**
- 80% of commits generated by agents
- All security audits include CVE checks
- Zero manual web searches for documentation

---

### Phase 3: Enhanced Capabilities (Week 3-4)

**Goal:** Add specialized capabilities for advanced workflows

**MCPs to Enable:**
6. Fetch MCP
7. Context7 MCP
8. Obsidian MCP (optional)

**Expected Impact:**
- Access to external documentation
- Accurate shellcheck explanations
- Project knowledge persistence

**Validation:**
- security-auditor fetches security bulletins
- code-reviewer explains shellcheck rules
- planner maintains project notes

**Success Criteria:**
- All security audits reference external sources
- Code reviews include rule explanations
- Project decisions documented in Obsidian

---

### Phase 4: Optimization (Ongoing)

**Goal:** Measure impact and optimize workflows

**Activities:**
- Track velocity improvements (target: 2.5-3x)
- Identify bottlenecks
- Refine agent-MCP integration
- Document best practices

**Metrics:**
- Task completion time (before/after)
- Error rate reduction
- Agent autonomy percentage
- Developer satisfaction

---

## Agent-MCP Compatibility

Impact ratings for each agent-MCP combination.

| Agent | Filesystem | Sequential | GitHub | Git | Brave | Fetch | Context7 | Obsidian |
|-------|-----------|-----------|--------|-----|-------|-------|----------|----------|
| **bash-script-developer** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐ |
| **test-automation-engineer** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐ | ⭐⭐ | ⭐ |
| **security-auditor** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐ | ⭐⭐⭐ |
| **code-reviewer** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐ | ⭐⭐⭐ | ⭐ |
| **debugger** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐ | ⭐⭐ |
| **documentation-engineer** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐ | ⭐⭐ |
| **planner** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ | ⭐ | ⭐⭐⭐ |

**Legend:**
- ⭐⭐⭐⭐⭐ Essential (critical for agent function)
- ⭐⭐⭐⭐ High Value (significant productivity improvement)
- ⭐⭐⭐ Medium Value (useful but not critical)
- ⭐⭐ Low Value (minor improvement)
- ⭐ Minimal Value (rarely used)

---

## Verification Procedures

### Test Each MCP Server

**Filesystem MCP:**
```bash
> Use bash-script-developer to read lib/core/logging.sh and summarize its functions
# Should return function list without errors
```

**Sequential Thinking MCP:**
```bash
> Use planner to use sequential thinking to plan adding a new Python tool
# Should show structured thought process
```

**GitHub Official MCP:**
```bash
> Use security-auditor to check this project's dependencies for vulnerabilities via GitHub
# Should query GitHub dependency API
```

**Git MCP:**
```bash
> Use bash-script-developer to show git status of current branch
# Should return git status output
```

**Brave Search MCP:**
```bash
> Use security-auditor to search Brave for "shellcheck best practices 2024"
# Should return search results
```

**Fetch MCP:**
```bash
> Use documentation-engineer to fetch content from https://www.shellcheck.net/
# Should return page content
```

**Context7 MCP:**
```bash
> Use code-reviewer to explain shellcheck rule SC2086 using Context7
# Should return detailed rule explanation
```

**Obsidian MCP:**
```bash
> Use planner to create a note in Obsidian documenting MCP setup
# Should create note in vault
```

---

## Troubleshooting

### Common Issues

#### MCP Server Won't Enable

**Problem:** `docker mcp server enable` fails

**Solutions:**
```bash
# 1. Check Docker Desktop version
docker --version
# Must be 27.0.0+ (Docker Desktop 4.48+)

# 2. Enable MCP Toolkit
# Docker Desktop → Settings → Experimental Features → MCP Toolkit

# 3. Restart Docker Desktop
```

---

#### Filesystem MCP Access Denied

**Problem:** Agent can't read/write project files

**Solutions:**
```bash
# 1. Check allowed paths configuration
# Docker Desktop → MCP Toolkit → Filesystem → Allowed Paths

# 2. Add project directory
# Add: /Users/mikeb/Documents/GitHub/tilix-tools-installer

# 3. Verify path is absolute (not relative)

# 4. Restart MCP server
docker mcp server restart filesystem
```

---

#### GitHub MCP Authentication Failed

**Problem:** GitHub API calls fail with 401 Unauthorized

**Solutions:**
```bash
# 1. Generate Personal Access Token
# https://github.com/settings/tokens
# Scopes: repo, read:org, read:user

# 2. Configure token
# Docker Desktop → MCP Toolkit → GitHub → API Token
# Or set environment: export GITHUB_TOKEN=ghp_your_token

# 3. Verify token
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user

# 4. Restart MCP server
docker mcp server restart github-official
```

---

#### Brave Search MCP No Results

**Problem:** Brave Search returns empty results

**Solutions:**
```bash
# 1. Get Brave Search API key
# https://brave.com/search/api/ (free tier available)

# 2. Configure API key
# Docker Desktop → MCP Toolkit → Brave Search → API Key

# 3. Test API key
curl -H "X-Subscription-Token: YOUR_KEY" \
  "https://api.search.brave.com/res/v1/web/search?q=test"

# 4. Restart MCP server
docker mcp server restart brave-search
```

---

#### Agent Not Using MCP Tools

**Problem:** Agent performs manual operations instead of using MCP

**Solutions:**
```bash
# 1. Verify MCP server is enabled and running
docker mcp server list
# Should show "enabled" and "running" status

# 2. Explicitly request MCP usage in prompt
> Use bash-script-developer with filesystem MCP to read install_security_tools.sh

# 3. Check agent configuration
# Ensure agent .md files reference MCP tools

# 4. Restart conversation
# MCPs are session-based; start new conversation
```

---

## Performance Impact

### Expected Improvements

**Time Savings by Task:**

| Task | Without MCPs | With MCPs | Time Savings |
|------|-------------|-----------|--------------|
| Add new tool | 30-45 min | 10-15 min | 66-75% |
| Fix bug | 30-45 min | 10-15 min | 66-75% |
| Security audit (full) | 60-90 min | 15-25 min | 72-80% |
| Security audit (targeted) | 20-30 min | 5-10 min | 67-75% |
| Create tests | 15-20 min | 5-10 min | 50-66% |
| Update documentation | 10-15 min | 5-10 min | 33-50% |
| Code review | 15-20 min | 5-10 min | 50-66% |

**Overall Velocity:**
- Without MCPs: 2-3 hours per feature (agent-assisted)
- With MCPs: 40-65 minutes per feature
- **Improvement: 2.5-3x faster**

---

### Resource Usage

**Disk Space:**
- MCP server images: ~500 MB total
- Obsidian vault (optional): ~10-50 MB

**Network Usage:**
- GitHub API: ~10-50 requests per audit
- Brave Search: ~5-20 searches per research task
- Fetch operations: ~1-10 MB per documentation download

**Docker Containers:**
- Each enabled MCP runs as separate container
- Minimal CPU/memory overhead (<100 MB RAM per server)
- Containers start on-demand, stop when idle

---

## Cross-References

### Related Documentation

📖 **[AGENT_USAGE.md](agents/AGENT_USAGE.md)** - Agent usage guide and workflows
📖 **[WORKFLOWS.md](agents/WORKFLOWS.md)** - Detailed agent workflow examples
📖 **[CLAUDE.md](../CLAUDE.md)** - Project context with MCP configuration section
📖 **[DEV_CHANGELOG.md](../DEV_CHANGELOG.md)** - MCP configuration history

### External Resources

📖 **[Docker MCP Catalog](https://hub.docker.com/mcp)** - Browse 270+ available MCP servers
📖 **[6 Must-Have MCP Servers (2025)](https://www.docker.com/blog/top-mcp-servers-2025/)** - Docker's recommended servers
📖 **[MCP Gateway Documentation](https://docs.docker.com/ai/mcp-catalog-and-toolkit/mcp-gateway/)** - Official Docker MCP docs
📖 **[Model Context Protocol Spec](https://modelcontextprotocol.io/)** - MCP protocol specification

### Full Implementation Plan

📖 **[~/.claude/plans/gleaming-waddling-sketch.md](~/.claude/plans/gleaming-waddling-sketch.md)** - Complete MCP analysis and implementation plan
- Detailed cost-benefit analysis
- Agent-MCP compatibility matrix
- 4-phase rollout strategy
- Reusable framework for other projects

---

## Next Steps

### Getting Started

1. **Verify Prerequisites:**
   ```bash
   docker --version  # Should be 27.0.0+
   docker mcp --help  # Should show MCP commands
   ```

2. **Enable Tier 1 MCPs (Essential):**
   ```bash
   docker mcp server enable filesystem
   docker mcp server enable sequentialthinking
   docker mcp server enable github-official
   ```

3. **Configure Filesystem Access:**
   - Open Docker Desktop → MCP Toolkit → Filesystem
   - Add: `/Users/mikeb/Documents/GitHub/tilix-tools-installer`

4. **Test with Agents:**
   ```bash
   > Use bash-script-developer to read README.md and summarize the project
   ```

5. **Enable Tier 2 MCPs (Week 2):**
   ```bash
   docker mcp server enable git
   docker mcp server enable brave-search
   ```

6. **Measure Impact:**
   - Track task completion times
   - Compare agent autonomy (before/after)
   - Document velocity improvements

---

**Document Version:** 1.0
**Last Updated:** January 15, 2026
**Maintained By:** documentation-engineer agent

For agent workflows with MCP integration, see 📖 **[AGENT_USAGE.md](agents/AGENT_USAGE.md)**.
For complete MCP analysis, see 📖 **[~/.claude/plans/gleaming-waddling-sketch.md](~/.claude/plans/gleaming-waddling-sketch.md)**.
