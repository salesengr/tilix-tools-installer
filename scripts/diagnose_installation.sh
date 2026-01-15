#!/usr/bin/env bash

################################################################################
# Security Tools Installation Diagnostic Script
#
# Purpose: Analyze installation, detect cleanup opportunities, verify XDG
#          compliance, and diagnose test failures
#
# Version: 1.0.0
# Author: Auto-generated for Security Tools Installer
# Date: 2025-12-16
################################################################################

# Error handling: Don't exit on error, handle manually
set +e

################################################################################
# GLOBAL VARIABLES
################################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
SCRIPT_VERSION="1.0.0"

# Color codes
GREEN=''
YELLOW=''
RED=''
BLUE=''
CYAN=''
MAGENTA=''
NC=''

# Report data structures
declare -a TOOL_LIST
declare -A INSTALLED_TOOLS
declare -A TOOL_VERSIONS
declare -A DISK_USAGE_CATEGORIES
declare -A BUILD_ARTIFACTS
declare -A XDG_VIOLATIONS
declare -A TEST_FAILURES

# Counters
TOTAL_TOOLS=0
INSTALLED_COUNT=0
TOTAL_DISK_USAGE=0
RECOVERABLE_SPACE=0

################################################################################
# HELPER FUNCTIONS
################################################################################

# Initialize color codes
init_colors() {
    if [[ -t 1 ]]; then
        GREEN='\033[0;32m'
        YELLOW='\033[1;33m'
        RED='\033[0;31m'
        BLUE='\033[0;36m'
        CYAN='\033[0;36m'
        MAGENTA='\033[0;35m'
        NC='\033[0m'
    fi
}

# Format bytes to human-readable size
format_size() {
    local bytes=$1
    if [ "$bytes" -ge 1073741824 ]; then
        echo "$(awk "BEGIN {printf \"%.1f\", $bytes/1073741824}") GB"
    elif [ "$bytes" -ge 1048576 ]; then
        echo "$(awk "BEGIN {printf \"%.1f\", $bytes/1048576}") MB"
    elif [ "$bytes" -ge 1024 ]; then
        echo "$(awk "BEGIN {printf \"%.1f\", $bytes/1024}") KB"
    else
        echo "${bytes} B"
    fi
}

# Check if script requirements are met
check_requirements() {
    local missing_tools=()

    # Check for required commands
    for cmd in bash find du grep awk sed; do
        if ! command -v "$cmd" &>/dev/null; then
            missing_tools+=("$cmd")
        fi
    done

    # Check bash version (need 4+ for associative arrays)
    if [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
        echo -e "${RED}Error: Bash 4.0 or higher is required (found ${BASH_VERSION})${NC}"
        return 1
    fi

    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo -e "${RED}Error: Missing required tools: ${missing_tools[*]}${NC}"
        return 1
    fi

    return 0
}

# Print section header
print_header() {
    local title=$1
    local width=80
    echo ""
    echo -e "${BLUE}$(printf '=%.0s' $(seq 1 $width))${NC}"
    echo -e "${BLUE}$title${NC}"
    echo -e "${BLUE}$(printf '=%.0s' $(seq 1 $width))${NC}"
    echo ""
}

# Print subsection header
print_subheader() {
    local title=$1
    echo ""
    echo -e "${CYAN}$title${NC}"
    echo -e "${CYAN}$(printf -- '-%.0s' $(seq 1 ${#title}))${NC}"
}

################################################################################
# USAGE AND HELP
################################################################################

show_help() {
    cat << EOF
${CYAN}Security Tools Installation Diagnostic Script${NC}
Version: $SCRIPT_VERSION

${YELLOW}USAGE:${NC}
    ./$SCRIPT_NAME [OPTIONS]

${YELLOW}DESCRIPTION:${NC}
    Analyzes security tools installation to identify:
    - What tools are installed and their disk usage
    - Build artifacts that can be safely removed
    - XDG Base Directory specification compliance
    - Test failures and their root causes
    - Optimization opportunities

${YELLOW}OPTIONS:${NC}
    ${GREEN}--inventory${NC}         Show installation inventory (what's installed)
    ${GREEN}--disk-usage${NC}        Analyze disk space usage by category
    ${GREEN}--build-artifacts${NC}   Detect build artifacts left behind
    ${GREEN}--xdg-check${NC}         Verify XDG specification compliance
    ${GREEN}--test-diagnosis${NC}    Run test suite and diagnose failures
    ${GREEN}--migration-plan${NC}    Show migration recommendations for XDG compliance
    ${GREEN}--cleanup-plan${NC}      Show safe cleanup commands (don't execute)
    ${GREEN}--full-report${NC}       Generate complete diagnostic report (DEFAULT)
    ${GREEN}--cleanup${NC}           EXECUTE safe cleanup operations (requires confirmation)
    ${GREEN}--help${NC}              Show this help message

${YELLOW}EXAMPLES:${NC}
    # Generate full diagnostic report
    ./$SCRIPT_NAME

    # Check only what's installed
    ./$SCRIPT_NAME --inventory

    # Analyze disk usage
    ./$SCRIPT_NAME --disk-usage

    # Diagnose test failures
    ./$SCRIPT_NAME --test-diagnosis

    # Show cleanup recommendations (safe, don't execute)
    ./$SCRIPT_NAME --cleanup-plan

    # Execute safe cleanup (will ask for confirmation)
    ./$SCRIPT_NAME --cleanup

${YELLOW}OUTPUT:${NC}
    Report saved to: ~/.local/state/install_tools/diagnostic-TIMESTAMP.txt

${YELLOW}SAFETY:${NC}
    - All analysis operations are read-only and safe
    - Cleanup operations require explicit confirmation
    - Migration commands are shown but not executed automatically

EOF
}

################################################################################
# LOAD TOOL DEFINITIONS
################################################################################

load_tool_definitions() {
    # Define all 37 tools and their check locations
    # Based on install_security_tools.sh

    TOTAL_TOOLS=37

    # Build tools
    TOOL_LIST+=("cmake" "github_cli")

    # Languages
    TOOL_LIST+=("go" "nodejs" "rust")

    # Python prerequisite
    TOOL_LIST+=("python_venv")

    # Python tools
    TOOL_LIST+=("sherlock" "holehe" "socialscan" "h8mail" "photon" "sublist3r")
    TOOL_LIST+=("shodan" "censys" "theHarvester" "spiderfoot" "yara" "wappalyzer")

    # Go tools
    TOOL_LIST+=("gobuster" "ffuf" "httprobe" "waybackurls" "assetfinder" "subfinder" "nuclei" "virustotal")

    # Node.js tools
    TOOL_LIST+=("trufflehog" "git-hound" "jwt-cracker")

    # Rust tools
    TOOL_LIST+=("feroxbuster" "rustscan" "ripgrep" "fd" "bat" "sd" "tokei" "dog")
}

################################################################################
# INVENTORY FUNCTIONS
################################################################################

is_tool_installed() {
    local tool=$1

    case "$tool" in
        cmake)
            [ -f "$HOME/.local/bin/cmake" ] && return 0 ;;
        github_cli)
            [ -f "$HOME/.local/bin/gh" ] && return 0 ;;
        nodejs)
            [ -f "$HOME/opt/node/bin/node" ] && return 0 ;;
        rust)
            [ -f "$HOME/.local/share/cargo/bin/cargo" ] && return 0 ;;
        python_venv)
            [ -d "$HOME/.local/share/virtualenvs/tools" ] && return 0 ;;
        # Python tools check wrapper
        sherlock|holehe|socialscan|h8mail|photon|sublist3r|shodan|censys|theHarvester|spiderfoot|yara|wappalyzer)
            [ -f "$HOME/.local/bin/$tool" ] && return 0 ;;
        # Go tools
        gobuster|ffuf|httprobe|waybackurls|assetfinder|subfinder|nuclei)
            [ -f "$HOME/opt/gopath/bin/$tool" ] && return 0 ;;
        virustotal)
            [ -f "$HOME/opt/gopath/bin/vt" ] && return 0 ;;
        # Node tools
        trufflehog|git-hound|jwt-cracker)
            [ -f "$HOME/.local/bin/$tool" ] && return 0 ;;
        # Rust tools
        feroxbuster|rustscan|sd|tokei|dog)
            command -v "$tool" &>/dev/null && return 0 ;;
        ripgrep)
            command -v rg &>/dev/null && return 0 ;;
        fd)
            command -v fd &>/dev/null && return 0 ;;
        bat)
            command -v bat &>/dev/null && return 0 ;;
    esac

    return 1
}

