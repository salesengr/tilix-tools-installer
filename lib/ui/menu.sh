#!/bin/bash
# Security Tools Installer - Menu Module
# Version: 1.4.0
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
    echo -e "${CATEGORY}BUILD & LANGUAGES:${NC} [1] CMake  [2] GitHub CLI  [3] Node.js  [4] Rust  [5] Go Runtime  [6] Python venv"
    echo ""
    echo -e "${CATEGORY}PASSIVE OSINT:${NC}"
    echo "  [7]  sherlock      [8]  holehe        [9]  socialscan    [10] theHarvester"
    echo "  [11] spiderfoot    [12] photon         [13] wappalyzer   [14] h8mail"
    echo "  [15] waybackurls   [16] assetfinder    [17] subfinder    [18] git-hound"
    echo ""
    echo -e "${CATEGORY}DOMAIN & SUBDOMAIN ENUMERATION:${NC}"
    echo "  [19] sublist3r     [20] gobuster       [21] ffuf"
    echo ""
    echo -e "${CATEGORY}ACTIVE RECON & SCANNING:${NC}"
    echo "  [22] httprobe      [23] rustscan       [24] feroxbuster  [25] nuclei"
    echo ""
    echo -e "${CATEGORY}CYBER THREAT INTEL (CTI):${NC}"
    echo "  [26] shodan        [27] censys         [28] yara         [29] trufflehog"
    echo "  [30] virustotal"
    echo ""
    echo -e "${CATEGORY}SECURITY TESTING:${NC} [31] jwt-cracker"
    echo ""
    echo -e "${CATEGORY}UTILITIES:${NC}"
    echo "  [32] ripgrep       [33] fd             [34] bat          [35] sd"
    echo "  [36] tokei         [37] dog            [38] aria2"
    echo ""
    echo -e "${CATEGORY}BULK INSTALL:${NC}"
    echo "  [39] All Passive OSINT    [40] All Domain/Subdomain    [41] All Active Recon"
    echo "  [42] All CTI              [43] All Utilities           [44] Install Everything"
    echo ""
    echo -e "${CATEGORY}INFO:${NC} [T] Show Installed Tools  [L] Show Logs  [Q] Quit"
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

        # PASSIVE OSINT (7-18)
        7)  install_tool "sherlock" ;;
        8)  install_tool "holehe" ;;
        9)  install_tool "socialscan" ;;
        10) install_tool "theHarvester" ;;
        11) install_tool "spiderfoot" ;;
        12) install_tool "photon" ;;
        13) install_tool "wappalyzer" ;;
        14) install_tool "h8mail" ;;
        15) install_tool "waybackurls" ;;
        16) install_tool "assetfinder" ;;
        17) install_tool "subfinder" ;;
        18) install_tool "git-hound" ;;

        # DOMAIN & SUBDOMAIN ENUMERATION (19-21)
        19) install_tool "sublist3r" ;;
        20) install_tool "gobuster" ;;
        21) install_tool "ffuf" ;;

        # ACTIVE RECON & SCANNING (22-25)
        22) install_tool "httprobe" ;;
        23) install_tool "rustscan" ;;
        24) install_tool "feroxbuster" ;;
        25) install_tool "nuclei" ;;

        # CYBER THREAT INTEL (26-30)
        26) install_tool "shodan" ;;
        27) install_tool "censys" ;;
        28) install_tool "yara" ;;
        29) install_tool "trufflehog" ;;
        30) install_tool "virustotal" ;;

        # SECURITY TESTING (31)
        31) install_tool "jwt-cracker" ;;

        # UTILITIES (32-38)
        32) install_tool "ripgrep" ;;
        33) install_tool "fd" ;;
        34) install_tool "bat" ;;
        35) install_tool "sd" ;;
        36) install_tool "tokei" ;;
        37) install_tool "dog" ;;
        38) install_tool "aria2" ;;

        # BULK INSTALL (39-44)
        39)
            # All Passive OSINT (auto-installs python_venv and Go as needed)
            install_tool "python_venv"
            for tool in "${PASSIVE_OSINT[@]}"; do
                install_tool "$tool"
            done
            ;;
        40)
            # All Domain/Subdomain Enumeration
            install_tool "python_venv"
            for tool in "${DOMAIN_ENUM[@]}"; do
                install_tool "$tool"
            done
            ;;
        41)
            # All Active Recon & Scanning
            install_tool "rust"
            for tool in "${ACTIVE_RECON[@]}"; do
                install_tool "$tool"
            done
            ;;
        42)
            # All CTI Tools
            install_tool "python_venv"
            install_tool "nodejs"
            for tool in "${CTI_TOOLS[@]}"; do
                install_tool "$tool"
            done
            ;;
        43)
            # All Utilities
            install_tool "rust"
            for tool in "${UTILITY_TOOLS[@]}"; do
                install_tool "$tool"
            done
            ;;
        44)
            # Install Everything
            echo -e "${WARNING}${WARN} Installing ALL tools — this will take 30-60 minutes${NC}"
            read -r -p "Continue? (yes/no): " confirm
            if [[ "$confirm" == "yes" ]]; then
                install_all
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
