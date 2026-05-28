#!/usr/bin/env bash
# remote_agent_setup_swgiweb.sh
# Sets up a direct reverse SSH tunnel to swgiweb + Python command server.
# Use when bore.pub and third-party tunnel services are blocked.
#
# Requirements:
#   1. Generate a throwaway key in the container:
#        ssh-keygen -t ed25519 -f /tmp/ck -N "" -q
#   2. Add the public key (/tmp/ck.pub) to swgiweb's ~/.ssh/authorized_keys:
#        ssh swgiweb "echo '<pubkey>' >> ~/.ssh/authorized_keys"
#   3. Run this script — it opens a reverse tunnel on swgiweb port 19999
#
# Orchestrator sends commands via:
#   ssh swgiweb "curl -s -X POST http://localhost:19999 -d 'cmd'"

set -euo pipefail

SERVER_PORT=9000
REMOTE_PORT=19999
SWGIWEB_HOST="swgiweb.myselab.net"
SWGIWEB_USER="ubuntu"
SSH_KEY="/tmp/ck"
TUNNEL_LOG="${HOME}/.local/swgiweb-tunnel.log"
SERVER_LOG="/tmp/cmd_server.log"

# ── Preflight checks ──────────────────────────────────────────────────────────
if [[ ! -f "${SSH_KEY}" ]]; then
    echo "ERROR: SSH key not found at ${SSH_KEY}" >&2
    echo "  Generate it with: ssh-keygen -t ed25519 -f /tmp/ck -N \"\" -q" >&2
    echo "  Then add /tmp/ck.pub to swgiweb's ~/.ssh/authorized_keys" >&2
    exit 1
fi

# ── Kill any previous instances ───────────────────────────────────────────────
pkill -f "cmd_server.py"                              2>/dev/null || true
pkill -f "ssh.*${SWGIWEB_HOST}.*${REMOTE_PORT}"       2>/dev/null || true
fuser -k "${SERVER_PORT}/tcp"                         2>/dev/null || true
sleep 1

# ── Write and start Python command server ─────────────────────────────────────
echo ">>> Starting command server on port ${SERVER_PORT}..."
cat > /tmp/cmd_server.py << 'PYEOF'
import http.server, subprocess, json

class CommandHandler(http.server.BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers["Content-Length"])
        cmd = self.rfile.read(length).decode()
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

http.server.HTTPServer(("127.0.0.1", 9000), CommandHandler).serve_forever()
PYEOF

python3 /tmp/cmd_server.py >"${SERVER_LOG}" 2>&1 &
SERVER_PID=$!
sleep 2

if ! kill -0 "${SERVER_PID}" 2>/dev/null; then
    echo "ERROR: Command server failed to start. Log:" >&2
    cat "${SERVER_LOG}" >&2
    exit 1
fi
echo "    Server PID: ${SERVER_PID} — OK"

# ── Open reverse SSH tunnel to swgiweb ────────────────────────────────────────
echo ">>> Opening reverse SSH tunnel to ${SWGIWEB_HOST}..."
ssh -o StrictHostKeyChecking=no \
    -o ServerAliveInterval=30 \
    -o ServerAliveCountMax=3 \
    -i "${SSH_KEY}" \
    -NR "${REMOTE_PORT}:localhost:${SERVER_PORT}" \
    "${SWGIWEB_USER}@${SWGIWEB_HOST}" >"${TUNNEL_LOG}" 2>&1 &
TUNNEL_PID=$!
sleep 3

if ! kill -0 "${TUNNEL_PID}" 2>/dev/null; then
    echo "ERROR: SSH tunnel failed to start. Log:" >&2
    cat "${TUNNEL_LOG}" >&2
    exit 1
fi
echo "    Tunnel PID: ${TUNNEL_PID} — OK"
echo ""
echo "=========================================="
echo "  Remote agent ready (swgiweb tunnel)."
echo "  Orchestrator endpoint: swgiweb:${REMOTE_PORT}"
echo ""
echo "  Send commands via:"
echo "  ssh swgiweb \"curl -s -X POST http://localhost:${REMOTE_PORT} -d 'cmd'\""
echo ""
echo "  Test:"
echo "  ssh swgiweb \"curl -s -X POST http://localhost:${REMOTE_PORT} -d 'whoami'\""
echo "=========================================="