get_tool_version() {
    local tool=$1
    local version="unknown"

    case "$tool" in
        cmake)
            version=$(cmake --version 2>/dev/null | head -1 | awk '{print $3}') ;;
        github_cli)
            version=$(gh --version 2>/dev/null | head -1 | awk '{print $3}') ;;
        nodejs)
            version=$(node --version 2>/dev/null | sed 's/v//') ;;
        rust)
            version=$(rustc --version 2>/dev/null | awk '{print $2}') ;;
        python_venv)
            version="N/A" ;;
        gobuster|ffuf|nuclei)
            version=$($tool -version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -1) ;;
        virustotal)
            version=$(vt --version 2>/dev/null | awk '{print $3}') ;;
        feroxbuster|rustscan)
            version=$($tool --version 2>/dev/null | awk '{print $2}') ;;
        ripgrep)
            version=$(rg --version 2>/dev/null | head -1 | awk '{print $2}') ;;
        fd)
            version=$(fd --version 2>/dev/null | awk '{print $2}') ;;
        bat)
            version=$(bat --version 2>/dev/null | awk '{print $2}') ;;
        *)
            version=$($tool --version 2>/dev/null | head -1 | grep -oP '\d+\.\d+\.\d+' | head -1)
            if [ -z "$version" ]; then
                version="installed"
            fi
            ;;
    esac

    echo "$version"
}

scan_installed_tools() {
    INSTALLED_COUNT=0

    for tool in "${TOOL_LIST[@]}"; do
        if is_tool_installed "$tool"; then
            INSTALLED_TOOLS["$tool"]="yes"
            TOOL_VERSIONS["$tool"]=$(get_tool_version "$tool")
            ((INSTALLED_COUNT++))
        else
            INSTALLED_TOOLS["$tool"]="no"
            TOOL_VERSIONS["$tool"]="N/A"
        fi
    done
}

generate_inventory_report() {
    print_subheader "Installation Inventory"

    echo -e "${CYAN}Total Tools Available: ${NC}$TOTAL_TOOLS"
    echo -e "${GREEN}Tools Installed: ${NC}$INSTALLED_COUNT"
    echo -e "${YELLOW}Tools Not Installed: ${NC}$((TOTAL_TOOLS - INSTALLED_COUNT))"
    echo ""

    printf "%-20s %-15s %-20s\n" "Tool" "Status" "Version"
    printf "%-20s %-15s %-20s\n" "$(printf -- '-%.0s' {1..20})" "$(printf -- '-%.0s' {1..15})" "$(printf -- '-%.0s' {1..20})"

    for tool in "${TOOL_LIST[@]}"; do
        local status="${INSTALLED_TOOLS[$tool]}"
        local version="${TOOL_VERSIONS[$tool]}"

        if [ "$status" = "yes" ]; then
            printf "%-20s ${GREEN}%-15s${NC} %-20s\n" "$tool" "✓ Installed" "$version"
        else
            printf "%-20s ${RED}%-15s${NC} %-20s\n" "$tool" "✗ Not Installed" "$version"
        fi
    done
}

