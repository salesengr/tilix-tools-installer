#!/usr/bin/env bash
set -euo pipefail

SCRIPT_VERSION="1.0.0"
DRY_RUN=0
VERBOSE=0

TOOLS_PREFIX="${TOOLS_PREFIX:-$HOME/.local}"
BIN_DIR="${BIN_DIR:-${TOOLS_PREFIX}/bin}"

required_cmds=(uname mkdir chmod grep)
optional_net_cmds=(curl wget)
required_dirs=(
  "$TOOLS_PREFIX"
  "$BIN_DIR"
  "$HOME/.config"
  "$HOME/.cache"
  "$HOME/.local/share"
)

log() { printf '[%s] %s\n' "$1" "$2"; }
info() { log INFO "$1"; }
ok() { log OK "$1"; }
warn() { log WARN "$1"; }
err() { log ERROR "$1" >&2; }
verbose() { [[ "$VERBOSE" -eq 1 ]] && info "$1" || true; }

usage() {
  cat <<'EOF'
preflight_env.sh v1.0.0

Usage:
  bash scripts/preflight_env.sh [--dry-run] [--verbose] [--help]

Purpose:
  Validate user-space install prerequisites and create required directories
  only when missing. Safe to run repeatedly (idempotent).

Options:
  --dry-run   Show what would happen without making changes
  --verbose   Show additional details
  -h, --help  Show this help

Environment:
  TOOLS_PREFIX   install prefix (default: $HOME/.local)
  BIN_DIR        install bin dir (default: $TOOLS_PREFIX/bin)
EOF
}

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf 'DRY_RUN: %q ' "$@"
    printf '\n'
    return 0
  fi
  "$@"
}

need_cmd() {
  local cmd="$1"
  if command -v "$cmd" >/dev/null 2>&1; then
    verbose "command found: $cmd"
  else
    err "missing required command: $cmd"
    return 1
  fi
}

check_downloader() {
  if command -v curl >/dev/null 2>&1; then
    ok "downloader available: curl"
    return 0
  fi
  if command -v wget >/dev/null 2>&1; then
    ok "downloader available: wget"
    return 0
  fi

  err "missing downloader: install curl or wget"
  return 1
}

ensure_dir() {
  local dir="$1"
  if [[ -d "$dir" ]]; then
    info "exists: $dir"
  else
    info "creating: $dir"
    run mkdir -p "$dir"
  fi

  if [[ -w "$dir" ]]; then
    ok "writable: $dir"
  else
    err "not writable: $dir"
    return 1
  fi
}

main() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run) DRY_RUN=1 ;;
      --verbose) VERBOSE=1 ;;
      -h|--help) usage; exit 0 ;;
      *) err "unknown argument: $1"; usage; exit 2 ;;
    esac
    shift
  done

  info "running environment preflight checks (script ${SCRIPT_VERSION})"
  info "TOOLS_PREFIX=${TOOLS_PREFIX}"
  info "BIN_DIR=${BIN_DIR}"

  local failures=0

  for c in "${required_cmds[@]}"; do
    if ! need_cmd "$c"; then
      failures=$((failures + 1))
    fi
  done

  if ! check_downloader; then
    failures=$((failures + 1))
  fi

  for d in "${required_dirs[@]}"; do
    if ! ensure_dir "$d"; then
      failures=$((failures + 1))
    fi
  done

  if [[ "$failures" -gt 0 ]]; then
    err "preflight failed with ${failures} issue(s)"
    exit 1
  fi

  ok "preflight completed successfully"
}

main "$@"
