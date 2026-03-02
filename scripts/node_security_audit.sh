#!/usr/bin/env bash
set -euo pipefail

REGISTRY="${NPM_REGISTRY_URL:-https://registry.npmjs.org}"
WORKDIR="$(mktemp -d)"
REPORT_PATH="${1:-node-audit-report.json}"

NPM_TOOLS=(
  "@trufflesecurity/trufflehog"
  "git-hound"
  "jwt-cracker"
)

available=()
unavailable=()

for pkg in "${NPM_TOOLS[@]}"; do
  if npm view "$pkg" version --registry "$REGISTRY" >/dev/null 2>&1; then
    available+=("$pkg")
  else
    unavailable+=("$pkg")
  fi
done

mkdir -p "$WORKDIR"
cd "$WORKDIR"

if [ "${#available[@]}" -gt 0 ]; then
  python3 - <<'PY' "${available[@]}"
import json, sys
pkgs = sys.argv[1:]
print(json.dumps({
  "name": "tilix-node-audit",
  "version": "1.0.0",
  "private": True,
  "dependencies": {p: "latest" for p in pkgs}
}, indent=2))
PY
fi > package.json

AUDIT_JSON='{}'
if [ "${#available[@]}" -gt 0 ]; then
  npm install --package-lock-only --registry "$REGISTRY" >/dev/null 2>&1 || true
  if [ -f package-lock.json ]; then
    npm audit --omit=dev --json > audit.json || true
    AUDIT_JSON="$(cat audit.json)"
  fi
fi

python3 - <<'PY' "$REPORT_PATH" "$REGISTRY" "$AUDIT_JSON" "${available[@]}" -- "${unavailable[@]}"
import json, sys
report_path = sys.argv[1]
registry = sys.argv[2]
audit_raw = sys.argv[3]
args = sys.argv[4:]
sep = args.index('--') if '--' in args else len(args)
available = args[:sep]
unavailable = args[sep+1:] if sep < len(args) else []

try:
    audit = json.loads(audit_raw) if audit_raw else {}
except Exception:
    audit = {}

summary = (((audit or {}).get('metadata') or {}).get('vulnerabilities') or {})

report = {
    "registry": registry,
    "available_packages": available,
    "unavailable_packages": unavailable,
    "audit_summary": summary,
    "note": "Unavailable packages are not covered by npm audit and require fallback binary advisory tracking."
}

with open(report_path, 'w') as f:
    json.dump(report, f, indent=2)

print(json.dumps(report, indent=2))
PY