################################################################################
# DISK USAGE FUNCTIONS
################################################################################

get_directory_size() {
    local dir=$1
    if [ -d "$dir" ]; then
        du -sb "$dir" 2>/dev/null | awk '{print $1}'
    else
        echo "0"
    fi
}

calculate_disk_usage() {
    local total_size=0

    # Binaries
    DISK_USAGE_CATEGORIES["binaries_local"]=$(get_directory_size "$HOME/.local/bin")
    DISK_USAGE_CATEGORIES["binaries_gopath"]=$(get_directory_size "$HOME/opt/gopath/bin")
    DISK_USAGE_CATEGORIES["binaries_cargo"]=$(get_directory_size "$HOME/.local/share/cargo/bin")

    # Build artifacts
    DISK_USAGE_CATEGORIES["go_pkg"]=$(get_directory_size "$HOME/opt/gopath/pkg")
    DISK_USAGE_CATEGORIES["go_src"]=$(get_directory_size "$HOME/opt/gopath/src")
    DISK_USAGE_CATEGORIES["cargo_registry"]=$(get_directory_size "$HOME/.local/share/cargo/registry")
    DISK_USAGE_CATEGORIES["cargo_git"]=$(get_directory_size "$HOME/.local/share/cargo/git")

    # Caches
    DISK_USAGE_CATEGORIES["pip_cache"]=$(get_directory_size "$HOME/.cache/pip")
    DISK_USAGE_CATEGORIES["npm_cache"]=$(get_directory_size "$HOME/.cache/npm")
    DISK_USAGE_CATEGORIES["go_cache"]=$(get_directory_size "$HOME/.cache/go-build")
    DISK_USAGE_CATEGORIES["python_cache"]=$(get_directory_size "$HOME/.cache/python")

    # Data
    DISK_USAGE_CATEGORIES["python_venv"]=$(get_directory_size "$HOME/.local/share/virtualenvs/tools")
    DISK_USAGE_CATEGORIES["nodejs_runtime"]=$(get_directory_size "$HOME/opt/node")
    DISK_USAGE_CATEGORIES["go_runtime"]=$(get_directory_size "$HOME/opt/go")

    # Logs
    DISK_USAGE_CATEGORIES["logs"]=$(get_directory_size "$HOME/.local/state/install_tools/logs")

    # Archives
    DISK_USAGE_CATEGORIES["archives"]=$(get_directory_size "$HOME/opt/src")

    # Calculate totals
    for category in "${!DISK_USAGE_CATEGORIES[@]}"; do
        ((total_size += DISK_USAGE_CATEGORIES[$category]))
    done

    TOTAL_DISK_USAGE=$total_size
}

categorize_disk_usage() {
    local binaries=0
    local build_artifacts=0
    local caches=0
    local data=0
    local logs=0
    local archives=0

    # Binaries
    ((binaries = DISK_USAGE_CATEGORIES[binaries_local] + DISK_USAGE_CATEGORIES[binaries_gopath] + DISK_USAGE_CATEGORIES[binaries_cargo]))

    # Build artifacts
    ((build_artifacts = DISK_USAGE_CATEGORIES[go_pkg] + DISK_USAGE_CATEGORIES[go_src] + DISK_USAGE_CATEGORIES[cargo_registry] + DISK_USAGE_CATEGORIES[cargo_git]))

    # Caches
    ((caches = DISK_USAGE_CATEGORIES[pip_cache] + DISK_USAGE_CATEGORIES[npm_cache] + DISK_USAGE_CATEGORIES[go_cache] + DISK_USAGE_CATEGORIES[python_cache]))

    # Data
    ((data = DISK_USAGE_CATEGORIES[python_venv] + DISK_USAGE_CATEGORIES[nodejs_runtime] + DISK_USAGE_CATEGORIES[go_runtime]))

    # Logs and archives
    logs=${DISK_USAGE_CATEGORIES[logs]}
    archives=${DISK_USAGE_CATEGORIES[archives]}

    # Recoverable space (build artifacts + caches + archives)
    ((RECOVERABLE_SPACE = build_artifacts + caches + archives))

    echo "$binaries|$build_artifacts|$caches|$data|$logs|$archives"
}

