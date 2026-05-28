#!/bin/bash
# Security Tools Installer - Menu Module
# Version: 1.4.2
# Purpose: Interactive user interface

# ===== MENU FUNCTIONS =====

# Function: _tool_status
# Purpose: Return a colored [✓] or dim [ ] prefix for a tool
# Parameters: $1 - tool name (must match INSTALLED_STATUS key)
# Returns: Prints status indicator without trailing newline
_tool_status() {
	local tool=$1
	if [[ "${INSTALLED_STATUS[$tool]:-false}" == "true" ]]; then
		printf '%b' "${SUCCESS}[✓]${NC}"
	else
		printf '%b' "\033[2m[ ]\033[0m"
	fi
}

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
	echo -e "${CATEGORY}BUILD & LANGUAGES:${NC} [1] $(_tool_status cmake)cmake  [2] $(_tool_status github_cli)GitHub CLI  [3] $(_tool_status nodejs)Node.js  [4] $(_tool_status rust)Rust  [5] $(_tool_status go_runtime)Go Runtime  [6] $(_tool_status python_venv)Python venv"
	echo ""
	echo -e "${CATEGORY}PASSIVE OSINT:${NC}"
	echo "  [7]  $(_tool_status sherlock)sherlock      [8]  $(_tool_status holehe)holehe        [9]  $(_tool_status socialscan)socialscan    [10] $(_tool_status theHarvester)theHarvester"
	echo "  [11] $(_tool_status spiderfoot)spiderfoot    [12] $(_tool_status photon)photon         [13] $(_tool_status wappalyzer)wappalyzer   [14] $(_tool_status h8mail)h8mail"
	echo "  [15] $(_tool_status waybackurls)waybackurls   [16] $(_tool_status assetfinder)assetfinder    [17] $(_tool_status subfinder)subfinder    [18] $(_tool_status git-hound)git-hound"
	echo "  [19] $(_tool_status amass)amass"
	echo ""
	echo -e "${CATEGORY}DOMAIN & SUBDOMAIN ENUMERATION:${NC}"
	echo "  [20] $(_tool_status sublist3r)sublist3r     [21] $(_tool_status gobuster)gobuster       [22] $(_tool_status ffuf)ffuf"
	echo ""
	echo -e "${CATEGORY}ACTIVE RECON & SCANNING:${NC}"
	echo "  [23] $(_tool_status httprobe)httprobe      [24] $(_tool_status rustscan)rustscan       [25] $(_tool_status feroxbuster)feroxbuster  [26] $(_tool_status nuclei)nuclei"
	echo ""
	echo -e "${CATEGORY}CYBER THREAT INTEL (CTI):${NC}"
	echo "  [27] $(_tool_status shodan)shodan        [28] $(_tool_status censys)censys         [29] $(_tool_status yara)yara         [30] $(_tool_status trufflehog)trufflehog"
	echo "  [31] $(_tool_status virustotal)virustotal"
	echo ""
	echo -e "${CATEGORY}SECURITY TESTING:${NC} [32] $(_tool_status jwt-cracker)jwt-cracker"
	echo ""
	echo -e "${CATEGORY}UTILITIES:${NC}"
	echo "  [33] $(_tool_status ripgrep)ripgrep       [34] $(_tool_status fd)fd             [35] $(_tool_status bat)bat          [36] $(_tool_status sd)sd"
	echo "  [37] $(_tool_status doggo)doggo          [38] $(_tool_status aria2)aria2"
	echo ""
	echo -e "${CATEGORY}WEB TOOLS:${NC}"
	echo "  [39] $(_tool_status seleniumbase)seleniumbase  [40] $(_tool_status playwright)playwright      [41] $(_tool_status yandex_browser)yandex-browser  [42] $(_tool_status tor_browser)tor-browser"
	echo "  [43] $(_tool_status qtox)qtox"
	echo ""
	echo -e "${CATEGORY}BULK INSTALL:${NC}"
	echo "  [44] All Passive OSINT    [45] All Domain/Subdomain    [46] All Active Recon"
	echo "  [47] All CTI              [48] All Utilities           [49] All Web Tools"
	echo "  [50] Install Everything"
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

	# PASSIVE OSINT (7-19)
	7) install_tool "sherlock" ;;
	8) install_tool "holehe" ;;
	9) install_tool "socialscan" ;;
	10) install_tool "theHarvester" ;;
	11) install_tool "spiderfoot" ;;
	12) install_tool "photon" ;;
	13) install_tool "wappalyzer" ;;
	14) install_tool "h8mail" ;;
	15) install_tool "waybackurls" ;;
	16) install_tool "assetfinder" ;;
	17) install_tool "subfinder" ;;
	18) install_tool "git-hound" ;;
	19) install_tool "amass" ;;

	# DOMAIN & SUBDOMAIN ENUMERATION (20-22)
	20) install_tool "sublist3r" ;;
	21) install_tool "gobuster" ;;
	22) install_tool "ffuf" ;;

	# ACTIVE RECON & SCANNING (23-26)
	23) install_tool "httprobe" ;;
	24) install_tool "rustscan" ;;
	25) install_tool "feroxbuster" ;;
	26) install_tool "nuclei" ;;

	# CYBER THREAT INTEL (27-31)
	27) install_tool "shodan" ;;
	28) install_tool "censys" ;;
	29) install_tool "yara" ;;
	30) install_tool "trufflehog" ;;
	31) install_tool "virustotal" ;;

	# SECURITY TESTING (32)
	32) install_tool "jwt-cracker" ;;

	# UTILITIES (33-38)
	33) install_tool "ripgrep" ;;
	34) install_tool "fd" ;;
	35) install_tool "bat" ;;
	36) install_tool "sd" ;;
	37) install_tool "doggo" ;;
	38) install_tool "aria2" ;;

	# WEB TOOLS (39-43)
	39) install_tool "seleniumbase" ;;
	40) install_tool "playwright" ;;
	41) install_tool "yandex_browser" ;;
	42) install_tool "tor_browser" ;;
	43) install_tool "qtox" ;;

	# BULK INSTALL (44-50)
	44)
		install_tool "python_venv"
		for tool in "${PASSIVE_OSINT[@]}"; do install_tool "$tool"; done
		;;
	45)
		install_tool "python_venv"
		for tool in "${DOMAIN_ENUM[@]}"; do install_tool "$tool"; done
		;;
	46)
		install_tool "rust"
		for tool in "${ACTIVE_RECON[@]}"; do install_tool "$tool"; done
		;;
	47)
		install_tool "python_venv"
		install_tool "nodejs"
		for tool in "${CTI_TOOLS[@]}"; do install_tool "$tool"; done
		;;
	48)
		install_tool "rust"
		for tool in "${UTILITY_TOOLS[@]}"; do install_tool "$tool"; done
		;;
	49)
		for tool in "${WEB_TOOLS[@]}"; do install_tool "$tool"; done
		;;
	50)
		echo -e "${WARNING}${WARN} Installing ALL tools — this will take 30-60 minutes${NC}"
		read -r -p "Continue? (yes/no): " confirm
		if [[ "$confirm" == "yes" ]]; then
			install_all
		fi
		;;

	# INFO OPTIONS (T, L, Q)
	T | t) show_installed ;;
	L | l) show_logs ;;
	Q | q) exit 0 ;;

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
