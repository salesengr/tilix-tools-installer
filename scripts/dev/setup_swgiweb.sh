#!/usr/bin/env bash
# setup_swgiweb.sh
# One-shot setup script for remote testing via a swgiweb-style SSH jump host.
# Run this in the Tilix container to get fully connected in one go.
#
# Usage: bash scripts/dev/setup_swgiweb.sh <jump-host> [jump-user] [remote-port]
#   jump-host    DNS name or IP of the SSH jump host (required)
#   jump-user    SSH username on jump host (default: ubuntu)
#   remote-port  Port to open on jump host (default: 19999)

set -uo pipefail

# Always prepend ~/.local/bin so installed tools are available immediately
export PATH="$HOME/.local/bin:${PATH}"

JUMP_HOST="${1:?Usage: $0 <jump-host> [jump-user] [remote-port]}"
JUMP_USER="${2:-ubuntu}"
REMOTE_PORT="${3:-19999}"
SSH_KEY="/tmp/ck"

echo ""
echo "=========================================="
echo "  Tilix Remote Testing Setup"
echo "  Jump host : ${JUMP_USER}@${JUMP_HOST}"
echo "  Remote port: ${REMOTE_PORT}"
echo "=========================================="
echo ""

# ── Step 1: Install nc fallback if needed ─────────────────────────────────────
if ! command -v nc &>/dev/null; then
    echo ">>> Installing nc fallback..."
    bash "$(dirname "$0")/install_nc_fallback.sh" >/dev/null 2>&1
fi

# ── Step 2: Get public IP ─────────────────────────────────────────────────────
echo ">>> Getting container public IP..."
PUBLIC_IP=$(curl -fsSL --max-time 10 'https://api.ipify.org?format=json' 2>/dev/null \
    | python3 -c "import sys,json; print(json.load(sys.stdin)['ip'])" 2>/dev/null || echo "unknown")
echo "    Container IP: ${PUBLIC_IP}"

# ── Step 3: Generate SSH key ──────────────────────────────────────────────────
if [[ ! -f "${SSH_KEY}" ]]; then
    echo ">>> Generating throwaway SSH key at ${SSH_KEY}..."
    ssh-keygen -t ed25519 -f "${SSH_KEY}" -N "" -q
else
    echo ">>> Using existing SSH key at ${SSH_KEY}"
fi

echo ""
echo "=========================================="
echo "  ACTION REQUIRED ON YOUR MAC"
echo "=========================================="
echo ""
echo "  1. Update NSG rule (if IP changed):"
echo "     update-tilix-nsg.sh ${PUBLIC_IP}"
echo ""
echo "  2. Add container key to jump host:"
echo "     ssh ${JUMP_USER}@${JUMP_HOST} \\"
echo "       \"echo '$(cat "${SSH_KEY}.pub")' >> ~/.ssh/authorized_keys\""
echo ""
echo "=========================================="
echo ""
read -r -p "Press Enter when the Mac steps above are complete..."
echo ""

# ── Step 4: Test connectivity via /dev/tcp (no nc needed) ────────────────────
echo ">>> Testing connectivity to ${JUMP_HOST}:22..."
if timeout 5 bash -c "echo >/dev/tcp/${JUMP_HOST}/22" 2>/dev/null; then
    echo "    ✓ Reachable"
else
    echo "    ✗ Cannot reach ${JUMP_HOST}:22 — check NSG rule and network"
    exit 1
fi

# ── Step 5: Start remote agent ────────────────────────────────────────────────
echo ""
bash "$(dirname "$0")/remote_agent_setup_ssh_tunnel.sh" \
    "${JUMP_HOST}" "${JUMP_USER}" "${REMOTE_PORT}" "${SSH_KEY}"