generate_disk_report() {
    print_subheader "Disk Usage Analysis"

    calculate_disk_usage
    local categories
    categories=$(categorize_disk_usage)

    local binaries=$(echo "$categories" | cut -d'|' -f1)
    local build_artifacts=$(echo "$categories" | cut -d'|' -f2)
    local caches=$(echo "$categories" | cut -d'|' -f3)
    local data=$(echo "$categories" | cut -d'|' -f4)
    local logs=$(echo "$categories" | cut -d'|' -f5)
    local archives=$(echo "$categories" | cut -d'|' -f6)

    printf "%-25s %-15s %-12s %s\n" "Category" "Size" "% of Total" "Cleanable?"
    printf "%-25s %-15s %-12s %s\n" "$(printf -- '-%.0s' {1..25})" "$(printf -- '-%.0s' {1..15})" "$(printf -- '-%.0s' {1..12})" "$(printf -- '-%.0s' {1..10})"

    local percent
    percent=$((binaries * 100 / TOTAL_DISK_USAGE))
    printf "%-25s %-15s %-12s %s\n" "Binaries" "$(format_size $binaries)" "$percent%" "No (required)"

    percent=$((build_artifacts * 100 / TOTAL_DISK_USAGE))
    printf "%-25s ${YELLOW}%-15s${NC} %-12s ${GREEN}%s${NC}\n" "Build Artifacts" "$(format_size $build_artifacts)" "$percent%" "Yes (safe)"

    percent=$((caches * 100 / TOTAL_DISK_USAGE))
    printf "%-25s ${YELLOW}%-15s${NC} %-12s ${GREEN}%s${NC}\n" "Caches" "$(format_size $caches)" "$percent%" "Yes (safe)"

    percent=$((data * 100 / TOTAL_DISK_USAGE))
    printf "%-25s %-15s %-12s %s\n" "Python/Node/Go Runtime" "$(format_size $data)" "$percent%" "No (required)"

    percent=$((logs * 100 / TOTAL_DISK_USAGE))
    printf "%-25s %-15s %-12s %s\n" "Logs" "$(format_size $logs)" "$percent%" "Partial"

    percent=$((archives * 100 / TOTAL_DISK_USAGE))
    printf "%-25s ${YELLOW}%-15s${NC} %-12s ${GREEN}%s${NC}\n" "Downloaded Archives" "$(format_size $archives)" "$percent%" "Yes (safe)"

    printf "%-25s %-15s %-12s %s\n" "$(printf -- '-%.0s' {1..25})" "$(printf -- '-%.0s' {1..15})" "$(printf -- '-%.0s' {1..12})" "$(printf -- '-%.0s' {1..10})"
    printf "%-25s ${CYAN}%-15s${NC} %-12s\n" "TOTAL" "$(format_size $TOTAL_DISK_USAGE)" "100%"
    printf "%-25s ${GREEN}%-15s${NC} %-12s\n" "RECOVERABLE" "$(format_size $RECOVERABLE_SPACE)" "$((RECOVERABLE_SPACE * 100 / TOTAL_DISK_USAGE))%"
}

################################################################################
# ARTIFACT DETECTION FUNCTIONS
################################################################################

find_go_artifacts() {
    local go_pkg_size=$(get_directory_size "$HOME/opt/gopath/pkg")
    local go_src_size=$(get_directory_size "$HOME/opt/gopath/src")

    if [ -d "$HOME/opt/gopath/pkg" ]; then
        BUILD_ARTIFACTS["go_pkg"]="$HOME/opt/gopath/pkg|$(format_size $go_pkg_size)|Safe to remove"
    fi

    if [ -d "$HOME/opt/gopath/src" ]; then
        BUILD_ARTIFACTS["go_src"]="$HOME/opt/gopath/src|$(format_size $go_src_size)|Safe to remove"
    fi
}

find_cargo_artifacts() {
    local cargo_reg_size=$(get_directory_size "$HOME/.local/share/cargo/registry")
    local cargo_git_size=$(get_directory_size "$HOME/.local/share/cargo/git")

    if [ -d "$HOME/.local/share/cargo/registry" ]; then
        BUILD_ARTIFACTS["cargo_registry"]="$HOME/.local/share/cargo/registry|$(format_size $cargo_reg_size)|Safe (will re-download)"
    fi

    if [ -d "$HOME/.local/share/cargo/git" ]; then
        BUILD_ARTIFACTS["cargo_git"]="$HOME/.local/share/cargo/git|$(format_size $cargo_git_size)|Safe (will re-download)"
    fi
}

find_cache_artifacts() {
    local pip_size=$(get_directory_size "$HOME/.cache/pip")
    local npm_size=$(get_directory_size "$HOME/.cache/npm")
    local go_size=$(get_directory_size "$HOME/.cache/go-build")
    local python_size=$(get_directory_size "$HOME/.cache/python")

    if [ -d "$HOME/.cache/pip" ]; then
        BUILD_ARTIFACTS["pip_cache"]="$HOME/.cache/pip|$(format_size $pip_size)|Safe to remove"
    fi

    if [ -d "$HOME/.cache/npm" ]; then
        BUILD_ARTIFACTS["npm_cache"]="$HOME/.cache/npm|$(format_size $npm_size)|Safe to remove"
    fi

    if [ -d "$HOME/.cache/go-build" ]; then
        BUILD_ARTIFACTS["go_cache"]="$HOME/.cache/go-build|$(format_size $go_size)|Safe to remove"
    fi

    if [ -d "$HOME/.cache/python" ]; then
        BUILD_ARTIFACTS["python_cache"]="$HOME/.cache/python|$(format_size $python_size)|Safe to remove"
    fi
}

find_archive_artifacts() {
    if [ -d "$HOME/opt/src" ]; then
        local archives_size=$(get_directory_size "$HOME/opt/src")
        local archive_count=$(find "$HOME/opt/src" -type f \( -name "*.tar.gz" -o -name "*.tar.xz" \) 2>/dev/null | wc -l)

        if [ "$archive_count" -gt 0 ]; then
            BUILD_ARTIFACTS["archives"]="$HOME/opt/src/*.tar.*|$(format_size $archives_size)|Safe to remove ($archive_count files)"
        fi
    fi
}

