#!/usr/bin/env bash
# test_harness.sh — Install a tool category and verify each tool.
# Usage: bash scripts/test_harness.sh <category-name> <install-flag> tool1 tool2 ...
# Example: bash scripts/test_harness.sh osint --osint-tools sherlock holehe socialscan

set -uo pipefail

CATEGORY="${1:?Usage: test_harness.sh <category> <flag> <tool...>}"
INSTALL_FLAG="${2:?Missing install flag}"
shift 2
TOOLS=("$@")

RESULTS_DIR="${HOME}/test-results/${CATEGORY}"
INSTALL_LOG="${RESULTS_DIR}/install.log"
SUMMARY="${RESULTS_DIR}/summary.txt"

mkdir -p "${RESULTS_DIR}"

# Source environment
# shellcheck disable=SC1090
source "${HOME}/.bashrc" 2>/dev/null || true
export PATH="${HOME}/.local/bin:${HOME}/opt/gopath/bin:${HOME}/.cargo/bin:${PATH}"
export GOPATH="${HOME}/opt/gopath"
export CARGO_HOME="${HOME}/.cargo"

# Install the category
echo "=== Installing ${CATEGORY} (${INSTALL_FLAG}) ==="
cd "${HOME}/tilix-tools-installer"
bash install_security_tools.sh "${INSTALL_FLAG}" 2>&1 | tee "${INSTALL_LOG}"
INSTALL_RC=${PIPESTATUS[0]}
echo "Install exit code: ${INSTALL_RC}" | tee -a "${INSTALL_LOG}"

# Tool verification commands — "binary-path|launch-command"
declare -A VERIFY
VERIFY[sherlock]="${HOME}/.local/bin/sherlock|sherlock --help 2>&1 | head -3"
VERIFY[holehe]="${HOME}/.local/bin/holehe|holehe --help 2>&1 | head -3"
VERIFY[socialscan]="${HOME}/.local/bin/socialscan|socialscan --help 2>&1 | head -3"
VERIFY[theHarvester]="${HOME}/.local/bin/theHarvester|theHarvester -h 2>&1 | head -3"
VERIFY[spiderfoot]="${HOME}/.local/bin/spiderfoot|spiderfoot --help 2>&1 | head -3"
VERIFY[photon]="${HOME}/.local/bin/photon|photon --help 2>&1 | head -3"
VERIFY[wappalyzer]="${HOME}/.local/bin/wappalyzer|wappalyzer --help 2>&1 | head -3"
VERIFY[h8mail]="${HOME}/.local/bin/h8mail|h8mail --help 2>&1 | head -3"
VERIFY[waybackurls]="${HOME}/opt/gopath/bin/waybackurls|waybackurls --help 2>&1 | head -3"
VERIFY[assetfinder]="${HOME}/opt/gopath/bin/assetfinder|assetfinder --help 2>&1 | head -3"
VERIFY[subfinder]="${HOME}/opt/gopath/bin/subfinder|subfinder --version 2>&1 | head -3"
VERIFY[git-hound]="${HOME}/.local/bin/git-hound|git-hound --help 2>&1 | head -3"
VERIFY[sublist3r]="${HOME}/.local/bin/sublist3r|sublist3r --help 2>&1 | head -3"
VERIFY[gobuster]="${HOME}/opt/gopath/bin/gobuster|gobuster --help 2>&1 | head -3"
VERIFY[ffuf]="${HOME}/opt/gopath/bin/ffuf|ffuf --help 2>&1 | head -3"
VERIFY[httprobe]="${HOME}/opt/gopath/bin/httprobe|httprobe --help 2>&1 | head -3"
VERIFY[rustscan]="${HOME}/.local/bin/rustscan|rustscan --help 2>&1 | head -3"
VERIFY[feroxbuster]="${HOME}/.local/bin/feroxbuster|feroxbuster --help 2>&1 | head -3"
VERIFY[nuclei]="${HOME}/opt/gopath/bin/nuclei|nuclei --version 2>&1 | head -3"
VERIFY[shodan]="${HOME}/.local/bin/shodan|shodan --help 2>&1 | head -3"
VERIFY[censys]="${HOME}/.local/bin/censys|censys --help 2>&1 | head -3"
VERIFY[yara]="${HOME}/.local/bin/yara|yara --version 2>&1 | head -3"
VERIFY[trufflehog]="${HOME}/.local/bin/trufflehog|trufflehog --help 2>&1 | head -3"
VERIFY[virustotal]="${HOME}/opt/gopath/bin/vt|vt --help 2>&1 | head -3"
VERIFY[jwt-cracker]="${HOME}/.local/bin/jwt-cracker|jwt-cracker --help 2>&1 | head -3"
VERIFY[ripgrep]="${HOME}/.local/bin/ripgrep|rg --version 2>&1 | head -2"
VERIFY[fd]="${HOME}/.local/bin/fd|fd --version 2>&1 | head -2"
VERIFY[bat]="${HOME}/.local/bin/bat|bat --version 2>&1 | head -2"
VERIFY[sd]="${HOME}/.local/bin/sd|sd --version 2>&1 | head -2"
VERIFY[dog]="${HOME}/.local/bin/dog|dog --version 2>&1 | head -2"
VERIFY[aria2]="${HOME}/.local/bin/aria2c|aria2c --version 2>&1 | head -2"
VERIFY[seleniumbase]="${HOME}/.local/bin/sbase|sbase --version 2>&1 | head -2"
VERIFY[playwright]="${HOME}/.local/bin/playwright|playwright --version 2>&1 | head -2"
VERIFY[yandex_browser]="${HOME}/.local/bin/yandex-browser|ls -la ${HOME}/.local/bin/yandex-browser 2>&1"
VERIFY[tor_browser]="${HOME}/.local/bin/tor-browser|ls -la ${HOME}/.local/bin/tor-browser 2>&1"
VERIFY[qtox]="${HOME}/.local/bin/qtox|ls -la ${HOME}/.local/bin/qtox 2>&1"

