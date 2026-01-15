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
    echo -e "${BLUE}=========================================="
    echo "Security Tools Installer v${SCRIPT_VERSION}"
    echo -e "==========================================${NC}"
    echo ""
    echo -e "${MAGENTA}BUILD & LANGUAGES:${NC} [1] CMake [2] GitHub CLI [3] Node.js [4] Rust"
    echo ""
    echo -e "${MAGENTA}PYTHON TOOLS${NC} (python_venv required):"
    echo "  [5] sherlock      [6] holehe        [7] socialscan    [8] theHarvester"
    echo "  [9] spiderfoot    [10] sublist3r    [11] photon       [12] wappalyzer"
    echo "  [13] shodan       [14] censys       [15] yara         [16] h8mail"
    echo ""
    echo -e "${MAGENTA}GO TOOLS${NC} (system Go required):"
    echo "  [17] gobuster     [18] ffuf         [19] httprobe     [20] waybackurls"
    echo "  [21] assetfinder  [22] subfinder    [23] nuclei       [24] virustotal"
    echo ""
    echo -e "${MAGENTA}NODE.JS:${NC} [25] trufflehog [26] git-hound [27] jwt-cracker"
    echo ""
    echo -e "${MAGENTA}RUST:${NC} [28] feroxbuster [29] rustscan [30] ripgrep [31] fd [32] bat"
    echo ""
    echo -e "${MAGENTA}BULK INSTALL:${NC} [33] All Python [34] All Go [35] All Node [36] All Rust"
    echo ""
    echo -e "${MAGENTA}INFO:${NC} [50] Show installed [51] Show logs [52] Exit"
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
        # BUILD & LANGUAGES (1-4)
        1) install_tool "cmake" ;;
        2) install_tool "github_cli" ;;
        3) install_tool "nodejs" ;;
        4) install_tool "rust" ;;

        # PYTHON TOOLS (5-16)
        5) install_tool "sherlock" ;;
        6) install_tool "holehe" ;;
        7) install_tool "socialscan" ;;
        8) install_tool "theHarvester" ;;
        9) install_tool "spiderfoot" ;;
        10) install_tool "sublist3r" ;;
        11) install_tool "photon" ;;
        12) install_tool "wappalyzer" ;;
        13) install_tool "shodan" ;;
        14) install_tool "censys" ;;
        15) install_tool "yara" ;;
        16) install_tool "h8mail" ;;

        # GO TOOLS (17-24)
        17) install_tool "gobuster" ;;
        18) install_tool "ffuf" ;;
        19) install_tool "httprobe" ;;
        20) install_tool "waybackurls" ;;
        21) install_tool "assetfinder" ;;
        22) install_tool "subfinder" ;;
        23) install_tool "nuclei" ;;
        24) install_tool "virustotal" ;;

        # NODE.JS TOOLS (25-27)
        25) install_tool "trufflehog" ;;
        26) install_tool "git-hound" ;;
        27) install_tool "jwt-cracker" ;;

        # RUST TOOLS (28-32)
        28) install_tool "feroxbuster" ;;
        29) install_tool "rustscan" ;;
        30) install_tool "ripgrep" ;;
        31) install_tool "fd" ;;
        32) install_tool "bat" ;;

        # BULK INSTALL (33-36)
        33)
            # All Python tools
            install_tool "python_venv"
            for tool in "${ALL_PYTHON_TOOLS[@]}"; do
                install_tool "$tool"
            done
            ;;
        34)
            # All Go tools
            echo -e "${YELLOW}Installing all Go tools (using system Go)...${NC}"
            if ! verify_system_go; then
                echo -e "${RED}✗ System Go not found. Cannot install Go tools.${NC}"
                read -p "Press Enter to continue..."
                return 1
            fi
            for tool in "${ALL_GO_TOOLS[@]}"; do
                install_tool "$tool"
            done
            ;;
        35)
            # All Node.js tools
            install_tool "nodejs"
            for tool in "${NODE_TOOLS[@]}"; do
                install_tool "$tool"
            done
            ;;
        36)
            # All Rust tools
            echo -e "${YELLOW}Warning: Rust tools take 15-30 minutes to compile${NC}"
            read -p "Continue? (yes/no): " confirm
            if [[ "$confirm" == "yes" ]]; then
                install_tool "rust"
                for tool in "${ALL_RUST_TOOLS[@]}"; do
                    install_tool "$tool"
                done
            fi
            ;;

        # INFO OPTIONS (50-52)
        50) show_installed ;;
        51) show_logs ;;
        52) exit 0 ;;

        *)
            echo -e "${RED}Invalid selection: $selection${NC}"
            ;;
    esac
}

# Function: print_shell_reload_reminder
# Purpose: Remind user to reload shell configuration
# Returns: Always succeeds
print_shell_reload_reminder() {
    echo -e "${YELLOW}Reminder:${NC} Run 'source ~/.bashrc' or open a new shell so newly installed tools are on your PATH."
}
