#!/bin/bash
# Security Tools Installer - Orchestration Module
# Version: 1.3.0
# Purpose: High-level installation coordination and workflow management

# ===== ORCHESTRATION FUNCTIONS =====

# Function: install_tool
# Purpose: Master dispatcher for tool installation
# Parameters: $1 - tool name
# Returns: 0 on success, 1 on failure
install_tool() {
    local tool=$1

    # Check if already installed
    if is_installed "$tool"; then
        echo -e "${GREEN}[OK] $tool already installed${NC}"
        return 0
    fi

    # Check dependencies
    if ! check_dependencies "$tool"; then
        echo -e "${RED}[FAIL] Failed to install dependencies for $tool${NC}"
        return 1
    fi

    # Install the tool
    echo ""
    echo -e "${INFO}${INFOSYM} Installing $tool...${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    case "$tool" in
        cmake) install_cmake ;;
        github_cli) install_github_cli ;;
        nodejs) install_nodejs ;;
        rust) install_rust ;;
        python_venv) install_python_venv ;;
        sherlock) install_sherlock ;;
        holehe) install_holehe ;;
        socialscan) install_socialscan ;;
        h8mail) install_h8mail ;;
        photon) install_photon ;;
        sublist3r) install_sublist3r ;;
        shodan) install_shodan ;;
        censys) install_censys ;;
        theHarvester) install_theHarvester ;;
        spiderfoot) install_spiderfoot ;;
        yara) install_yara ;;
        wappalyzer) install_wappalyzer ;;
        gobuster) install_gobuster ;;
        ffuf) install_ffuf ;;
        httprobe) install_httprobe ;;
        waybackurls) install_waybackurls ;;
        assetfinder) install_assetfinder ;;
        subfinder) install_subfinder ;;
        nuclei) install_nuclei ;;
        virustotal) install_virustotal ;;
        trufflehog) install_trufflehog ;;
        git-hound) install_git-hound ;;
        jwt-cracker) install_jwt-cracker ;;
        feroxbuster) install_feroxbuster ;;
        rustscan) install_rustscan ;;
        ripgrep) install_ripgrep ;;
        fd) install_fd ;;
        bat) install_bat ;;
        sd) install_sd ;;
        tokei) install_tokei ;;
        dog) install_dog ;;
        *)
            echo -e "${RED}Unknown tool: $tool${NC}"
            return 1
            ;;
    esac
}

# Function: install_all
# Purpose: Bulk installer for all tools
# Returns: 0 on success, 1 on user cancellation
install_all() {
    echo -e "${YELLOW}Installing ALL tools...${NC}"
    echo -e "${YELLOW}This will take 30-60 minutes and use ~2GB disk space${NC}"
    read -p "Continue? (yes/no): " confirm

    if [[ "$confirm" != "yes" ]]; then
        echo "Installation cancelled"
        return 1
    fi

    local all_tools=(
        "cmake" "github_cli" "nodejs" "rust" "python_venv"
        "${ALL_PYTHON_TOOLS[@]}"
        "${ALL_GO_TOOLS[@]}"
        "${NODE_TOOLS[@]}"
        "${ALL_RUST_TOOLS[@]}"
    )

    for tool in "${all_tools[@]}"; do
        install_tool "$tool"
    done
}

# Function: dry_run_install
# Purpose: Preview what would be installed without actually installing
# Parameters:
#   $1 - tool name
#   $2 - indent level (optional, for recursive display)
# Returns: Always succeeds
dry_run_install() {
    local tool=$1
    local indent="${2:-  }"

    echo "${indent}[DRY RUN] Would install: $tool"

    # Check dependencies
    local deps=${TOOL_DEPENDENCIES[$tool]}
    if [[ -n "$deps" ]]; then
        echo "${indent}  Prerequisites:"
        for dep in $deps; do
            if is_installed "$dep"; then
                echo "${indent}    [OK] $dep (already installed)"
            else
                echo "${indent}    -> $dep (would be installed)"
                dry_run_install "$dep" "${indent}      "
            fi
        done
    fi

    # Show details
    local info=${TOOL_INFO[$tool]}
    local size=${TOOL_SIZES[$tool]}
    local location=${TOOL_INSTALL_LOCATION[$tool]}

    echo "${indent}  Download size: $size"
    echo "${indent}  Install location: $location"
    echo ""
}

# Function: process_cli_args
# Purpose: Process command-line arguments and install requested tools
# Parameters: $@ - tool names or category flags
# Returns: Based on installation results
process_cli_args() {
    local args=("$@")

    # Handle special keywords
    if [[ "${args[0]}" == "all" ]]; then
        install_all
        return
    fi

    if [[ "${args[0]}" == "--python-tools" ]]; then
        install_tool "python_venv"
        for tool in "${ALL_PYTHON_TOOLS[@]}"; do
            install_tool "$tool"
        done
        return
    fi

    if [[ "${args[0]}" == "--go-tools" ]]; then
        echo -e "${YELLOW}Installing all Go tools (using system Go)...${NC}"
        if ! verify_system_go; then
            echo -e "${RED}ERROR: System Go not found. Cannot install Go tools.${NC}"
            echo "Please ensure Go is installed at /usr/local/go"
            exit 1
        fi
        for tool in "${ALL_GO_TOOLS[@]}"; do
            install_tool "$tool"
        done
        return
    fi

    if [[ "${args[0]}" == "--node-tools" ]]; then
        install_tool "nodejs"
        for tool in "${NODE_TOOLS[@]}"; do
            install_tool "$tool"
        done
        return
    fi

    if [[ "${args[0]}" == "--rust-tools" ]]; then
        install_tool "rust"
        for tool in "${ALL_RUST_TOOLS[@]}"; do
            install_tool "$tool"
        done
        return
    fi

    # Handle individual tool names
    for tool in "${args[@]}"; do
        install_tool "$tool"
    done
}
