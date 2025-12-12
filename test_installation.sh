#!/bin/bash
# Test Script for Security Tools Installation
# Version: 1.0
# Verifies all installed tools are working correctly
#
# Usage: bash test_installation.sh [tool_name]
#        bash test_installation.sh              # Test all installed
#        bash test_installation.sh sherlock     # Test specific tool

# ===== COLOR CODES =====
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;36m'
CYAN='\033[0;36m'
NC='\033[0m'

# ===== COUNTERS =====
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
declare -a FAILED_TOOLS

# ===== TEST RESULT TRACKING =====
test_result() {
    local tool=$1
    local test_name=$2
    local result=$3
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ $result -eq 0 ]; then
        echo -e "${GREEN}  âœ“${NC} $test_name"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        return 0
    else
        echo -e "${RED}  âœ—${NC} $test_name"
        FAILED_TESTS=$((FAILED_TESTS + 1))
        FAILED_TOOLS+=("$tool")
        return 1
    fi
}

# ===== BUILD TOOLS TESTS =====

test_cmake() {
    echo -e "${CYAN}Testing CMake...${NC}"
    
    # Test 1: Command exists
    command -v cmake &>/dev/null
    test_result "cmake" "Command exists" $?
    
    # Test 2: Version check
    cmake --version &>/dev/null
    test_result "cmake" "Version check" $?
    
    # Test 3: Location check
    [ -f "$HOME/.local/bin/cmake" ]
    test_result "cmake" "Binary in correct location" $?
    
    echo ""
}

test_github_cli() {
    echo -e "${CYAN}Testing GitHub CLI...${NC}"
    
    # Test 1: Command exists
    command -v gh &>/dev/null
    test_result "github_cli" "Command exists" $?
    
    # Test 2: Version check
    gh --version &>/dev/null
    test_result "github_cli" "Version check" $?
    
    # Test 3: Binary in correct location
    [ -f "$HOME/.local/bin/gh" ]
    test_result "github_cli" "Binary in correct location" $?
    
    echo ""
}

# ===== LANGUAGE RUNTIME TESTS =====

test_go() {
    echo -e "${CYAN}Testing Go...${NC}"
    
    # Test 1: Command exists
    command -v go &>/dev/null
    test_result "go" "Command exists" $?
    
    # Test 2: Version check
    go version &>/dev/null
    test_result "go" "Version check" $?
    
    # Test 3: Location check
    [ -f "$HOME/opt/go/bin/go" ]
    test_result "go" "Binary in correct location" $?
    
    # Test 4: GOPATH set
    [ -n "$GOPATH" ]
    test_result "go" "GOPATH environment variable set" $?
    
    # Test 5: Can compile
    echo 'package main; func main() {}' | go run - &>/dev/null
    test_result "go" "Can compile simple program" $?
    
    echo ""
}

test_nodejs() {
    echo -e "${CYAN}Testing Node.js...${NC}"
    
    # Test 1: Node command exists
    command -v node &>/dev/null
    test_result "nodejs" "Node command exists" $?
    
    # Test 2: npm command exists
    command -v npm &>/dev/null
    test_result "nodejs" "npm command exists" $?
    
    # Test 3: Version check
    node --version &>/dev/null
    test_result "nodejs" "Node version check" $?
    
    # Test 4: npm version
    npm --version &>/dev/null
    test_result "nodejs" "npm version check" $?
    
    # Test 5: Location check
    [ -f "$HOME/opt/node/bin/node" ]
    test_result "nodejs" "Binary in correct location" $?
    
    # Test 6: Can run JavaScript
    node -e "console.log('test')" &>/dev/null
    test_result "nodejs" "Can execute JavaScript" $?
    
    echo ""
}

test_rust() {
    echo -e "${CYAN}Testing Rust...${NC}"
    
    # Test 1: cargo command exists
    command -v cargo &>/dev/null
    test_result "rust" "cargo command exists" $?
    
    # Test 2: rustc command exists
    command -v rustc &>/dev/null
    test_result "rust" "rustc command exists" $?
    
    # Test 3: Version check
    cargo --version &>/dev/null
    test_result "rust" "cargo version check" $?
    
    # Test 4: CARGO_HOME set
    [ -n "$CARGO_HOME" ]
    test_result "rust" "CARGO_HOME environment variable set" $?
    
    echo ""
}

