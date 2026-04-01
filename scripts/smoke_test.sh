#!/usr/bin/env bash
# ============================================================
# smoke_test.sh — Tilix Tools Installer Smoke Test Suite
# Version: 1.0.0
# Purpose: Non-destructive verification that every installed
#          tool is reachable and responds correctly.
#          Run after a fresh install to catch broken installs,
#          missing PATH entries, or dependency gaps.
# Usage:
#   bash scripts/smoke_test.sh                  # test all tools
#   bash scripts/smoke_test.sh --category osint # specific category
#   bash scripts/smoke_test.sh --tool sherlock  # single tool
#   bash scripts/smoke_test.sh --installed-only # skip [--] tools
# ============================================================

set -euo pipefail

# ===== COLORS =====
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'
BOLD='\033[1m'

CHECK="✔"
CROSS="✘"
SKIP="—"

# ===== STATE =====
PASS=()
FAIL=()
SKIPPED=()
ISSUES=()

INSTALLED_ONLY=false
FILTER_CATEGORY=""
FILTER_TOOL=""
LOG_DIR="${HOME}/.local/state/install_tools/smoke_test"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/smoke_$(date '+%Y%m%d_%H%M%S').log"

# ===== ARGS =====
while [[ $# -gt 0 ]]; do
    case "$1" in
        --installed-only) INSTALLED_ONLY=true; shift ;;
        --category) FILTER_CATEGORY="$2"; shift 2 ;;
        --tool) FILTER_TOOL="$2"; shift 2 ;;
        *) echo "Unknown arg: $1"; exit 1 ;;
    esac
done

# ===== HELPERS =====

# Log to file + stdout
log() { echo -e "$*" | tee -a "$LOG_FILE"; }

# Run a test for a single tool.
# Args: tool_name display_name command [expected_string]
run_test() {
    local display="$2"
    local cmd="$3"
    local expect="${4:-}"

    # Check if tool binary is present first
    local binary
    binary=$(echo "$cmd" | awk '{print $1}')
    if ! command -v "$binary" &>/dev/null && [[ ! -f "$binary" ]]; then
        if $INSTALLED_ONLY; then
            SKIPPED+=("$display")
            log "  ${YELLOW}[${SKIP}]${NC} ${display} — not installed (skipped)"
            return
        fi
        FAIL+=("$display")
        ISSUES+=("$display: binary not found ($binary) — check PATH or install")
        log "  ${RED}[${CROSS}]${NC} ${display} — binary not found: $binary"
        return
    fi

    # Run the command with a timeout, capturing output
    local output
    local exit_code=0
    output=$(timeout 15s bash -c "$cmd" 2>&1) || exit_code=$?

    if [[ $exit_code -eq 124 ]]; then
        FAIL+=("$display")
        ISSUES+=("$display: timed out after 15s — may be hanging or waiting for input")
        log "  ${RED}[${CROSS}]${NC} ${display} — TIMEOUT"
        return
    fi

    # If an expected string is given, check for it
    if [[ -n "$expect" ]] && ! echo "$output" | grep -qi "$expect"; then
        FAIL+=("$display")
        ISSUES+=("$display: unexpected output (expected '$expect') — got: $(echo "$output" | head -2)")
        log "  ${RED}[${CROSS}]${NC} ${display} — unexpected output (expected: '$expect')"
        log "    → $(echo "$output" | head -3 | sed 's/^/    /')"
        return
    fi

    PASS+=("$display")
    log "  ${GREEN}[${CHECK}]${NC} ${display}"
}

# Category header
header() {
    log ""
    log "${MAGENTA}${BOLD}═══ $1 ═══${NC}"
}

# Should we run this category?
should_run_category() {
    [[ -z "$FILTER_CATEGORY" ]] || [[ "$FILTER_CATEGORY" == "$1" ]]
}

# Should we run this tool?
should_run_tool() {
    [[ -z "$FILTER_TOOL" ]] || [[ "$FILTER_TOOL" == "$1" ]]
}

