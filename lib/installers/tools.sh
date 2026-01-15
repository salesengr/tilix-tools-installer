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
install_photon() { install_python_tool "photon" "photon-python"; }
install_sublist3r() { install_python_tool "sublist3r" "sublist3r"; }
install_shodan() { install_python_tool "shodan" "shodan"; }
install_censys() { install_python_tool "censys" "censys"; }
install_theHarvester() { install_python_tool "theHarvester" "theHarvester"; }
install_spiderfoot() { install_python_tool "spiderfoot" "spiderfoot"; }
install_wappalyzer() { install_python_tool "wappalyzer" "python-Wappalyzer"; }

# ===== YARA (Special Python Tool with Fallback) =====

# Function: install_yara
# Purpose: Install YARA with fallback to building C library if needed
# Returns: 0 on success, 1 on failure
install_yara() {
    local logfile=$(create_tool_log "yara")

    {
        echo "=========================================="
        echo "Installing YARA"
        echo "Started: $(date)"
        echo "=========================================="

        source "$XDG_DATA_HOME/virtualenvs/tools/bin/activate" || return 1

        echo "Attempting to install yara-python..."
        pip install --quiet yara-python

        # Test if it works
        if ! python3 -c "import yara" 2>/dev/null; then
            echo "yara-python failed, building YARA C library..."

            mkdir -p "$HOME/opt/src"
            cd "$HOME/opt/src" || return 1

            local filename="v4.5.0.tar.gz"
            local url="https://github.com/VirusTotal/yara/archive/${filename}"

            if ! download_file "$url" "$filename"; then
                echo "ERROR: Failed to download YARA source"
                return 1
            fi

            tar -xzf "$filename" || return 1
            cd yara-4.5.0 || return 1
            ./bootstrap.sh || return 1
            ./configure --prefix="$HOME/.local" || return 1
            make || return 1
            make install || return 1

            cd "$HOME/opt/src" || return 1
            rm -rf yara-4.5.0 v4.5.0.tar.gz

            pip install --quiet yara-python || return 1
        fi

        deactivate

        echo "Creating wrapper script..."
        create_python_wrapper "yara"

        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1

    if is_installed "yara"; then
        echo -e "${GREEN}[OK] YARA installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("yara")
        log_installation "yara" "success" "$logfile"
        cleanup_old_logs "yara"
        return 0
    else
        echo -e "${RED}[FAIL] YARA installation failed${NC}"
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
