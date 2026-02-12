#!/usr/bin/env bash
set -euo pipefail

# Friendly entrypoint for customers.
exec "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/install_security_tools.sh" "$@"