test_python_venv() {
    echo -e "${CYAN}Testing Python Virtual Environment...${NC}"
    
    # Test 1: Venv directory exists
    [ -d "$XDG_DATA_HOME/virtualenvs/tools" ]
    test_result "python_venv" "Venv directory exists" $?
    
    # Test 2: Activation script exists
    [ -f "$XDG_DATA_HOME/virtualenvs/tools/bin/activate" ]
    test_result "python_venv" "Activation script exists" $?
    
    # Test 3: Python in venv
    [ -f "$XDG_DATA_HOME/virtualenvs/tools/bin/python" ]
    test_result "python_venv" "Python binary in venv" $?
    
    # Test 4: pip in venv
    [ -f "$XDG_DATA_HOME/virtualenvs/tools/bin/pip" ]
    test_result "python_venv" "pip in venv" $?
    
    # Test 5: Can activate venv
    source "$XDG_DATA_HOME/virtualenvs/tools/bin/activate" && deactivate &>/dev/null
    test_result "python_venv" "Can activate and deactivate venv" $?
    
    echo ""
}

# ===== PYTHON TOOL TESTS =====

test_python_tool() {
    local tool=$1
    local package=$2
    
    echo -e "${CYAN}Testing $tool...${NC}"
    
    # Test 1: Wrapper exists
    [ -f "$HOME/.local/bin/$tool" ]
    test_result "$tool" "Wrapper script exists" $?
    
    # Test 2: Wrapper is executable
    [ -x "$HOME/.local/bin/$tool" ]
    test_result "$tool" "Wrapper is executable" $?
    
    # Test 3: Command exists in PATH
    command -v "$tool" &>/dev/null
    test_result "$tool" "Command in PATH" $?
    
    # Test 4: Package installed in venv
    source "$XDG_DATA_HOME/virtualenvs/tools/bin/activate"
    pip show "$package" &>/dev/null
    local result=$?
    deactivate
    test_result "$tool" "Package installed in venv" $result
    
    # Test 5: Can show help
    timeout 5 "$tool" --help &>/dev/null
    test_result "$tool" "Can execute --help" $?
    
    echo ""
}

test_sherlock() { test_python_tool "sherlock" "sherlock-project"; }
test_holehe() { test_python_tool "holehe" "holehe"; }
test_socialscan() { test_python_tool "socialscan" "socialscan"; }
test_h8mail() { test_python_tool "h8mail" "h8mail"; }
test_photon() { test_python_tool "photon" "photon-python"; }
test_sublist3r() { test_python_tool "sublist3r" "sublist3r"; }
test_shodan() { test_python_tool "shodan" "shodan"; }
test_censys() { test_python_tool "censys" "censys"; }
test_theHarvester() { test_python_tool "theHarvester" "theHarvester"; }
test_spiderfoot() { test_python_tool "spiderfoot" "spiderfoot"; }

test_yara() {
    echo -e "${CYAN}Testing YARA...${NC}"
    
    # Test 1: Wrapper exists
    [ -f "$HOME/.local/bin/yara" ]
    test_result "yara" "Wrapper script exists" $?
    
    # Test 2: Package installed
    source "$XDG_DATA_HOME/virtualenvs/tools/bin/activate"
    python3 -c "import yara" &>/dev/null
    local result=$?
    deactivate
    test_result "yara" "Python module can be imported" $result
    
    # Test 3: yara-python installed
    source "$XDG_DATA_HOME/virtualenvs/tools/bin/activate"
    pip show yara-python &>/dev/null
    result=$?
    deactivate
    test_result "yara" "yara-python package installed" $result
    
    echo ""
}

# ===== GO TOOL TESTS =====

test_go_tool() {
    local tool=$1
    local binary=${2:-$tool}
    
    echo -e "${CYAN}Testing $tool...${NC}"
    
    # Test 1: Binary exists
    [ -f "$HOME/opt/gopath/bin/$binary" ]
    test_result "$tool" "Binary exists in GOPATH" $?
    
    # Test 2: Command in PATH
    command -v "$binary" &>/dev/null
    test_result "$tool" "Command in PATH" $?
    
    # Test 3: Can show version or help
    timeout 5 "$binary" --version &>/dev/null || timeout 5 "$binary" -h &>/dev/null
    test_result "$tool" "Can execute (version/help)" $?
    
    # Test 4: Is executable
    [ -x "$HOME/opt/gopath/bin/$binary" ]
    test_result "$tool" "Binary is executable" $?
    
    echo ""
}

test_gobuster() { test_go_tool "gobuster"; }
test_ffuf() { test_go_tool "ffuf"; }
test_httprobe() { test_go_tool "httprobe"; }
test_waybackurls() { test_go_tool "waybackurls"; }
test_assetfinder() { test_go_tool "assetfinder"; }
test_subfinder() { test_go_tool "subfinder"; }
test_nuclei() { test_go_tool "nuclei"; }
test_virustotal() { test_go_tool "virustotal" "vt"; }