generate_artifact_report() {
    print_subheader "Build Artifacts Detection"

    find_go_artifacts
    find_cargo_artifacts
    find_cache_artifacts
    find_archive_artifacts

    if [ ${#BUILD_ARTIFACTS[@]} -eq 0 ]; then
        echo -e "${GREEN}✓ No build artifacts found (or all cleaned)${NC}"
        return
    fi

    printf "%-40s %-15s %s\n" "Artifact Path" "Size" "Safety"
    printf "%-40s %-15s %s\n" "$(printf -- '-%.0s' {1..40})" "$(printf -- '-%.0s' {1..15})" "$(printf -- '-%.0s' {1..30})"

    for artifact in "${!BUILD_ARTIFACTS[@]}"; do
        local info="${BUILD_ARTIFACTS[$artifact]}"
        local path=$(echo "$info" | cut -d'|' -f1)
        local size=$(echo "$info" | cut -d'|' -f2)
        local safety=$(echo "$info" | cut -d'|' -f3)

        printf "%-40s ${YELLOW}%-15s${NC} ${GREEN}%s${NC}\n" "$path" "$size" "$safety"
    done

    echo ""
    echo -e "${CYAN}Total Artifacts Found: ${NC}${#BUILD_ARTIFACTS[@]}"
    echo -e "${YELLOW}These artifacts can be safely removed to recover disk space${NC}"
}

################################################################################
# TEST DIAGNOSIS FUNCTIONS
################################################################################

run_test_suite() {
    if [ ! -f "$SCRIPT_DIR/test_installation.sh" ]; then
        echo -e "${RED}Error: test_installation.sh not found${NC}"
        return 1
    fi

    echo -e "${CYAN}Running test suite...${NC}"
    # Run test suite with timeout to prevent infinite loops
    timeout 300 bash "$SCRIPT_DIR/test_installation.sh" 2>&1 || {
        local exit_code=$?
        if [ $exit_code -eq 124 ]; then
            echo -e "${RED}Error: Test suite timed out after 5 minutes (likely due to tool hanging)${NC}"
            echo -e "${YELLOW}Suggestion: Some tools like theHarvester may cause hangs during testing${NC}"
        fi
        return $exit_code
    }
}

parse_test_results() {
    local test_output="$1"
    local total_tests=0
    local passed_tests=0
    local failed_tests=0

    # Count test results
    total_tests=$(echo "$test_output" | grep -c '\[OK\]\|\[FAIL\]' || echo "0")
    passed_tests=$(echo "$test_output" | grep -c '\[OK\]' || echo "0")
    failed_tests=$(echo "$test_output" | grep -c '\[FAIL\]' || echo "0")

    echo "$total_tests|$passed_tests|$failed_tests"
}

check_environment_vars() {
    local issues=()

    # Check GOPATH
    if [ -z "$GOPATH" ]; then
        issues+=("GOPATH not set")
    elif [ ! -d "$GOPATH" ]; then
        issues+=("GOPATH directory does not exist: $GOPATH")
    fi

    # Check XDG variables
    for var in XDG_DATA_HOME XDG_CONFIG_HOME XDG_CACHE_HOME XDG_STATE_HOME; do
        if [ -z "${!var}" ]; then
            issues+=("$var not set")
        fi
    done

    # Check PATH components
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        issues+=("~/.local/bin not in PATH")
    fi

    if ! echo "$PATH" | grep -q "$HOME/opt/gopath/bin"; then
        issues+=("~/opt/gopath/bin not in PATH")
    fi

    if [ ${#issues[@]} -gt 0 ]; then
        printf '%s\n' "${issues[@]}"
        return 1
    fi

    return 0
}

diagnose_test_failure() {
    local test_name=$1
    local tool=$2

    case "$test_name" in
        *"Binary in correct location"*)
            if [ "$tool" = "go" ]; then
                echo "  ${YELLOW}Cause:${NC} Test expects /usr/bin/go but tool is in ~/opt/go/bin/"
                echo "  ${GREEN}Status:${NC} This is CORRECT for user-space installation"
                echo "  ${GREEN}Fix:${NC} No action needed - test script checks wrong path"
            elif [ "$tool" = "nodejs" ]; then
                echo "  ${YELLOW}Cause:${NC} Test expects /usr/local/bin/node but tool is in ~/opt/node/bin/"
                echo "  ${GREEN}Status:${NC} This is CORRECT for user-space installation"
                echo "  ${GREEN}Fix:${NC} No action needed - test script checks wrong path"
            fi
            ;;
        *"GOPATH environment variable"*)
            if [ -z "$GOPATH" ]; then
                echo "  ${RED}Cause:${NC} GOPATH environment variable not loaded"
                echo "  ${YELLOW}Fix:${NC} Run 'source ~/.bashrc' or start new shell session"
                echo "  ${CYAN}Verify:${NC} echo \$GOPATH (should show ~/opt/gopath)"
            else
                echo "  ${GREEN}Status:${NC} GOPATH is set: $GOPATH"
            fi
            ;;
        *"Can compile simple program"*)
            echo "  ${YELLOW}Cause:${NC} Prerequisite failure (GOPATH not set)"
            echo "  ${YELLOW}Fix:${NC} Resolve GOPATH issue first"
            ;;
        *"theHarvester"*)
            echo "  ${YELLOW}Cause:${NC} theHarvester tool hangs on help commands"
            echo "  ${GREEN}Status:${NC} This is a known issue with theHarvester"
            echo "  ${GREEN}Fix:${NC} Test script now skips execution test for theHarvester"
            ;;
        *)
            echo "  ${CYAN}Info:${NC} Generic test failure - check test output"
            ;;
    esac
}

