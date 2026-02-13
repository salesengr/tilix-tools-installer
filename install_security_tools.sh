#!/usr/bin/env bash
set -euo pipefail

SCRIPT_VERSION="2.1.0"
TOOLS_PREFIX="${TOOLS_PREFIX:-$HOME/.local}"
BIN_DIR="${TOOLS_PREFIX}/bin"
DRY_RUN=0

# Add/override tool install functions in scripts/tools.d/*.sh
TOOLS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/scripts/tools.d"

log() { printf '[%s] %s\n' "$1" "$2"; }
info() { log INFO "$1"; }
ok() { log OK "$1"; }
err() { log ERROR "$1" >&2; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    err "missing required command: $1"
    return 1
  }
}

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf 'DRY_RUN: %q ' "$@"; printf '\n'
    return 0
  fi
  "$@"
}

print_help() {
  cat <<'EOF'
install_security_tools.sh v2.1.0

Usage:
  bash install_security_tools.sh [--list] [--dry-run] [all|tool1 tool2 ...]

Environment:
  TOOLS_PREFIX   Install prefix (default: $HOME/.local)

Examples:
  bash install_security_tools.sh --list
  bash install_security_tools.sh waybackurls assetfinder seleniumbase
  TOOLS_PREFIX=$HOME/.local bash install_security_tools.sh all
EOF
}

preflight() {
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

  if [[ -x "${script_dir}/scripts/preflight_env.sh" ]]; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
      bash "${script_dir}/scripts/preflight_env.sh" --dry-run
    else
      bash "${script_dir}/scripts/preflight_env.sh"
    fi
  else
    need_cmd uname
    need_cmd mkdir
    need_cmd chmod
    need_cmd grep

    mkdir -p "$BIN_DIR"
    [[ -w "$BIN_DIR" ]] || {
      err "install directory is not writable: $BIN_DIR"
      exit 1
    }
  fi

  if command -v curl >/dev/null 2>&1; then
    DOWNLOADER="curl -fsSL"
  elif command -v wget >/dev/null 2>&1; then
    DOWNLOADER="wget -qO-"
  else
    err "curl or wget is required"
    exit 1
  fi

  export DOWNLOADER BIN_DIR TOOLS_PREFIX
}

verify_path_hint() {
  if ! echo ":$PATH:" | grep -q ":${BIN_DIR}:"; then
    info "${BIN_DIR} is not on PATH in this shell"
    info "Add it with: export PATH=\"${BIN_DIR}:\$PATH\""
  fi
}

install_waybackurls() {
  if [[ "$DRY_RUN" -ne 1 ]]; then
    need_cmd go || return 1
  fi
  run env GOBIN="$BIN_DIR" go install github.com/tomnomnom/waybackurls@latest
  [[ "$DRY_RUN" -eq 1 ]] && return 0
  [[ -x "${BIN_DIR}/waybackurls" ]]
}

install_assetfinder() {
  if [[ "$DRY_RUN" -ne 1 ]]; then
    need_cmd go || return 1
  fi
  run env GOBIN="$BIN_DIR" go install github.com/tomnomnom/assetfinder@latest
  [[ "$DRY_RUN" -eq 1 ]] && return 0
  [[ -x "${BIN_DIR}/assetfinder" ]]
}

install_seleniumbase() {
  if [[ "$DRY_RUN" -ne 1 ]]; then
    need_cmd python3 || return 1
    need_cmd pip3 || return 1
  fi

  run python3 -m pip install --upgrade --prefix "$TOOLS_PREFIX" seleniumbase

  [[ "$DRY_RUN" -eq 1 ]] && return 0
  [[ -x "${BIN_DIR}/sbase" ]]
}

TOOL_LIST=(
  waybackurls
  assetfinder
  seleniumbase
)

load_custom_tools() {
  if [[ -d "$TOOLS_DIR" ]]; then
    # shellcheck disable=SC1090
    for f in "$TOOLS_DIR"/*.sh; do
      [[ -e "$f" ]] || continue
      source "$f"
    done
  fi
}

list_tools() {
  printf '%s\n' "${TOOL_LIST[@]}"
}

install_tool() {
  local tool="$1"
  local fn="install_${tool}"

  if ! declare -F "$fn" >/dev/null 2>&1; then
    err "unknown tool: $tool"
    return 1
  fi

  info "installing ${tool}..."
  if "$fn"; then
    ok "${tool} installed"
    return 0
  fi

  err "${tool} install failed"
  return 1
}

main() {
  local requested=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --list) list_tools; exit 0 ;;
      --dry-run) DRY_RUN=1 ;;
      -h|--help) print_help; exit 0 ;;
      all) requested=("${TOOL_LIST[@]}") ;;
      *) requested+=("$1") ;;
    esac
    shift
  done

  [[ ${#requested[@]} -gt 0 ]] || requested=("${TOOL_LIST[@]}")

  preflight
  load_custom_tools

  local failures=0
  for t in "${requested[@]}"; do
    if ! install_tool "$t"; then
      failures=$((failures + 1))
    fi
  done

  verify_path_hint

  if [[ "$failures" -gt 0 ]]; then
    err "completed with ${failures} failure(s)"
    exit 1
  fi

  ok "all requested tools installed (script ${SCRIPT_VERSION})"
}

main "$@"