# ===== NODE.JS TOOL TESTS =====

test_node_tool() {
    local tool=$1
    local binary=${2:-$tool}
    
    echo -e "${CYAN}Testing $tool...${NC}"
    
    # Test 1: Command exists
    command -v "$binary" &>/dev/null
    test_result "$tool" "Command exists" $?
    
    # Test 2: Binary in .local/bin
    [ -f "$HOME/.local/bin/$binary" ] || [ -L "$HOME/.local/bin/$binary" ]
    test_result "$tool" "Binary in .local/bin" $?
    
    # Test 3: Can show version or help
    timeout 5 "$binary" --version &>/dev/null || timeout 5 "$binary" --help &>/dev/null || timeout 5 "$binary" -h &>/dev/null
    test_result "$tool" "Can execute (version/help)" $?
    
    echo ""
}

test_trufflehog() { test_node_tool "trufflehog"; }
test_git-hound() { test_node_tool "git-hound"; }
test_jwt-cracker() { test_node_tool "jwt-cracker"; }

# ===== RUST TOOL TESTS =====

test_rust_tool() {
    local tool=$1
    local command=${2:-$tool}
    
    echo -e "${CYAN}Testing $tool...${NC}"
    
    # Test 1: Command exists
    command -v "$command" &>/dev/null
    test_result "$tool" "Command exists" $?
    
    # Test 2: Can show version or help
    timeout 5 "$command" --version &>/dev/null || timeout 5 "$command" --help &>/dev/null
    test_result "$tool" "Can execute (version/help)" $?
    
    # Test 3: Binary is in CARGO_HOME or PATH
    which "$command" &>/dev/null
    test_result "$tool" "Binary in PATH" $?
    
    echo ""
}

test_feroxbuster() { test_rust_tool "feroxbuster"; }
test_rustscan() { test_rust_tool "rustscan"; }
test_ripgrep() { test_rust_tool "ripgrep" "rg"; }
test_fd() { test_rust_tool "fd"; }
test_bat() { test_rust_tool "bat"; }
test_sd() { test_rust_tool "sd"; }
test_tokei() { test_rust_tool "tokei"; }
test_dog() { test_rust_tool "dog"; }

# ===== INTEGRATION TESTS =====

test_integration() {
    echo -e "${BLUE}=========================================="
    echo "Integration Tests"
    echo -e "==========================================${NC}"
    echo ""
    
    # Test 1: Python tools can access venv
    if command -v sherlock &>/dev/null; then
        echo -e "${CYAN}Testing Python tool venv integration...${NC}"
        sherlock --help &>/dev/null
        test_result "integration" "Python tools auto-activate venv" $?
        echo ""
    fi
    
    # Test 2: Go tools have correct GOPATH
    if command -v gobuster &>/dev/null; then
        echo -e "${CYAN}Testing Go tool GOPATH integration...${NC}"
        [ -f "$GOPATH/bin/gobuster" ]
        test_result "integration" "Go tools in GOPATH" $?
        echo ""
    fi
    
    # Test 3: Environment variables set
    echo -e "${CYAN}Testing environment variables...${NC}"
    [ -n "$XDG_DATA_HOME" ]
    test_result "integration" "XDG_DATA_HOME is set" $?
    
    [ -n "$XDG_CONFIG_HOME" ]
    test_result "integration" "XDG_CONFIG_HOME is set" $?
    
    [ -n "$XDG_CACHE_HOME" ]
    test_result "integration" "XDG_CACHE_HOME is set" $?
    
    echo ""
}

# ===== MAIN TEST RUNNER =====

