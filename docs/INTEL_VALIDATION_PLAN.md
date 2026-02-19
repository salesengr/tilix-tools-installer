# Intel Validation Plan (Post-Emulation)

## Status Update (2026-02-18)
- ✅ Intel native full-matrix execution completed.
- ✅ Result: `36/36` pass, `0` fail.
- ✅ Run artifacts: `.tmp/docker-validation-20260218-163121-full-matrix`

Remaining recommendation(s):
- Add checksum/signature verification for release-binary fallback downloads (`trufflehog`, `git-hound`, `dog`) to strengthen supply-chain assurance.

## Goal
Complete validation of remaining legacy tool installs on a native Intel/amd64 Docker host to avoid arm64 emulation slowness and false failures.

## Baseline Context
- Baseline image digest:
  - `sha256:8e4fb43f5d6a26787318202abb852520039f547807811b7fd13e19fde4137e89`
- Current full-matrix status from emulated run:
  - `pass: 27`
  - `fail: 9`
- Remaining tools to validate/fix:
  - `nuclei`
  - `trufflehog`
  - `git-hound`
  - `feroxbuster`
  - `rustscan`
  - `fd`
  - `bat`
  - `tokei`
  - `dog`

## Core Rule
Before testing each remaining tool, create a dedicated Docker snapshot image that already includes **all required prerequisites** for that tool.

If multiple prerequisites are needed (example: both Rust and Node), install them all in the same snapshot before testing the tool.

## Prerequisite Matrix
- `nuclei`
  - Required prereqs in snapshot: `go` runtime/toolchain available and PATH configured for GOPATH bin.
- `trufflehog`
  - Required prereqs in snapshot: `nodejs` + `npm` + PATH includes Node and user bin.
- `git-hound`
  - Required prereqs in snapshot: `nodejs` + `npm` + PATH includes Node and user bin.
- `feroxbuster`
  - Required prereqs in snapshot: `rust`/`cargo` + PATH includes Cargo bin.
- `rustscan`
  - Required prereqs in snapshot: `rust`/`cargo` + PATH includes Cargo bin.
- `fd`
  - Required prereqs in snapshot: `rust`/`cargo` + PATH includes Cargo bin.
- `bat`
  - Required prereqs in snapshot: `rust`/`cargo` + PATH includes Cargo bin.
- `tokei`
  - Required prereqs in snapshot: `rust`/`cargo` + PATH includes Cargo bin.
- `dog`
  - Required prereqs in snapshot: `rust`/`cargo` + PATH includes Cargo bin.

## Snapshot Naming Convention
Use deterministic, per-tool tags:
- `tilix-app:intel-precheck-<tool>-<YYYYMMDD>`

Examples:
- `tilix-app:intel-precheck-nuclei-20260218`
- `tilix-app:intel-precheck-trufflehog-20260218`
- `tilix-app:intel-precheck-feroxbuster-20260218`

## Execution Workflow

### 1) Move to Intel Host
- Confirm Docker host architecture is amd64.
- Ensure repository branch is `recovery/tool-install-validation`.

### 2) For each remaining tool
1. Start from baseline image digest.
2. Run bootstrap in container:
   - `bash xdg_setup.sh`
   - source shell profile
3. Install all prerequisites for the target tool:
   - example: `bash install_security_tools.sh nodejs`
   - example: `bash install_security_tools.sh rust`
4. Commit container as tool-specific snapshot tag.
5. Run fresh-container validation from that snapshot:
   - `bash install_security_tools.sh <tool>`
   - smoke check for installed command/path.
6. Save logs under `.tmp/docker-validation-<timestamp>/`.

### 3) If a tool fails
- Classify failure type:
  - installer logic error
  - upstream/source/package issue
  - smoke-check mismatch
- Patch minimally (no large restructure).
- Re-run only that tool on its snapshot.
- Then run a focused regression check for same ecosystem.

## Regression Rules (No Restructure Phase)
For every tool fix:
- Re-test fixed tool.
- Re-test its prerequisite installer command(s).
- Re-test one previously passing tool in same ecosystem.

Example:
- Fix `git-hound`:
  - re-test `git-hound`
  - re-test `nodejs`
  - re-test `jwt-cracker`

## Required Artifacts to Maintain
- `scripts/manifests/legacy_tools_d870fee.tsv` remains source-of-truth tool list.
- Keep a run ledger (append-only) with:
  - tool
  - snapshot tag/digest
  - prerequisites baked in
  - pass/fail
  - log path
  - notes

Suggested ledger file:
- `docs/INTEL_VALIDATION_RUN_LOG.md`

## Completion Criteria
- All 9 remaining tools pass on native Intel Docker.
- No legacy tool is removed from install paths.
- `install all` behavior still includes legacy tool set.
- Only then move to “add new tools” work; modular restructuring remains a later phase.

## Completion Status (2026-02-18)
Status: ✅ Completed for current validation scope.

Evidence:
- Intel full-matrix run log dir: `.tmp/docker-validation-20260218-163121-full-matrix`
- Reported result: `pass: 36`, `fail: 0`, `skip: 0`
- Branch includes fallback hardening for `trufflehog`, `git-hound`, and `dog` (`1ccbaa8`).

Recommended next action:
- Treat this validation phase as closed and transition to the next planned phase (new tools and/or modular improvements) in a separate scoped branch.

## Completion Check (2026-02-18)
- Criteria met for Intel validation phase.
- Recommended follow-up is hardening-only (checksum/signature verification for fallback binaries), not functional blocker work.
