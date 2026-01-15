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
    echo -e "${MAGENTA}BUILD TOOLS${NC}"
    echo "  [1] CMake"
    echo "  [2] GitHub CLI"
    echo ""
    echo -e "${MAGENTA}LANGUAGES & RUNTIMES${NC}"
    echo "  [3] Node.js"
    echo "  [4] Rust (compile time: 5-10 min)"
    echo ""
    echo -e "${MAGENTA}PYTHON TOOLS - OSINT${NC}"
    echo "  [5] Python Virtual Environment (required)"
    echo "  [6] sherlock - Username search"
    echo "  [7] holehe - Email verification"
    echo "  [8] socialscan - Username/email availability"
    echo "  [9] theHarvester - Multi-source OSINT"
    echo "  [10] spiderfoot - Automated OSINT"
    echo "  [11] All Python OSINT Tools"
    echo ""
    echo -e "${MAGENTA}PYTHON TOOLS - CTI${NC}"
    echo "  [12] shodan - Internet device intelligence"
    echo "  [13] censys - Certificate/service intelligence"
    echo "  [14] yara - Malware pattern matching"
    echo "  [15] All Python CTI Tools"
    echo ""
    echo -e "${MAGENTA}GO TOOLS - ACTIVE RECON${NC}"
    echo "  [16] gobuster - Directory/DNS bruteforcing"
    echo "  [17] ffuf - Fast web fuzzer"
    echo "  [18] subfinder - Subdomain discovery"
    echo "  [19] nuclei - Vulnerability scanner"
    echo "  [20] All Go Tools"
    echo ""
    echo -e "${MAGENTA}GO TOOLS - CTI${NC}"
    echo "  [21] virustotal - VirusTotal CLI"
    echo ""
    echo -e "${MAGENTA}NODE.JS TOOLS${NC}"
    echo "  [22] trufflehog - Secret scanning"
    echo "  [23] All Node.js Tools"
    echo ""
    echo -e "${MAGENTA}RUST TOOLS${NC}"
    echo "  [24] feroxbuster - Content discovery"
    echo "  [25] rustscan - Fast port scanner"
    echo "  [26] ripgrep - Fast grep"
    echo "  [27] All Rust Tools (long compile time)"
    echo ""
    echo -e "${MAGENTA}BULK OPTIONS${NC}"
    echo "  [30] Install Everything"
    echo ""
    echo -e "${MAGENTA}OTHER OPTIONS${NC}"
    echo "  [40] Show installed tools"
    echo "  [41] Show installation logs"
    echo "  [42] Exit"
    echo ""
    echo -n "Enter selection (comma-separated for multiple): "
}

# Function: process_menu_selection
# Purpose: Handle menu input
# Parameters: $1 - menu selection
# Returns: Based on action taken
process_menu_selection() {
    local selection=$1

    case "$selection" in
        1) install_tool "cmake" ;;
        2) install_tool "github_cli" ;;
        3) install_tool "nodejs" ;;
        4) install_tool "rust" ;;
        5) install_tool "python_venv" ;;
        6) install_tool "sherlock" ;;
        7) install_tool "holehe" ;;
        8) install_tool "socialscan" ;;
        9) install_tool "theHarvester" ;;
        10) install_tool "spiderfoot" ;;
        11)
            install_tool "python_venv"
            for tool in "${ALL_PYTHON_TOOLS[@]}"; do
                install_tool "$tool"
            done
            ;;
        12) install_tool "shodan" ;;
        13) install_tool "censys" ;;
        14) install_tool "yara" ;;
        15)
            install_tool "python_venv"
            for tool in shodan censys yara; do
                install_tool "$tool"
            done
            ;;
        16) install_tool "gobuster" ;;
        17) install_tool "ffuf" ;;
        18) install_tool "subfinder" ;;
        19) install_tool "nuclei" ;;
        20)
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
        21) install_tool "virustotal" ;;
        22) install_tool "trufflehog" ;;
        23)
            install_tool "nodejs"
            for tool in "${NODE_TOOLS[@]}"; do
                install_tool "$tool"
            done
            ;;
        24) install_tool "feroxbuster" ;;
        25) install_tool "rustscan" ;;
        26) install_tool "ripgrep" ;;
        27)
            echo -e "${YELLOW}Warning: Rust tools take 15-30 minutes to compile${NC}"
            read -p "Continue? (yes/no): " confirm
            if [[ "$confirm" == "yes" ]]; then
                install_tool "rust"
                for tool in "${ALL_RUST_TOOLS[@]}"; do
                    install_tool "$tool"
                done
            fi
            ;;
        30) install_all ;;
        40) show_installed ;;
        41) show_logs ;;
        42) exit 0 ;;
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