# ===== BANNER =====
log ""
log "${BLUE}${BOLD}╔══════════════════════════════════════════╗${NC}"
log "${BLUE}${BOLD}║     Tilix Tools Installer Smoke Test     ║${NC}"
log "${BLUE}${BOLD}╚══════════════════════════════════════════╝${NC}"
log "  Started: $(date)"
log "  Log: $LOG_FILE"
log ""

# ===================================================
# PASSIVE OSINT
# ===================================================
if should_run_category "osint"; then
    header "PASSIVE OSINT"

    should_run_tool "sherlock"    && run_test "sherlock"    "sherlock"    "sherlock --help"           "usage"
    should_run_tool "holehe"      && run_test "holehe"      "holehe"      "holehe --help"             "usage"
    should_run_tool "socialscan"  && run_test "socialscan"  "socialscan"  "socialscan --help"         "usage"
    should_run_tool "theHarvester" && run_test "theHarvester" "theHarvester" "theHarvester --help"   "usage"
    should_run_tool "spiderfoot"  && run_test "spiderfoot"  "spiderfoot"  "spiderfoot --help"         "usage"
    should_run_tool "photon"      && run_test "photon"      "photon"      "photon --help"             "usage"
    should_run_tool "wappalyzer"  && run_test "wappalyzer"  "wappalyzer"  "wappalyzer --help"         "usage"
    should_run_tool "h8mail"      && run_test "h8mail"      "h8mail"      "h8mail --help"             "usage"
    should_run_tool "waybackurls" && run_test "waybackurls" "waybackurls" "echo '' | waybackurls --help 2>&1 || waybackurls --help" "usage"
    should_run_tool "assetfinder" && run_test "assetfinder" "assetfinder" "assetfinder --help 2>&1 || true" "usage"
    should_run_tool "subfinder"   && run_test "subfinder"   "subfinder"   "subfinder -version"        "subfinder"
    should_run_tool "git-hound"   && run_test "git-hound"   "git-hound"   "git-hound --help"          "usage"
fi

# ===================================================
# DOMAIN & SUBDOMAIN ENUMERATION
# ===================================================
if should_run_category "domain"; then
    header "DOMAIN & SUBDOMAIN ENUMERATION"

    should_run_tool "sublist3r" && run_test "sublist3r" "sublist3r" "sublist3r --help" "usage"
    should_run_tool "gobuster"  && run_test "gobuster"  "gobuster"  "gobuster version" "gobuster"
    should_run_tool "ffuf"      && run_test "ffuf"      "ffuf"      "ffuf --help 2>&1 | head -5" "usage"
fi

# ===================================================
# ACTIVE RECON & SCANNING
# ===================================================
if should_run_category "recon"; then
    header "ACTIVE RECON & SCANNING"

    should_run_tool "httprobe"     && run_test "httprobe"     "httprobe"     "httprobe --help 2>&1 || true"  "usage"
    should_run_tool "rustscan"     && run_test "rustscan"     "rustscan"     "rustscan --version"             "rustscan"
    should_run_tool "feroxbuster"  && run_test "feroxbuster"  "feroxbuster"  "feroxbuster --version"          "feroxbuster"
    should_run_tool "nuclei"       && run_test "nuclei"       "nuclei"       "nuclei -version"                "nuclei"
fi

# ===================================================
# CYBER THREAT INTELLIGENCE
# ===================================================
if should_run_category "cti"; then
    header "CYBER THREAT INTELLIGENCE"

    should_run_tool "shodan"      && run_test "shodan"      "shodan"      "shodan --help"             "usage"
    should_run_tool "censys"      && run_test "censys"      "censys"      "censys --help 2>&1"        "usage"
    should_run_tool "yara"        && run_test "yara"        "yara"        "yara --version"            "yara"
    should_run_tool "trufflehog"  && run_test "trufflehog"  "trufflehog"  "trufflehog --version"      "trufflehog"
    should_run_tool "vt"          && run_test "vt"          "virustotal"  "vt --help"                 "usage"
