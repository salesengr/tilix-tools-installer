# Custom Tool Installer Template

Use this pattern when adding a new installer script.

```bash
#!/usr/bin/env bash
set -euo pipefail

TOOL_NAME="example"
TOOL_VERSION="${TOOL_VERSION:-1.2.3}"
TOOLS_PREFIX="${TOOLS_PREFIX:-$HOME/.local}"
BIN_DIR="${TOOLS_PREFIX}/bin"

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "[ERROR] missing required command: $1" >&2
    exit 1
  }
}

preflight() {
  need_cmd uname
  need_cmd mkdir
  need_cmd chmod

  if command -v curl >/dev/null 2>&1; then
    DL="curl -fsSL"
  elif command -v wget >/dev/null 2>&1; then
    DL="wget -qO-"
  else
    echo "[ERROR] curl or wget required" >&2
    exit 1
  fi

  mkdir -p "$BIN_DIR"
  [ -w "$BIN_DIR" ] || {
    echo "[ERROR] not writable: $BIN_DIR" >&2
    exit 1
  }
}

install_tool() {
  local url="https://example.invalid/${TOOL_VERSION}/example-linux-amd64"
  $DL "$url" >"${BIN_DIR}/${TOOL_NAME}"
  chmod +x "${BIN_DIR}/${TOOL_NAME}"
}

verify() {
  "${BIN_DIR}/${TOOL_NAME}" --version || true
  if ! command -v "$TOOL_NAME" >/dev/null 2>&1; then
    echo "[INFO] Add to PATH: export PATH=\"$BIN_DIR:\$PATH\""
  fi
}

main() {
  preflight
  install_tool
  verify
  echo "[OK] installed ${TOOL_NAME} ${TOOL_VERSION} to ${BIN_DIR}"
}

main "$@"
```

## Required behaviors

- User-space default prefix (`$HOME/.local`).
- Dependency preflight.
- Explicit version pin/default behavior.
- Post-install PATH guidance and verification.
- Safe rerun/idempotent handling where possible.
