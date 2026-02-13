# Changelog

All notable changes to this project are documented here.

## [Unreleased]

### Added
- New idempotent user-space preflight script: `scripts/preflight_env.sh` (`--dry-run`, `--verbose`).
- Comparison guide: `docs/PREFLIGHT_VS_XDG_SETUP.md`.

### Changed
- `install_security_tools.sh` now runs `scripts/preflight_env.sh` during preflight when available.
- README and user-space docs now point to explicit preflight usage.

### Removed / Relocated
- Legacy modular framework moved from `lib/` to `.internal/legacy/lib/`.
- Legacy diagnostics moved from `scripts/diagnose_installation.sh` and `scripts/test_installation.sh` to `.internal/legacy/`.

## [2.1.0] - 2026-02-12

### Added
- Customer-ready installer entrypoints: `installer.sh` and `install_security_tools.sh`.
- Built-in tool install support for `waybackurls` and `assetfinder` in user space.
- Extension scaffold in `scripts/tools.d/example_custom_tool.sh`.
- README updates for install, verification, extension, and troubleshooting flow.

### Changed
- Documentation now aligns with a public release baseline and non-sudo environments.

## [2.0.0] - 2026-02-12

### Added
- Major documentation refresh for user-space first usage.
- New maintainer policy baseline in `CLAUDE.md`.
- User-space install guide and custom tool template docs.

### Notes
- This release consolidated prior 1.3.x operational improvements into a major documentation line.
