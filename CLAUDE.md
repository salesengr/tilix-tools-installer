# CLAUDE.md

Repository maintenance rules for **tilix-tools-installer**.

## Project Intent and Evolution (Introspection)

### Original intent
Provide a practical installer/maintenance toolkit for developer tools in constrained Linux environments (including user-space/non-root contexts), with clear operational docs.

### Recurring failure patterns observed
1. **Root-first assumptions** (`sudo`, `/usr/local`, system package writes) made workflows brittle in restricted environments.
2. **Missing preflight checks** caused late failures (unsupported architecture, missing downloader, missing tar/unzip).
3. **PATH drift** (install succeeds but binary not discoverable in current shell).
4. **Version/update ambiguity** (latest-only behavior, no explicit pin/upgrade policy).
5. **Docs lagging implementation** (scripts evolve but docs and troubleshooting do not).

### Guardrails that would have prevented most issues
- Mandatory preflight function in all install/update scripts.
- Explicit user-space default install root (`$HOME/.local` unless overridden).
- Post-install wrapper validation + `command -v` verification.
- Stable version policy and recorded source URL/checksum where feasible.
- Docs-sync required for any behavior change (PR/release gate).

### Standards for future changes
- Prefer additive, backwards-compatible changes.
- Ship scripted checks before adding new tool installers.
- Never merge script changes without syntax check and dry-run evidence.
- Update user docs in same change set as script behavior updates.

---

## Repo Rules (Authoritative)

### 1) User-space installs (no sudo assumptions)
- Default install prefix: `${TOOLS_PREFIX:-$HOME/.local}`.
- Do not assume write access outside `$HOME`.
- `sudo` must be optional and never required for default flow.
- If system packages are needed, provide user-space alternatives and clearly document limitations.

### 2) Dependency preflight checks
Every executable installer script must implement and call preflight checks for:
- OS + architecture support.
- Required commands (`curl`/`wget`, `tar`, `unzip`, `sha256sum` where used).
- Network/source reachability with actionable error output.
- Destination directory writability and free space sanity.

### 3) PATH verification and wrapper validation
Post-install checks must verify:
- Installed executable exists and is executable.
- `command -v <tool>` resolves either directly or after documented PATH export.
- Wrapper scripts (if used) have valid shebang, executable bit, and pass `shellcheck`/`bash -n` where applicable.
- Print exact shell snippet users can add to profile files.

### 4) Versioning/update policy
- Support explicit version pin (env var or arg), and a documented default version behavior.
- Log installed version after success.
- Upgrades must be idempotent and safe if same version already present.
- Breaking installer behavior requires release note entry.

### 5) Test/verification expectations
For script changes, run at minimum:
- `bash -n` on all shell scripts.
- Link/format checks for changed Markdown docs.
- Basic install smoke path in user-space (`$HOME/.local`) in clean shell.

### 6) Docs sync expectations
Any change in script behavior must update at least one of:
- `README.md`
- `docs/USER_SPACE_INSTALLS.md`
- tool-specific doc page (if present)

PR/commit should mention docs impacted.

---

## Collaboration Mode: Sub-Agent-First (Authoritative)

This repository is operated in **sub-agent-first mode** by default.

### Default behavior
- Delegate non-trivial implementation, audits, and documentation passes to sub-agents.
- Keep the main session focused on coordination, prioritization, and user interaction.
- Use parallel sub-agents for independent workstreams when beneficial.

### Main-session coordinator checklist
Before delegating:
1. Define scope, acceptance criteria, and constraints.
2. Specify required validations (syntax checks, smoke tests, link checks).
3. Require commit(s) with clear messages.

After completion:
1. Review outputs for correctness and customer-facing quality.
2. Confirm docs-sync and changelog impact.
3. Return concise summary with files changed + commit hash(es).

### Exceptions
Main session may execute directly only for:
- tiny/surgical edits,
- quick status/inspection commands,
- fast clarifications that are cheaper than delegation.

If direct work grows beyond a short task, switch back to sub-agent execution.

## Reusable Agent/Skill/Rule Patterns that would help
If automation agents are used for this repo, reusable capabilities should include:
- **preflight-check skill**: standardized dependency and environment checks.
- **path-health skill**: post-install PATH and wrapper verification.
- **docs-sync rule**: blocks completion if behavior changed but docs unchanged.
- **release-note rule**: requires version/update note for breaking changes.
- **customer-docs lint rule**: avoid internal/session language in public docs.
