#!/usr/bin/env bash
# setup_swgiweb.sh
# One-shot self-contained setup for remote testing via an SSH jump host.
# Run this in the Tilix container to get fully connected in one go.
#
# ⚠ SECURITY WARNING: Starts an HTTP command server with per-session token auth.
# Keep the printed token private. Developer/testing use only.
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
SERVER_PORT=9000
SSH_KEY="/tmp/ck"
SERVER_LOG="/tmp/cmd_server.log"
TUNNEL_LOG="${HOME}/.local/jump-tunnel.log"

echo ""
echo "=========================================="
echo "  Tilix Remote Testing Setup"
echo "  Jump host : ${JUMP_USER}@${JUMP_HOST}"
echo "  Remote port: ${REMOTE_PORT}"
echo "=========================================="
echo ""

# ── Step 1: Get public IP ─────────────────────────────────────────────────────
echo ">>> Getting container public IP..."
PUBLIC_IP=$(curl -fsSL --max-time 10 'https://api.ipify.org?format=json' 2>/dev/null \
    | python3 -c "import sys,json; print(json.load(sys.stdin)['ip'])" 2>/dev/null || echo "unknown")
echo "    Container IP: ${PUBLIC_IP}"

# ── Step 2: Generate SSH key ──────────────────────────────────────────────────
if [[ ! -f "${SSH_KEY}" ]]; then
    echo ">>> Generating throwaway SSH key at ${SSH_KEY}..."
    ssh-keygen -t ed25519 -f "${SSH_KEY}" -N "" -q
else
    echo ">>> Using existing SSH key at ${SSH_KEY}"
fi

echo ""
echo "=========================================="
echo "  ACTION REQUIRED ON YOUR ORCHESTRATOR"
echo "=========================================="
echo ""
echo "  1. Update NSG rule (if IP changed):"
echo "     # Update your jump host NSG/firewall to allow SSH from ${PUBLIC_IP}"
echo ""
echo "  2. Add container key to jump host:"
echo "     ssh ${JUMP_USER}@${JUMP_HOST} \\"
echo "       \"echo '$(cat "${SSH_KEY}.pub")' >> ~/.ssh/authorized_keys\""
echo ""
echo "=========================================="
echo ""
read -r -p "Press Enter when the steps above are complete on your orchestrator machine..."
echo ""

# ── Step 3: Test connectivity ─────────────────────────────────────────────────
echo ">>> Testing connectivity to ${JUMP_HOST}:22..."
if timeout 5 bash -c "echo >/dev/tcp/${JUMP_HOST}/22" 2>/dev/null; then
    echo "    ✓ Reachable"
else
    echo "    ✗ Cannot reach ${JUMP_HOST}:22 — check NSG rule and network"
    exit 1
fi

# ── Step 4: Generate per-session auth token ───────────────────────────────────
CMD_TOKEN=$(python3 -c "import secrets; print(secrets.token_hex(32))")

# ── Step 5: Kill any previous instances ──────────────────────────────────────
set +e
pkill -f "cmd_server.py"                   2>/dev/null
pkill -f "ssh -o.*-NR ${REMOTE_PORT}"      2>/dev/null
fuser -k "${SERVER_PORT}/tcp"              2>/dev/null
set -e
sleep 1

# ── Step 6: Write and start Python command server ─────────────────────────────
echo ">>> Starting command server on port ${SERVER_PORT}..."
cat > /tmp/cmd_server.py << PYEOF
import http.server, subprocess, json, os

REQUIRED_TOKEN = "${CMD_TOKEN}"

class CommandHandler(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        token = self.headers.get("X-Token", "")
        if not REQUIRED_TOKEN or token != REQUIRED_TOKEN:
            self.send_response(403)
            self.send_header("Content-Length", "0")
            self.end_headers()
            return
        length = int(self.headers["Content-Length"])
        cmd = self.rfile.read(length).decode().strip()
        if cmd.endswith("&"):
            inner = cmd[:-1].strip()
            p = subprocess.Popen(
                inner, shell=True, close_fds=True,
                stdout=open("/dev/null", "w"), stderr=subprocess.STDOUT,
                stdin=open("/dev/null"),
            )
            body = json.dumps({"stdout": str(p.pid) + "\n", "stderr": "", "rc": 0}).encode()
        else:
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            body = json.dumps({
                "stdout": result.stdout,
                "stderr": result.stderr,
                "rc":     result.returncode,
            }).encode()
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def log_message(self, *args):
        pass

http.server.HTTPServer(("127.0.0.1", ${SERVER_PORT}), CommandHandler).serve_forever()
PYEOF

python3 /tmp/cmd_server.py >"${SERVER_LOG}" 2>&1 &
SERVER_PID=$!
sleep 2

if ! kill -0 "${SERVER_PID}" 2>/dev/null; then
    echo "ERROR: Command server failed to start." >&2
    cat "${SERVER_LOG}" >&2
    exit 1
fi
echo "    Server PID: ${SERVER_PID} — OK"

# ── Step 7: Open reverse SSH tunnel ──────────────────────────────────────────
echo ">>> Opening reverse SSH tunnel to ${JUMP_HOST}..."
mkdir -p "${HOME}/.local"
ssh -o StrictHostKeyChecking=no \
    -o ServerAliveInterval=30 \
    -o ServerAliveCountMax=3 \
    -i "${SSH_KEY}" \
    -NR "${REMOTE_PORT}:localhost:${SERVER_PORT}" \
    "${JUMP_USER}@${JUMP_HOST}" >"${TUNNEL_LOG}" 2>&1 &
TUNNEL_PID=$!
sleep 3

if ! kill -0 "${TUNNEL_PID}" 2>/dev/null; then
    echo "ERROR: SSH tunnel failed to start." >&2
    cat "${TUNNEL_LOG}" >&2
    exit 1
fi
echo "    Tunnel PID: ${TUNNEL_PID} — OK"
echo ""
echo "=========================================="
echo "  Remote agent ready."
echo "  Jump host : ${JUMP_USER}@${JUMP_HOST}"
echo "  Endpoint  : localhost:${REMOTE_PORT} on jump host"
echo ""
echo "  Auth token: ${CMD_TOKEN}"
echo ""
echo "  Test with:"
echo "  ssh ${JUMP_USER}@${JUMP_HOST} \"curl -s -H 'X-Token: ${CMD_TOKEN}' -X POST http://localhost:${REMOTE_PORT} -d 'whoami'\""
echo "=========================================="
