# Preflight Script vs `xdg_setup.sh`

This document clarifies when to use the new customer-facing preflight script and how it differs from the older `xdg_setup.sh` workflow.

## TL;DR

- Use `scripts/preflight_env.sh` before installs (or rely on installer auto-preflight).
- Treat `xdg_setup.sh` as a legacy environment bootstrap script, not part of the default customer flow.

## Comparison

| Area | `scripts/preflight_env.sh` | `xdg_setup.sh` |
|---|---|---|
| Scope | Minimal install-readiness checks for current installer flow | Broad shell/XDG bootstrap and profile guidance |
| Side effects | Only creates missing user directories and reports state | Performs larger environment setup and prints shell mutation steps |
| Environment mutation | No persistent shell/profile mutation | Designed around exporting/appending environment settings |
| Idempotency | Explicitly idempotent (`exists -> report`, else create) | Partially idempotent, but broader setup intent and mutation surface |
| Failure model | Fast fail on missing required commands or non-writable user paths | Mixed setup/reporting flow; not optimized for current installer preflight |
| Recommended usage | Customer-safe default precheck (`bash scripts/preflight_env.sh`) | Legacy/advanced/manual use only |

## Recommended usage

### Standard customer workflow

```bash
bash scripts/preflight_env.sh
bash installer.sh all
```

`install_security_tools.sh` also invokes `scripts/preflight_env.sh` automatically when present.

### When to use `xdg_setup.sh`

Only if you specifically need the legacy environment bootstrap behavior and understand its wider shell/environment impact.

## Notes for maintainers

- Keep `preflight_env.sh` focused on install prerequisites and user-space writability.
- Avoid adding persistent profile edits to preflight.
- Keep `xdg_setup.sh` out of default docs/quickstart paths.
