#!/usr/bin/env bash
# remote_agent_setup_localrun.sh
# Sets up a localhost.run HTTPS tunnel + Python command server for remote orchestration.
# Use when bore.pub is blocked and serveo.net rejects port forwarding.
# Requires SSH port 22 outbound. No binary downloads required.
#
# localhost.run tunnels HTTP only — the Python server on port 9000 is exposed
# via HTTPS at a *.lhr.life URL. The orchestrator connects via:
#   ssh swgiweb "curl -s -X POST https://<id>.lhr.life -d 'cmd'"

set -euo pipefail

SERVER_PORT=9000
TUNNEL_LOG="${HOME}/.local/localrun-tunnel.log"
SERVER_LOG="/tmp/cmd_server.log"

# ── Kill any previous instances ───────────────────────────────────────────────
pkill -f "cmd_server.py"           2>/dev/null || true
pkill -f "ssh.*localhost.run"      2>/dev/null || true
fuser -k "${SERVER_PORT}/tcp"      2>/dev/null || true
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

# ── Open localhost.run tunnel ─────────────────────────────────────────────────
echo ">>> Opening localhost.run SSH tunnel..."
ssh -o StrictHostKeyChecking=no \
    -o ServerAliveInterval=30 \
    -o ServerAliveCountMax=3 \
    -NR "80:localhost:${SERVER_PORT}" \
    nokey@localhost.run >"${TUNNEL_LOG}" 2>&1 &
TUNNEL_PID=$!

# localhost.run prints URL after the welcome banner (~10-20s)
# Format: "xxxxxxxx.lhr.life tunneled with tls termination, https://xxxxxxxx.lhr.life"
for i in $(seq 1 60); do
    if grep -q "lhr.life" "${TUNNEL_LOG}" 2>/dev/null; then
        break
    fi
    sleep 1
done

if ! kill -0 "${TUNNEL_PID}" 2>/dev/null; then
    echo "ERROR: localhost.run tunnel failed to start. Log:" >&2
    cat "${TUNNEL_LOG}" >&2
    exit 1
fi

TUNNEL_URL=$(grep -oP 'https://\S+\.lhr\.life' "${TUNNEL_LOG}" 2>/dev/null | head -1 || echo "")

echo "    Tunnel PID: ${TUNNEL_PID} — OK"
echo ""
echo "=========================================="
echo "  Remote agent ready (localhost.run)."
if [[ -n "${TUNNEL_URL}" ]]; then
    echo "  Orchestrator endpoint: ${TUNNEL_URL}"
    echo ""
    echo "  Test with (via swgiweb):"
    echo "  ssh swgiweb \"curl -s -X POST ${TUNNEL_URL} -d 'whoami'\""
else
    echo "  Could not detect URL. Full log:"
    cat "${TUNNEL_LOG}"
fi
echo "=========================================="
