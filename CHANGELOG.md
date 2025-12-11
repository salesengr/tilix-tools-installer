# Changelog

All notable changes to the Security Tools Installer project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-12-11

### Initial Release

A comprehensive user-space installation system for OSINT/CTI/PenTest security tools that requires no sudo access.

#### Core Features
- Interactive menu system for tool selection
- CLI support for automation and scripting
- Comprehensive logging system with rotation
- Automatic dependency resolution
- Dry-run mode for preview installations
- Installation status tracking
- Support for comma-separated menu selections
- Download retry logic with automatic error recovery
- XDG Base Directory Specification compliance

#### Tools Included (37+ tools)

**Build Tools & Runtimes (4)**
- CMake 3.28.1
- Go 1.21.5
- Node.js 20.10.0
- Rust (latest)

**Python Tools (16)**
- sherlock - Username search across social networks
- holehe - Email verification
- socialscan - Username/email availability checker
- theHarvester - Multi-source OSINT gathering
- spiderfoot - Automated OSINT collection
- sublist3r - Subdomain enumeration
- photon - Web crawler
- h8mail - Email OSINT and breach hunting
- shodan - Internet device search engine CLI
- censys - Internet-wide scanning data
- yara - Malware pattern matching
- wappalyzer - Technology profiler

**Go Tools (8)**
- gobuster - Directory/DNS/vhost bruteforcing
- ffuf - Fast web fuzzer
- httprobe - HTTP/HTTPS service probe
- waybackurls - Wayback Machine URL fetcher
- assetfinder - Domain/subdomain finder
- subfinder - Subdomain discovery
- nuclei - Vulnerability scanner
- virustotal - VirusTotal CLI

**Node.js Tools (4)**
- trufflehog - Secret scanning
- wappalyzer-cli - Technology profiler
- git-hound - GitHub reconnaissance
- jwt-cracker - JWT token analysis

**Rust Tools (8)**
- feroxbuster - Content discovery
- rustscan - Fast port scanner
- ripgrep - Fast recursive grep
- fd - Fast file finder
- bat - Cat with syntax highlighting
- sd - Intuitive find & replace
- tokei - Code statistics analyzer
- dog - Modern DNS client

#### Installation System
- User-space only (no sudo required)
- Automatic environment variable configuration
- Virtual environment management for Python tools
- Wrapper script creation for seamless tool execution
- Robust error handling with retry logic
- Detailed logging with automatic log rotation

#### Documentation
- Comprehensive README with usage examples
- Script extension guide (EXTENDING_THE_SCRIPT.md)
- User-space compatibility analysis (USER_SPACE_COMPATIBILITY.md)
- Detailed tool documentation (install_tools.md, xdg_setup.md)
- Developer guide (CLAUDE.md)

---

## Future Releases

See [GitHub Releases](https://github.com/your-repo/security-tools-installer/releases) for upcoming versions.
