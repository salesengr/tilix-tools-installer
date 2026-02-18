# Validation Results (2026-02-18, arm64 host with amd64 image emulation)

## Scope
Validation of legacy tools from `scripts/manifests/legacy_tools_d870fee.tsv` using:
- image: `sha256:8e4fb43f5d6a26787318202abb852520039f547807811b7fd13e19fde4137e89`
- branch: `recovery/tool-install-validation`
- harness: `scripts/docker_validate_tools.sh`

## Summary
Full matrix run directory:
- `.tmp/docker-validation-20260218-003811`

Result:
- pass: `27`
- fail: `9`
- skip: `0`

## Failed Tools (from full matrix)
- `nuclei`
- `trufflehog`
- `git-hound`
- `feroxbuster`
- `rustscan`
- `fd`
- `bat`
- `tokei`
- `dog`

## Findings
- On this host, Docker runs the target image as `linux/amd64` under arm64 emulation.
- Go/Rust compile-heavy tools are prone to very long compile times and timeout/failure behavior in emulation.
- `trufflehog` and `git-hound` failures need Intel-native reruns for definitive diagnosis because logs in this run cut off after npm-install start.

## Snapshot Work Completed
A Rust-preinstalled snapshot was created for targeted Rust-tool testing:
- tag: `tilix-app:rust-preinstalled-20260218`
- image id: `sha256:64bf288381c5d72be3beef761c67bdcf4afc9b4de9bb03657f3f3752ec8845db`

Related run directory:
- `.tmp/docker-validation-20260218-005439`

## Artifacts Added In This Branch
- `scripts/generate_tool_manifest.sh`
- `scripts/docker_validate_tools.sh`
- `scripts/manifests/legacy_tools_d870fee.tsv`
- `docs/INTEL_VALIDATION_PLAN.md`
- `docs/VALIDATION_RESULTS_20260218_ARM64.md`

## Next Execution Target
Use native Intel/amd64 Docker host and follow:
- `docs/INTEL_VALIDATION_PLAN.md`
