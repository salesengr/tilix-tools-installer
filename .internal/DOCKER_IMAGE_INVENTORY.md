# Docker Image Inventory (Base/Reset Environment)

_Date:_ 2026-02-12 (America/New_York)  
_Branch:_ `dev`

## Scope and method

This inventory was built using two evidence sources:

1. **Repository inspection** for Docker/image/build references:
   - Searched for `Dockerfile*`, compose files, container build files, and README/docs mentions.
   - Result: **no Dockerfile/compose/container build manifests were found in this repo**.
2. **Live environment inspection (read-only)** from this workspace session:
   - OS/runtime/package-manager/binary checks via `uname`, `/etc/os-release`, `command -v`, `--version`.
   - Installed package snapshots where accessible (`dpkg -l`, `apt list --installed`, `pip list`, `npm -g ls`).
   - Browser/selenium detect checks.
   - Root/sudo discoverability checks (without privilege escalation).

Raw command output captured at: `.internal/inventory_scan_raw.txt`.

---

## Confidence legend

- **Confirmed installed**: directly observed from executable presence/version and/or package listings.
- **Inferred from config**: implied by repo config/scripts but not directly observed as installed.
- **Not confirmed**: checked and not found, or inaccessible without elevated permissions.

---

## 1) Confirmed installed

### OS + package ecosystem

- Ubuntu 24.04.4 LTS (`/etc/os-release`)
- `apt`, `apt-get`, `dpkg`, `snap` present
- No RPM-family managers detected (`rpm`, `dnf`, `yum` missing)

### Core CLI/toolchain baseline

Confirmed on PATH:
- `bash`, `sh`, `curl`, `wget`, `git`, `tar`, `zip`, `unzip`, `jq`, `make`, `gcc`, `g++`

### Language runtimes + package managers

- **Python**: `python3` (Linuxbrew) -> `Python 3.14.3`
- **pip**: `pip3` -> `pip 26.0`
- **Go**: `go version go1.25.7 linux/amd64`
- **Node.js**: `node v25.6.0`, `npm 11.8.0`, `npx` present

Additional package evidence:
- Apt also reports distro `python3`/`nodejs` packages installed.
- Linuxbrew runtime path present (`/home/linuxbrew/.linuxbrew/...`) and active in PATH.

### Browser / automation related

- **Google Chrome**: `Google Chrome 145.0.7632.45` (`/usr/bin/google-chrome`)
- **Firefox**: `Mozilla Firefox 147.0.3` (`/usr/bin/firefox`; also snap package installed)

Docker/desktop related (host tooling):
- `docker` CLI: `Docker version 29.2.1`
- `docker compose`: `Docker Compose version v5.0.2`
- Apt lists `docker-ce-cli`, `docker-compose-plugin`, `docker-buildx-plugin`, `docker-desktop`

### Other notable preinstalled stack

- `azure-cli` installed (apt package evidence)

---

## 2) Inferred from config (repo evidence)

Current installer script (`install_security_tools.sh`) supports these user-space tools:
- `waybackurls` (via `go install github.com/tomnomnom/waybackurls@latest`)
- `assetfinder` (via `go install github.com/tomnomnom/assetfinder@latest`)
- `seleniumbase` (via `python3 -m pip install --prefix "$TOOLS_PREFIX" seleniumbase`)

These are **available for installation**, but not preinstalled in this session by default.

---

## 3) Not confirmed / absent in this session

Checked and not found on PATH:
- Selenium server binary (`selenium-server`)
- ChromeDriver (`chromedriver`)
- GeckoDriver (`geckodriver`)
- Java (`java`, `javac`)
- `python` (unversioned alias), `pip` (unversioned alias)

Python package checks (`pip list`) did **not** show selenium/playwright/webdriver packages in the active Linuxbrew Python environment.

SeleniumBase compatibility notes:
- PyPI metadata indicates SeleniumBase requires Python `>=3.9`; current Python is `3.14.3` (compatible by version range).
- Chrome is already present (`google-chrome 145.x`), so no additional browser install is needed for SeleniumBase onboarding.
- Missing local `chromedriver` is acceptable for most SeleniumBase flows because Selenium Manager can acquire/manage driver versions at runtime.

Repo-level Docker manifests:
- No Dockerfile/compose manifests found in this repository, so base-image contents cannot be corroborated from repo build definitions.

---

## Root/sudo discoverability caveats

- `sudo -n` is not available (no passwordless sudo from this user context).
- `/root` is not readable from this session.
- Some root-owned install locations are still discoverable (e.g., `/usr/local/bin/docker` symlink, `/opt/docker-desktop`, `/opt/google`).

**Implication:** inventory is high-confidence for user-visible environment and package metadata, but may miss root-only artifacts not visible without elevated access.

---

## Practical summary

This base/reset environment appears to be a **desktop-capable Ubuntu 24.04 image** with:
- modern **Go/Node/Python (Linuxbrew)** toolchains,
- **Chrome + Firefox** preinstalled,
- **Docker CLI/Compose/Desktop components** present,
- plus apt/snap ecosystem and common developer CLI utilities.

Security recon tools in this repo (`waybackurls`, `assetfinder`) are currently **installer-provided, not preinstalled**.
