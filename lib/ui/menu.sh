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
    echo -e "${CATEGORY}BUILD & LANGUAGES:${NC} [1] CMake [2] GitHub CLI [3] Node.js [4] Rust [5] Python venv"
    echo ""
    echo -e "${CATEGORY}PYTHON TOOLS:${NC}"
    echo "  [6] sherlock      [7] holehe        [8] socialscan    [9] theHarvester"
    echo "  [10] spiderfoot   [11] sublist3r    [12] photon       [13] wappalyzer"
    echo "  [14] shodan       [15] censys       [16] yara         [17] h8mail"
    echo ""
    echo -e "${CATEGORY}GO TOOLS (system Go required):${NC}"
    echo "  [18] gobuster     [19] ffuf         [20] httprobe     [21] waybackurls"
    echo "  [22] assetfinder  [23] subfinder    [24] nuclei       [25] virustotal"
    echo ""
    echo -e "${CATEGORY}NODE.JS:${NC} [26] trufflehog [27] git-hound [28] jwt-cracker"
    echo ""
    echo -e "${CATEGORY}RUST:${NC} [29] feroxbuster [30] rustscan [31] ripgrep [32] fd [33] bat"
    echo ""
    echo -e "${CATEGORY}BULK INSTALL:${NC} [34] All Python [35] All Go [36] All Node [37] All Rust"
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
        # BUILD & LANGUAGES (1-5)
        1) install_tool "cmake" ;;
        2) install_tool "github_cli" ;;
        3) install_tool "nodejs" ;;
        4) install_tool "rust" ;;
        5) install_tool "python_venv" ;;

        # PYTHON TOOLS (6-17)
        6) install_tool "sherlock" ;;
        7) install_tool "holehe" ;;
        8) install_tool "socialscan" ;;
        9) install_tool "theHarvester" ;;
        10) install_tool "spiderfoot" ;;
        11) install_tool "sublist3r" ;;
        12) install_tool "photon" ;;
        13) install_tool "wappalyzer" ;;
        14) install_tool "shodan" ;;
        15) install_tool "censys" ;;
        16) install_tool "yara" ;;
        17) install_tool "h8mail" ;;

        # GO TOOLS (18-25)
        18) install_tool "gobuster" ;;
        19) install_tool "ffuf" ;;
        20) install_tool "httprobe" ;;
        21) install_tool "waybackurls" ;;
        22) install_tool "assetfinder" ;;
        23) install_tool "subfinder" ;;
        24) install_tool "nuclei" ;;
        25) install_tool "virustotal" ;;

        # NODE.JS TOOLS (26-28)
        26) install_tool "trufflehog" ;;
        27) install_tool "git-hound" ;;
        28) install_tool "jwt-cracker" ;;

        # RUST TOOLS (29-33)
        29) install_tool "feroxbuster" ;;
        30) install_tool "rustscan" ;;
        31) install_tool "ripgrep" ;;
        32) install_tool "fd" ;;
        33) install_tool "bat" ;;

        # BULK INSTALL (34-37)
        34)
            # All Python tools
            install_tool "python_venv"
            for tool in "${ALL_PYTHON_TOOLS[@]}"; do
                install_tool "$tool"
            done
            ;;
        35)
            # All Go tools
            echo -e "${WARNING}${WARN} Installing all Go tools (using system Go)...${NC}"
            if ! verify_system_go; then
                echo -e "${ERROR}${CROSS} System Go not found. Cannot install Go tools.${NC}"
                read -p "Press Enter to continue..."
                return 1
            fi
            for tool in "${ALL_GO_TOOLS[@]}"; do
                install_tool "$tool"
            done
            ;;
        36)
            # All Node.js tools
            install_tool "nodejs"
            for tool in "${NODE_TOOLS[@]}"; do
                install_tool "$tool"
            done
            ;;
        37)
            # All Rust tools
            echo -e "${WARNING}${WARN} Warning: Rust tools take 15-30 minutes to compile${NC}"
            read -p "Continue? (yes/no): " confirm
            if [[ "$confirm" == "yes" ]]; then
                install_tool "rust"
                for tool in "${ALL_RUST_TOOLS[@]}"; do
                    install_tool "$tool"
                done
            fi
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
