# Extending install_security_tools.sh

## Overview

The `install_security_tools.sh` script is designed to be easily extensible. This guide shows you how to add new tools following the established patterns.

## Current Implementation Status

### âœ… Fully Implemented (36 tools)
- **Build Tools:** cmake
- **Languages:** go, nodejs, rust
- **Python Prerequisite:** python_venv
- **Python Tools (12):** sherlock, holehe, socialscan, h8mail, photon, sublist3r, shodan, censys, theHarvester, spiderfoot, yara, wappalyzer
- **Go Tools (8):** gobuster, ffuf, httprobe, waybackurls, assetfinder, subfinder, nuclei, virustotal
- **Node.js Tools (3):** trufflehog, git-hound, jwt-cracker
- **Rust Tools (8):** feroxbuster, rustscan, ripgrep, fd, bat, sd, tokei, dog

## Adding a New Tool

### Step 1: Define the Tool

Add to the `define_tools()` function:

```bash
define_tools() {
    # ... existing definitions ...
    
    # Your new tool
    TOOL_INFO[newtool]="NewTool|Short description|Category"
    TOOL_SIZES[newtool]="10MB"
    TOOL_DEPENDENCIES[newtool]="python_venv"  # or "go" or "nodejs" or "rust"
    TOOL_INSTALL_LOCATION[newtool]="~/.local/bin/newtool"
}
```

### Step 2: Add to Category Array

Add the tool name to the appropriate category array:

```bash
# For Python tools
PYTHON_RECON_PASSIVE=("sherlock" "holehe" "socialscan" "newtool")

# For Go tools
GO_RECON_ACTIVE=("gobuster" "ffuf" "newtool")

# For Node.js tools
NODE_TOOLS=("trufflehog" "git-hound" "newtool")

# For Rust tools
RUST_RECON=("feroxbuster" "rustscan" "newtool")
```

### Step 3: Add Installation Status Check

Add to the `is_installed()` function:

```bash
is_installed() {
    local tool=$1
    
    case "$tool" in
        # ... existing cases ...
        
        # Your new tool
        newtool)
            [ -f "$HOME/.local/bin/newtool" ] && return 0 ;;
    esac
    
    return 1
}
```

### Step 4: Create Installation Function

#### Option A: Python Tool (Use Generic Installer)

```bash
# Just add this one line:
install_newtool() { install_python_tool "newtool" "newtool-package"; }

# Or if the pip package name is different:
install_newtool() { install_python_tool "newtool" "python-newtool"; }
```

#### Option B: Go Tool (Use Generic Installer)

```bash
# Just add this one line:
install_newtool() { install_go_tool "newtool" "github.com/author/newtool"; }
```

#### Option C: Node.js Tool (Use Generic Installer)

```bash
# Just add this one line:
install_newtool() { install_node_tool "newtool" "newtool-npm-package"; }
```

#### Option D: Rust Tool (Use Generic Installer)

```bash
# Just add this one line:
install_newtool() { install_rust_tool "newtool" "newtool"; }
```

#### Option E: Custom Installation (Complex Tools)

```bash
install_newtool() {
    local logfile=$(create_tool_log "newtool")
    
    {
        echo "=========================================="
        echo "Installing NewTool"
        echo "Started: $(date)"
        echo "=========================================="
        
        # Your custom installation steps here
        cd "$HOME/opt/src"
        wget https://example.com/newtool.tar.gz
        tar -xzf newtool.tar.gz
        cd newtool
        make PREFIX="$HOME/.local" install
        
        echo "=========================================="
        echo "Completed: $(date)"
        echo "=========================================="
    } > "$logfile" 2>&1
    
    if is_installed "newtool"; then
        echo -e "${GREEN}âœ“ NewTool installed successfully${NC}"
        SUCCESSFUL_INSTALLS+=("newtool")
        log_installation "newtool" "success" "$logfile"
        cleanup_old_logs "newtool"
        return 0
    else
        echo -e "${RED}âœ— NewTool installation failed${NC}"
        echo "  See log: $logfile"
        FAILED_INSTALLS+=("newtool")
        FAILED_INSTALL_LOGS["newtool"]="$logfile"
        log_installation "newtool" "failure" "$logfile"
        return 1
    fi
}
```

### Step 5: Add to Install Tool Dispatcher

Add to the `install_tool()` function's case statement:

```bash
install_tool() {
    local tool=$1
    
    # ... dependency checks ...
    
    case "$tool" in
        # ... existing cases ...
        newtool) install_newtool ;;
        *)
            echo -e "${RED}Unknown tool: $tool${NC}"
            return 1
            ;;
    esac
}
```

### Step 6: Add to Menu

Add to the `show_menu()` function:

```bash
show_menu() {
    # ... existing menu items ...
    
    echo -e "${MAGENTA}YOUR CATEGORY${NC}"
    echo "  [XX] newtool - Description"
    
    # ... rest of menu ...
}
```

Add to `process_menu_selection()`:

```bash
process_menu_selection() {
    local selection=$1
    
    case "$selection" in
        # ... existing cases ...
        XX) install_tool "newtool" ;;
        # ... rest of cases ...
    esac
}
```

### Step 7: Add Test Function

Add to `test_installation.sh`:

```bash
test_newtool() {
    echo -e "${CYAN}Testing NewTool...${NC}"
    
    # Test 1: Command exists
    command -v newtool &>/dev/null
    test_result "newtool" "Command exists" $?
    
    # Test 2: Can show help
    timeout 5 newtool --help &>/dev/null
    test_result "newtool" "Can execute --help" $?
    
    # Test 3: Binary in correct location
    [ -f "$HOME/.local/bin/newtool" ]
    test_result "newtool" "Binary in correct location" $?
    
    echo ""
}
```

