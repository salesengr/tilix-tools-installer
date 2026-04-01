# Smoke Test Plan

**Script:** `scripts/smoke_test.sh`
**Target:** `salesengr/local-apps:tilix-amd64` container, run as root with VNC
**Branch:** `feature/smoke-test-plan`

---

## Overview

A non-destructive smoke test suite that verifies every installed tool is reachable and responds correctly after a fresh install. Tests run with a 15-second timeout per tool and produce a pass/fail summary with a log file.

---

## Setup

```bash
# 1. Clone the feature branch into the container
git clone -b dev https://github.com/salesengr/tilix-tools-installer.git
cd tilix-tools-installer

# 2. Install all tools
bash installer.sh all

# 3. Reload PATH
source ~/.bashrc

# 4. Run the smoke test
bash scripts/smoke_test.sh
```

---

## Test Invocations

| Mode | Command |
|------|---------|
| All tools | `bash scripts/smoke_test.sh` |
| Specific category | `bash scripts/smoke_test.sh --category osint` |
| Single tool | `bash scripts/smoke_test.sh --tool sherlock` |
| Skip uninstalled | `bash scripts/smoke_test.sh --installed-only` |

**Category values:** `osint`, `domain`, `recon`, `cti`, `security`, `utilities`, `web`

---

## Test Matrix

### Passive OSINT

| Tool | Test Command | Pass Condition |
|------|-------------|----------------|
| sherlock | `sherlock --help` | output contains "usage" |
| holehe | `holehe --help` | output contains "usage" |
| socialscan | `socialscan --help` | output contains "usage" |
| theHarvester | `theHarvester --help` | output contains "usage" |
| spiderfoot | `spiderfoot --help` | output contains "usage" |
| photon | `photon --help` | output contains "usage" |
| wappalyzer | `wappalyzer --help` | output contains "usage" |
| h8mail | `h8mail --help` | output contains "usage" |
| waybackurls | `waybackurls --help` | output contains "usage" |
| assetfinder | `assetfinder --help` | output contains "usage" |
| subfinder | `subfinder -version` | output contains "subfinder" |
| git-hound | `git-hound --help` | output contains "usage" |

### Domain & Subdomain Enumeration

| Tool | Test Command | Pass Condition |
|------|-------------|----------------|
| sublist3r | `sublist3r --help` | output contains "usage" |
| gobuster | `gobuster version` | output contains "gobuster" |
| ffuf | `ffuf --help` | output contains "usage" |

### Active Recon & Scanning

| Tool | Test Command | Pass Condition |
|------|-------------|----------------|
| httprobe | `httprobe --help` | output contains "usage" |
| rustscan | `rustscan --version` | output contains "rustscan" |
| feroxbuster | `feroxbuster --version` | output contains "feroxbuster" |
| nuclei | `nuclei -version` | output contains "nuclei" |

### Cyber Threat Intelligence

| Tool | Test Command | Pass Condition |
|------|-------------|----------------|
| shodan | `shodan --help` | output contains "usage" |
| censys | `censys --help` | output contains "usage" |
| yara | `yara --version` | output contains "yara" |
| trufflehog | `trufflehog --version` | output contains "trufflehog" |
| virustotal (vt) | `vt --help` | output contains "usage" |

### Security Testing

| Tool | Test Command | Pass Condition |
|------|-------------|----------------|
| jwt-cracker | `jwt-cracker --help` | output contains "usage" |

### Utilities

| Tool | Binary | Test Command | Pass Condition |
|------|--------|-------------|----------------|
| ripgrep | `rg` | `rg --version` | output contains "ripgrep" |
| fd | `fd` | `fd --version` | output contains "fd" |
| bat | `bat` | `bat --version` | output contains "bat" |
| sd | `sd` | `sd --version` | output contains "sd" |
| dog | `dog` | `dog --version` | output contains "dog" |
| aria2 | `aria2c` | `aria2c --version` | output contains "aria2" |

### Web Tools

| Tool | Test Command | Pass Condition | Notes |
|------|-------------|----------------|-------|
| Google Chrome | `google-chrome --no-sandbox --version` | output contains "google chrome" | `--no-sandbox` required as root |
| SeleniumBase | `sbase --version` or `python3 -c 'import seleniumbase; print(seleniumbase.__version__)'` | exits 0 | |
| Playwright | `python3 -c 'import playwright; print(playwright.__version__)'` | exits 0 | |
| Yandex Browser | `yandex-browser-beta --version` | output contains "yandex" | amd64 only |
| Tor Browser | file check `~/opt/tor-browser/Browser/start-tor-browser` | file exists | no launch — requires display |
| qTox | file check `~/opt/qtox/squashfs-root/AppRun` + `~/.local/bin/qtox` | both files exist | no launch — requires display |

---

## Output

Tests produce three states:

| Symbol | Color | Meaning |
|--------|-------|---------|
| `[✔]` | green | Passed |
| `[✘]` | red | Failed — binary not found, timeout, or unexpected output |
| `[—]` | yellow | Skipped — not installed (only with `--installed-only`) |

A log file is written to `~/.local/state/install_tools/smoke_test/smoke_<timestamp>.log`.

---

## Known Expected Issues (as-is)

| Tool | Expected Issue | Reason |
|------|---------------|--------|
| Google Chrome | Fails without `--no-sandbox` as root | Container runs as root |
| qTox | Cannot launch GUI headlessly | Requires `$DISPLAY` / VNC |
| Yandex Browser | Cannot launch GUI headlessly | Requires `$DISPLAY` / VNC |
| Tor Browser | Cannot launch GUI headlessly | Requires `$DISPLAY` / VNC |
| shodan / censys / vt | May warn about missing API key | CLI still responds to `--help` |

---

## After Running

1. Capture the log from `~/.local/state/install_tools/smoke_test/`
2. File an issue on GitHub for each `[✘]` that isn't in the Known Expected Issues table above
3. Create a fix branch per issue: `fix/<tool>-smoke-failure`
