#!/usr/bin/env bash
# remote_agent_setup.sh
# Sets up a bore tunnel + Python command server for remote orchestration.
# Run as the target user (no root required).

set -euo pipefail

BORE_VERSION="v0.6.0"
BORE_URL="https://github.com/ekzhang/bore/releases/download/${BORE_VERSION}/bore-${BORE_VERSION}-x86_64-unknown-linux-musl.tar.gz"
SERVER_PORT=9000

# ── Install bore ──────────────────────────────────────────────────────────────
echo ">>> Installing bore ${BORE_VERSION}..."
mkdir -p "${HOME}/.local/bin"
curl -fsSL "${BORE_URL}" | tar -xz -C "${HOME}/.local/bin/"
echo "    bore installed to ~/.local/bin/bore"

# ── Add ~/.local/bin to PATH for this session ─────────────────────────────────
export PATH="${HOME}/.local/bin:${PATH}"

# ── Start Python command server ───────────────────────────────────────────────
echo ">>> Starting command server on port ${SERVER_PORT}..."
python3 - <<'PYEOF' &
import http.server
import subprocess
import json

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

print(f"Command server listening on 127.0.0.1:9000", flush=True)
http.server.HTTPServer(("127.0.0.1", 9000), CommandHandler).serve_forever()
PYEOF

SERVER_PID=$!
echo "    Server PID: ${SERVER_PID}"

# Give the server a moment to bind
sleep 1

# Verify it's up
if ! kill -0 "${SERVER_PID}" 2>/dev/null; then
    echo "ERROR: Command server failed to start" >&2
    exit 1
fi

# ── Expose via bore ───────────────────────────────────────────────────────────
echo ">>> Exposing port ${SERVER_PORT} via bore..."
echo "    (Share the bore.pub port printed below with your orchestrator)"
echo ""
bore local "${SERVER_PORT}" --to bore.pub
