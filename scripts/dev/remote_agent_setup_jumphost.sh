#!/usr/bin/env bash
# remote_agent_setup_jumphost.sh
# Sets up a direct reverse SSH tunnel to a jump host + Python command server.
# Use when bore.pub and third-party tunnel services are blocked.
#
# Usage: bash remote_agent_setup_jumphost.sh <jump-host> [jump-user] [remote-port] [ssh-key]
#   jump-host    DNS name or IP of the SSH jump host (required)
#   jump-user    SSH username on jump host (default: ubuntu)
#   remote-port  Port to open on jump host (default: 19999)
#   ssh-key      Path to SSH key (default: /tmp/ck)
#
# Requirements:
#   1. Generate a throwaway key in the container:
#        ssh-keygen -t ed25519 -f /tmp/ck -N "" -q
#   2. Add /tmp/ck.pub to the jump host's ~/.ssh/authorized_keys
#   3. Run this script
#
# Orchestrator sends commands via:
#   ssh <jump-user>@<jump-host> "curl -s -H 'X-Token: <token>' -X POST http://localhost:<remote-port> -d 'cmd'"
#
# ⚠ SECURITY WARNING: This script starts an HTTP command server protected by a
# per-session token. Keep the printed token private — anyone with the token and
# tunnel endpoint can execute arbitrary shell commands as the container user.
# For developer/testing use only. Never use in production environments.

set -uo pipefail

# ── Generate per-session auth token ──────────────────────────────────────────
CMD_TOKEN=$(python3 -c "import secrets; print(secrets.token_hex(32))")

if [[ -z "${1:-}" ]]; then
	echo "Usage: $0 <jump-host> [jump-user] [remote-port] [ssh-key]" >&2
	exit 1
fi
JUMP_HOST="${1}"
JUMP_USER="${2:-ubuntu}"
SERVER_PORT=9000
REMOTE_PORT="${3:-19999}"
SSH_KEY="${4:-/tmp/ck}"
TUNNEL_LOG="${HOME}/.local/jump-tunnel.log"
SERVER_LOG="/tmp/cmd_server.log"

# ── Preflight checks ──────────────────────────────────────────────────────────
if [[ ! -f "${SSH_KEY}" ]]; then
	echo "ERROR: SSH key not found at ${SSH_KEY}" >&2
	echo "  Generate it with: ssh-keygen -t ed25519 -f /tmp/ck -N \"\" -q" >&2
	echo "  Then add /tmp/ck.pub to the jump host's ~/.ssh/authorized_keys" >&2
	exit 1
fi

# ── Kill any previous instances ───────────────────────────────────────────────
set +e
pkill -f "cmd_server.py" 2>/dev/null
pkill -f "ssh -o.*-NR ${REMOTE_PORT}" 2>/dev/null
fuser -k "${SERVER_PORT}/tcp" 2>/dev/null
set -e
sleep 1

# ── Write and start Python command server ─────────────────────────────────────
echo ">>> Starting command server on port ${SERVER_PORT}..."
cat >/tmp/cmd_server.py <<PYEOF
import http.server, subprocess, json, os, socketserver

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
        # Background commands (ending with &): use Popen with close_fds so the
        # detached process doesn't hold our capture pipes open and block the response.
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

class _ThreadedServer(socketserver.ThreadingMixIn, http.server.HTTPServer):
    daemon_threads = True

_ThreadedServer(("127.0.0.1", 9000), CommandHandler).serve_forever()
PYEOF

python3 /tmp/cmd_server.py >"${SERVER_LOG}" 2>&1 &
rm -f /tmp/cmd_server.py # token now only in process memory
SERVER_PID=$!
sleep 2

if ! kill -0 "${SERVER_PID}" 2>/dev/null; then
	echo "ERROR: Command server failed to start. Log:" >&2
	cat "${SERVER_LOG}" >&2
	exit 1
fi
echo "    Server PID: ${SERVER_PID} — OK"

# ── Open reverse SSH tunnel to jump host ────────────────────────────────────────
echo ">>> Opening reverse SSH tunnel to ${JUMP_HOST}..."
ssh -o StrictHostKeyChecking=no \
	-o ServerAliveInterval=30 \
	-o ServerAliveCountMax=3 \
	-i "${SSH_KEY}" \
	-NR "${REMOTE_PORT}:localhost:${SERVER_PORT}" \
	"${JUMP_USER}@${JUMP_HOST}" >"${TUNNEL_LOG}" 2>&1 &
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
echo "  Remote agent ready (reverse SSH tunnel)."
echo "  Jump host : ${JUMP_USER}@${JUMP_HOST}"
echo "  Endpoint  : localhost:${REMOTE_PORT} on jump host"
echo ""
echo "  Auth token: ${CMD_TOKEN}"
echo ""
echo "  Test with:"
echo "  ssh ${JUMP_USER}@${JUMP_HOST} \"curl -s -H 'X-Token: ${CMD_TOKEN}' -X POST http://localhost:${REMOTE_PORT} -d 'whoami'\""
echo "=========================================="
