# Repository Startup Rules

These rules apply when working on legacy installer validation in this repository.

## Current Working Branch
- Use `recovery/tool-install-validation` unless explicitly directed otherwise.

## Validation Constraints
- Do not perform large installer restructures during validation phase.
- Keep changes minimal and behavior-preserving.
- Preserve legacy tool coverage; do not remove existing tool install paths.

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

## Required References
- Plan: `docs/INTEL_VALIDATION_PLAN.md`
- Latest results: `docs/VALIDATION_RESULTS_20260218_ARM64.md`
