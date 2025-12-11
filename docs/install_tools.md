# Tools Installation Script Documentation

## Overview

`install_security_tools.sh` installs a comprehensive suite of user-space development tools and security/OSINT applications without requiring sudo access.

## Prerequisites

**REQUIRED:** Must run `xdg_setup.sh` first!

The tools script depends on the XDG directory structure and environment variables created by the setup script.

## Usage

```bash
# First: Set up XDG environment
bash xdg_setup.sh
source ~/.bashrc

# Then: Install tools
bash install_security_tools.sh
source ~/.bashrc

# Start using tools
sherlock username
gobuster dir -u https://example.com -w wordlist.txt
```

## What Gets Installed

### Build Tools

#### CMake 3.28.1
- **Purpose:** Cross-platform build system generator
- **Install Location:** `~/.local/bin/cmake`
- **Size:** ~50MB
- **Usage:** `cmake --version`
- **Why needed:** Required for building many C/C++ projects from source

#### Go 1.21.5
- **Purpose:** Programming language and runtime
- **Install Location:** `~/opt/go/`
- **Size:** ~120MB
- **Usage:** `go version`
- **Why needed:** Required for installing Go-based security tools

### Python Tools (OSINT/Security)

All Python tools are installed in an isolated virtual environment to avoid conflicts.

#### sherlock-project
- **Purpose:** Username search across 300+ social networks
- **Install Location:** `$XDG_DATA_HOME/virtualenvs/tools/`
- **Wrapper:** `~/.local/bin/sherlock`
- **Usage:** 
  ```bash
  sherlock username
  sherlock username1 username2 username3
  sherlock --timeout 10 username
  ```
- **What it does:** Searches for username availability/existence across social media platforms

#### holehe
- **Purpose:** Email verification across websites
- **Install Location:** `$XDG_DATA_HOME/virtualenvs/tools/`
- **Wrapper:** `~/.local/bin/holehe`
- **Usage:**
  ```bash
  holehe email@example.com
  holehe email1@example.com email2@example.com
  ```
- **What it does:** Checks if an email is used on different websites

#### socialscan
- **Purpose:** Username and email availability checker
- **Install Location:** `$XDG_DATA_HOME/virtualenvs/tools/`
- **Wrapper:** `~/.local/bin/socialscan`
- **Usage:**
  ```bash
  socialscan username email@example.com
  socialscan --available-only username1 username2
  ```
- **What it does:** Checks username/email availability on social platforms

#### h8mail
- **Purpose:** Email OSINT and breach hunting
- **Install Location:** `$XDG_DATA_HOME/virtualenvs/tools/`
- **Wrapper:** `~/.local/bin/h8mail`
- **Usage:**
  ```bash
  h8mail -t target@example.com
  h8mail -t emails.txt
  ```
- **What it does:** Searches for email leaks and breaches using multiple data sources

#### photon
- **Purpose:** Fast web crawler and OSINT tool
- **Install Location:** `$XDG_DATA_HOME/virtualenvs/tools/`
- **Wrapper:** `~/.local/bin/photon`
- **Usage:**
  ```bash
  photon -u https://example.com
  photon -u https://example.com -l 3 -t 10
  ```
- **What it does:** Extracts URLs, emails, files, account info, etc. from websites

#### sublist3r
- **Purpose:** Subdomain enumeration tool
- **Install Location:** `$XDG_DATA_HOME/virtualenvs/tools/`
- **Wrapper:** `~/.local/bin/sublist3r`
- **Usage:**
  ```bash
  sublist3r -d example.com
  sublist3r -d example.com -b
  ```
- **What it does:** Enumerates subdomains using search engines and passive sources

#### Supporting Libraries
Also installed (as dependencies):
- dnspython - DNS toolkit
- requests - HTTP library
- beautifulsoup4 - HTML parsing
- lxml - XML/HTML processing
- colorama - Colored terminal output
- pwnedpasswords - Check passwords against breaches

