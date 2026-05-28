#!/usr/bin/env bash
# install_nc_fallback.sh
# Installs a Python-based nc (netcat) fallback into ~/.local/bin/nc.
# Supports -z (port scan), -v (verbose), -w (timeout), -l (listen).
# Use when netcat is not installed and /dev/tcp is unavailable.

set -euo pipefail

mkdir -p "${HOME}/.local/bin"

cat > "${HOME}/.local/bin/nc" << 'PYEOF'
#!/usr/bin/env python3
"""
Minimal netcat replacement implemented in Python.
Supports: nc host port | nc -l port | nc -zv host port | nc -w N host port
"""
import sys
import socket
import threading
import argparse


def recv_loop(sock):
    while True:
        try:
            data = sock.recv(4096)
            if not data:
                break
            sys.stdout.buffer.write(data)
            sys.stdout.flush()
        except OSError:
            break


def main():
    parser = argparse.ArgumentParser(
        prog="nc",
        description="Minimal netcat replacement (Python fallback)",
        add_help=False,
    )
    parser.add_argument("-h", "--help", action="store_true")
    parser.add_argument("-z", action="store_true", help="Port scan mode — connect and immediately close")
    parser.add_argument("-v", action="store_true", help="Verbose output")
    parser.add_argument("-l", action="store_true", help="Listen mode")
    parser.add_argument("-w", type=float, default=None, metavar="TIMEOUT", help="Timeout in seconds")
    parser.add_argument("args", nargs="*")

    opts = parser.parse_args()

    if opts.help or (not opts.l and len(opts.args) < 2):
        print("Usage: nc [-z] [-v] [-w timeout] <host> <port>")
        print("       nc -l <port>")
        sys.exit(0 if opts.help else 1)

    timeout = opts.w  # None means blocking

    if opts.l:
        # Listen mode
        port = int(opts.args[0])
        srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        srv.bind(("0.0.0.0", port))
        srv.listen(1)
        if opts.v:
            print(f"Listening on 0.0.0.0:{port}", file=sys.stderr)
        conn, addr = srv.accept()
        if opts.v:
            print(f"Connection from {addr[0]}:{addr[1]}", file=sys.stderr)
        srv.close()
        sock = conn
    else:
        host, port = opts.args[0], int(opts.args[1])
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        if timeout is not None:
            sock.settimeout(timeout)
        try:
            sock.connect((host, port))
        except (socket.timeout, TimeoutError):
            if opts.v:
                print(f"nc: connect to {host} port {port}: timed out", file=sys.stderr)
            sys.exit(1)
        except ConnectionRefusedError:
            if opts.v:
                print(f"nc: connect to {host} port {port}: Connection refused", file=sys.stderr)
            sys.exit(1)
        except OSError as e:
            if opts.v:
                print(f"nc: connect to {host} port {port}: {e}", file=sys.stderr)
            sys.exit(1)

        if opts.v:
            print(f"Connection to {host} {port} port [tcp] succeeded!", file=sys.stderr)

        if opts.z:
            # Scan mode — just check reachability, don't transfer data
            sock.close()
            sys.exit(0)

    # Interactive / pipe mode
    try:
        t = threading.Thread(target=recv_loop, args=(sock,), daemon=True)
        t.start()
        while True:
            line = sys.stdin.buffer.readline()
            if not line:
                break
            sock.sendall(line)
    except KeyboardInterrupt:
        pass
    finally:
        sock.close()


if __name__ == "__main__":
    main()
PYEOF

chmod +x "${HOME}/.local/bin/nc"

# Ensure ~/.local/bin is first in PATH (prepend, even if already present elsewhere)
export PATH="${HOME}/.local/bin:${PATH}"
if ! grep -q 'HOME/.local/bin' "${HOME}/.bashrc" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "${HOME}/.bashrc"
fi

echo "nc installed to ${HOME}/.local/bin/nc"
echo "Active nc: $(command -v nc)"
echo "Test: nc -zv google.com 443"