fi

# ===================================================
# SECURITY TESTING
# ===================================================
if should_run_category "security"; then
    header "SECURITY TESTING"

    should_run_tool "jwt-cracker" && run_test "jwt-cracker" "jwt-cracker" "jwt-cracker --help 2>&1 || true" "usage"
fi

# ===================================================
# UTILITIES
# ===================================================
if should_run_category "utilities"; then
    header "UTILITIES"

    should_run_tool "ripgrep"  && run_test "ripgrep"  "ripgrep (rg)"   "rg --version"        "ripgrep"
    should_run_tool "fd"       && run_test "fd"       "fd"              "fd --version"        "fd"
    should_run_tool "bat"      && run_test "bat"      "bat"             "bat --version"       "bat"
    should_run_tool "sd"       && run_test "sd"       "sd"              "sd --version"        "sd"
    should_run_tool "dog"      && run_test "dog"      "dog"             "dog --version"       "dog"
    should_run_tool "aria2"    && run_test "aria2"    "aria2 (aria2c)"  "aria2c --version"    "aria2"
fi

# ===================================================
# WEB TOOLS
# ===================================================
if should_run_category "web"; then
    header "WEB TOOLS"

    # Chrome — root-safe check
    should_run_tool "google-chrome" && run_test "google-chrome" "Google Chrome" \
        "google-chrome --no-sandbox --version 2>/dev/null || google-chrome --version 2>/dev/null" \
        "google chrome"

    # SeleniumBase
    should_run_tool "seleniumbase" && run_test "seleniumbase" "SeleniumBase (sbase)" \
        "sbase --version 2>/dev/null || python3 -c 'import seleniumbase; print(seleniumbase.__version__)'" \
        ""

    # Playwright
    should_run_tool "playwright" && run_test "playwright" "Playwright" \
        "python3 -c 'import playwright; print(playwright.__version__)'" \
        ""

    # Yandex Browser
    should_run_tool "yandex_browser" && run_test "yandex_browser" "Yandex Browser" \
        "yandex-browser-beta --version 2>/dev/null || echo 'yandex-browser-beta not in PATH'" \
        "yandex"

    # Tor Browser
    should_run_tool "tor_browser" && run_test "tor_browser" "Tor Browser" \
        "[ -f \$HOME/opt/tor-browser/Browser/start-tor-browser ] && echo 'tor-browser: OK'" \
        "ok"

    # qTox
    should_run_tool "qtox" && run_test "qtox" "qTox" \
        "[ -f \$HOME/opt/qtox/squashfs-root/AppRun ] && [ -f \$HOME/.local/bin/qtox ] && echo 'qtox: OK'" \
        "ok"
fi

# ===================================================
# SUMMARY
# ===================================================
log ""
log "${BLUE}${BOLD}╔══════════════════════════════════════════╗${NC}"
log "${BLUE}${BOLD}║              Smoke Test Summary          ║${NC}"
log "${BLUE}${BOLD}╚══════════════════════════════════════════╝${NC}"
log ""
log "  ${GREEN}Passed : ${#PASS[@]}${NC}"
log "  ${RED}Failed : ${#FAIL[@]}${NC}"
log "  ${YELLOW}Skipped: ${#SKIPPED[@]}${NC}"
log ""

if [[ ${#FAIL[@]} -gt 0 ]]; then
    log "${RED}${BOLD}Issues Found:${NC}"
    for issue in "${ISSUES[@]}"; do
        log "  ${RED}${CROSS}${NC} $issue"
    done
    log ""
    log "Full log: $LOG_FILE"
    exit 1
else
    log "${GREEN}${BOLD}All tests passed.${NC}"
    log "Full log: $LOG_FILE"
    exit 0
fi