### Go Tools (Security/Reconnaissance)

All Go tools are compiled and installed to `~/opt/gopath/bin/`.

#### gobuster
- **Repository:** github.com/OJ/gobuster/v3
- **Purpose:** Directory/DNS/vhost bruteforcing
- **Install Location:** `~/opt/gopath/bin/gobuster`
- **Usage:**
  ```bash
  # Directory bruteforce
  gobuster dir -u https://example.com -w wordlist.txt
  
  # DNS subdomain bruteforce
  gobuster dns -d example.com -w wordlist.txt
  
  # Virtual host bruteforce
  gobuster vhost -u https://example.com -w wordlist.txt
  ```
- **What it does:** Brute force URIs (directories/files), DNS subdomains, and virtual hosts

#### ffuf
- **Repository:** github.com/ffuf/ffuf/v2
- **Purpose:** Fast web fuzzer
- **Install Location:** `~/opt/gopath/bin/ffuf`
- **Usage:**
  ```bash
  # URL fuzzing
  ffuf -u https://example.com/FUZZ -w wordlist.txt
  
  # Parameter fuzzing
  ffuf -u https://example.com?id=FUZZ -w numbers.txt
  
  # POST data fuzzing
  ffuf -u https://example.com -X POST -d "username=admin&password=FUZZ" -w passwords.txt
  ```
- **What it does:** Fast, flexible web fuzzer for discovering hidden content

#### httprobe
- **Repository:** github.com/tomnomnom/httprobe
- **Purpose:** HTTP/HTTPS service probe
- **Install Location:** `~/opt/gopath/bin/httprobe`
- **Usage:**
  ```bash
  cat domains.txt | httprobe
  cat domains.txt | httprobe -c 50
  ```
- **What it does:** Takes domain list and probes for working HTTP/HTTPS services

#### waybackurls
- **Repository:** github.com/tomnomnom/waybackurls
- **Purpose:** Fetch URLs from Wayback Machine
- **Install Location:** `~/opt/gopath/bin/waybackurls`
- **Usage:**
  ```bash
  waybackurls example.com
  echo "example.com" | waybackurls
  ```
- **What it does:** Fetches all URLs archived by Wayback Machine for a domain

#### assetfinder
- **Repository:** github.com/tomnomnom/assetfinder
- **Purpose:** Find domains and subdomains
- **Install Location:** `~/opt/gopath/bin/assetfinder`
- **Usage:**
  ```bash
  assetfinder example.com
  assetfinder --subs-only example.com
  ```
- **What it does:** Finds related domains and subdomains using passive sources

#### subfinder
- **Repository:** github.com/projectdiscovery/subfinder/v2
- **Purpose:** Subdomain discovery tool
- **Install Location:** `~/opt/gopath/bin/subfinder`
- **Usage:**
  ```bash
  subfinder -d example.com
  subfinder -d example.com -all
  subfinder -dL domains.txt -o results.txt
  ```
- **What it does:** Fast passive subdomain enumeration using multiple sources

#### nuclei
- **Repository:** github.com/projectdiscovery/nuclei/v3
- **Purpose:** Vulnerability scanner
- **Install Location:** `~/opt/gopath/bin/nuclei`
- **Usage:**
  ```bash
  nuclei -u https://example.com
  nuclei -l urls.txt
  nuclei -u https://example.com -t cves/
  ```
- **What it does:** Fast vulnerability scanner using customizable templates

## Installation Process

### Step-by-Step Execution

1. **Prerequisites Check**
   - Verifies XDG directories exist
   - Checks for XDG environment variables
   - Sets defaults if variables are missing
   - Exits with error if XDG setup not completed

2. **CMake Installation**
   - Downloads CMake 3.28.1 binary distribution
   - Extracts to temporary location
   - Copies binaries to `~/.local/bin/`
   - Copies shared files to `~/.local/share/`
   - Cleans up downloaded files
   - Skips if CMake already installed

