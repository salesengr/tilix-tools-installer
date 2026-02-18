#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
DEFINITIONS_FILE="${REPO_ROOT}/lib/data/tool-definitions.sh"
OUT_FILE="${1:-${REPO_ROOT}/scripts/manifests/legacy_tools_d870fee.tsv}"

mkdir -p "$(dirname "${OUT_FILE}")"

# shellcheck source=lib/data/tool-definitions.sh
source "${DEFINITIONS_FILE}"

all_tools=(
  "${BUILD_TOOLS[@]}"
  "${LANGUAGES[@]}"
  "python_venv"
  "${ALL_PYTHON_TOOLS[@]}"
  "${ALL_GO_TOOLS[@]}"
  "${NODE_TOOLS[@]}"
  "${ALL_RUST_TOOLS[@]}"
)

expected_command() {
  local tool="$1"
  case "$tool" in
    github_cli) echo "gh" ;;
    nodejs) echo "node" ;;
    rust) echo "cargo" ;;
    python_venv) echo "python" ;;
    virustotal) echo "vt" ;;
    ripgrep) echo "rg" ;;
    *) echo "$tool" ;;
  esac
}

extract_value() {
  local key="$1"
  local tool="$2"
  local line

  line="$(grep -F "${key}[${tool}]=" "${DEFINITIONS_FILE}" | head -n 1 || true)"
  if [[ -z "${line}" ]]; then
    echo ""
    return 0
  fi

  echo "${line}" | awk -F'"' '{print $2}'
}

{
  printf 'tool\tcategory\tinstall_location\tsmoke_type\tsmoke_target\n'

  seen="|"
  for tool in "${all_tools[@]}"; do
    case "${seen}" in
      *"|${tool}|"*) continue ;;
    esac
    seen="${seen}${tool}|"

    info="$(extract_value "TOOL_INFO" "${tool}")"
    location="$(extract_value "TOOL_INSTALL_LOCATION" "${tool}")"
    category="$(echo "${info}" | cut -d'|' -f3)"
    category="${category:-unknown}"

    smoke_type="command"
    smoke_target="$(expected_command "$tool")"

    if [[ "$tool" == "python_venv" ]]; then
      smoke_type="path"
      smoke_target='~/.local/share/virtualenvs/tools/bin/python'
    fi

    printf '%s\t%s\t%s\t%s\t%s\n' "$tool" "$category" "$location" "$smoke_type" "$smoke_target"
  done
} > "$OUT_FILE"

echo "Wrote manifest: ${OUT_FILE}"
