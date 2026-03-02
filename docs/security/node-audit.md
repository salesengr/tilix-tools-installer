# Node Security Audit Coverage

This repo installs Node-based tools through two possible paths:

1. **npm package install path**
2. **release-binary fallback path** (when npm package install fails)

Because of that, npm audit coverage can be partial if packages are unavailable in the active registry.

## Audit script

Use:

```bash
scripts/node_security_audit.sh
```

Optional custom registry:

```bash
NPM_REGISTRY_URL=https://registry.npmjs.org scripts/node_security_audit.sh
```

Output report: `node-audit-report.json`

## Interpreting results

- `available_packages`: covered by npm lockfile + npm audit
- `unavailable_packages`: not resolvable in current registry; not covered by npm audit
- `audit_summary`: npm vulnerability counts for covered packages

## Policy

If a package is unavailable in registry, treat npm audit as **incomplete** and rely on:
- release source verification (checksums/signatures)
- fixed version tracking for fallback binaries
- periodic advisory review for fallback tools