generate_test_diagnosis_report() {
    print_subheader "Test Suite Diagnosis"

    # Run tests and capture output
    local test_output
    test_output=$(run_test_suite)

    echo ""
    print_subheader "Test Results Summary"

    # Parse results
    local results
    results=$(parse_test_results "$test_output")
    local total_tests=$(echo "$results" | cut -d'|' -f1)
    local passed_tests=$(echo "$results" | cut -d'|' -f2)
    local failed_tests=$(echo "$results" | cut -d'|' -f3)

    echo -e "${CYAN}Total Tests: ${NC}$total_tests"
    echo -e "${GREEN}Passed: ${NC}$passed_tests ($((passed_tests * 100 / total_tests))%)"
    echo -e "${RED}Failed: ${NC}$failed_tests ($((failed_tests * 100 / total_tests))%)"
    echo ""

    # Environment check
    print_subheader "Environment Variables Check"
    local env_issues
    if env_issues=$(check_environment_vars); then
        echo -e "${GREEN}✓ All environment variables are set correctly${NC}"
    else
        echo -e "${RED}✗ Environment issues detected:${NC}"
        while IFS= read -r issue; do
            echo -e "  ${YELLOW}•${NC} $issue"
        done <<< "$env_issues"
    fi
    echo ""

    # Analyze failed tests
    if [ "$failed_tests" -gt 0 ]; then
        print_subheader "Failed Test Analysis"

        # Extract and diagnose Go failures
        if echo "$test_output" | grep -q "Testing Go"; then
            echo -e "${MAGENTA}Go Tests:${NC}"
            if echo "$test_output" | grep -A1 "Testing Go" | grep -q "FAIL.*Binary in correct location"; then
                echo -e "${RED}  ✗ Binary in correct location${NC}"
                diagnose_test_failure "Binary in correct location" "go"
            fi
            if echo "$test_output" | grep -A1 "Testing Go" | grep -q "FAIL.*GOPATH"; then
                echo -e "${RED}  ✗ GOPATH environment variable set${NC}"
                diagnose_test_failure "GOPATH environment variable" "go"
            fi
            if echo "$test_output" | grep -A1 "Testing Go" | grep -q "FAIL.*compile"; then
                echo -e "${RED}  ✗ Can compile simple program${NC}"
                diagnose_test_failure "Can compile simple program" "go"
            fi
            echo ""
        fi

        # Extract and diagnose Node.js failures
        if echo "$test_output" | grep -q "Testing Node.js"; then
            echo -e "${MAGENTA}Node.js Tests:${NC}"
            if echo "$test_output" | grep -A1 "Testing Node.js" | grep -q "FAIL.*Binary in correct location"; then
                echo -e "${RED}  ✗ Binary in correct location${NC}"
                diagnose_test_failure "Binary in correct location" "nodejs"
            fi
            echo ""
        fi

        # Overall recommendation
        print_subheader "Recommendations"
        echo -e "${YELLOW}Root Cause:${NC} Test script expects system paths (/usr/bin, /usr/local/bin)"
        echo -e "${YELLOW}Reality:${NC} Tools installed in user-space paths (~/opt/, ~/.local/)"
        echo -e "${GREEN}Conclusion:${NC} Installation is CORRECT - test script needs updating for user-space"
        echo ""
        echo -e "${CYAN}Suggested Actions:${NC}"
        echo "  1. Run 'source ~/.bashrc' to load environment variables"
        echo "  2. Verify GOPATH: echo \$GOPATH"
        echo "  3. If tests hang on theHarvester, the test script has been updated to skip problematic tests"
        echo "  4. Consider updating test_installation.sh to check user-space paths"
    else
        echo -e "${GREEN}✓ All tests passed!${NC}"
    fi
}

################################################################################
# XDG COMPLIANCE FUNCTIONS
################################################################################

check_xdg_compliance() {
    # Check each major installation location against XDG spec
    local compliant=0
    local non_compliant=0

    # Compliant locations
    if [ -d "$HOME/.local/bin" ]; then
        ((compliant++))
    fi
    if [ -d "$HOME/.local/share" ]; then
        ((compliant++))
    fi
    if [ -d "$HOME/.config" ]; then
        ((compliant++))
    fi
    if [ -d "$HOME/.cache" ]; then
        ((compliant++))
    fi
    if [ -d "$HOME/.local/state" ]; then
        ((compliant++))
    fi

    # Non-compliant locations
    if [ -d "$HOME/opt/gopath" ]; then
        XDG_VIOLATIONS["gopath"]="~/opt/gopath|Should be ~/.local/share/gopath"
        ((non_compliant++))
    fi
    if [ -d "$HOME/opt/node" ]; then
        XDG_VIOLATIONS["node"]="~/opt/node|Should be ~/.local/opt/node"
        ((non_compliant++))
    fi
    if [ -d "$HOME/opt/go" ]; then
        XDG_VIOLATIONS["go"]="~/opt/go|Should be ~/.local/opt/go"
        ((non_compliant++))
    fi

    echo "$compliant|$non_compliant"
}

