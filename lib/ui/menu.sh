#!/bin/bash
# Security Tools Installer - Menu Module
# Version: 1.3.0
# Purpose: Interactive user interface

# ===== MENU FUNCTIONS =====

# Function: show_menu
# Purpose: Display interactive menu
# Returns: Always succeeds
show_menu() {
    clear
    print_shell_reload_reminder
    echo -e "${HEADER}=========================================="
    echo "Security Tools Installer v${SCRIPT_VERSION}"
    echo -e "==========================================${NC}"
    echo ""
    echo -e "${CATEGORY}BUILD & LANGUAGES:${NC} [1] CMake [2] GitHub CLI [3] Node.js [4] Rust [5] Go Runtime [6] Python venv"
    echo ""
    echo -e "${CATEGORY}PYTHON TOOLS:${NC}"
    echo "  [7] sherlock      [8] holehe        [9] socialscan    [10] theHarvester"
    echo "  [11] spiderfoot   [12] sublist3r    [13] photon       [14] wappalyzer"
    echo "  [15] shodan       [16] censys       [17] yara         [18] h8mail"
    echo ""
    echo -e "${CATEGORY}GO TOOLS (auto-installs Go if needed):${NC}"
    echo "  [19] gobuster     [20] ffuf         [21] httprobe     [22] waybackurls"
    echo "  [23] assetfinder  [24] subfinder    [25] nuclei       [26] virustotal"
    echo ""
    echo -e "${CATEGORY}NODE.JS:${NC} [27] trufflehog [28] git-hound [29] jwt-cracker"
    echo ""
    echo -e "${CATEGORY}RUST:${NC} [30] feroxbuster [31] rustscan [32] ripgrep [33] fd [34] bat"
    echo ""
    echo -e "${CATEGORY}UTILITIES:${NC} [35] aria2"
    echo ""
    echo -e "${CATEGORY}BULK INSTALL:${NC} [36] All Python [37] All Go [38] All Node [39] All Rust [40] All Utilities"
    echo ""
    echo -e "${CATEGORY}INFO:${NC} [T] Show Installed Tools [L] Show Logs [Q] Quit"
    echo ""
    echo -n "Enter selection (comma-separated): "
}

# Function: process_menu_selection
# Purpose: Handle menu input
# Parameters: $1 - menu selection
# Returns: Based on action taken
process_menu_selection() {
    local selection=$1

    case "$selection" in
        # BUILD & LANGUAGES (1-6)
        1) install_tool "cmake" ;;
        2) install_tool "github_cli" ;;
        3) install_tool "nodejs" ;;
        4) install_tool "rust" ;;
        5) install_tool "go_runtime" ;;
        6) install_tool "python_venv" ;;

        # PYTHON TOOLS (7-18)
        7) install_tool "sherlock" ;;
        8) install_tool "holehe" ;;
        9) install_tool "socialscan" ;;
        10) install_tool "theHarvester" ;;
        11) install_tool "spiderfoot" ;;
        12) install_tool "sublist3r" ;;
        13) install_tool "photon" ;;
        14) install_tool "wappalyzer" ;;
        15) install_tool "shodan" ;;
        16) install_tool "censys" ;;
        17) install_tool "yara" ;;
        18) install_tool "h8mail" ;;

        # GO TOOLS (19-26)
        19) install_tool "gobuster" ;;
        20) install_tool "ffuf" ;;
        21) install_tool "httprobe" ;;
        22) install_tool "waybackurls" ;;
        23) install_tool "assetfinder" ;;
        24) install_tool "subfinder" ;;
        25) install_tool "nuclei" ;;
        26) install_tool "virustotal" ;;

        # NODE.JS TOOLS (27-29)
        27) install_tool "trufflehog" ;;
        28) install_tool "git-hound" ;;
        29) install_tool "jwt-cracker" ;;

        # RUST TOOLS (30-34)
        30) install_tool "feroxbuster" ;;
        31) install_tool "rustscan" ;;
        32) install_tool "ripgrep" ;;
        33) install_tool "fd" ;;
        34) install_tool "bat" ;;

        # UTILITY TOOLS (35)
        35) install_tool "aria2" ;;

        # BULK INSTALL (36-40)
        36)
            # All Python tools
            install_tool "python_venv"
            for tool in "${ALL_PYTHON_TOOLS[@]}"; do
                install_tool "$tool"
            done
            ;;
        37)
            # All Go tools (auto-installs Go runtime if missing)
            for tool in "${ALL_GO_TOOLS[@]}"; do
                install_tool "$tool"
            done
            ;;
        38)
            # All Node.js tools
            install_tool "nodejs"
            for tool in "${NODE_TOOLS[@]}"; do
                install_tool "$tool"
            done
            ;;
        39)
            # All Rust tools
            echo -e "${WARNING}${WARN} Warning: Rust tools take 15-30 minutes to compile${NC}"
            read -r -p "Continue? (yes/no): " confirm
            if [[ "$confirm" == "yes" ]]; then
                install_tool "rust"
                for tool in "${ALL_RUST_TOOLS[@]}"; do
                    install_tool "$tool"
                done
            fi
            ;;
        40)
            # All Utility tools
            for tool in "${ALL_UTILITY_TOOLS[@]}"; do
                install_tool "$tool"
            done
            ;;

        # INFO OPTIONS (T, L, Q)
        T|t) show_installed ;;
        L|l) show_logs ;;
        Q|q) exit 0 ;;

        *)
            echo -e "${ERROR}${CROSS} Invalid selection: $selection${NC}"
            ;;
    esac
}

# Function: print_shell_reload_reminder
# Purpose: Remind user to reload shell configuration
# Returns: Always succeeds
print_shell_reload_reminder() {
    echo -e "${INFO}${INFOSYM} Reminder:${NC} Run 'source ~/.bashrc' or open a new shell so newly installed tools are on your PATH."
}