# Test each tool
PASS=0
FAIL=0
WARN=0

{
    echo "=== Test Results: ${CATEGORY} ==="
    echo "Install exit code: ${INSTALL_RC}"
    echo "Tested at: $(date)"
    echo ""
} > "${SUMMARY}"

for tool in "${TOOLS[@]}"; do
    RESULT_FILE="${RESULTS_DIR}/${tool}.result"
    entry="${VERIFY[$tool]:-}"

    if [[ -z "${entry}" ]]; then
        echo "SKIP ${tool} — no verify entry" | tee -a "${SUMMARY}"
        continue
    fi

    IFS='|' read -r binary launch_cmd <<< "${entry}"

    {
        echo "=== ${tool} ==="
        echo "Expected binary: ${binary}"

        if [[ -f "${binary}" ]]; then
            echo "BINARY: FOUND at ${binary}"
        elif command -v "${tool}" &>/dev/null; then
            echo "BINARY: FOUND via PATH ($(command -v "${tool}" 2>/dev/null))"
        else
            echo "BINARY: MISSING — expected at ${binary}"
        fi

        echo "--- Launch output ---"
        eval "${launch_cmd}" 2>&1
        LAUNCH_RC=$?
        echo "--- Launch exit code: ${LAUNCH_RC} ---"
    } > "${RESULT_FILE}" 2>&1

    if grep -q "BINARY: FOUND" "${RESULT_FILE}"; then
        if grep -q "Launch exit code: 0" "${RESULT_FILE}"; then
            STATUS="PASS"
            PASS=$((PASS + 1))
        else
            STATUS="WARN"
            WARN=$((WARN + 1))
        fi
    else
        STATUS="FAIL"
        FAIL=$((FAIL + 1))
    fi

    echo "${STATUS} ${tool}" | tee -a "${SUMMARY}"
done

{
    echo ""
    echo "=== Summary ==="
    echo "PASS: ${PASS}  WARN: ${WARN}  FAIL: ${FAIL}  TOTAL: $((PASS + WARN + FAIL))"
} | tee -a "${SUMMARY}"
