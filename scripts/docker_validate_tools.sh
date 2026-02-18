#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DEFAULT_MANIFEST="${REPO_ROOT}/scripts/manifests/legacy_tools_d870fee.tsv"

IMAGE=""
MANIFEST="$DEFAULT_MANIFEST"
TOOLS_CSV=""
LOG_DIR="${REPO_ROOT}/.tmp/docker-validation-$(date +%Y%m%d-%H%M%S)"
STOP_ON_FAIL=0
TOOL_TIMEOUT=1800

usage() {
  cat <<USAGE
Usage:
  bash scripts/docker_validate_tools.sh --image <docker-image> [options]

Options:
  --image <image>          Docker image to test against (required)
  --manifest <path>        Manifest TSV (default: ${DEFAULT_MANIFEST})
  --tools <a,b,c>          Run only selected tools
  --log-dir <path>         Directory to write per-tool logs
  --stop-on-fail           Exit immediately when a tool fails
  --tool-timeout <sec>     Max seconds per tool in container (default: 1800)
  -h, --help               Show help
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --image)
      IMAGE="${2:-}"
      shift 2
      ;;
    --manifest)
      MANIFEST="${2:-}"
      shift 2
      ;;
    --tools)
      TOOLS_CSV="${2:-}"
      shift 2
      ;;
    --log-dir)
      LOG_DIR="${2:-}"
      shift 2
      ;;
    --stop-on-fail)
      STOP_ON_FAIL=1
      shift
      ;;
    --tool-timeout)
      TOOL_TIMEOUT="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$IMAGE" ]]; then
  echo "--image is required" >&2
  usage
  exit 1
fi

command -v docker >/dev/null 2>&1 || {
  echo "docker is required" >&2
  exit 1
}

[[ -f "$MANIFEST" ]] || {
  echo "manifest not found: $MANIFEST" >&2
  exit 1
}

mkdir -p "$LOG_DIR"

TOOLS_CSV="$(echo "$TOOLS_CSV" | tr -d ' ')"

is_selected() {
  local tool="$1"
  if [[ -z "$TOOLS_CSV" ]]; then
    return 0
  fi
  case ",${TOOLS_CSV}," in
    *",${tool},"*) return 0 ;;
    *) return 1 ;;
  esac
}

PASS=0
FAIL=0
SKIP=0

while IFS=$'\t' read -r tool category install_location smoke_type smoke_target; do
  [[ "$tool" == "tool" ]] && continue

  if ! is_selected "$tool"; then
    SKIP=$((SKIP + 1))
    continue
  fi

  log_file="${LOG_DIR}/${tool}.log"
  echo "==> [$tool] category=${category}"

  if [[ "$smoke_type" == "path" ]]; then
    smoke_cmd="target=\"${smoke_target}\"; if [[ \"\${target:0:2}\" == \"~/\" ]]; then target=\"\$HOME/\${target:2}\"; fi; test -e \"\$target\""
  else
    smoke_cmd="command -v \"$smoke_target\" >/dev/null 2>&1"
  fi

  if docker run --rm \
    --entrypoint bash \
    -v "${REPO_ROOT}:/workspace" \
    -w /workspace \
    "$IMAGE" \
    -lc "set -euo pipefail; bash xdg_setup.sh >/tmp/xdg_setup.log 2>&1 || true; set +u; source \"\$HOME/.bashrc\" >/dev/null 2>&1 || true; set -u; XDG_DATA_HOME=\"\${XDG_DATA_HOME:-\$HOME/.local/share}\"; GOPATH=\"\${GOPATH:-\$HOME/opt/gopath}\"; CARGO_HOME=\"\${CARGO_HOME:-\$XDG_DATA_HOME/cargo}\"; export XDG_DATA_HOME GOPATH CARGO_HOME; export PATH=\"\$HOME/.local/bin:\$HOME/opt/node/bin:\$GOPATH/bin:\$CARGO_HOME/bin:\$PATH\"; timeout \"${TOOL_TIMEOUT}\" bash install_security_tools.sh \"$tool\"; ${smoke_cmd}" \
    >"$log_file" 2>&1; then
    PASS=$((PASS + 1))
    echo "    PASS (log: $log_file)"
  else
    FAIL=$((FAIL + 1))
    echo "    FAIL (log: $log_file)"
    if [[ "$STOP_ON_FAIL" -eq 1 ]]; then
      break
    fi
  fi
done < "$MANIFEST"

echo
echo "Validation complete"
echo "  pass: ${PASS}"
echo "  fail: ${FAIL}"
echo "  skip: ${SKIP}"
echo "  logs: ${LOG_DIR}"

[[ "$FAIL" -eq 0 ]]