3. **Go Installation**
   - Downloads Go 1.21.5 binary distribution
   - Extracts to `~/opt/go/`
   - Sets up Go environment variables
   - Cleans up downloaded files
   - Skips if Go already installed

4. **Python Virtual Environment Setup**
   - Creates isolated Python environment at `$XDG_DATA_HOME/virtualenvs/tools/`
   - Upgrades pip, wheel, and setuptools
   - Deactivates after setup
   - Skips if venv already exists

5. **Python Tools Installation**
   - Activates the tools virtual environment
   - Installs all Python packages using pip
   - Packages installed with `--upgrade` flag
   - Deactivates after installation

6. **Python Tool Wrappers Creation**
   - Creates executable wrapper scripts in `~/.local/bin/`
   - Each wrapper activates the venv and runs the tool
   - Makes running tools transparent (no manual venv activation needed)
   - Sets execute permissions on wrappers

7. **Go Tools Installation**
   - Sets up Go environment variables
   - Uses `go install` to compile and install each tool
   - Tools are installed to `$GOPATH/bin/`
   - Each tool compiled from latest version
   - Continues even if individual tools have issues

8. **Installation Testing**
   - Tests if each tool is accessible via PATH
   - Reports status of build tools (cmake, go)
   - Reports status of Python tools
   - Reports status of Go tools
   - Notes if tools need bashrc reload

9. **Documentation Creation**
   - Creates `INSTALLED_TOOLS.md` in `~/opt/tools/`
   - Documents all installed tools
   - Provides usage examples
   - Includes update instructions

## Output Example

```
==========================================
User-Space Tools Installation
==========================================

Checking prerequisites...
âœ“ Prerequisites met

Verifying directory structure...
âœ“ Directories verified

==========================================
Installing CMake
==========================================
Downloading CMake 3.28.1...
Extracting...
Installing to ~/.local/...
âœ“ CMake 3.28.1 installed

==========================================
Installing Go
==========================================
Downloading Go 1.21.5...
Extracting...
âœ“ Go 1.21.5 installed

==========================================
Setting Up Python Environment
==========================================
Creating virtual environment...
Upgrading pip, wheel, and setuptools...
âœ“ Virtual environment created

==========================================
Installing Python Tools
==========================================
Installing Python packages...
[installation output...]
âœ“ Python tools installed

Creating tool wrappers in ~/.local/bin/...
  âœ“ sherlock
  âœ“ holehe
  âœ“ socialscan
  âœ“ h8mail
  âœ“ photon
  âœ“ sublist3r
âœ“ Tool wrappers created

==========================================
Installing Go Tools
==========================================
Installing Go packages (this may take a few minutes)...
  - gobuster (directory/DNS bruteforcer)...
    âœ“ Installed
  - ffuf (fast web fuzzer)...
    âœ“ Installed
  [... more tools ...]
âœ“ Go tools installed

==========================================
Testing Installations
==========================================

Build tools:
  âœ“ cmake (3.28.1)
  âœ“ go (go1.21.5)

Python tools:
  âœ“ sherlock
  âœ“ holehe
  âœ“ socialscan
  âœ“ h8mail
  âœ“ photon
  âœ“ sublist3r

Go tools:
  âœ“ gobuster
  âœ“ ffuf
  âœ“ httprobe
  âœ“ waybackurls
  âœ“ assetfinder
  âœ“ subfinder
  âœ“ nuclei

âœ“ Tools documentation created: ~/opt/tools/INSTALLED_TOOLS.md

==========================================
Tools Installation Complete!
==========================================

Installation Summary:
  âœ“ CMake (build system)
  âœ“ Go (programming language)
  âœ“ Python tools (6 packages + dependencies)
  âœ“ Go tools (7 security/recon tools)
  âœ“ Tool wrappers created

Next Steps:
  1. Reload environment: source ~/.bashrc
  2. Test a tool: sherlock --help
  3. Or activate venv: tools-venv
  4. Read docs: cat ~/opt/tools/INSTALLED_TOOLS.md
```

