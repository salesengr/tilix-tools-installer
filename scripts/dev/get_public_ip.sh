#!/usr/bin/env bash
# get_public_ip.sh
# Returns the container's public IP address using the ipify API.
# Usage: bash scripts/get_public_ip.sh

set -euo pipefail

IP=$(curl -fsSL --max-time 10 'https://api.ipify.org?format=json' | python3 -c "import sys,json; print(json.load(sys.stdin)['ip'])")
echo "${IP}"