Add to test runner:

```bash
run_all_tests() {
    # ... existing tests ...
    command -v newtool &>/dev/null && test_newtool
}

run_specific_test() {
    local tool=$1
    
    case "$tool" in
        # ... existing cases ...
        newtool) test_newtool ;;
        # ... rest of cases ...
    esac
}
```

## Complete Example: Adding "recon-ng"

Here's a complete example of adding a new Python tool called recon-ng:

### 1. Tool Definition
```bash
TOOL_INFO[recon-ng]="Recon-ng|Web reconnaissance framework|OSINT"
TOOL_SIZES[recon-ng]="25MB"
TOOL_DEPENDENCIES[recon-ng]="python_venv"
TOOL_INSTALL_LOCATION[recon-ng]="~/.local/bin/recon-ng"
```

### 2. Category
```bash
PYTHON_RECON_PASSIVE=("sherlock" "holehe" "socialscan" "theHarvester" "spiderfoot" "recon-ng")
```

### 3. Installation Check
```bash
recon-ng)
    [ -f "$HOME/.local/bin/recon-ng" ] && return 0 ;;
```

### 4. Installation Function
```bash
install_recon-ng() { install_python_tool "recon-ng" "recon-ng"; }
```

### 5. Dispatcher
```bash
recon-ng) install_recon-ng ;;
```

### 6. Menu
```bash
echo "  [XX] recon-ng - Web reconnaissance framework"

# In process_menu_selection:
XX) install_tool "recon-ng" ;;
```

### 7. Test
```bash
test_recon-ng() { test_python_tool "recon-ng" "recon-ng"; }

# In runners:
command -v recon-ng &>/dev/null && test_recon-ng
recon-ng) test_recon-ng ;;
```

## Generic Installers Reference

### Python Tool Installer
```bash
install_python_tool "tool_name" "pip_package_name"
```
- Installs from PyPI
- Creates venv if missing
- Creates wrapper script
- Handles logging automatically

### Go Tool Installer
```bash
install_go_tool "tool_name" "github.com/author/repo"
```
- Compiles from source using `go install`
- Installs to $GOPATH/bin
- Handles logging automatically

### Node.js Tool Installer
```bash
install_node_tool "tool_name" "npm_package_name"
```
- Installs from npm
- Installs globally to ~/.local
- Handles logging automatically

### Rust Tool Installer
```bash
install_rust_tool "tool_name" "crate_name"
```
- Compiles from source using `cargo install`
- Installs to $CARGO_HOME/bin
- Shows compile time warning
- Handles logging automatically

## Tips for Adding Tools

### 1. Check Installation Location

Different tools install to different locations:

```bash
# Python tools â†’ ~/.local/bin/toolname (wrapper)
# Go tools â†’ ~/opt/gopath/bin/toolname
# Node.js tools â†’ ~/.local/bin/toolname
# Rust tools â†’ $CARGO_HOME/bin/toolname (usually ~/.local/share/cargo/bin/)
```

### 2. Handle Binary Name Differences

If the command name differs from the tool name:

```bash
# Tool name vs binary name
TOOL_INFO[virustotal]="..."
# Binary is "vt" not "virustotal"

is_installed() {
    virustotal)
        [ -f "$HOME/opt/gopath/bin/vt" ] && return 0 ;;
}
```

### 3. Test Thoroughly

After adding a tool:

```bash
# Test installation
bash install_security_tools.sh newtool

# Test verification
bash test_installation.sh newtool

# Test help output
newtool --help
```

### 4. Handle Dependencies

If a tool needs specific prerequisites:

```bash
# Example: Tool needs both Go and special library
TOOL_DEPENDENCIES[special-tool]="go libspecial"

# Then create install function for libspecial
install_libspecial() {
    # Custom installation logic
}
```

### 5. Add CLI Support

Don't forget to support CLI installation:

```bash
# Should work after adding to dispatcher:
bash install_security_tools.sh newtool
```

## Testing Your Addition

```bash
# 1. Define and add tool (follow steps above)

# 2. Test dry run
bash install_security_tools.sh --dry-run newtool

# 3. Test actual installation
bash install_security_tools.sh newtool

# 4. Verify installation
bash test_installation.sh newtool

# 5. Test tool functionality
newtool --help
newtool --version
```

## Common Patterns

### Pattern 1: Simple Python CLI Tool
- Use `install_python_tool` generic installer
- One-liner installation function
- Standard wrapper script creation

### Pattern 2: Simple Go Tool
- Use `install_go_tool` generic installer
- One-liner installation function
- Compiles to static binary

### Pattern 3: Tool with Complex Dependencies
- Create custom install function
- Install dependencies first
- Build from source if needed
- Copy binaries to correct location

### Pattern 4: Tool with Alternative Binary Name
- Define different check in `is_installed()`
- Adjust test function accordingly
- Document in TOOL_INFO

## Troubleshooting

### Tool Not Found After Installation

Check:
1. Is tool in correct category array?
2. Is `is_installed()` checking correct path?
3. Is dispatcher case statement correct?
4. Did you source ~/.bashrc?

### Installation Fails Silently

Check:
1. Log file in ~/.local/state/install_tools/logs/
2. Error messages in installation function
3. Dependencies installed correctly

### Test Fails

Check:
1. Tool actually works manually
2. Test checking correct binary name
3. Test checking correct location
4. Timeout isn't too short

## Questions?

The script follows consistent patterns:
1. Define â†’ Add to category â†’ Check installation â†’ Install function â†’ Dispatcher â†’ Menu â†’ Test

Each step builds on the previous one. Follow the examples and your tool will integrate seamlessly!
