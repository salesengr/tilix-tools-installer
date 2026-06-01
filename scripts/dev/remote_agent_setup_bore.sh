#!/usr/bin/env bash
# remote_agent_setup_bore.sh
# Sets up a bore tunnel + Python command server for remote orchestration.
# Run as the target user (no root required). Both services run in the background.
#
# ⚠ SECURITY WARNING: This script starts an HTTP command server protected by a
# per-session token. Keep the printed token private — anyone with the token and
# bore endpoint can execute arbitrary shell commands as the container user.
# For developer/testing use only. Never use in production environments.

set -euo pipefail

BORE_VERSION="v0.6.0"
BORE_URL="https://github.com/ekzhang/bore/releases/download/${BORE_VERSION}/bore-${BORE_VERSION}-x86_64-unknown-linux-musl.tar.gz"
BORE_SHA256="e484d1e3acba77169b773f31a5bfb34192d4b660f44a094a658a2522cd2270f7"
SERVER_PORT=9000
BORE_LOG="${HOME}/.local/bore-tunnel.log"

# ── Generate per-session auth token ──────────────────────────────────────────
CMD_TOKEN=$(python3 -c "import secrets; print(secrets.token_hex(32))")

# ── Install bore (skip if already present) ────────────────────────────────────
mkdir -p "${HOME}/.local/bin"
export PATH="${HOME}/.local/bin:${PATH}"

if ! command -v bore &>/dev/null; then
	echo ">>> Installing bore ${BORE_VERSION}..."
	BORE_TMP=$(mktemp)
	curl -fsSL --max-time 120 "${BORE_URL}" -o "${BORE_TMP}"
	echo "${BORE_SHA256}  ${BORE_TMP}" | sha256sum -c - || {
		echo "ERROR: bore SHA256 mismatch — aborting install" >&2
		rm -f "${BORE_TMP}"
		exit 1
	}
	tar -xz -C "${HOME}/.local/bin/" -f "${BORE_TMP}"
	rm -f "${BORE_TMP}"
	echo "    bore installed to ~/.local/bin/bore"
fi

# ── Kill any previous instances ───────────────────────────────────────────────
set +e
pkill -f "bore local ${SERVER_PORT}" 2>/dev/null
pkill -f "cmd_server.py" 2>/dev/null
fuser -k "${SERVER_PORT}/tcp" 2>/dev/null
set -e
sleep 1

# ── Write Python command server with token auth ───────────────────────────────
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

SERVER_LOG="/tmp/cmd_server.log"
python3 /tmp/cmd_server.py >"${SERVER_LOG}" 2>&1 &
rm -f /tmp/cmd_server.py  # token now only in process memory
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

for _ in $(seq 1 20); do
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
echo "  Auth token: ${CMD_TOKEN}"
echo ""
echo "  Test with:"
echo "  curl -s -H 'X-Token: ${CMD_TOKEN}' -X POST http://bore.pub:${BORE_PORT} -d 'whoami'"
echo "=========================================="