## Installation Locations Summary

```
~/.local/bin/
â”œâ”€â”€ cmake                    # CMake binary
â”œâ”€â”€ sherlock                 # Python tool wrapper
â”œâ”€â”€ holehe                   # Python tool wrapper
â”œâ”€â”€ socialscan               # Python tool wrapper
â”œâ”€â”€ h8mail                   # Python tool wrapper
â”œâ”€â”€ photon                   # Python tool wrapper
â””â”€â”€ sublist3r                # Python tool wrapper

~/.local/share/
â””â”€â”€ virtualenvs/
    â””â”€â”€ tools/               # Python virtual environment
        â”œâ”€â”€ bin/
        â”‚   â””â”€â”€ [actual Python tools]
        â””â”€â”€ lib/
            â””â”€â”€ python3.13/
                â””â”€â”€ site-packages/

~/opt/
â”œâ”€â”€ go/                      # Go installation
â”‚   â””â”€â”€ bin/
â”‚       â””â”€â”€ go
â”œâ”€â”€ gopath/                  # Go workspace
â”‚   â””â”€â”€ bin/
â”‚       â”œâ”€â”€ gobuster
â”‚       â”œâ”€â”€ ffuf
â”‚       â”œâ”€â”€ httprobe
â”‚       â”œâ”€â”€ waybackurls
â”‚       â”œâ”€â”€ assetfinder
â”‚       â”œâ”€â”€ subfinder
â”‚       â””â”€â”€ nuclei
â””â”€â”€ tools/
    â””â”€â”€ INSTALLED_TOOLS.md   # Documentation
```

## Usage Examples

### Python Tools (Require No Venv Activation)

Thanks to the wrapper scripts, Python tools work directly:

```bash
# Username search
sherlock john_doe

# Email verification
holehe target@example.com

# Availability check
socialscan username email@example.com

# Breach hunting
h8mail -t victim@example.com

# Web crawling
photon -u https://example.com -o output/

# Subdomain enumeration
sublist3r -d example.com
```

### Go Tools

Go tools are standard binaries, use directly:

```bash
# Directory bruteforce
gobuster dir -u https://target.com -w /path/to/wordlist.txt

# Fast fuzzing
ffuf -u https://target.com/FUZZ -w wordlist.txt -mc 200

# Probe for HTTP services
cat domains.txt | httprobe | tee live-hosts.txt

# Wayback URLs
waybackurls target.com | tee wayback-urls.txt

# Asset discovery
assetfinder --subs-only target.com | tee subdomains.txt

# Subdomain enumeration
subfinder -d target.com -o subdomains.txt

# Vulnerability scanning
nuclei -u https://target.com -severity critical,high
```

### Manual Venv Activation (If Needed)

If you need to install additional Python packages:

```bash
# Activate venv
source $XDG_DATA_HOME/virtualenvs/tools/bin/activate
# or
tools-venv

# Install additional tools
pip install tool-name

# Deactivate
deactivate
```

## Updating Tools

### Update Python Tools

```bash
# Activate venv
tools-venv

# Update all tools
pip install --upgrade sherlock-project holehe socialscan h8mail photon-python sublist3r

# Or update specific tool
pip install --upgrade sherlock-project

# Deactivate
deactivate
```

### Update Go Tools

```bash
# Reinstall (pulls latest version)
go install github.com/OJ/gobuster/v3@latest
go install github.com/ffuf/ffuf/v2@latest
go install github.com/tomnomnom/httprobe@latest
go install github.com/tomnomnom/waybackurls@latest
go install github.com/tomnomnom/assetfinder@latest
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
```

### Update CMake