run_all_tests() {
    echo -e "${BLUE}=========================================="
    echo "Security Tools Installation Test Suite"
    echo -e "==========================================${NC}"
    echo ""
    
    # Build Tools
    command -v cmake &>/dev/null && test_cmake
    command -v gh &>/dev/null && test_github_cli
    
    # Languages
    command -v go &>/dev/null && test_go
    command -v node &>/dev/null && test_nodejs
    command -v cargo &>/dev/null && test_rust
    
    # Python venv
    [ -d "$XDG_DATA_HOME/virtualenvs/tools" ] && test_python_venv
    
    # Python tools
    command -v sherlock &>/dev/null && test_sherlock
    command -v holehe &>/dev/null && test_holehe
    command -v socialscan &>/dev/null && test_socialscan
    command -v h8mail &>/dev/null && test_h8mail
    command -v photon &>/dev/null && test_photon
    command -v sublist3r &>/dev/null && test_sublist3r
    command -v shodan &>/dev/null && test_shodan
    command -v censys &>/dev/null && test_censys
    command -v theHarvester &>/dev/null && test_theHarvester
    command -v spiderfoot &>/dev/null && test_spiderfoot
    [ -f "$HOME/.local/bin/yara" ] && test_yara
    
    # Go tools
    command -v gobuster &>/dev/null && test_gobuster
    command -v ffuf &>/dev/null && test_ffuf
    command -v httprobe &>/dev/null && test_httprobe
    command -v waybackurls &>/dev/null && test_waybackurls
    command -v assetfinder &>/dev/null && test_assetfinder
    command -v subfinder &>/dev/null && test_subfinder
    command -v nuclei &>/dev/null && test_nuclei
    command -v vt &>/dev/null && test_virustotal
    
    # Node.js tools
    command -v trufflehog &>/dev/null && test_trufflehog
    command -v git-hound &>/dev/null && test_git-hound
    command -v jwt-cracker &>/dev/null && test_jwt-cracker
    
    # Rust tools
    command -v feroxbuster &>/dev/null && test_feroxbuster
    command -v rustscan &>/dev/null && test_rustscan
    command -v rg &>/dev/null && test_ripgrep
    command -v fd &>/dev/null && test_fd
    command -v bat &>/dev/null && test_bat
    command -v sd &>/dev/null && test_sd
    command -v tokei &>/dev/null && test_tokei
    command -v dog &>/dev/null && test_dog
    
    # Integration tests
    test_integration
}

run_specific_test() {
    local tool=$1
    
    echo -e "${BLUE}=========================================="
    echo "Testing: $tool"
    echo -e "==========================================${NC}"
    echo ""
    
    case "$tool" in
        cmake) test_cmake ;;
        github_cli) test_github_cli ;;
        go) test_go ;;
        nodejs) test_nodejs ;;
        rust) test_rust ;;
        python_venv) test_python_venv ;;
        sherlock) test_sherlock ;;
        holehe) test_holehe ;;
        socialscan) test_socialscan ;;
        h8mail) test_h8mail ;;
        photon) test_photon ;;
        sublist3r) test_sublist3r ;;
        shodan) test_shodan ;;
        censys) test_censys ;;
        theHarvester) test_theHarvester ;;
        spiderfoot) test_spiderfoot ;;
        yara) test_yara ;;
        gobuster) test_gobuster ;;
        ffuf) test_ffuf ;;
        httprobe) test_httprobe ;;
        waybackurls) test_waybackurls ;;
        assetfinder) test_assetfinder ;;
        subfinder) test_subfinder ;;
        nuclei) test_nuclei ;;
        virustotal) test_virustotal ;;
        trufflehog) test_trufflehog ;;
        git-hound) test_git-hound ;;
        jwt-cracker) test_jwt-cracker ;;
        feroxbuster) test_feroxbuster ;;
        rustscan) test_rustscan ;;
        ripgrep) test_ripgrep ;;
        fd) test_fd ;;
        bat) test_bat ;;
        sd) test_sd ;;
        tokei) test_tokei ;;
        dog) test_dog ;;
        integration) test_integration ;;
        *)
            echo -e "${RED}Unknown tool: $tool${NC}"
            exit 1
            ;;
    esac
}

show_summary() {
    echo -e "${BLUE}=========================================="
    echo "Test Summary"
    echo -e "==========================================${NC}"
    echo ""
    echo "Total tests: $TOTAL_TESTS"
    echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
    echo -e "${RED}Failed: $FAILED_TESTS${NC}"
    echo ""
    
    if [ $FAILED_TESTS -gt 0 ]; then
        echo -e "${RED}Failed tools:${NC}"
        # Remove duplicates
        printf '%s\n' "${FAILED_TOOLS[@]}" | sort -u | while read tool; do
            echo -e "  ${RED}âœ—${NC} $tool"
        done
        echo ""
        exit 1
    else
        echo -e "${GREEN}All tests passed! âœ“${NC}"
        echo ""
        exit 0
    fi
}

# ===== MAIN =====

main() {
    # Check XDG environment
    if [ -z "$XDG_DATA_HOME" ]; then
        export XDG_DATA_HOME="$HOME/.local/share"
        export XDG_CONFIG_HOME="$HOME/.config"
        export XDG_CACHE_HOME="$HOME/.cache"
        export XDG_STATE_HOME="$HOME/.local/state"
    fi
    
    # Check for specific tool test
    if [ $# -eq 1 ]; then
        run_specific_test "$1"
        show_summary
    else
        run_all_tests
        show_summary
    fi
}

main "$@"
