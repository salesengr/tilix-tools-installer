#!/bin/bash
# Security Tools Installer - Tool-Specific Installers Module
# Version: 1.3.0
# Purpose: Tool-specific installation logic and wrapper functions

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
    local logfile=$(create_tool_log "photon")

    echo -e "${INFO}⚙ Activating Python environment...${NC}"

    {
        echo "=========================================="
        echo "Installing photon"
        echo "Started: $(date)"
        echo "=========================================="

        source "$XDG_DATA_HOME/virtualenvs/tools/bin/activate" || return 1

        mkdir -p "$HOME/opt/src"

        if [ -d "$HOME/opt/src/Photon/.git" ]; then
            echo "Updating existing Photon checkout..."
            git -C "$HOME/opt/src/Photon" pull --ff-only || return 1
        else
            echo "Cloning Photon from GitHub..."
            rm -rf "$HOME/opt/src/Photon"
            git clone --depth 1 "https://github.com/s0md3v/Photon.git" "$HOME/opt/src/Photon" || return 1
        fi

        echo "Installing Photon dependencies..."
        pip install --quiet -r "$HOME/opt/src/Photon/requirements.txt" || return 1

        deactivate

        echo "Creating wrapper script..."
        cat > "$HOME/.local/bin/photon" << 'WRAPPER_EOF'
#!/bin/bash
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
TOOL_PY="$XDG_DATA_HOME/virtualenvs/tools/bin/python"
TOOL_SCRIPT="$HOME/opt/src/Photon/photon.py"

if [ ! -x "$TOOL_PY" ]; then
    echo "Error: Python tools virtualenv not found at $TOOL_PY" >&2
    echo "Run: bash install_security_tools.sh python_venv" >&2
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
install_shodan() { install_python_tool "shodan" "shodan"; }
install_censys() { install_python_tool "censys" "censys"; }
# Function: install_theHarvester
# Purpose: Install active theHarvester release from GitHub (PyPI package is stale)
# Returns: 0 on success, 1 on failure
install_theHarvester() {
    local logfile=$(create_tool_log "theHarvester")

    echo -e "${INFO}⚙ Activating Python environment...${NC}"

    {
        echo "=========================================="
        echo "Installing theHarvester"
        echo "Started: $(date)"
        echo "=========================================="

        source "$XDG_DATA_HOME/virtualenvs/tools/bin/activate" || return 1

        echo "Installing latest theHarvester from GitHub..."
        pip install --quiet "git+https://github.com/laramies/theHarvester.git" || return 1

        deactivate

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
    local logfile=$(create_tool_log "spiderfoot")

    echo -e "${INFO}⚙ Activating Python environment...${NC}"

    {
        echo "=========================================="
        echo "Installing spiderfoot"
        echo "Started: $(date)"
        echo "=========================================="

        source "$XDG_DATA_HOME/virtualenvs/tools/bin/activate" || return 1

        mkdir -p "$HOME/opt/src"

        if [ -d "$HOME/opt/src/spiderfoot/.git" ]; then
            echo "Updating existing SpiderFoot checkout..."
            git -C "$HOME/opt/src/spiderfoot" pull --ff-only || return 1
        else
            echo "Cloning SpiderFoot from GitHub..."
            rm -rf "$HOME/opt/src/spiderfoot"
            git clone --depth 1 "https://github.com/smicallef/spiderfoot.git" "$HOME/opt/src/spiderfoot" || return 1
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
        pip install --quiet -r "$HOME/opt/src/spiderfoot/requirements.py313.txt" || return 1

        deactivate

        echo "Creating wrapper script..."
        cat > "$HOME/.local/bin/spiderfoot" << 'WRAPPER_EOF'
#!/bin/bash
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
TOOL_PY="$XDG_DATA_HOME/virtualenvs/tools/bin/python"
TOOL_SCRIPT="$HOME/opt/src/spiderfoot/sf.py"

if [ ! -x "$TOOL_PY" ]; then
    echo "Error: Python tools virtualenv not found at $TOOL_PY" >&2
    echo "Run: bash install_security_tools.sh python_venv" >&2
    exit 1
fi

if [ ! -f "$TOOL_SCRIPT" ]; then
    echo "Error: SpiderFoot script not found at $TOOL_SCRIPT" >&2
    echo "Run: bash install_security_tools.sh spiderfoot" >&2
    exit 1
fi

exec "$TOOL_PY" "$TOOL_SCRIPT" "$@"
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
    local logfile=$(create_tool_log "wappalyzer")

    echo -e "${INFO}⚙ Activating Python environment...${NC}"

    {
        echo "=========================================="
        echo "Installing wappalyzer"
        echo "Started: $(date)"
        echo "=========================================="

        source "$XDG_DATA_HOME/virtualenvs/tools/bin/activate" || return 1

        echo "Installing python-Wappalyzer..."
        pip install --quiet "python-Wappalyzer" || return 1

        deactivate

        echo "Creating wrapper script..."
        cat > "$HOME/.local/bin/wappalyzer" << 'WRAPPER_EOF'
#!/bin/bash
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
TOOL_PY="$XDG_DATA_HOME/virtualenvs/tools/bin/python"

if [ ! -x "$TOOL_PY" ]; then
    echo "Error: Python tools virtualenv not found at $TOOL_PY" >&2
    echo "Run: bash install_security_tools.sh python_venv" >&2
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
    local logfile=$(create_tool_log "yara")

    {
        echo "=========================================="
        echo "Installing YARA"
        echo "Started: $(date)"
        echo "=========================================="

        source "$XDG_DATA_HOME/virtualenvs/tools/bin/activate" || return 1

        echo "Installing yara-python..."
        pip install --quiet yara-python || return 1

        # Confirm Python module availability.
        python3 -c "import yara" >/dev/null 2>&1 || return 1

        deactivate

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
                    tar -xzf "$filename" || true
                    cd yara-4.5.0 || true
                    ./bootstrap.sh || true
                    ./configure --prefix="$HOME/.local" || true
                    make -j"$(nproc)" || true
                    make install || true
                    cd "$HOME/opt/src" || true
                    rm -rf yara-4.5.0 "$filename"
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
TOOL_PY="$XDG_DATA_HOME/virtualenvs/tools/bin/python"

if [ ! -x "$TOOL_PY" ]; then
    echo "Error: Python tools virtualenv not found at $TOOL_PY" >&2
    echo "Run: bash install_security_tools.sh python_venv" >&2
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

# ===== GO TOOL WRAPPERS =====

# Convenience wrappers for Go tools using generic installer
install_gobuster() { install_go_tool "gobuster" "github.com/OJ/gobuster/v3"; }
install_ffuf() { install_go_tool "ffuf" "github.com/ffuf/ffuf/v2"; }
install_httprobe() { install_go_tool "httprobe" "github.com/tomnomnom/httprobe"; }
install_waybackurls() { install_go_tool "waybackurls" "github.com/tomnomnom/waybackurls"; }
install_assetfinder() { install_go_tool "assetfinder" "github.com/tomnomnom/assetfinder"; }
install_subfinder() { install_go_tool "subfinder" "github.com/projectdiscovery/subfinder/v2/cmd/subfinder"; }
install_nuclei() { install_go_tool "nuclei" "github.com/projectdiscovery/nuclei/v3/cmd/nuclei"; }
install_virustotal() { install_go_tool "virustotal" "github.com/VirusTotal/vt-cli/vt"; }

# ===== NODE.JS TOOL WRAPPERS =====

# Convenience wrappers for Node.js tools using generic installer
install_trufflehog() { install_node_tool "trufflehog" "@trufflesecurity/trufflehog"; }
install_git-hound() { install_node_tool "git-hound" "git-hound"; }
install_jwt-cracker() { install_node_tool "jwt-cracker" "jwt-cracker"; }

# ===== RUST TOOL WRAPPERS =====

# Convenience wrappers for Rust tools using generic installer
install_feroxbuster() { install_rust_tool "feroxbuster" "feroxbuster"; }
install_rustscan() { install_rust_tool "rustscan" "rustscan"; }
install_ripgrep() { install_rust_tool "ripgrep" "ripgrep"; }
install_fd() { install_rust_tool "fd" "fd-find"; }
install_bat() { install_rust_tool "bat" "bat"; }
install_sd() { install_rust_tool "sd" "sd"; }
install_tokei() { install_rust_tool "tokei" "tokei"; }
install_dog() { install_rust_tool "dog" "dog"; }