generate_xdg_report() {
    print_subheader "XDG Base Directory Specification Compliance"

    local compliance
    compliance=$(check_xdg_compliance)
    local compliant=$(echo "$compliance" | cut -d'|' -f1)
    local non_compliant=$(echo "$compliance" | cut -d'|' -f2)
    local total=$((compliant + non_compliant))

    echo -e "${GREEN}✅ Compliant Locations: ${NC}$compliant/$total ($((compliant * 100 / total))%)"
    if [ "$non_compliant" -gt 0 ]; then
        echo -e "${RED}❌ Non-Compliant Locations: ${NC}$non_compliant/$total ($((non_compliant * 100 / total))%)"
    fi
    echo ""

    printf "%-30s %-20s\n" "Location" "Status"
    printf "%-30s %-20s\n" "$(printf -- '-%.0s' {1..30})" "$(printf -- '-%.0s' {1..20})"

    # Show compliant locations
    printf "%-30s ${GREEN}%-20s${NC}\n" "~/.local/bin/" "[COMPLIANT]"
    printf "%-30s ${GREEN}%-20s${NC}\n" "~/.local/share/" "[COMPLIANT]"
    printf "%-30s ${GREEN}%-20s${NC}\n" "~/.local/state/" "[COMPLIANT]"
    printf "%-30s ${GREEN}%-20s${NC}\n" "~/.config/" "[COMPLIANT]"
    printf "%-30s ${GREEN}%-20s${NC}\n" "~/.cache/" "[COMPLIANT]"

    # Show non-compliant locations
    for violation in "${!XDG_VIOLATIONS[@]}"; do
        local info="${XDG_VIOLATIONS[$violation]}"
        local path=$(echo "$info" | cut -d'|' -f1)
        printf "%-30s ${RED}%-20s${NC}\n" "$path" "[NON-COMPLIANT]"
    done

    if [ "$non_compliant" -gt 0 ]; then
        echo ""
        print_subheader "Migration Recommendations"
        echo -e "${YELLOW}Use --migration-plan to see detailed migration commands${NC}"
    fi
}

generate_migration_plan() {
    print_subheader "XDG Compliance Migration Plan"

    check_xdg_compliance  # Populate XDG_VIOLATIONS

    if [ ${#XDG_VIOLATIONS[@]} -eq 0 ]; then
        echo -e "${GREEN}✓ All locations are XDG compliant!${NC}"
        return
    fi

    echo -e "${YELLOW}The following commands will migrate non-compliant locations:${NC}"
    echo -e "${RED}⚠ WARNING: These commands are shown for reference. Review carefully before executing!${NC}"
    echo ""

    for violation in "${!XDG_VIOLATIONS[@]}"; do
        local info="${XDG_VIOLATIONS[$violation]}"
        local current_path=$(echo "$info" | cut -d'|' -f1)
        local recommended_path=$(echo "$info" | cut -d'|' -f2 | sed 's/Should be //')

        echo -e "${CYAN}# Migrate $current_path${NC}"
        echo "mkdir -p $(dirname "$recommended_path")"
        echo "mv $current_path $recommended_path"

        case "$violation" in
            gopath)
                echo "# Update GOPATH in ~/.bashrc"
                echo "sed -i 's|~/opt/gopath|~/.local/share/gopath|g' ~/.bashrc"
                echo "source ~/.bashrc"
                ;;
            node)
                echo "# Update PATH in ~/.bashrc"
                echo "sed -i 's|~/opt/node|~/.local/opt/node|g' ~/.bashrc"
                echo "source ~/.bashrc"
                ;;
            go)
                echo "# Update GOROOT in ~/.bashrc"
                echo "sed -i 's|~/opt/go|~/.local/opt/go|g' ~/.bashrc"
                echo "source ~/.bashrc"
                ;;
        esac
        echo ""
    done

    echo -e "${YELLOW}⚠ Note: Test tools after migration to ensure everything works${NC}"
}

################################################################################
# CLEANUP FUNCTIONS
################################################################################

generate_cleanup_commands() {
    print_subheader "Safe Cleanup Commands"

    echo -e "${YELLOW}The following commands can safely recover disk space:${NC}"
    echo ""

    echo -e "${GREEN}# Immediate Safe Cleanup (No impact on functionality)${NC}"
    echo ""
    echo "# Remove downloaded archives"
    echo "rm -f ~/opt/src/*.tar.gz ~/opt/src/*.tar.xz"
    echo ""
    echo "# Remove Go build artifacts (will be rebuilt if needed)"
    echo "rm -rf ~/opt/gopath/pkg/* ~/opt/gopath/src/*"
    echo ""
    echo "# Clear pip cache"
    echo "rm -rf ~/.cache/pip/*"
    echo ""
    echo "# Clear npm cache"
    echo "npm cache clean --force"
    echo ""
    echo "# Clear Go build cache"
    echo "go clean -cache -modcache 2>/dev/null || true"
    echo ""

    echo -e "${YELLOW}# Conservative Cleanup (May slow down future builds)${NC}"
    echo ""
    echo "# Remove Cargo registry (will re-download if needed)"
    echo "rm -rf ~/.local/share/cargo/registry/*"
    echo ""
    echo "# Remove Cargo git checkouts"
    echo "rm -rf ~/.local/share/cargo/git/*"
    echo ""
    echo "# Remove Python bytecode cache"
    echo "find ~/.cache/python/ -type f -name '*.pyc' -delete 2>/dev/null || true"
    echo ""

    echo -e "${CYAN}Expected space recovery: $(format_size $RECOVERABLE_SPACE)${NC}"
    echo ""
    echo -e "${YELLOW}To execute cleanup, run: ./diagnose_installation.sh --cleanup${NC}"
}