```bash
# Download new version
cd ~/opt/src
CMAKE_VERSION="3.29.0"  # or latest
wget https://github.com/Kitware/CMake/releases/download/v${CMAKE_VERSION}/cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz
tar -xzf cmake-${CMAKE_VERSION}-linux-x86_64.tar.gz
cp -r cmake-${CMAKE_VERSION}-linux-x86_64/bin/* ~/.local/bin/
cp -r cmake-${CMAKE_VERSION}-linux-x86_64/share/* ~/.local/share/
rm -rf cmake-${CMAKE_VERSION}-linux-x86_64*
```

### Update Go

```bash
# Download new version
cd ~/opt
GO_VERSION="1.22.0"  # or latest
wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
rm -rf go  # Remove old version
tar -xzf go${GO_VERSION}.linux-amd64.tar.gz
rm go${GO_VERSION}.linux-amd64.tar.gz
```

## Troubleshooting

### Prerequisites check fails

**Problem:** "XDG directories not found!"

**Solution:**
```bash
bash xdg_setup.sh
source ~/.bashrc
```

### Tools not found after installation

**Problem:** `command not found: sherlock`

**Solution:**
```bash
# Reload environment
source ~/.bashrc

# Verify PATH includes ~/.local/bin
echo $PATH | grep "$HOME/.local/bin"

# Check if wrapper exists
ls -la ~/.local/bin/sherlock
```

### Python tools error with "No module named..."

**Problem:** Import errors when running Python tools

**Solution:**
```bash
# Check venv exists
ls -la $XDG_DATA_HOME/virtualenvs/tools/

# Manually activate and test
source $XDG_DATA_HOME/virtualenvs/tools/bin/activate
sherlock --help
deactivate

# If still fails, reinstall
rm -rf $XDG_DATA_HOME/virtualenvs/tools/
bash install_security_tools.sh
```

### Go tools not found

**Problem:** `command not found: gobuster`

**Solution:**
```bash
# Check GOPATH is set
echo $GOPATH

# Verify tools are installed
ls -la ~/opt/gopath/bin/

# Check if GOPATH/bin is in PATH
echo $PATH | grep "gopath/bin"

# If missing, reload
source ~/.bashrc
```

### Download failures

**Problem:** `wget: unable to resolve host address`

**Solution:**
```bash
# Check network connectivity
ping google.com

# Try with curl instead
curl -O https://github.com/...

# Check if proxy needed
echo $http_proxy
```

### Permission denied errors

**Problem:** Cannot write to directories

**Solution:**
```bash
# Check home directory permissions
ls -la ~/

# Verify you can write
touch ~/.test && rm ~/.test && echo "OK"

# Check specific directories
ls -la ~/.local/
ls -la ~/opt/
```

### Tool warnings during Go installation

**Problem:** "Warning: gobuster install had issues"

**Solution:**
This is usually not critical. The tool may still install successfully. Verify:
```bash
# Check if tool exists
which gobuster
gobuster version

# If missing, try manual install
go install -v github.com/OJ/gobuster/v3@latest
```

## Disk Space Requirements

| Component | Size | Location |
|-----------|------|----------|
| CMake | ~50 MB | ~/.local/ |
| Go installation | ~120 MB | ~/opt/go/ |
| Go tools | ~50-100 MB | ~/opt/gopath/bin/ |
| Python venv | ~50 MB | ~/.local/share/virtualenvs/tools/ |
| Python tools | ~30 MB | (inside venv) |
| **Total** | **~300-350 MB** | |

Plus temporary download files during installation (~200 MB, auto-deleted).

## Related Documentation

- [XDG Setup Guide](xdg_setup.md) - Setup XDG environment first
- [Backup/Restore Guide](backup_restore.md) - Backup your installed tools

## Version History

- **v1.0** - Initial release
  - CMake 3.28.1
  - Go 1.21.5
  - 6 Python OSINT tools
  - 7 Go security tools
  - Automatic wrapper creation
  - Comprehensive testing
