# Security Tools Installer

**Version:** 1.5.1 | **Release Date:** May 29, 2026

A comprehensive user-space installation system for OSINT/CTI/PenTest and web automation tools. No sudo required — everything installs to `~/.local/`.

📖 **[Full Documentation → GitHub Wiki](https://github.com/salesengr/tilix-tools-installer/wiki)**

---

## 🎯 Features

- ✅ **37 security tools** — OSINT, CTI, reconnaissance, pentesting, web automation
- ✅ **No sudo required** — complete user-space installation
- ✅ **Pre-built binaries** — fast installs via GitHub releases; compile-from-source as fallback
- ✅ **Use-case categories** — install exactly what you need with one command
- ✅ **pip install --user** — no Python virtualenv overhead
- ✅ **System runtimes** — uses system Node.js, Go, Python where available
- ✅ **Interactive menu** — point-and-click installation
- ✅ **XDG compliant** — follows Linux filesystem standards
- ✅ **Shellcheck clean** — zero warnings across all scripts
- ✅ **Detached GUI launchers** — GUI tools (`chrome`, `yandex-browser`, `tor-browser`, `qtox`, `spiderfoot`) background automatically using `nohup` + `disown`; guard checks verify binary presence and `DISPLAY` before launching
- ✅ **News spider script** — `scripts/news_spider_playwright.py` captures screenshots, PDFs, and MHTML snapshots of news sites (BBC, Nikkei, Google News); no installer entry needed

---

## ⚡ Quick Start

```bash
git clone https://github.com/salesengr/tilix-tools-installer.git
cd tilix-tools-installer
bash installer.sh
```

Or install by category directly:

```bash
bash install_security_tools.sh --osint-tools      # Passive OSINT (13 tools)
bash install_security_tools.sh --domain-tools     # Domain & Subdomain Enum (3 tools)
bash install_security_tools.sh --recon-tools      # Active Recon & Scanning (4 tools)
bash install_security_tools.sh --cti-tools        # Cyber Threat Intel (5 tools)
bash install_security_tools.sh --utility-tools    # Utilities (6 tools)
bash install_security_tools.sh --web-tools        # Web Tools (5 tools)
bash install_security_tools.sh all               # Everything
```

After install, reload your shell: `source ~/.bashrc`

---

## ⚙️ Tool Configuration

Some tools require API key setup before they return results:

| Tool | Setup Command | Get Key From |
|------|--------------|--------------|
| shodan | `shodan init <key>` | [account.shodan.io](https://account.shodan.io) |
| censys | `censys config` | [search.censys.io/account/api](https://search.censys.io/account/api) |
| virustotal | `vt init` | [virustotal.com/gui/my-apikey](https://www.virustotal.com/gui/my-apikey) |
| h8mail | Edit `~/.config/h8mail.ini` | See [h8mail docs](https://github.com/khast3x/h8mail) |

Tools without setup work immediately after install.

---

## 📦 What Gets Installed

Tools are organized by use-case. → **[Full tool list with descriptions](https://github.com/salesengr/tilix-tools-installer/wiki/Tool-Categories)**

| Category | Tools | Flag |
|----------|-------|------|
| Passive OSINT | sherlock, holehe, theHarvester, spiderfoot, subfinder, git-hound, amass + 6 more | `--osint-tools` |
| Domain & Subdomain Enum | sublist3r, gobuster, ffuf | `--domain-tools` |
| Active Recon & Scanning | httprobe, rustscan, feroxbuster, nuclei | `--recon-tools` |
| Cyber Threat Intelligence | shodan, censys, yara, trufflehog, virustotal | `--cti-tools` |
| Security Testing | jwt-cracker | — |
| Utilities | ripgrep, fd, bat, sd, doggo, aria2 | `--utility-tools` |
| Web Tools | SeleniumBase, Playwright, Yandex Browser, Tor Browser, qTox | `--web-tools` |

---

## 🚀 Installation Methods

### One-Command Bootstrap
```bash
curl -fsSL https://raw.githubusercontent.com/salesengr/tilix-tools-installer/main/installer.sh -o installer.sh
bash installer.sh
```

### Step-by-Step
```bash
# 1. Setup XDG environment (first time only)
bash xdg_setup.sh && source ~/.bashrc

# 2. Install tools interactively
bash install_security_tools.sh

# 3. Or use CLI flags for automation
bash install_security_tools.sh --osint-tools --cti-tools
```

→ **[Full installation guide](https://github.com/salesengr/tilix-tools-installer/wiki/Getting-Started)**

---

## 📁 Directory Structure

```
~/.local/bin/               # All tool binaries and wrappers (including GUI launchers)
~/.local/lib/python3.13/    # Python tools (pip --user)
~/.local/state/install_tools/logs/  # Installation logs
~/opt/gopath/bin/           # Go tool binaries (symlinked to ~/.local/bin)
~/opt/src/spiderfoot/       # SpiderFoot source
~/opt/tor-browser/          # Tor Browser
~/opt/qtox/squashfs-root/   # qTox (AppImage extracted)
~/.local/share/cargo/bin/   # Rust tool binaries (symlinked to ~/.local/bin)
```

---

## 📚 Documentation

| Resource | Description |
|----------|-------------|
| **[Wiki: Getting Started](https://github.com/salesengr/tilix-tools-installer/wiki/Getting-Started)** | Prerequisites, install methods, first run |
| **[Wiki: Tool Categories](https://github.com/salesengr/tilix-tools-installer/wiki/Tool-Categories)** | Full tool list with descriptions |
| **[Wiki: CLI Reference](https://github.com/salesengr/tilix-tools-installer/wiki/CLI-Reference)** | All flags, options, examples |
| **[Wiki: Usage Examples](https://github.com/salesengr/tilix-tools-installer/wiki/Usage-Examples)** | Practical examples for every tool |
| **[Wiki: Web Tools](https://github.com/salesengr/tilix-tools-installer/wiki/Web-Tools)** | SeleniumBase, Playwright, Yandex Browser, Tor Browser, qTox |
| **[Wiki: Troubleshooting](https://github.com/salesengr/tilix-tools-installer/wiki/Troubleshooting)** | Common issues and fixes |
| **[Wiki: Disk Space & Performance](https://github.com/salesengr/tilix-tools-installer/wiki/Disk-Space-and-Performance)** | Sizes and install times |
| **[docs/EXTENDING_THE_SCRIPT.md](docs/EXTENDING_THE_SCRIPT.md)** | How to add new tools (versioned) |
| **[docs/tool_installation_summary.md](docs/tool_installation_summary.md)** | Where each tool lands on disk (versioned) |
| **[docs/xdg_setup.md](docs/xdg_setup.md)** | XDG environment setup (versioned) |

---

## 💾 Disk Space & Performance

Typical install: **400-800 MB** (vs 1.3-2 GB before v1.4.0)

| Flag | Time |
|------|------|
| `--domain-tools` | ~13 seconds |
| `--osint-tools` | ~3 minutes |
| `--recon-tools` | ~6 minutes |
| Everything | ~20-30 minutes |

→ **[Full breakdown](https://github.com/salesengr/tilix-tools-installer/wiki/Disk-Space-and-Performance)**

---

## 🔧 Quick Usage Examples

```bash
# OSINT
sherlock john_doe                              # username search
theHarvester -d example.com -b all           # domain intel
spiderfoot                                    # start web UI → chrome http://127.0.0.1:5001

# Recon
gobuster dir -u https://target.com -w wordlist.txt
nuclei -u https://target.com

# Web Tools (all GUI launchers background automatically)
chrome                                        # launch Chrome detached
yandex-browser                               # launch Yandex Browser detached
tor-browser                                  # launch Tor Browser detached (nohup + disown)
qtox                                         # launch qTox detached
sbase get https://example.com --headless      # SeleniumBase headless screenshot

# News Spider (requires: playwright install chromium)
python3 scripts/news_spider_playwright.py --site bbc --max-pages 2
python3 scripts/news_spider_playwright.py --site nikkei --output-pdf --output-mhtml
```

> **Playwright note:** After `bash install_security_tools.sh playwright`, run `playwright install chromium` to download the Chromium binary (~300 MB) required by the news spider and other scripts that launch their own browser.

→ **[Full usage examples](https://github.com/salesengr/tilix-tools-installer/wiki/Usage-Examples)**

---

## 🐛 Troubleshooting

**Tools not found?** → `source ~/.bashrc` or open a new terminal

**Common fixes:**
```bash
pip show sherlock-project     # check Python tool install
ls ~/.local/bin/              # verify binary location
tail -20 ~/.local/state/install_tools/installation_history.log
```

→ **[Full troubleshooting guide](https://github.com/salesengr/tilix-tools-installer/wiki/Troubleshooting)**

---

## 🤝 Contributing

→ **[How to add new tools](https://github.com/salesengr/tilix-tools-installer/wiki/Extending-the-Installer)** | **[Versioned technical docs](docs/EXTENDING_THE_SCRIPT.md)**

1. Add tool definition to `lib/data/tool-definitions.sh`
2. Add `is_installed()` check to `lib/core/verification.sh`
3. Create `install_<tool>()` in `lib/installers/tools.sh`
4. Register in `lib/ui/orchestration.sh` and `lib/ui/menu.sh`
5. Test with `bash install_security_tools.sh --dry-run <tool>`

---

## 📋 Requirements

- Ubuntu 20.04+ (or compatible Linux)
- `git` and `curl`
- ~800 MB free disk space
- Internet connection

---

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md) for full version history.

## 📄 License

[MIT License](LICENSE) — Copyright (c) 2026 salesengr

Provided as-is for educational and professional security testing. Always obtain proper authorization before testing systems you don't own.

---

## 🛠 Developer Tools

Scripts in `scripts/dev/` are for testing and remote orchestration — not intended for trial users.

| Script | Purpose |
|--------|---------|
| `remote_agent_setup_bore.sh` | bore tunnel for remote container access |
| `remote_agent_setup_ssh_tunnel.sh` | Direct reverse SSH tunnel (most reliable) |
| `remote_agent_setup_serveo.sh` | serveo.net SSH tunnel fallback |
| `remote_agent_setup_localrun.sh` | localhost.run tunnel fallback |
| `scripts/dev/test_harness.sh` | Install + verify a tool category |
| `get_public_ip.sh` | Get container public IP via ipify |
| `install_nc_fallback.sh` | Python netcat replacement with -z/-v/-w support |