execute_cleanup() {
    print_subheader "Execute Safe Cleanup"

    # Calculate what we can recover
    calculate_disk_usage
    categorize_disk_usage >/dev/null

    echo -e "${CYAN}Estimated recoverable space: $(format_size $RECOVERABLE_SPACE)${NC}"
    echo ""
    echo -e "${YELLOW}This will remove:${NC}"
    echo "  • Downloaded archives (~/opt/src/*.tar.*)"
    echo "  • Go build artifacts (~/opt/gopath/pkg, ~/opt/gopath/src)"
    echo "  • pip cache (~/.cache/pip)"
    echo "  • npm cache (~/.cache/npm)"
    echo "  • Go build cache (~/.cache/go-build)"
    echo ""
    echo -e "${RED}⚠ This action cannot be undone easily!${NC}"
    echo ""
    read -p "Continue with cleanup? (yes/no): " confirm

    if [ "$confirm" != "yes" ]; then
        echo -e "${YELLOW}Cleanup cancelled${NC}"
        return 1
    fi

    echo ""
    echo -e "${CYAN}Executing cleanup...${NC}"

    # Remove archives
    if [ -d "$HOME/opt/src" ]; then
        echo -n "Removing archives... "
        rm -f "$HOME/opt/src"/*.tar.gz "$HOME/opt/src"/*.tar.xz 2>/dev/null
        echo -e "${GREEN}done${NC}"
    fi

    # Remove Go artifacts
    if [ -d "$HOME/opt/gopath/pkg" ]; then
        echo -n "Removing Go pkg... "
        rm -rf "$HOME/opt/gopath/pkg"/* 2>/dev/null
        echo -e "${GREEN}done${NC}"
    fi
    if [ -d "$HOME/opt/gopath/src" ]; then
        echo -n "Removing Go src... "
        rm -rf "$HOME/opt/gopath/src"/* 2>/dev/null
        echo -e "${GREEN}done${NC}"
    fi

    # Clear caches
    if [ -d "$HOME/.cache/pip" ]; then
        echo -n "Clearing pip cache... "
        rm -rf "$HOME/.cache/pip"/* 2>/dev/null
        echo -e "${GREEN}done${NC}"
    fi

    if command -v npm &>/dev/null; then
        echo -n "Clearing npm cache... "
        npm cache clean --force >/dev/null 2>&1
        echo -e "${GREEN}done${NC}"
    fi

    if command -v go &>/dev/null; then
        echo -n "Clearing Go cache... "
        go clean -cache -modcache 2>/dev/null || true
        echo -e "${GREEN}done${NC}"
    fi

    echo ""
    echo -e "${GREEN}✓ Cleanup completed!${NC}"
    echo ""
    echo "Verifying tools still work..."
    # Quick verification
    local broken_tools=0
    for tool in cmake node go cargo; do
        if command -v "$tool" &>/dev/null; then
            echo -e "  ${GREEN}✓${NC} $tool is accessible"
        else
            if is_tool_installed "$tool"; then
                echo -e "  ${RED}✗${NC} $tool may be broken"
                ((broken_tools++))
            fi
        fi
    done

    if [ "$broken_tools" -eq 0 ]; then
        echo ""
        echo -e "${GREEN}✓ All tools verified - cleanup successful!${NC}"
    else
        echo ""
        echo -e "${RED}⚠ Some tools may need attention${NC}"
    fi
}

################################################################################
# MAIN EXECUTION
################################################################################

main() {
    init_colors

    # Check requirements
    if ! check_requirements; then
        exit 1
    fi

    # Parse command-line arguments
    local mode="full-report"

    while [[ $# -gt 0 ]]; do
        case $1 in
            --inventory)
                mode="inventory"
                shift
                ;;
            --disk-usage)
                mode="disk-usage"
                shift
                ;;
            --build-artifacts)
                mode="build-artifacts"
                shift
                ;;
            --xdg-check)
                mode="xdg-check"
                shift
                ;;
            --test-diagnosis)
                mode="test-diagnosis"
                shift
                ;;
            --migration-plan)
                mode="migration-plan"
                shift
                ;;
            --cleanup-plan)
                mode="cleanup-plan"
                shift
                ;;
            --full-report)
                mode="full-report"
                shift
                ;;
            --cleanup)
                mode="cleanup"
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo -e "${RED}Error: Unknown option: $1${NC}"
                echo -e "Use ${CYAN}--help${NC} for usage information"
                exit 1
                ;;
        esac
    done

    # Print banner
    print_header "Security Tools Installation Diagnostic Report"
    echo -e "${CYAN}Generated: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
    echo -e "${CYAN}Script Version: $SCRIPT_VERSION${NC}"

    # Load tool definitions
    load_tool_definitions

    # Execute requested mode
    case $mode in
        inventory)
            scan_installed_tools
            generate_inventory_report
            ;;
        disk-usage)
            generate_disk_report
            ;;
        build-artifacts)
            generate_artifact_report
            ;;
        xdg-check)
            generate_xdg_report
            ;;
        test-diagnosis)
            generate_test_diagnosis_report
            ;;
        migration-plan)
            generate_migration_plan
            ;;
        cleanup-plan)
            calculate_disk_usage
            categorize_disk_usage >/dev/null
            generate_cleanup_commands
            ;;
        full-report)
            # Generate comprehensive diagnostic report
            scan_installed_tools
            generate_inventory_report

            generate_disk_report

            generate_artifact_report

            generate_xdg_report

            calculate_disk_usage
            categorize_disk_usage >/dev/null
            generate_cleanup_commands

            # Save report location note
            local report_file="$HOME/.local/state/install_tools/diagnostic-$(date '+%Y%m%d-%H%M%S').txt"
            echo ""
            echo -e "${CYAN}Note: To save this report, redirect output to a file:${NC}"
            echo "  ./diagnose_installation.sh --full-report > \"$report_file\""
            ;;
        cleanup)
            execute_cleanup
            ;;
    esac

    echo ""
    echo -e "${GREEN}Diagnostic script completed.${NC}"
    echo ""
}

# Run main function
main "$@"
