#!/bin/bash
# Security Tools Installer - Tool-Specific Installers Module
# Version: 1.4.0
# Purpose: Tool-specific installation logic and wrapper functions

# shellcheck disable=SC2034  # FAILED_INSTALL_LOGS used in parent script
# shellcheck disable=SC2329  # Go fallback stubs called indirectly via _install_go_with_fallback
# shellcheck disable=SC1091  # Source files in virtualenvs (dynamic paths)

# ===== PYTHON TOOL WRAPPERS =====

# Convenience wrappers for Python tools using generic installer
install_sherlock() { install_python_tool "sherlock" "sherlock-project"; }
install_holehe() { install_python_tool "holehe" "holehe"; }
install_socialscan() { install_python_tool "socialscan" "socialscan"; }
install_h8mail() { install_python_tool "h8mail" "h8mail"; }
# Function: install_photon
# Purpose: Install Photon from upstream GitHub (no maintained PyPI package)
# Returns: 0 on success, 1 on failure
install_photon() {
    local logfile
    logfile=$(create_tool_log "photon")

    echo -e "${INFO}⚙ Activating Python environment...${NC}"

    {
        echo "=========================================="
        echo "Installing photon"
        echo "Started: $(date)"
        echo "=========================================="

        # No venv — using pip --user with system Python
        local python_bin; python_bin=$(_get_python_bin)

        mkdir -p "$HOME/opt/src"

        # Pinned to a specific tag — update deliberately after review
        local PHOTON_VERSION="v1.3.3"
        if [ -d "$HOME/opt/src/Photon/.git" ]; then
            echo "Updating existing Photon checkout to ${PHOTON_VERSION}..."
            git -C "$HOME/opt/src/Photon" fetch --tags || return 1
            git -C "$HOME/opt/src/Photon" checkout "${PHOTON_VERSION}" || return 1
        else
            echo "Cloning Photon ${PHOTON_VERSION} from GitHub..."
            rm -rf "$HOME/opt/src/Photon"
            git clone --depth 1 --branch "${PHOTON_VERSION}" \
                "https://github.com/s0md3v/Photon.git" "$HOME/opt/src/Photon" || return 1
        fi

        echo "Installing Photon dependencies..."
        "$python_bin" -m pip install --user --quiet -r "$HOME/opt/src/Photon/requirements.txt" || return 1


        echo "Creating wrapper script..."
        cat > "$HOME/.local/bin/photon" << 'WRAPPER_EOF'
#!/bin/bash
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
TOOL_PY="$(command -v python3.13 || command -v python3)"
TOOL_SCRIPT="$HOME/opt/src/Photon/photon.py"

if [ ! -x "$TOOL_PY" ]; then
    echo "Error: Python not found at $TOOL_PY" >&2
    echo "Run: bash install_security_tools.sh python_venv" >&2  # ensures python3 available
    exit 1
fi

if [ ! -f "$TOOL_SCRIPT" ]; then
    echo "Error: Photon script not found at $TOOL_SCRIPT" >&2
    echo "Run: bash install_security_tools.sh photon" >&2
    exit 1
fi

exec "$TOOL_PY" "$TOOL_SCRIPT" "$@"
WRAPPER_EOF
        chmod +x "$HOME/.local/bin/photon"

        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1

    if is_installed "photon"; then
        echo -e "${SUCCESS}${CHECK} photon installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("photon")
        log_installation "photon" "success" "$logfile"
        cleanup_old_logs "photon"
        return 0
    else
        echo -e "${ERROR}${CROSS} photon installation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("photon")
        FAILED_INSTALL_LOGS["photon"]="$logfile"
        log_installation "photon" "failure" "$logfile"
        return 1
    fi
}
install_sublist3r() { install_python_tool "sublist3r" "sublist3r"; }
install_shodan() {
    # shodan imports pkg_resources which was removed from Python 3.13+ stdlib.
    # Install setuptools first to restore pkg_resources, then install shodan.
    local python_bin; python_bin=$(_get_python_bin)
    local logfile; logfile=$(create_tool_log "shodan")
    echo -e "${INFO}⚙ Installing shodan via pip --user...${NC}"
    {
        echo "Installing shodan"; echo "Started: $(date)"
        mkdir -p "$HOME/.local/bin"
        export PATH="$HOME/.local/bin:$PATH"
        # Install setuptools<70 which still ships pkg_resources (removed in newer versions)
        # Log but do not abort if setuptools install fails — shodan install below will catch it
        "$python_bin" -m pip install --user --quiet "setuptools<70" \
            || "$python_bin" -m pip install --user --quiet "setuptools" \
            || echo "WARNING: Could not install setuptools; shodan may fail at runtime"
        "$python_bin" -m pip install --user --quiet "shodan" || return 1
        # Patch the shodan wrapper to inject setuptools path if needed
        if [ -f "$HOME/.local/bin/shodan" ]; then
            # If pkg_resources still missing, create a patched wrapper
            if ! "$python_bin" -c "import pkg_resources" 2>/dev/null; then
                cat > "$HOME/.local/bin/shodan" << WRAPPER_EOF
#!/usr/bin/env python3
import sys
import types
try:
    import pkg_resources
except ImportError:
    pkg_resources = types.ModuleType("pkg_resources")
    pkg_resources.require = lambda *a, **kw: None
    sys.modules["pkg_resources"] = pkg_resources
import runpy
runpy.run_module("shodan.__main__", run_name="__main__", alter_sys=True)
WRAPPER_EOF
            fi
        fi
        echo "Completed: $(date)"
    } > "$logfile" 2>&1
    if is_installed "shodan"; then
        echo -e "${SUCCESS}${CHECK} shodan installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("shodan")
        log_installation "shodan" "success" "$logfile"
        cleanup_old_logs "shodan"
        return 0
    fi
    echo -e "${ERROR}${CROSS} shodan installation failed — see $logfile${NC}"
    FAILED_INSTALLS+=("shodan")
    FAILED_INSTALL_LOGS["shodan"]="$logfile"
    log_installation "shodan" "failure" "$logfile"
    return 1
}
install_censys() { install_python_tool "censys" "censys"; }
# Function: install_theHarvester
# Purpose: Install active theHarvester release from GitHub (PyPI package is stale)
# Returns: 0 on success, 1 on failure
install_theHarvester() {
    local logfile
    logfile=$(create_tool_log "theHarvester")

    echo -e "${INFO}⚙ Activating Python environment...${NC}"

    {
        echo "=========================================="
        echo "Installing theHarvester"
        echo "Started: $(date)"
        echo "=========================================="

        # No venv — using pip --user with system Python
        local python_bin; python_bin=$(_get_python_bin)

        # Pinned to a specific tag — update deliberately after review
        local THEHARVESTER_VERSION="v4.6.0"
        echo "Installing theHarvester ${THEHARVESTER_VERSION} from GitHub..."
        "$python_bin" -m pip install --user --quiet \
            "git+https://github.com/laramies/theHarvester.git@${THEHARVESTER_VERSION}" || return 1


        echo "Creating wrapper script..."
        create_python_wrapper "theHarvester"

        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1

    if is_installed "theHarvester"; then
        echo -e "${SUCCESS}${CHECK} theHarvester installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("theHarvester")
        log_installation "theHarvester" "success" "$logfile"
        cleanup_old_logs "theHarvester"
        return 0
    else
        echo -e "${ERROR}${CROSS} theHarvester installation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("theHarvester")
        FAILED_INSTALL_LOGS["theHarvester"]="$logfile"
        log_installation "theHarvester" "failure" "$logfile"
        return 1
    fi
}
# Function: install_spiderfoot
# Purpose: Install SpiderFoot from upstream source and use Python 3.13-friendly deps
# Returns: 0 on success, 1 on failure
install_spiderfoot() {
    local logfile
    logfile=$(create_tool_log "spiderfoot")

    echo -e "${INFO}⚙ Activating Python environment...${NC}"

    {
        echo "=========================================="
        echo "Installing spiderfoot"
        echo "Started: $(date)"
        echo "=========================================="

        # No venv — using pip --user with system Python
        local python_bin; python_bin=$(_get_python_bin)

        mkdir -p "$HOME/opt/src"

        # Pinned to a specific tag — update deliberately after review
        local SPIDERFOOT_VERSION="v4.0"
        if [ -d "$HOME/opt/src/spiderfoot/.git" ]; then
            echo "Updating existing SpiderFoot checkout to ${SPIDERFOOT_VERSION}..."
            git -C "$HOME/opt/src/spiderfoot" fetch --tags || return 1
            git -C "$HOME/opt/src/spiderfoot" checkout "${SPIDERFOOT_VERSION}" || return 1
        else
            echo "Cloning SpiderFoot ${SPIDERFOOT_VERSION} from GitHub..."
            rm -rf "$HOME/opt/src/spiderfoot"
            git clone --depth 1 --branch "${SPIDERFOOT_VERSION}" \
                "https://github.com/smicallef/spiderfoot.git" "$HOME/opt/src/spiderfoot" || return 1
        fi

        # SpiderFoot pins many upper bounds for older Python; strip only the
        # '<x' constraints to avoid source builds/incompatibilities on Python 3.13.
        awk '{
            line=$0
            sub(/#.*/, "", line)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", line)
            if (line=="") next
            sub(/,[[:space:]]*<[^,]+/, "", line)
            print line
        }' "$HOME/opt/src/spiderfoot/requirements.txt" > "$HOME/opt/src/spiderfoot/requirements.py313.txt"

        echo "Installing SpiderFoot dependencies..."
        "$python_bin" -m pip install --user --quiet -r "$HOME/opt/src/spiderfoot/requirements.py313.txt" || return 1


        echo "Creating wrapper script..."
        cat > "$HOME/.local/bin/spiderfoot" << 'WRAPPER_EOF'
#!/usr/bin/env bash
# SpiderFoot launcher — starts web UI detached from terminal.
# Override host/port via SF_HOST / SF_PORT environment variables.
TOOL_PY="$(command -v python3.13 || command -v python3)"
TOOL_SCRIPT="$HOME/opt/src/spiderfoot/sf.py"
SF_HOST="${SF_HOST:-127.0.0.1}"
SF_PORT="${SF_PORT:-5001}"

if [ ! -x "${TOOL_PY}" ]; then
    echo "Error: Python not found" >&2
    echo "Run: bash install_security_tools.sh python_venv" >&2
    exit 1
fi

if [ ! -f "${TOOL_SCRIPT}" ]; then
    echo "Error: SpiderFoot not found at ${TOOL_SCRIPT}" >&2
    echo "Run: bash install_security_tools.sh spiderfoot" >&2
    exit 1
fi

echo ""
echo "Starting SpiderFoot web UI..."
echo "  URL : http://${SF_HOST}:${SF_PORT}"
echo ""
echo "  Open in Chrome:"
echo "  chrome http://${SF_HOST}:${SF_PORT}"
echo ""

nohup "${TOOL_PY}" "${TOOL_SCRIPT}" -l "${SF_HOST}:${SF_PORT}" "$@" &>/dev/null &
SF_PID=$!
disown

sleep 1
if kill -0 "${SF_PID}" 2>/dev/null; then
    echo "SpiderFoot started (PID ${SF_PID})"
    echo "To stop: kill ${SF_PID}  or  pkill -f sf.py"
else
    echo "Error: SpiderFoot failed to start — check dependencies are installed" >&2
    exit 1
fi
echo ""
WRAPPER_EOF
        chmod +x "$HOME/.local/bin/spiderfoot"

        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1

    if is_installed "spiderfoot"; then
        echo -e "${SUCCESS}${CHECK} spiderfoot installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("spiderfoot")
        log_installation "spiderfoot" "success" "$logfile"
        cleanup_old_logs "spiderfoot"
        return 0
    else
        echo -e "${ERROR}${CROSS} spiderfoot installation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("spiderfoot")
        FAILED_INSTALL_LOGS["spiderfoot"]="$logfile"
        log_installation "spiderfoot" "failure" "$logfile"
        return 1
    fi
}
# Function: install_wappalyzer
# Purpose: Install python-Wappalyzer and provide a usable CLI wrapper
# Returns: 0 on success, 1 on failure
install_wappalyzer() {
    local logfile
    logfile=$(create_tool_log "wappalyzer")

    echo -e "${INFO}⚙ Activating Python environment...${NC}"

    {
        echo "=========================================="
        echo "Installing wappalyzer"
        echo "Started: $(date)"
        echo "=========================================="

        # No venv — using pip --user with system Python
        local python_bin; python_bin=$(_get_python_bin)

        echo "Installing python-Wappalyzer..."
        "$python_bin" -m pip install --user --quiet "python-Wappalyzer" || return 1


        echo "Creating wrapper script..."
        cat > "$HOME/.local/bin/wappalyzer" << 'WRAPPER_EOF'
#!/bin/bash
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
TOOL_PY="$(command -v python3.13 || command -v python3)"

if [ ! -x "$TOOL_PY" ]; then
    echo "Error: Python not found at $TOOL_PY" >&2
    echo "Run: bash install_security_tools.sh python_venv" >&2  # ensures python3 available
    exit 1
fi

exec "$TOOL_PY" - "$@" << 'PY_EOF'
import argparse
import json
import sys

parser = argparse.ArgumentParser(
    prog="wappalyzer",
    description="Detect web technologies for a target URL using python-Wappalyzer"
)
parser.add_argument("url", nargs="?", help="Target URL (e.g. https://example.com)")
parser.add_argument("--json", action="store_true", help="Output as JSON")
args = parser.parse_args()

if not args.url:
    parser.print_help()
    sys.exit(0)

from Wappalyzer import Wappalyzer, WebPage  # pylint: disable=import-error

webpage = WebPage.new_from_url(args.url)
wappalyzer = Wappalyzer.latest()
tech = sorted(wappalyzer.analyze(webpage))

if args.json:
    print(json.dumps(tech))
else:
    for item in tech:
        print(item)
PY_EOF
WRAPPER_EOF
        chmod +x "$HOME/.local/bin/wappalyzer"

        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1

    if is_installed "wappalyzer"; then
        echo -e "${SUCCESS}${CHECK} wappalyzer installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("wappalyzer")
        log_installation "wappalyzer" "success" "$logfile"
        cleanup_old_logs "wappalyzer"
        return 0
    else
        echo -e "${ERROR}${CROSS} wappalyzer installation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("wappalyzer")
        FAILED_INSTALL_LOGS["wappalyzer"]="$logfile"
        log_installation "wappalyzer" "failure" "$logfile"
        return 1
    fi
}

# ===== YARA (Special Python Tool with CLI Build/Wrapping Fallback) =====

# Function: install_yara
# Purpose: Install yara-python and provide a usable yara CLI in user-space
# Returns: 0 on success, 1 on failure
install_yara() {
    local logfile
    logfile=$(create_tool_log "yara")

    {
        echo "=========================================="
        echo "Installing YARA"
        echo "Started: $(date)"
        echo "=========================================="

        # yara-python requires gcc to compile its C extension.
        # Some images strip gcc in cleanup layers — restore it if missing.
        if ! command -v gcc &>/dev/null; then
            echo "gcc not found — attempting to install via apt..."
            if command -v apt-get &>/dev/null; then
                apt-get update -qq 2>/dev/null || true
                apt-get install -y --no-install-recommends gcc 2>/dev/null || true
            fi
            if ! command -v gcc &>/dev/null; then
                echo "ERROR: gcc is required for yara-python but could not be installed."
                echo "Install gcc first: apt-get install -y gcc"
                return 1
            fi
        fi

        # No venv — using pip --user with system Python
        local python_bin; python_bin=$(_get_python_bin)

        echo "Installing yara-python..."
        "$python_bin" -m pip install --user --quiet yara-python || return 1

        # Confirm Python module availability.
        "$python_bin" -c "import yara" >/dev/null 2>&1 || return 1


        # yara-python does not provide a native yara CLI binary.
        # Try native build first (if autotools are available), otherwise create
        # a lightweight CLI wrapper backed by yara-python.
        if [ ! -x "$HOME/.local/bin/yara" ]; then
            echo "YARA CLI not found, attempting native source build..."

            if command -v autoreconf >/dev/null 2>&1; then
                mkdir -p "$HOME/opt/src"
                cd "$HOME/opt/src" || return 1

                local filename="v4.5.0.tar.gz"
                local url="https://github.com/VirusTotal/yara/archive/${filename}"

                rm -rf yara-4.5.0 "$filename"

                if download_file "$url" "$filename"; then
                    local _yara_built=0
                    if tar -xzf "$filename" && cd yara-4.5.0; then
                        if ./bootstrap.sh \
                            && ./configure --prefix="$HOME/.local" \
                            && make -j"$(nproc)" \
                            && make install; then
                            _yara_built=1
                        else
                            echo "YARA native build failed — will use Python wrapper fallback"
                        fi
                    else
                        echo "YARA source extraction failed — will use Python wrapper fallback"
                    fi
                    cd "$HOME/opt/src" || true
                    rm -rf yara-4.5.0 "$filename"
                    [ "${_yara_built}" -eq 0 ] && true  # fall through to wrapper below
                else
                    echo "YARA source download failed — will use Python wrapper fallback"
                fi
            else
                echo "autoreconf not found; skipping native YARA build"
            fi
        fi

        if [ ! -x "$HOME/.local/bin/yara" ]; then
            echo "Creating yara CLI wrapper backed by yara-python..."
            cat > "$HOME/.local/bin/yara" << 'WRAPPER_EOF'
#!/bin/bash
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
TOOL_PY="$(command -v python3.13 || command -v python3)"

if [ ! -x "$TOOL_PY" ]; then
    echo "Error: Python not found at $TOOL_PY" >&2
    echo "Run: bash install_security_tools.sh python_venv" >&2  # ensures python3 available
    exit 1
fi

exec "$TOOL_PY" - "$@" << 'PY_EOF'
import argparse
import os
import sys
import yara  # pylint: disable=import-error

parser = argparse.ArgumentParser(
    prog="yara",
    description="Minimal yara CLI compatibility wrapper (yara-python backend)",
)
parser.add_argument("rule_file", nargs="?", help="Path to YARA rules file")
parser.add_argument("targets", nargs="*", help="Files or directories to scan")
parser.add_argument("-r", "--recursive", action="store_true", help="Recurse into directories")
args = parser.parse_args()

if not args.rule_file or not args.targets:
    parser.print_help()
    sys.exit(0)

rules = yara.compile(filepath=args.rule_file)


def iter_targets(paths, recursive):
    for path in paths:
        if os.path.isdir(path):
            if recursive:
                for root, _, files in os.walk(path):
                    for name in files:
                        yield os.path.join(root, name)
            else:
                for name in os.listdir(path):
                    full = os.path.join(path, name)
                    if os.path.isfile(full):
                        yield full
        else:
            yield path


exit_code = 0
for target in iter_targets(args.targets, args.recursive):
    try:
        matches = rules.match(target)
    except Exception as exc:  # pylint: disable=broad-exception-caught
        print(f"error scanning {target}: {exc}", file=sys.stderr)
        exit_code = 2
        continue

    if matches:
        print(f"{target}: " + " ".join(match.rule for match in matches))

sys.exit(exit_code)
PY_EOF
WRAPPER_EOF
            chmod +x "$HOME/.local/bin/yara"
        fi

        if [ ! -x "$HOME/.local/bin/yara" ]; then
            echo "ERROR: YARA CLI is still unavailable at $HOME/.local/bin/yara"
            return 1
        fi

        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1

    if is_installed "yara"; then
        echo -e "${SUCCESS}${CHECK} YARA installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("yara")
        log_installation "yara" "success" "$logfile"
        cleanup_old_logs "yara"
        return 0
    else
        echo -e "${ERROR}${CROSS} YARA installation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("yara")
        FAILED_INSTALL_LOGS["yara"]="$logfile"
        log_installation "yara" "failure" "$logfile"
        return 1
    fi
}

# ===== GO TOOL WRAPPERS — Pre-built binaries primary, go install fallback =====

# Function: _install_go_with_fallback
# Purpose: Try pre-built binary first, fall back to go install
# Parameters: $1=tool $2=repo $3=asset_pattern $4=binary_name $5=archive $6=go_module
_install_go_with_fallback() {
    local tool=$1 repo=$2 pattern=$3 binname=$4 archive=$5 gomod=$6
    local logfile
    logfile=$(create_tool_log "$tool")

    echo -e "${INFO}⬇ Installing $tool (pre-built binary)...${NC}"

    if install_prebuilt_binary "$tool" "$repo" "$pattern" "$binname" "$archive" 2>/dev/null; then
        if [ -x "$HOME/.local/bin/$tool" ]; then
            echo -e "${SUCCESS}${CHECK} $tool installed successfully (pre-built)${NC}"
            SUCCESSFUL_INSTALLS+=("$tool")
            log_installation "$tool" "success" "$logfile"
            cleanup_old_logs "$tool"
            return 0
        fi
    fi

    echo -e "${WARNING}${WARN} Pre-built download failed, falling back to go install...${NC}"
    if install_go_tool "$tool" "$gomod"; then
        return 0
    fi

    echo -e "${ERROR}${CROSS} $tool installation failed${NC}"
    FAILED_INSTALLS+=("$tool")
    FAILED_INSTALL_LOGS["$tool"]="$logfile"
    return 1
}

install_gobuster() {
    _install_go_with_fallback "gobuster" \
        "OJ/gobuster" \
        "Linux_x86_64\.tar\.gz" \
        "gobuster" "tar.gz" \
        "github.com/OJ/gobuster/v3"
}

install_ffuf() {
    _install_go_with_fallback "ffuf" \
        "ffuf/ffuf" \
        "linux_amd64\.tar\.gz" \
        "ffuf" "tar.gz" \
        "github.com/ffuf/ffuf/v2"
}

install_httprobe() {
    _install_go_with_fallback "httprobe" \
        "tomnomnom/httprobe" \
        "linux-amd64.*\.tgz" \
        "httprobe" "tar.gz" \
        "github.com/tomnomnom/httprobe"
}

install_waybackurls() {
    _install_go_with_fallback "waybackurls" \
        "tomnomnom/waybackurls" \
        "linux-amd64.*\.tgz" \
        "waybackurls" "tar.gz" \
        "github.com/tomnomnom/waybackurls"
}

install_assetfinder() {
    # No pre-built binary available — go install only
    install_go_tool "assetfinder" "github.com/tomnomnom/assetfinder"
}

install_subfinder() {
    _install_go_with_fallback "subfinder" \
        "projectdiscovery/subfinder" \
        "linux_amd64\.zip" \
        "subfinder" "zip" \
        "github.com/projectdiscovery/subfinder/v2/cmd/subfinder"
}

install_nuclei() {
    _install_go_with_fallback "nuclei" \
        "projectdiscovery/nuclei" \
        "linux_amd64\.zip" \
        "nuclei" "zip" \
        "github.com/projectdiscovery/nuclei/v3/cmd/nuclei"
}

install_virustotal() {
    # No pre-built binary available — go install only
    install_go_tool "virustotal" "github.com/VirusTotal/vt-cli/vt"
}

# ===== NODE.JS TOOL WRAPPERS =====

# Function: _install_node_with_fallback
# Purpose: Try pre-built binary first, fall back to npm install
_install_node_with_fallback() {
    local tool=$1 repo=$2 pattern=$3 binname=$4 archive=$5 npm_pkg=$6
    local logfile
    logfile=$(create_tool_log "$tool")

    echo -e "${INFO}⬇ Installing $tool (pre-built binary)...${NC}"

    if install_prebuilt_binary "$tool" "$repo" "$pattern" "$binname" "$archive" 2>/dev/null; then
        if [ -x "$HOME/.local/bin/$tool" ]; then
            echo -e "${SUCCESS}${CHECK} $tool installed successfully (pre-built)${NC}"
            SUCCESSFUL_INSTALLS+=("$tool")
            log_installation "$tool" "success" "$logfile"
            cleanup_old_logs "$tool"
            return 0
        fi
    fi

    echo -e "${WARNING}${WARN} Pre-built download failed, falling back to npm...${NC}"
    if install_node_tool "$tool" "$npm_pkg"; then
        return 0
    fi

    echo -e "${ERROR}${CROSS} $tool installation failed${NC}"
    FAILED_INSTALLS+=("$tool")
    FAILED_INSTALL_LOGS["$tool"]="$logfile"
    return 1
}

install_trufflehog() {
    _install_node_with_fallback "trufflehog" \
        "trufflesecurity/trufflehog" \
        "linux_amd64\.tar\.gz" \
        "trufflehog" "tar.gz" \
        "@trufflesecurity/trufflehog"
}

install_git-hound() {
    _install_node_with_fallback "git-hound" \
        "tillson/git-hound" \
        "linux_amd64\.zip" \
        "git-hound" "zip" \
        "git-hound"
}

install_jwt-cracker() { install_node_tool "jwt-cracker" "jwt-cracker"; }

# ===== RUST TOOL WRAPPERS =====

# Convenience wrappers for Rust tools using generic installer
# ===== RUST TOOLS — Pre-built binaries primary, cargo fallback =====

# Function: _install_rust_with_fallback
# Purpose: Try pre-built binary first, fall back to cargo compile
# Parameters: $1=tool $2=repo $3=asset_pattern $4=binary_name $5=archive $6=crate $7=crate_version (optional)
_install_rust_with_fallback() {
    local tool=$1 repo=$2 pattern=$3 binname=$4 archive=$5 crate=$6
    local crate_version=${7:-}   # optional pinned crate version for cargo fallback
    local logfile
    logfile=$(create_tool_log "$tool")

    echo -e "${INFO}⬇ Installing $tool (pre-built binary)...${NC}"

    if install_prebuilt_binary "$tool" "$repo" "$pattern" "$binname" "$archive" 2>/dev/null; then
        if [ -x "$HOME/.local/bin/$tool" ]; then
            echo -e "${SUCCESS}${CHECK} $tool installed successfully (pre-built)${NC}"
            SUCCESSFUL_INSTALLS+=("$tool")
            log_installation "$tool" "success" "$logfile"
            cleanup_old_logs "$tool"
            return 0
        fi
    fi

    echo -e "${WARNING}${WARN} Pre-built download failed, falling back to cargo compile...${NC}"
    if install_rust_tool "$tool" "$crate" "$crate_version"; then
        return 0
    fi

    echo -e "${ERROR}${CROSS} $tool installation failed${NC}"
    FAILED_INSTALLS+=("$tool")
    FAILED_INSTALL_LOGS["$tool"]="$logfile"
    return 1
}

install_feroxbuster() {
    _install_rust_with_fallback "feroxbuster" \
        "epi052/feroxbuster" \
        "x86_64-linux.*\.tar\.gz" \
        "feroxbuster" \
        "tar.gz" \
        "feroxbuster" \
        "2.10.4"
}

install_rustscan() {
    # RustScan ships a zip containing a tar.gz — extract zip then tar
    local logfile
    logfile=$(create_tool_log "rustscan")
    echo -e "${INFO}⬇ Installing rustscan (pre-built binary)...${NC}"
    {
        echo "Installing rustscan"; echo "Started: $(date)"
        mkdir -p "$HOME/.local/bin" "$HOME/opt/src"
        local api_url="https://api.github.com/repos/RustScan/RustScan/releases/latest"
        local asset_url
        asset_url=$(curl -fsSL "$api_url" 2>/dev/null \
            | grep -oP '"browser_download_url":\s*"\K[^"]+' \
            | grep "x86_64-linux-rustscan\.tar\.gz\.zip" \
            | head -1)
        if [[ -z "$asset_url" ]]; then echo "ERROR: asset not found"; return 1; fi
        echo "Downloading: $asset_url"
        cd "$HOME/opt/src" || return 1
        curl -fsSL "$asset_url" -o rustscan.zip || return 1
        unzip -q rustscan.zip 2>/dev/null || true
        local tgz
        tgz=$(find . -name "*.tar.gz" | head -1)
        if [[ -n "$tgz" ]]; then
            tar -xzf "$tgz" 2>/dev/null || true
        fi
        local bin
        bin=$(find . -name "rustscan" -type f 2>/dev/null | head -1)
        if [[ -n "$bin" ]]; then
            cp "$bin" "$HOME/.local/bin/rustscan"
            chmod +x "$HOME/.local/bin/rustscan"
        else
            echo "ERROR: rustscan binary not found"; return 1
        fi
        rm -f rustscan.zip "$tgz"
        echo "Completed: $(date)"
    } > "$logfile" 2>&1
    if [ -x "$HOME/.local/bin/rustscan" ]; then
        echo -e "${SUCCESS}${CHECK} rustscan installed successfully (pre-built)${NC}"
        SUCCESSFUL_INSTALLS+=("rustscan")
        log_installation "rustscan" "success" "$logfile"
        cleanup_old_logs "rustscan"
        return 0
    fi
    echo -e "${WARNING}${WARN} Pre-built download failed, falling back to cargo...${NC}"
    install_rust_tool "rustscan" "rustscan" "2.3.0"
}

install_ripgrep() {
    _install_rust_with_fallback "ripgrep" \
        "BurntSushi/ripgrep" \
        "x86_64-unknown-linux-musl\.tar\.gz" \
        "rg" \
        "tar.gz" \
        "ripgrep" \
        "14.1.1"
}

install_fd() {
    _install_rust_with_fallback "fd" \
        "sharkdp/fd" \
        "x86_64-unknown-linux-musl\.tar\.gz" \
        "fd" \
        "tar.gz" \
        "fd-find" \
        "10.2.0"
}

install_bat() {
    _install_rust_with_fallback "bat" \
        "sharkdp/bat" \
        "x86_64-unknown-linux-musl\.tar\.gz" \
        "bat" \
        "tar.gz" \
        "bat" \
        "0.24.0"
}



# ===== UTILITY TOOL INSTALLERS =====

# Function: install_aria2
# Purpose: Install aria2 pre-built binary into user-space (~/.local/bin)
#          aria2 was originally in the Tilix Dockerfile but was commented out.
#          This installer adds it to user-space without requiring root.
# Returns: 0 on success, 1 on failure
install_aria2() {
    local logfile
    logfile=$(create_tool_log "aria2")

    echo -e "${INFO}⬇ Downloading aria2 pre-built binary...${NC}"

    {
        echo "=========================================="
        echo "Installing aria2"
        echo "Started: $(date)"
        echo "=========================================="

        mkdir -p "$HOME/.local/bin" "$HOME/opt/src"

        # Detect architecture
        local arch
        arch=$(uname -m)
        case "$arch" in
            x86_64)  arch_tag="x86_64" ;;
            aarch64) arch_tag="aarch64" ;;
            *)
                echo "ERROR: Unsupported architecture: $arch"
                return 1
                ;;
        esac

        # Fetch latest release tag from GitHub API
        local latest_tag
        latest_tag=$(curl -fsSL "https://api.github.com/repos/aria2/aria2/releases/latest" \
            | grep -oP '"tag_name":\s*"\K[^"]+')

        if [[ -z "$latest_tag" ]]; then
            echo "ERROR: Could not determine latest aria2 release tag"
            return 1
        fi

        echo "Latest aria2 release: $latest_tag"

        # aria2 distributes static Linux binaries via GitHub Actions artifacts,
        # but official release assets are source tarballs only.
        # Use the abcguitar/aria2-static-build releases which provide
        # pre-built static binaries, or fall back to building from source via apt.
        # Simplest reliable approach for Debian/Ubuntu (Tilix base): use the
        # system package manager to install into the user prefix.

        echo "Attempting install via system package manager..."

        if command -v apt-get &>/dev/null; then
            # Strategy 1: direct install (works if running as root, e.g. in Docker)
            apt-get update -qq 2>/dev/null || true
            if apt-get install -y --no-install-recommends aria2 2>/dev/null; then
                local sys_bin
                sys_bin=$(command -v aria2c 2>/dev/null)
                if [ -n "$sys_bin" ]; then
                    cp "$sys_bin" "$HOME/.local/bin/aria2c"
                    chmod +x "$HOME/.local/bin/aria2c"
                    echo "aria2c installed via apt and copied to user-space"
                fi
            else
                # Strategy 2: apt-get download + dpkg extract (no root needed)
                echo "Direct apt install failed, trying package extraction..."
                local tmp_prefix="$HOME/opt/src/aria2-pkg"
                mkdir -p "$tmp_prefix"
                cd "$tmp_prefix" || return 1

                if apt-get download aria2 2>/dev/null && ls aria2_*.deb &>/dev/null; then
                    dpkg -x aria2_*.deb . 2>/dev/null || true
                    if [ -f "./usr/bin/aria2c" ]; then
                        cp ./usr/bin/aria2c "$HOME/.local/bin/aria2c"
                        chmod +x "$HOME/.local/bin/aria2c"
                        echo "aria2c installed from package extraction"
                    fi
                fi

                cd "$HOME" || true
                rm -rf "$tmp_prefix"
            fi
        fi

        # No further fallback — community-maintained third-party binaries (e.g.
        # p3ng0s/static-aria2) are excluded on supply chain grounds: no provenance
        # guarantee, no checksum, no affiliation with the upstream aria2 project.
        # If apt strategies above both failed, report clearly.
        if [ ! -f "$HOME/.local/bin/aria2c" ]; then
            echo "ERROR: aria2 could not be installed via apt — ensure apt-get is available and the package index is populated"
            return 1
        fi

        # Create convenience symlink aria2 -> aria2c
        if [ -f "$HOME/.local/bin/aria2c" ] && [ ! -e "$HOME/.local/bin/aria2" ]; then
            ln -sf "$HOME/.local/bin/aria2c" "$HOME/.local/bin/aria2"
            echo "Created symlink: aria2 -> aria2c"
        fi

        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1

    if is_installed "aria2"; then
        local version
        version=$("$HOME/.local/bin/aria2c" --version 2>/dev/null | head -1 || echo "unknown")
        echo -e "${SUCCESS}${CHECK} aria2 installed successfully ($version)${NC}"
        SUCCESSFUL_INSTALLS+=("aria2")
        log_installation "aria2" "success" "$logfile"
        cleanup_old_logs "aria2"
        return 0
    else
        echo -e "${ERROR}${CROSS} aria2 installation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("aria2")
        FAILED_INSTALL_LOGS["aria2"]="$logfile"
        log_installation "aria2" "failure" "$logfile"
        return 1
    fi
}

# ===== WEB TOOLS =====

# Function: install_seleniumbase
# Purpose: Install SeleniumBase via pip --user
#          Provides UC Mode and CDP Mode for bypassing bot-detection and CAPTCHAs.
#          Works with the system Chrome already present in the Tilix image.
install_seleniumbase() {
    local logfile
    logfile=$(create_tool_log "seleniumbase")
    echo -e "${INFO}⚙ Installing SeleniumBase via pip --user...${NC}"
    {
        echo "Installing seleniumbase"
        echo "Started: $(date)"
        local python_bin; python_bin=$(_get_python_bin)
        mkdir -p "$HOME/.local/bin"
        # Note: seleniumbase requires selenium as a direct dependency and will
        # install selenium 4.41+ to ~/.local even though selenium 4.40 is
        # system-wide. The ~28MB duplicate is unavoidable with pip --user.
        "$python_bin" -m pip install --user --quiet seleniumbase || return 1
        echo "Completed: $(date)"
    } > "$logfile" 2>&1
    if is_installed "seleniumbase"; then
        echo -e "${SUCCESS}${CHECK} SeleniumBase installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("seleniumbase")
        log_installation "seleniumbase" "success" "$logfile"
        cleanup_old_logs "seleniumbase"
        return 0
    fi
    echo -e "${ERROR}${CROSS} SeleniumBase installation failed — see $logfile${NC}"
    FAILED_INSTALLS+=("seleniumbase")
    FAILED_INSTALL_LOGS["seleniumbase"]="$logfile"
    log_installation "seleniumbase" "failure" "$logfile"
    return 1
}

# Function: install_playwright
# Purpose: Install Playwright Python package.
#          Uses the system Chrome (/usr/bin/google-chrome) already present in
#          the Tilix image — avoids downloading 620MB+ of Chromium binaries.
#          Set PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 to prevent any browser download.
install_playwright() {
    local logfile
    logfile=$(create_tool_log "playwright")
    echo -e "${INFO}⚙ Installing Playwright...${NC}"
    {
        echo "Installing playwright"
        echo "Started: $(date)"
        local python_bin; python_bin=$(_get_python_bin)
        mkdir -p "$HOME/.local/bin"
        # Install playwright Python package only — no browser download needed.
        # The Tilix image ships Google Chrome at /usr/bin/google-chrome.
        # Use: playwright.chromium.launch(executable_path="/usr/bin/google-chrome")
        PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD=1 "$python_bin" -m pip install --user --quiet playwright || return 1
        echo "NOTE: Using system Chrome at /usr/bin/google-chrome"
        echo "      Pass executable_path='/usr/bin/google-chrome' to launch()"

        # Create a detached launcher so `chrome` can be opened from the terminal
        # without keeping the shell attached. Uses nohup + disown, same pattern
        # as yandex-browser and qtox. The system google-chrome binary is left
        # untouched for programmatic use by Playwright and SeleniumBase.
        cat > "$HOME/.local/bin/chrome" << 'WRAPPER'
#!/usr/bin/env bash
# Chrome launcher — runs detached from terminal
nohup /usr/bin/google-chrome "$@" &>/dev/null &
disown
WRAPPER
        chmod +x "$HOME/.local/bin/chrome"

        echo "Completed: $(date)"
    } > "$logfile" 2>&1
    if is_installed "playwright"; then
        echo -e "${SUCCESS}${CHECK} Playwright installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("playwright")
        log_installation "playwright" "success" "$logfile"
        cleanup_old_logs "playwright"
        return 0
    fi
    echo -e "${ERROR}${CROSS} Playwright installation failed — see $logfile${NC}"
    FAILED_INSTALLS+=("playwright")
    FAILED_INSTALL_LOGS["playwright"]="$logfile"
    log_installation "playwright" "failure" "$logfile"
    return 1
}

# Function: install_yandex_browser
# Purpose: Install Yandex Browser via official APT repository (amd64 only)
#          Useful for Russian-language OSINT and accessing Yandex services.
install_yandex_browser() {
    local logfile
    logfile=$(create_tool_log "yandex_browser")
    echo -e "${INFO}⬇ Installing Yandex Browser...${NC}"
    {
        echo "Installing yandex_browser"
        echo "Started: $(date)"

        # amd64 only
        if [ "$(uname -m)" != "x86_64" ]; then
            echo "ERROR: Yandex Browser is only available for amd64 (x86_64)"
            return 1
        fi

        if ! command -v apt-get &>/dev/null; then
            echo "ERROR: apt-get required"
            return 1
        fi

        apt-get update -qq 2>/dev/null || true
        apt-get install -y --no-install-recommends gnupg2 curl 2>/dev/null || true

        # Add Yandex GPG key using the modern signed-by method (apt-key is deprecated
        # since Ubuntu 22.04 and removed in Debian bookworm).
        # /etc/apt/keyrings/ requires root — fail clearly if not writable.
        local keyring="/etc/apt/keyrings/yandex-browser.gpg"
        if [ ! -w /etc/apt/keyrings ] && [ ! -w /etc/apt ] && [ "$(id -u)" != "0" ]; then
            echo "ERROR: Cannot write to /etc/apt/keyrings — re-run as root or with sudo"
            return 1
        fi
        mkdir -p /etc/apt/keyrings
        curl -fsSL "https://repo.yandex.ru/yandex-browser/YANDEX-BROWSER-KEY.GPG" \
            | gpg --dearmor -o "${keyring}" || {
            echo "ERROR: Failed to import Yandex Browser GPG key"
            return 1
        }
        chmod 644 "${keyring}"
        echo "deb [arch=amd64 signed-by=${keyring}] http://repo.yandex.ru/yandex-browser/deb beta main" \
            > /etc/apt/sources.list.d/yandex-browser.list

        apt-get update -qq 2>/dev/null || true
        apt-get install -y --no-install-recommends yandex-browser-beta 2>/dev/null || return 1

        # Create launcher wrapper in ~/.local/bin
        mkdir -p "$HOME/.local/bin"
        cat > "$HOME/.local/bin/yandex-browser" << 'WRAPPER'
#!/usr/bin/env bash
# Yandex Browser launcher — runs detached from terminal
nohup /usr/bin/yandex-browser-beta "$@" &>/dev/null &
disown
WRAPPER
        chmod +x "$HOME/.local/bin/yandex-browser"

        echo "Completed: $(date)"
    } > "$logfile" 2>&1
    if is_installed "yandex_browser"; then
        echo -e "${SUCCESS}${CHECK} Yandex Browser installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("yandex_browser")
        log_installation "yandex_browser" "success" "$logfile"
        cleanup_old_logs "yandex_browser"
        return 0
    fi
    echo -e "${ERROR}${CROSS} Yandex Browser installation failed — see $logfile${NC}"
    FAILED_INSTALLS+=("yandex_browser")
    FAILED_INSTALL_LOGS["yandex_browser"]="$logfile"
    log_installation "yandex_browser" "failure" "$logfile"
    return 1
}

# Function: install_tor_browser
# Purpose: Install Tor Browser from official Tor Project release tarball
#          Provides anonymous browsing via Tor network for dark web OSINT.
install_tor_browser() {
    local logfile
    logfile=$(create_tool_log "tor_browser")
    echo -e "${INFO}⬇ Installing Tor Browser...${NC}"
    {
        echo "Installing tor_browser"
        echo "Started: $(date)"

        mkdir -p "$HOME/opt"

        # Fetch latest version from Tor Project dist
        local version
        version=$(curl -fsSL "https://www.torproject.org/dist/torbrowser/" 2>/dev/null \
            | grep -oE 'href="[0-9]+\.[0-9.]+/"' \
            | grep -oE '[0-9]+\.[0-9.]+' \
            | sort -V | tail -1)

        if [[ -z "$version" ]]; then
            version="15.0.8"  # fallback to known good version
        fi

        echo "Installing Tor Browser $version..."
        local filename="tor-browser-linux-x86_64-${version}.tar.xz"
        local url="https://www.torproject.org/dist/torbrowser/${version}/${filename}"

        # GPG is required for signature verification
        if ! command -v gpg &>/dev/null; then
            echo "ERROR: gpg not found — required for Tor Browser signature verification"
            return 1
        fi

        # Import Tor Browser Team signing key if not already in keyring
        # Fingerprint: EF6E286DDA85EA2A4BA7DE684E2C6E8793298290 (torproject.org)
        local TOR_KEY_FP="EF6E286DDA85EA2A4BA7DE684E2C6E8793298290"
        if ! gpg --list-keys "${TOR_KEY_FP}" &>/dev/null; then
            echo "Importing Tor Browser signing key ${TOR_KEY_FP}..."
            curl -fsSL "https://keys.openpgp.org/vks/v1/by-fingerprint/${TOR_KEY_FP}" \
                | gpg --import 2>&1 || {
                echo "ERROR: Could not import Tor Browser signing key"
                return 1
            }
            # Verify the imported key matches the expected fingerprint to prevent
            # key substitution attacks (e.g. a rogue key returned by the server)
            if ! gpg --list-keys "${TOR_KEY_FP}" &>/dev/null; then
                echo "ERROR: Imported key fingerprint does not match ${TOR_KEY_FP}"
                return 1
            fi
        fi

        cd "$HOME/opt" || return 1
        curl -fsSL "$url" -o "$filename" || return 1
        curl -fsSL "${url}.asc" -o "${filename}.asc" || {
            echo "ERROR: Could not download signature file"
            rm -f "$filename"
            return 1
        }

        # Verify detached signature — fail hard on mismatch
        echo "Verifying GPG signature..."
        if ! gpg --verify "${filename}.asc" "$filename" 2>&1; then
            echo "ERROR: GPG signature verification FAILED — aborting installation"
            rm -f "$filename" "${filename}.asc"
            return 1
        fi
        echo "GPG signature OK"
        rm -f "${filename}.asc"

        tar -xJf "$filename" 2>/dev/null || return 1
        rm -f "$filename"

        # Create launcher wrapper in ~/.local/bin
        # Unquoted heredoc so $HOME expands at write time; \$@ escapes for runtime
        cat > "$HOME/.local/bin/tor-browser" << WRAPPER
#!/usr/bin/env bash
exec "${HOME}/opt/tor-browser/Browser/start-tor-browser" --detach "\$@"
WRAPPER
        chmod +x "$HOME/.local/bin/tor-browser"

        echo "Tor Browser $version installed to ~/opt/tor-browser"
        echo "Completed: $(date)"
    } > "$logfile" 2>&1
    if is_installed "tor_browser"; then
        echo -e "${SUCCESS}${CHECK} Tor Browser installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("tor_browser")
        log_installation "tor_browser" "success" "$logfile"
        cleanup_old_logs "tor_browser"
        return 0
    fi
    echo -e "${ERROR}${CROSS} Tor Browser installation failed — see $logfile${NC}"
    FAILED_INSTALLS+=("tor_browser")
    FAILED_INSTALL_LOGS["tor_browser"]="$logfile"
    log_installation "tor_browser" "failure" "$logfile"
    return 1
}

install_sd() {
    # Use musl static build — avoids GLIBC_2.32 incompatibility on Ubuntu 20.04
    local logfile; logfile=$(create_tool_log "sd")
    echo -e "${INFO}⬇ Installing sd (pre-built musl binary)...${NC}"
    {
        echo "Installing sd"; echo "Started: $(date)"
        local api_url="https://api.github.com/repos/chmln/sd/releases/latest"
        local asset_url
        asset_url=$(curl -fsSL "$api_url" 2>/dev/null \
            | grep -oP '"browser_download_url":\s*"\K[^"]+' \
            | grep "x86_64-unknown-linux-musl\.tar\.gz" \
            | head -1)
        echo "Downloading musl: $asset_url"
        mkdir -p "$HOME/.local/bin" "$HOME/opt/src"
        cd "$HOME/opt/src" || return 1
        curl -fsSL "$asset_url" -o sd-musl.tar.gz || return 1
        tar -xzf sd-musl.tar.gz 2>/dev/null || true
        local found; found=$(find . -name "sd" -type f ! -name "*.tar.gz" 2>/dev/null | head -1)
        if [[ -n "$found" ]]; then
            cp "$found" "$HOME/.local/bin/sd"
            chmod +x "$HOME/.local/bin/sd"
        else
            echo "ERROR: sd binary not found in musl archive"; return 1
        fi
        rm -f sd-musl.tar.gz; echo "Completed: $(date)"
    } > "$logfile" 2>&1
    if [ -x "$HOME/.local/bin/sd" ]; then
        echo -e "${SUCCESS}${CHECK} sd installed successfully (pre-built musl)${NC}"
        SUCCESSFUL_INSTALLS+=("sd"); log_installation "sd" "success" "$logfile"; cleanup_old_logs "sd"; return 0
    fi
    echo -e "${WARNING}${WARN} musl download failed, falling back to cargo...${NC}"
    install_rust_tool "sd" "sd" "1.0.0"
}

install_dog() {
    # dog has no musl build; gnu binary requires GLIBC_2.32 (Ubuntu 20.04 has 2.31)
    # Compile from cargo — gcc is available in the Tilix image
    install_rust_tool "dog" "dog" "0.1.0"
}

# Function: install_qtox
# Purpose: Install qTox encrypted chat client via AppImage extraction.
#          AppImages normally require FUSE, which is unavailable in containers.
#          Using --appimage-extract mode instead — extracts to ~/opt/qtox/squashfs-root/
#          and runs directly without FUSE.
# Returns: 0 on success, 1 on failure
install_qtox() {
    local logfile
    logfile=$(create_tool_log "qtox")
    echo -e "${INFO}⬇ Installing qTox (AppImage extract mode)...${NC}"
    {
        echo "Installing qTox"
        echo "Started: $(date)"

        mkdir -p "$HOME/opt" "$HOME/.local/bin"

        # Fetch latest release asset URL
        local api_url="https://api.github.com/repos/TokTok/qTox/releases/latest"
        local asset_url
        asset_url=$(curl -fsSL "$api_url" 2>/dev/null \
            | grep -oP '"browser_download_url":\s*"\K[^"]+' \
            | grep "x86_64\.AppImage" \
            | grep -v "\.asc\|\.sha256\|\.zsync" \
            | head -1)

        if [[ -z "$asset_url" ]]; then
            echo "ERROR: Could not find qTox AppImage asset"
            return 1
        fi

        echo "Downloading: $asset_url"
        cd "$HOME/opt" || return 1
        curl -fsSL "$asset_url" -o qtox.AppImage || return 1
        chmod +x qtox.AppImage

        # Extract AppImage without FUSE (container-compatible)
        echo "Extracting AppImage (FUSE-free mode)..."
        rm -rf qtox/squashfs-root
        mkdir -p qtox
        cd qtox || return 1
        ../qtox.AppImage --appimage-extract 2>/dev/null || true
        cd "$HOME/opt" || return 1
        rm -f qtox.AppImage

        if [ ! -f "$HOME/opt/qtox/squashfs-root/AppRun" ]; then
            echo "ERROR: AppImage extraction failed — AppRun not found"
            return 1
        fi

        # Create launcher wrapper
        # Unquoted heredoc so $HOME expands at write time; \$@ escapes for runtime
        cat > "$HOME/.local/bin/qtox" << WRAPPER
#!/usr/bin/env bash
# qTox launcher — runs extracted AppImage without FUSE, detached from terminal
nohup "${HOME}/opt/qtox/squashfs-root/AppRun" "\$@" &>/dev/null &
disown
WRAPPER
        chmod +x "$HOME/.local/bin/qtox"

        echo "qTox installed at ~/opt/qtox/squashfs-root/"
        echo "Completed: $(date)"
    } > "$logfile" 2>&1

    if is_installed "qtox"; then
        echo -e "${SUCCESS}${CHECK} qTox installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("qtox")
        log_installation "qtox" "success" "$logfile"
        cleanup_old_logs "qtox"
        return 0
    fi
    echo -e "${ERROR}${CROSS} qTox installation failed — see $logfile${NC}"
    FAILED_INSTALLS+=("qtox")
    FAILED_INSTALL_LOGS["qtox"]="$logfile"
    log_installation "qtox" "failure" "$logfile"
    return 1
}
