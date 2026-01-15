# Security Tools Reference Guide

**Version:** 1.3.0
**Last Updated:** January 15, 2026
**Purpose:** Comprehensive reference for all 37+ security tools installed by this system

This document provides complete metadata, usage examples, and categorization for every tool available in the Security Tools Installer. For installation instructions, see 📖 [Script Usage Guide](script_usage.md).

---

## Table of Contents

1. [Overview](#overview)
2. [Build Tools & Runtimes](#build-tools--runtimes)
3. [Python Tools](#python-tools)
4. [Go Tools](#go-tools)
5. [Node.js Tools](#nodejs-tools)
6. [Rust Tools](#rust-tools)
7. [Use Case Categories](#use-case-categories)
8. [Alphabetical Index](#alphabetical-index)
9. [Quick Reference Tables](#quick-reference-tables)
10. [Cross-References](#cross-references)

---

## Overview

The Security Tools Installer provides **37+ tools** across **5 categories**:

| Category | Count | Total Size | Use Cases |
|----------|-------|------------|-----------|
| Build Tools & Runtimes | 5 | ~1.1 GB | Development infrastructure |
| Python Tools | 12 | ~230 MB | OSINT, CTI, reconnaissance |
| Go Tools | 8 | ~100 MB | Active/passive recon, scanning |
| Node.js Tools | 3 | ~80 MB | Secret scanning, GitHub intel |
| Rust Tools | 8 | ~30 MB | Fast scanning & utilities |
| **Total** | **37** | **~1.3-2 GB** | Complete security toolkit |

**Installation Time:** 30-60 minutes (complete installation)
**Installation Method:** User-space only (no sudo required)
**Supported Platforms:** Ubuntu 20.04+, compatible Linux distributions

---

## Build Tools & Runtimes

These foundational tools enable installation of language-specific security tools.

### CMake

**Category:** Build Tool
**Version:** 3.28.1
**Size:** ~50 MB
**Installation Location:** `~/.local/bin/cmake`
**Dependencies:** None

**Description:**
Cross-platform build system generator required for compiling tools from source.

**Usage:**
```bash
cmake --version
cmake -S . -B build
cmake --build build
```

**Update Command:**
```bash
# Manual reinstallation required
bash install_security_tools.sh cmake
```

---

### GitHub CLI

**Category:** Build Tool
**Version:** 2.53.0
**Size:** ~90 MB
**Installation Location:** `~/.local/bin/gh`
**Dependencies:** None

**Description:**
GitHub workflow automation tool for managing repositories, issues, and pull requests from the terminal.

**Usage:**
```bash
gh --version
gh auth login
gh repo list
gh issue list
gh pr create
```

**Common Operations:**
```bash
# Clone repository
gh repo clone owner/repo

# Create issue
gh issue create --title "Bug report" --body "Description"

# View PR
gh pr view 123

# Check CI status
gh run list
```

**Update Command:**
```bash
# Manual reinstallation required
bash install_security_tools.sh github_cli
```

---

### Go Runtime

**Category:** Language Runtime
**Version:** System-installed (1.21.5+ recommended)
**Size:** ~120 MB
**Installation Location:** `/usr/local/go` (system)
**Workspace:** `~/opt/gopath` (user-space)

**Description:**
Go programming language runtime required for Go-based security tools. Expected to be pre-installed system-wide.

**Environment Variables:**
```bash
GOPATH="$HOME/opt/gopath"
PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"
GOCACHE="$HOME/.cache/go-build"
```

**Usage:**
```bash
go version
go env
```

---

### Node.js Runtime

**Category:** Language Runtime
**Version:** 20.10.0
**Size:** ~50 MB
**Installation Location:** `~/opt/node/`
**Dependencies:** None

**Description:**
JavaScript runtime environment for Node.js-based security tools.

**Environment Variables:**
```bash
PATH="$HOME/opt/node/bin:$PATH"
NPM_CONFIG_PREFIX="$HOME/.local"
```

**Usage:**
```bash
node --version
npm --version
npm list -g --depth=0
```

**Update Command:**
```bash
bash install_security_tools.sh nodejs
```

---

### Rust Runtime

**Category:** Language Runtime
**Version:** Latest stable
**Size:** ~800 MB
**Installation Location:** `$CARGO_HOME/` (`~/.local/share/cargo/`)
**Dependencies:** None

**Description:**
Systems programming language runtime. Largest component (800MB) but includes extremely fast tools.

**Environment Variables:**
```bash
CARGO_HOME="$XDG_DATA_HOME/cargo"
RUSTUP_HOME="$XDG_DATA_HOME/rustup"
PATH="$CARGO_HOME/bin:$PATH"
```

**Usage:**
```bash
rustc --version
cargo --version
rustup update
```

**Update Command:**
```bash
rustup update
```

---

### Python Virtual Environment

**Category:** Python Environment
**Size:** ~50 MB
**Installation Location:** `$XDG_DATA_HOME/virtualenvs/tools/`
**Dependencies:** Python 3.8+ (system)

**Description:**
Isolated Python environment for all Python-based security tools. Prevents dependency conflicts.

**Activation:**
```bash
source ~/.local/share/virtualenvs/tools/bin/activate
```

**Management:**
```bash
# Activate environment
source $XDG_DATA_HOME/virtualenvs/tools/bin/activate

# View installed packages
pip list

# Update packages
pip install --upgrade sherlock-project holehe socialscan

# Deactivate
deactivate
```

---

## Python Tools

**Total:** 12 tools | **Size:** ~230 MB | **Prerequisites:** `python_venv`

All Python tools are installed in a shared virtual environment and accessed via wrapper scripts in `~/.local/bin/`.

### Username/Email OSINT Tools

#### Sherlock

**Category:** OSINT - Passive Reconnaissance
**Size:** ~30 MB
**Installation Location:** `~/.local/bin/sherlock`
**Dependencies:** `python_venv`

**Description:**
Search for usernames across 300+ social networks and websites. Excellent for investigating online presence.

**Usage:**
```bash
# Basic search
sherlock john_doe

# Search multiple usernames
sherlock john_doe jane_smith

# Output to file
sherlock john_doe --output results.txt

# Timeout control
sherlock john_doe --timeout 10

# Search specific sites only
sherlock john_doe --site Twitter --site Instagram
```

**Common Use Cases:**
- Background checks on individuals
- Online presence mapping
- Social engineering prep
- Username availability checks

**Update:**
```bash
source ~/.local/share/virtualenvs/tools/bin/activate
pip install --upgrade sherlock-project
deactivate
```

---

#### Holehe

**Category:** OSINT - Email Intelligence
**Size:** ~25 MB
**Installation Location:** `~/.local/bin/holehe`
**Dependencies:** `python_venv`

**Description:**
Check if an email address is registered on 120+ websites without sending login requests.

**Usage:**
```bash
# Check single email
holehe target@example.com

# Check multiple emails
holehe target1@example.com target2@example.com

# Output to JSON
holehe target@example.com --output results.json

# Only show sites where email is found
holehe target@example.com --only-used
```

**Common Use Cases:**
- Email reconnaissance
- Account enumeration
- Breach investigation prep
- Social engineering intelligence

**Update:**
```bash
source ~/.local/share/virtualenvs/tools/bin/activate
pip install --upgrade holehe
deactivate
```

---

#### Socialscan

**Category:** OSINT - Availability Checker
**Size:** ~20 MB
**Installation Location:** `~/.local/bin/socialscan`
**Dependencies:** `python_venv`

**Description:**
Fast checker for email and username availability across multiple platforms.

**Usage:**
```bash
# Check username availability
socialscan john_doe

# Check email availability
socialscan target@example.com

# Check both
socialscan john_doe target@example.com

# Specific platforms
socialscan john_doe --platforms twitter instagram github

# JSON output
socialscan john_doe --json
```

**Common Use Cases:**
- Username enumeration
- Account discovery
- Brand monitoring
- Competitor analysis

**Update:**
```bash
source ~/.local/share/virtualenvs/tools/bin/activate
pip install --upgrade socialscan
deactivate
```

---

#### h8mail

**Category:** OSINT - Breach Hunting
**Size:** ~25 MB
**Installation Location:** `~/.local/bin/h8mail`
**Dependencies:** `python_venv`

**Description:**
Email OSINT and breach hunting tool. Search for compromised credentials across breaches.

**Usage:**
```bash
# Basic email search
h8mail -t victim@example.com

# Multiple targets
h8mail -t email1@example.com -t email2@example.com

# Use API services
h8mail -t victim@example.com --breach-compilation /path/to/breaches/

# Chase related emails
h8mail -t victim@example.com -c
```

**Common Use Cases:**
- Breach investigation
- Credential exposure checks
- Email compromise assessment
- OSINT investigations

**Update:**
```bash
source ~/.local/share/virtualenvs/tools/bin/activate
pip install --upgrade h8mail
deactivate
```

---

### Web & Domain Reconnaissance Tools

#### theHarvester

**Category:** OSINT - Multi-Source Gathering
**Size:** ~15 MB
**Installation Location:** `~/.local/bin/theHarvester`
**Dependencies:** `python_venv`

**Description:**
Gather emails, subdomains, hosts, employee names, and open ports from public sources.

**Usage:**
```bash
# Basic domain search
theHarvester -d example.com -b all

# Specific sources
theHarvester -d example.com -b google,bing,linkedin

# DNS enumeration
theHarvester -d example.com -b all -n

# Virtual host verification
theHarvester -d example.com -b all -v

# Output to XML/HTML
theHarvester -d example.com -b all -f output
```

**Common Use Cases:**
- Domain reconnaissance
- Email harvesting
- Subdomain enumeration
- Employee enumeration

**Update:**
```bash
source ~/.local/share/virtualenvs/tools/bin/activate
pip install --upgrade theHarvester
deactivate
```

---

#### Sublist3r

**Category:** OSINT - Subdomain Enumeration
**Size:** ~25 MB
**Installation Location:** `~/.local/bin/sublist3r`
**Dependencies:** `python_venv`

**Description:**
Fast subdomain enumeration tool using OSINT. Queries search engines and DNS databases.

**Usage:**
```bash
# Basic enumeration
sublist3r -d example.com

# Enable brute force
sublist3r -d example.com -b

# Specify threads
sublist3r -d example.com -t 10

# Output to file
sublist3r -d example.com -o subdomains.txt

# Enable port scanning
sublist3r -d example.com -p 80,443
```

**Common Use Cases:**
- Subdomain discovery
- Attack surface mapping
- Asset inventory
- Reconnaissance

**Update:**
```bash
source ~/.local/share/virtualenvs/tools/bin/activate
pip install --upgrade sublist3r
deactivate
```

---

#### Photon

**Category:** OSINT - Web Crawler
**Size:** ~30 MB
**Installation Location:** `~/.local/bin/photon`
**Dependencies:** `python_venv`

**Description:**
Fast web crawler that extracts URLs, emails, files, accounts, and more from websites.

**Usage:**
```bash
# Basic crawl
photon -u https://example.com

# Specify depth
photon -u https://example.com -l 3

# Output directory
photon -u https://example.com -o results/

# Extract specific data
photon -u https://example.com --keys  # API keys
photon -u https://example.com --emails  # Email addresses
photon -u https://example.com --files  # File links

# User agent
photon -u https://example.com --user-agent "CustomBot"
```

**Common Use Cases:**
- Website reconnaissance
- Data extraction
- Link analysis
- Credential discovery

**Update:**
```bash
source ~/.local/share/virtualenvs/tools/bin/activate
pip install --upgrade photon
deactivate
```

---

#### SpiderFoot

**Category:** OSINT - Automated Collection
**Size:** ~30 MB
**Installation Location:** `~/.local/bin/spiderfoot`
**Dependencies:** `python_venv`

**Description:**
Automated OSINT reconnaissance tool with 200+ modules for intelligence gathering.

**Usage:**
```bash
# List available modules
spiderfoot -M

# CLI scan
spiderfoot -s example.com -t DOMAIN

# Web interface (port 5001)
spiderfoot -l 127.0.0.1:5001

# Specific modules only
spiderfoot -s example.com -t DOMAIN -m sfp_dnsresolve,sfp_whois
```

**Common Use Cases:**
- Comprehensive reconnaissance
- Threat intelligence
- Digital footprint analysis
- Security assessments

**Update:**
```bash
source ~/.local/share/virtualenvs/tools/bin/activate
pip install --upgrade spiderfoot
deactivate
```

---

#### Wappalyzer

**Category:** OSINT - Technology Profiler
**Size:** ~15 MB
**Installation Location:** `~/.local/bin/wappalyzer`
**Dependencies:** `python_venv`

**Description:**
Identify technologies used by websites (CMS, frameworks, servers, analytics, etc.).

**Usage:**
```bash
# Basic scan
wappalyzer https://example.com

# Batch scan from file
wappalyzer -f urls.txt

# JSON output
wappalyzer https://example.com -o json

# Verbose mode
wappalyzer https://example.com -v
```

**Common Use Cases:**
- Technology stack identification
- Vulnerability research
- Competitor analysis
- Attack surface assessment

**Update:**
```bash
source ~/.local/share/virtualenvs/tools/bin/activate
pip install --upgrade wappalyzer
deactivate
```

---

### Threat Intelligence Tools

#### Shodan CLI

**Category:** CTI - Internet Scanning
**Size:** ~10 MB
**Installation Location:** `~/.local/bin/shodan`
**Dependencies:** `python_venv`

**Description:**
Command-line interface for Shodan, the search engine for Internet-connected devices.

**Setup:**
```bash
# Initialize with API key
shodan init YOUR_API_KEY
```

**Usage:**
```bash
# Search for services
shodan search apache

# Get host information
shodan host 8.8.8.8

# Download search results
shodan download --limit 100 results apache

# Count search results
shodan count apache country:US

# View account info
shodan info
```

**Common Use Cases:**
- Internet-wide device discovery
- Vulnerability scanning
- Threat intelligence
- Attack surface monitoring

**Update:**
```bash
source ~/.local/share/virtualenvs/tools/bin/activate
pip install --upgrade shodan
deactivate
```

---

#### Censys CLI

**Category:** CTI - Internet Scanning
**Size:** ~5 MB
**Installation Location:** `~/.local/bin/censys`
**Dependencies:** `python_venv`

**Description:**
Access Censys internet-wide scanning data from the command line.

**Setup:**
```bash
# Configure credentials
censys config

# Or set environment variables
export CENSYS_API_ID="your-id"
export CENSYS_API_SECRET="your-secret"
```

**Usage:**
```bash
# Search hosts
censys search "service.software.product: Apache"

# View host details
censys view 8.8.8.8

# Search certificates
censys search "parsed.names: example.com" --index certificates
```

**Common Use Cases:**
- Certificate monitoring
- Infrastructure discovery
- Vulnerability research
- Threat intelligence

**Update:**
```bash
source ~/.local/share/virtualenvs/tools/bin/activate
pip install --upgrade censys
deactivate
```

---

#### YARA

**Category:** CTI - Pattern Matching
**Size:** ~5 MB
**Installation Location:** `~/.local/bin/yara`
**Dependencies:** `python_venv`

**Description:**
Pattern matching tool for malware research and detection. Identify and classify malware samples.

**Usage:**
```bash
# Scan file with rule
yara rule.yar target_file

# Scan directory recursively
yara -r rule.yar /path/to/directory/

# Multiple rule files
yara rule1.yar rule2.yar target_file

# Print matching strings
yara -s rule.yar target_file

# Fast mode (no strings)
yara -f rule.yar target_file
```

**Example Rule:**
```yara
rule SuspiciousBehavior
{
    strings:
        $a = "http://" nocase
        $b = "powershell" nocase
    condition:
        $a and $b
}
```

**Common Use Cases:**
- Malware detection
- File classification
- Threat hunting
- IOC matching

**Update:**
```bash
source ~/.local/share/virtualenvs/tools/bin/activate
pip install --upgrade yara-python
deactivate
```

---

## Go Tools

**Total:** 8 tools | **Size:** ~100 MB | **Prerequisites:** System Go installation

All Go tools are compiled and installed to `$GOPATH/bin` (`~/opt/gopath/bin/`).

### Active Reconnaissance Tools

#### Gobuster

**Category:** Active Reconnaissance - Directory/DNS Brute Force
**Size:** ~15 MB
**Installation Location:** `$GOPATH/bin/gobuster`
**Dependencies:** System Go

**Description:**
Multi-purpose brute-forcing tool for URIs, DNS subdomains, and virtual hosts.

**Usage:**
```bash
# Directory brute force
gobuster dir -u https://example.com -w wordlist.txt

# DNS subdomain enumeration
gobuster dns -d example.com -w subdomains.txt

# Vhost discovery
gobuster vhost -u https://example.com -w vhosts.txt

# Status code filtering
gobuster dir -u https://example.com -w wordlist.txt -s 200,204,301,302,307,401,403

# Extensions
gobuster dir -u https://example.com -w wordlist.txt -x php,html,txt

# Threads
gobuster dir -u https://example.com -w wordlist.txt -t 50

# Output to file
gobuster dir -u https://example.com -w wordlist.txt -o results.txt
```

**Common Use Cases:**
- Directory enumeration
- Subdomain discovery
- Virtual host detection
- Hidden resource discovery

**Update:**
```bash
go install github.com/OJ/gobuster/v3@latest
```

---

#### FFuF

**Category:** Active Reconnaissance - Web Fuzzing
**Size:** ~12 MB
**Installation Location:** `$GOPATH/bin/ffuf`
**Dependencies:** System Go

**Description:**
Fast web fuzzer for discovery and vulnerability identification. Extremely flexible and performant.

**Usage:**
```bash
# Directory fuzzing
ffuf -u https://example.com/FUZZ -w wordlist.txt

# Subdomain fuzzing
ffuf -u https://FUZZ.example.com -w subdomains.txt

# Parameter fuzzing
ffuf -u https://example.com/api?param=FUZZ -w params.txt

# POST data fuzzing
ffuf -u https://example.com/login -X POST -d "user=admin&pass=FUZZ" -w passwords.txt

# Header fuzzing
ffuf -u https://example.com -H "X-Header: FUZZ" -w headers.txt

# Status code filtering
ffuf -u https://example.com/FUZZ -w wordlist.txt -fc 404

# Match/filter by size
ffuf -u https://example.com/FUZZ -w wordlist.txt -fs 4242

# Rate limiting
ffuf -u https://example.com/FUZZ -w wordlist.txt -rate 100

# Output to file
ffuf -u https://example.com/FUZZ -w wordlist.txt -o results.json
```

**Common Use Cases:**
- Directory/file discovery
- Parameter brute-forcing
- Virtual host enumeration
- API fuzzing

**Update:**
```bash
go install github.com/ffuf/ffuf/v2@latest
```

---

#### httprobe

**Category:** Active Reconnaissance - Service Probe
**Size:** ~5 MB
**Installation Location:** `$GOPATH/bin/httprobe`
**Dependencies:** System Go

**Description:**
Take a list of domains and probe for working HTTP/HTTPS servers. Fast port checking.

**Usage:**
```bash
# Basic probe
cat domains.txt | httprobe

# Specify ports
cat domains.txt | httprobe -p http:8080 -p https:8443

# Concurrency
cat domains.txt | httprobe -c 50

# Timeout
cat domains.txt | httprobe -t 10000

# Save results
cat domains.txt | httprobe > live_hosts.txt

# Prefer HTTPS
cat domains.txt | httprobe -prefer-https
```

**Common Use Cases:**
- Live host detection
- HTTP/HTTPS service discovery
- Port scanning
- Attack surface mapping

**Update:**
```bash
go install github.com/tomnomnom/httprobe@latest
```

---

#### Nuclei

**Category:** Vulnerability Scanning
**Size:** ~20 MB
**Installation Location:** `$GOPATH/bin/nuclei`
**Dependencies:** System Go

**Description:**
Fast vulnerability scanner powered by customizable YAML templates. 5,000+ templates included.

**Usage:**
```bash
# Single target scan
nuclei -u https://example.com

# Multiple targets
nuclei -l targets.txt

# Specific template
nuclei -u https://example.com -t cves/2021/

# Severity filtering
nuclei -u https://example.com -severity critical,high

# Tags
nuclei -u https://example.com -tags cve,rce

# Update templates
nuclei -update-templates

# Rate limiting
nuclei -u https://example.com -rate-limit 150

# Output
nuclei -u https://example.com -o results.txt
nuclei -u https://example.com -json -o results.json
```

**Common Use Cases:**
- Vulnerability scanning
- CVE detection
- Misconfiguration checks
- Security assessments

**Update:**
```bash
go install github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
nuclei -update-templates
```

---

### Passive Reconnaissance Tools

#### waybackurls

**Category:** Passive Reconnaissance - Archive Crawling
**Size:** ~5 MB
**Installation Location:** `$GOPATH/bin/waybackurls`
**Dependencies:** System Go

**Description:**
Fetch all URLs known to the Wayback Machine for a domain. Historical data mining.

**Usage:**
```bash
# Single domain
echo "example.com" | waybackurls

# Multiple domains
cat domains.txt | waybackurls

# Get subdomains too
echo "example.com" | waybackurls -get-versions

# Date filtering (since YYYYMMDD)
echo "example.com" | waybackurls -dates 20210101

# Save results
echo "example.com" | waybackurls > urls.txt
```

**Common Use Cases:**
- Historical URL discovery
- Endpoint enumeration
- Old vulnerability research
- Data archaeology

**Update:**
```bash
go install github.com/tomnomnom/waybackurls@latest
```

---

#### assetfinder

**Category:** Passive Reconnaissance - Asset Discovery
**Size:** ~5 MB
**Installation Location:** `$GOPATH/bin/assetfinder`
**Dependencies:** System Go

**Description:**
Find domains and subdomains related to a given domain using passive reconnaissance.

**Usage:**
```bash
# Basic subdomain search
assetfinder example.com

# Include subdomains of subdomains
assetfinder --subs-only example.com

# Save results
assetfinder example.com > subdomains.txt

# Combine with other tools
assetfinder example.com | httprobe
```

**Common Use Cases:**
- Subdomain discovery
- Asset enumeration
- Attack surface mapping
- Reconnaissance

**Update:**
```bash
go install github.com/tomnomnom/assetfinder@latest
```

---

#### subfinder

**Category:** Passive Reconnaissance - Subdomain Discovery
**Size:** ~15 MB
**Installation Location:** `$GOPATH/bin/subfinder`
**Dependencies:** System Go

**Description:**
Fast passive subdomain discovery tool using multiple sources (40+ services). More comprehensive than alternatives.

**Usage:**
```bash
# Basic scan
subfinder -d example.com

# Silent mode (only subdomains)
subfinder -d example.com -silent

# Output to file
subfinder -d example.com -o subdomains.txt

# All sources
subfinder -d example.com -all

# Specific sources
subfinder -d example.com -sources crtsh,virustotal

# Verify with DNS resolution
subfinder -d example.com -nW

# Rate limiting
subfinder -d example.com -rate-limit 100

# JSON output
subfinder -d example.com -json
```

**Common Use Cases:**
- Comprehensive subdomain enumeration
- Asset discovery
- Attack surface analysis
- Reconnaissance

**Update:**
```bash
go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
```

---

### Threat Intelligence Tools

#### VirusTotal CLI

**Category:** CTI - Threat Intelligence
**Size:** ~10 MB
**Installation Location:** `$GOPATH/bin/vt` (binary name: `vt`)
**Dependencies:** System Go

**Description:**
Official VirusTotal command-line client for file/URL/domain analysis and threat intelligence.

**Setup:**
```bash
# Set API key
vt init
# Or
export VT_API_KEY="your-api-key"
```

**Usage:**
```bash
# Scan file
vt scan file suspicious.exe

# Check URL
vt url https://example.com

# Domain reputation
vt domain example.com

# IP address
vt ip 8.8.8.8

# File hash lookup
vt file 44d88612fea8a8f36de82e1278abb02f

# Get relationships
vt domain example.com --relationships communicating_files

# Monitor hunting notifications
vt monitor items
```

**Common Use Cases:**
- Malware analysis
- URL/domain reputation checks
- Threat intelligence
- IOC validation

**Update:**
```bash
go install github.com/VirusTotal/vt-cli@latest
```

---

## Node.js Tools

**Total:** 3 tools | **Size:** ~80 MB | **Prerequisites:** Node.js runtime

All Node.js tools are installed globally and linked to `~/.local/bin/`.

### TruffleHog

**Category:** CTI - Secret Scanning
**Size:** ~15 MB
**Installation Location:** `~/.local/bin/trufflehog`
**Dependencies:** `nodejs`

**Description:**
Search git repositories for high entropy strings and secrets. Detect credentials in commit history.

**Usage:**
```bash
# Scan git repository
trufflehog git https://github.com/user/repo.git

# Scan local repo
trufflehog filesystem /path/to/repo/

# JSON output
trufflehog git https://github.com/user/repo.git --json

# Verify secrets
trufflehog git https://github.com/user/repo.git --verify

# Scan specific branch
trufflehog git https://github.com/user/repo.git --branch main

# Since commit
trufflehog git https://github.com/user/repo.git --since-commit abc123

# Only verified secrets
trufflehog git https://github.com/user/repo.git --only-verified
```

**Common Use Cases:**
- Secret leak detection
- Credential exposure
- Commit history auditing
- Security assessments

**Update:**
```bash
npm update -g @trufflesecurity/trufflehog
```

---

### git-hound

**Category:** OSINT - GitHub Reconnaissance
**Size:** ~10 MB
**Installation Location:** `~/.local/bin/git-hound`
**Dependencies:** `nodejs`

**Description:**
Search GitHub for sensitive data and credentials using pattern matching.

**Setup:**
```bash
# Configure GitHub token
git-hound --config
```

**Usage:**
```bash
# Search GitHub
git-hound --subdomain-file subdomains.txt

# Search with keywords
git-hound --keywords api_key,password,secret

# Search specific users/orgs
git-hound --users target-user --orgs target-org

# Output to file
git-hound --subdomain-file subdomains.txt -o results.json

# Threads
git-hound --subdomain-file subdomains.txt --threads 10
```

**Common Use Cases:**
- GitHub reconnaissance
- Credential discovery
- API key exposure
- Code intelligence

**Update:**
```bash
npm update -g git-hound
```

---

### JWT Cracker

**Category:** Security Testing - JWT Analysis
**Size:** ~5 MB
**Installation Location:** `~/.local/bin/jwt-cracker`
**Dependencies:** `nodejs`

**Description:**
Brute-force JWT token secrets using wordlists or character sets.

**Usage:**
```bash
# Brute force with wordlist
jwt-cracker <token> <wordlist>

# Example
jwt-cracker "eyJhbGc..." /usr/share/wordlists/rockyou.txt

# Alphabet brute force
jwt-cracker <token> -a "abcdefghijklmnopqrstuvwxyz" -l 6

# Max length
jwt-cracker <token> <wordlist> --max 10
```

**Common Use Cases:**
- JWT security testing
- Weak secret detection
- Authentication analysis
- Security assessments

**Update:**
```bash
npm update -g jwt-cracker
```

---

## Rust Tools

**Total:** 8 tools | **Size:** ~30 MB | **Prerequisites:** Rust runtime

All Rust tools are compiled from source and installed to `$CARGO_HOME/bin` (`~/.local/share/cargo/bin/`).

### Reconnaissance Tools

#### feroxbuster

**Category:** Active Reconnaissance - Content Discovery
**Size:** ~5 MB
**Installation Location:** `$CARGO_HOME/bin/feroxbuster`
**Dependencies:** `rust`

**Description:**
Fast, simple, recursive content discovery tool written in Rust. Alternative to Gobuster/dirbuster.

**Usage:**
```bash
# Basic scan
feroxbuster -u https://example.com

# With wordlist
feroxbuster -u https://example.com -w wordlist.txt

# Specify depth
feroxbuster -u https://example.com -d 4

# Threads
feroxbuster -u https://example.com -t 50

# Extensions
feroxbuster -u https://example.com -x php,html,txt

# Status code filtering
feroxbuster -u https://example.com -C 404,403

# Output to file
feroxbuster -u https://example.com -o results.txt

# Silent mode
feroxbuster -u https://example.com --silent
```

**Common Use Cases:**
- Directory brute-forcing
- Content discovery
- Hidden resource finding
- Attack surface mapping

**Update:**
```bash
cargo install feroxbuster --force
```

---

#### RustScan

**Category:** Active Reconnaissance - Port Scanning
**Size:** ~3 MB
**Installation Location:** `$CARGO_HOME/bin/rustscan`
**Dependencies:** `rust`

**Description:**
Modern, fast port scanner with adaptive timing. Scans all 65,535 ports in seconds.

**Usage:**
```bash
# Basic scan
rustscan -a example.com

# Scan multiple hosts
rustscan -a example.com,8.8.8.8

# Specify ports
rustscan -a example.com -p 80,443,8080

# Port range
rustscan -a example.com --range 1-10000

# Batch size
rustscan -a example.com -b 1000

# Scripts (nmap integration)
rustscan -a example.com -- -sV -sC

# Timeout
rustscan -a example.com -t 1500

# Greppable output
rustscan -a example.com -g
```

**Common Use Cases:**
- Fast port scanning
- Service discovery
- Network reconnaissance
- Attack surface analysis

**Update:**
```bash
cargo install rustscan --force
```

---

### Utility Tools

#### ripgrep (rg)

**Category:** Utility - Fast Search
**Size:** ~2 MB
**Installation Location:** `$CARGO_HOME/bin/rg`
**Dependencies:** `rust`

**Description:**
Recursively search directories for regex patterns. Faster than grep, respects .gitignore.

**Usage:**
```bash
# Basic search
rg "pattern"

# Case insensitive
rg -i "pattern"

# Search specific file types
rg -t py "pattern"
rg -t js "pattern"

# Search hidden files
rg --hidden "pattern"

# Show context
rg -C 3 "pattern"

# Count matches
rg -c "pattern"

# List files with matches
rg -l "pattern"

# Inverse match
rg -v "pattern"

# Replace preview
rg "pattern" -r "replacement"
```

**Common Use Cases:**
- Code searching
- Log analysis
- File content searching
- Pattern matching

**Update:**
```bash
cargo install ripgrep --force
```

---

#### fd

**Category:** Utility - Fast File Finder
**Size:** ~1.5 MB
**Installation Location:** `$CARGO_HOME/bin/fd`
**Dependencies:** `rust`

**Description:**
Fast, user-friendly alternative to 'find'. Simple syntax, respects .gitignore.

**Usage:**
```bash
# Basic search
fd pattern

# Case insensitive
fd -i pattern

# Search by extension
fd -e txt
fd -e py

# Search hidden files
fd -H pattern

# Execute command on results
fd pattern -x ls -lh

# Search in specific directory
fd pattern /path/to/dir

# Type filtering
fd -t f pattern  # files only
fd -t d pattern  # directories only

# Exclude patterns
fd -E "*.log" pattern
```

**Common Use Cases:**
- Fast file finding
- Directory searching
- Build system integration
- Script automation

**Update:**
```bash
cargo install fd-find --force
```

---

#### bat

**Category:** Utility - Enhanced Cat
**Size:** ~2 MB
**Installation Location:** `$CARGO_HOME/bin/bat`
**Dependencies:** `rust`

**Description:**
Cat clone with syntax highlighting, git integration, and automatic paging.

**Usage:**
```bash
# View file
bat file.py

# Multiple files
bat file1.py file2.py

# Show line numbers
bat -n file.py

# Show git diff
bat --diff file.py

# Plain output (no decorations)
bat -p file.py

# Specific language
bat -l python file.txt

# Theme
bat --theme="Monokai Extended" file.py

# List themes
bat --list-themes
```

**Common Use Cases:**
- Code viewing with syntax highlighting
- Log file viewing
- Config file viewing
- Git diff visualization

**Update:**
```bash
cargo install bat --force
```

---

#### sd

**Category:** Utility - Find & Replace
**Size:** ~1 MB
**Installation Location:** `$CARGO_HOME/bin/sd`
**Dependencies:** `rust`

**Description:**
Intuitive find & replace CLI tool. Simpler syntax than sed.

**Usage:**
```bash
# Basic replace
sd 'old' 'new' file.txt

# In-place edit
sd -i 'old' 'new' file.txt

# Regex patterns
sd '\d+' 'NUMBER' file.txt

# Case insensitive
sd -f i 'pattern' 'replacement' file.txt

# Multiple files
sd 'old' 'new' *.txt

# Preview mode
sd --preview 'old' 'new' file.txt

# String literal mode
sd -s 'old' 'new' file.txt
```

**Common Use Cases:**
- Text replacement
- File refactoring
- Bulk editing
- Config updates

**Update:**
```bash
cargo install sd --force
```

---

#### tokei

**Category:** Utility - Code Statistics
**Size:** ~2 MB
**Installation Location:** `$CARGO_HOME/bin/tokei`
**Dependencies:** `rust`

**Description:**
Fast code statistics analyzer. Count lines of code, comments, blanks by language.

**Usage:**
```bash
# Analyze current directory
tokei

# Specific directory
tokei /path/to/project

# Output formats
tokei --output json
tokei --output yaml

# Sort by lines
tokei --sort lines

# Exclude patterns
tokei --exclude "*.log" --exclude "vendor/*"

# Show files
tokei --files

# Compact output
tokei -c
```

**Common Use Cases:**
- Project statistics
- Code metrics
- Language breakdown
- Documentation analysis

**Update:**
```bash
cargo install tokei --force
```

---

#### dog

**Category:** Utility - Modern DNS Client
**Size:** ~1.5 MB
**Installation Location:** `$CARGO_HOME/bin/dog`
**Dependencies:** `rust`

**Description:**
Modern DNS client with colorized output. Alternative to dig with better UX.

**Usage:**
```bash
# Basic query
dog example.com

# Specific record type
dog example.com A
dog example.com AAAA
dog example.com MX
dog example.com TXT

# Use specific DNS server
dog example.com @8.8.8.8

# Short output
dog example.com -s

# JSON output
dog example.com -J

# Show query time
dog example.com -t

# Reverse DNS
dog --reverse 8.8.8.8
```

**Common Use Cases:**
- DNS queries
- Domain investigation
- DNS troubleshooting
- Network reconnaissance

**Update:**
```bash
cargo install dog --force
```

---

## Use Case Categories

Tools organized by security testing use case for quick reference.

### Username/Email OSINT

**Find accounts and online presence for usernames/emails:**

| Tool | Type | Best For |
|------|------|----------|
| **Sherlock** | Python | Username search across 300+ platforms |
| **Holehe** | Python | Email registration checks |
| **Socialscan** | Python | Username/email availability |
| **h8mail** | Python | Breach hunting and credential exposure |

**Typical Workflow:**
```bash
# 1. Check if username exists
sherlock target_user

# 2. Check email registrations
holehe target@example.com

# 3. Check availability
socialscan target_user target@example.com

# 4. Check for breaches
h8mail -t target@example.com
```

---

### Subdomain Enumeration

**Discover subdomains for a target domain:**

| Tool | Type | Method | Speed |
|------|------|--------|-------|
| **subfinder** | Go | Passive (40+ sources) | Fast |
| **assetfinder** | Go | Passive | Fast |
| **Sublist3r** | Python | Passive (search engines) | Medium |
| **theHarvester** | Go | Passive + DNS | Medium |
| **Gobuster** | Go | Active (DNS brute force) | Fast |

**Typical Workflow:**
```bash
# 1. Passive enumeration
subfinder -d example.com -o subdomains.txt
assetfinder example.com >> subdomains.txt

# 2. Sort and deduplicate
sort -u subdomains.txt -o subdomains.txt

# 3. Probe for live hosts
cat subdomains.txt | httprobe > live_subs.txt

# 4. Active brute force (optional)
gobuster dns -d example.com -w wordlist.txt
```

---

### Directory/Content Discovery

**Find hidden directories and files on web servers:**

| Tool | Language | Speed | Features |
|------|----------|-------|----------|
| **FFuF** | Go | Fastest | Fuzzing, flexible filtering |
| **Gobuster** | Go | Fast | Dir/DNS/vhost modes |
| **feroxbuster** | Rust | Fast | Recursive, auto-tune |

**Typical Workflow:**
```bash
# 1. Fast initial scan
ffuf -u https://example.com/FUZZ -w common.txt

# 2. Recursive with extensions
feroxbuster -u https://example.com -x php,html,txt

# 3. Vhost discovery
gobuster vhost -u https://example.com -w vhosts.txt
```

---

### Vulnerability Scanning

**Identify vulnerabilities and misconfigurations:**

| Tool | Type | Coverage | Update Frequency |
|------|------|----------|------------------|
| **Nuclei** | Go | 5,000+ templates | Daily |
| **RustScan** | Rust | Port scanning | N/A |

**Typical Workflow:**
```bash
# 1. Port scan
rustscan -a example.com

# 2. Vulnerability scan
nuclei -u https://example.com -severity critical,high

# 3. Specific CVE checks
nuclei -u https://example.com -t cves/2023/
```

---

### Web Reconnaissance

**Gather intelligence from websites:**

| Tool | Type | Specialization |
|------|------|----------------|
| **Photon** | Python | Web crawling & data extraction |
| **Wappalyzer** | Python | Technology identification |
| **waybackurls** | Go | Historical URL discovery |
| **theHarvester** | Python | Multi-source OSINT |

**Typical Workflow:**
```bash
# 1. Identify technologies
wappalyzer https://example.com

# 2. Crawl for data
photon -u https://example.com -o results/

# 3. Historical URLs
echo "example.com" | waybackurls > historical_urls.txt

# 4. Email/host gathering
theHarvester -d example.com -b all
```

---

### Threat Intelligence

**Analyze threats and IOCs:**

| Tool | Type | Data Source |
|------|------|-------------|
| **Shodan** | Python | Internet-wide scanning |
| **Censys** | Python | Internet-wide scanning |
| **VirusTotal** | Go | Malware/URL analysis |
| **YARA** | Python | Pattern matching |
| **TruffleHog** | Node.js | Secret detection |

**Typical Workflow:**
```bash
# 1. IP/domain reputation
shodan host 8.8.8.8
vt domain example.com

# 2. Secret scanning
trufflehog git https://github.com/target/repo.git

# 3. Malware analysis
yara rules.yar suspicious_file
```

---

### Port Scanning & Service Discovery

**Identify open ports and running services:**

| Tool | Type | Speed | Best For |
|------|------|-------|----------|
| **RustScan** | Rust | Fastest | All 65k ports in seconds |
| **httprobe** | Go | Fast | HTTP/HTTPS services only |

**Typical Workflow:**
```bash
# 1. Fast comprehensive scan
rustscan -a example.com

# 2. HTTP service check
cat hosts.txt | httprobe > http_services.txt

# 3. Integration with Nmap
rustscan -a example.com -- -sV -sC
```

---

### Code Analysis

**Search and analyze source code:**

| Tool | Type | Use Case |
|------|------|----------|
| **ripgrep** | Rust | Fast code searching |
| **fd** | Rust | Fast file finding |
| **bat** | Rust | Code viewing with syntax |
| **tokei** | Rust | Code statistics |

**Typical Workflow:**
```bash
# 1. Find files
fd -e py

# 2. Search code
rg "password" --type py

# 3. View with syntax
bat config.py

# 4. Get statistics
tokei
```

---

## Alphabetical Index

Quick alphabetical reference with tool type and primary use case.

| Tool | Type | Category | Primary Use |
|------|------|----------|-------------|
| **assetfinder** | Go | OSINT | Passive subdomain discovery |
| **bat** | Rust | Utility | Syntax-highlighted file viewing |
| **Censys** | Python | CTI | Internet scanning data |
| **CMake** | Build | Build | Compile tools from source |
| **dog** | Rust | Utility | Modern DNS queries |
| **fd** | Rust | Utility | Fast file finder |
| **feroxbuster** | Rust | Active Recon | Content discovery |
| **FFuF** | Go | Active Recon | Web fuzzing |
| **git-hound** | Node.js | OSINT | GitHub reconnaissance |
| **GitHub CLI** | Build | Build | GitHub automation |
| **Gobuster** | Go | Active Recon | Directory/DNS brute force |
| **Go Runtime** | Runtime | Runtime | Go language support |
| **h8mail** | Python | OSINT | Breach hunting |
| **Holehe** | Python | OSINT | Email verification |
| **httprobe** | Go | Active Recon | HTTP service probe |
| **JWT Cracker** | Node.js | Testing | JWT token analysis |
| **Node.js** | Runtime | Runtime | JavaScript runtime |
| **Nuclei** | Go | Vuln Scan | Vulnerability scanner |
| **Photon** | Python | OSINT | Web crawler |
| **Python venv** | Environment | Runtime | Python isolation |
| **ripgrep** | Rust | Utility | Fast recursive search |
| **Rust** | Runtime | Runtime | Rust language support |
| **RustScan** | Rust | Active Recon | Fast port scanner |
| **sd** | Rust | Utility | Find & replace |
| **Sherlock** | Python | OSINT | Username search |
| **Shodan** | Python | CTI | Internet device search |
| **Socialscan** | Python | OSINT | Availability checker |
| **SpiderFoot** | Python | OSINT | Automated OSINT |
| **subfinder** | Go | OSINT | Subdomain discovery |
| **Sublist3r** | Python | OSINT | Subdomain enumeration |
| **theHarvester** | Python | OSINT | Multi-source gathering |
| **tokei** | Rust | Utility | Code statistics |
| **TruffleHog** | Node.js | CTI | Secret scanning |
| **VirusTotal** | Go | CTI | Threat intelligence |
| **Wappalyzer** | Python | OSINT | Technology profiler |
| **waybackurls** | Go | OSINT | Archive URL fetcher |
| **YARA** | Python | CTI | Pattern matching |

---

## Quick Reference Tables

### Tools by Install Time

| Duration | Tools |
|----------|-------|
| **Fast** (< 5 min) | Most Python tools, Go tools |
| **Medium** (5-15 min) | CMake, GitHub CLI, Node.js tools |
| **Slow** (15-30 min) | Individual Rust tools |
| **Very Slow** (20-30 min+) | All Rust tools together |

### Tools by Disk Space

| Size Range | Tools |
|------------|-------|
| **Tiny** (< 5 MB) | yara, censys, shodan, httprobe, waybackurls, assetfinder, jwt-cracker, sd, dog, fd, rustscan |
| **Small** (5-15 MB) | holehe, socialscan, h8mail, sublist3r, theHarvester, wappalyzer, gobuster, ffuf, subfinder, virustotal, trufflehog, git-hound, feroxbuster |
| **Medium** (15-50 MB) | sherlock, photon, spiderfoot, nuclei, ripgrep, bat, tokei, cmake |
| **Large** (50-100 MB) | github_cli, nodejs, python_venv |
| **Huge** (100 MB+) | go (120 MB), rust (800 MB) |

### Tools by Prerequisites

| Prerequisites | Tools |
|---------------|-------|
| **None** | cmake, github_cli, nodejs, rust |
| **System Go** | All Go tools (8) |
| **Python venv** | All Python tools (12) |
| **Node.js** | trufflehog, git-hound, jwt-cracker |
| **Rust** | feroxbuster, rustscan, ripgrep, fd, bat, sd, tokei, dog |

### Tools by Update Method

| Method | Tools |
|--------|-------|
| **Reinstall** | cmake, github_cli, nodejs |
| **pip upgrade** | All Python tools |
| **go install @latest** | All Go tools |
| **npm update -g** | All Node.js tools |
| **cargo install --force** | All Rust tools |
| **rustup update** | Rust runtime |

---

## Cross-References

### Related Documentation

📖 **[README.md](../README.md)** - Project overview and quick start
📖 **[Script Usage Guide](script_usage.md)** - How to install and run tools
📖 **[XDG Setup Guide](xdg_setup.md)** - Environment configuration
📖 **[Extending the Script](EXTENDING_THE_SCRIPT.md)** - Add new tools
📖 **[CHANGELOG.md](../CHANGELOG.md)** - Version history

### Tool Definitions Source

All tool metadata in this document is sourced from:
📖 **[lib/data/tool-definitions.sh](../lib/data/tool-definitions.sh)** - Canonical tool definitions

### Testing & Verification

📖 **[scripts/test_installation.sh](../scripts/test_installation.sh)** - Verify tool installations
📖 **[scripts/diagnose_installation.sh](../scripts/diagnose_installation.sh)** - Diagnostics & maintenance

### Developer Resources

📖 **[CLAUDE.md](../CLAUDE.md)** - AI assistant project context
📖 **[Agent Workflows](.claude/agents/WORKFLOWS.md)** - Development automation

---

**Document Version:** 1.0
**Last Updated:** January 15, 2026
**Maintained By:** documentation-engineer agent

For installation instructions, see 📖 [Script Usage Guide](script_usage.md).
For adding new tools, see 📖 [Extending the Script](EXTENDING_THE_SCRIPT.md).
