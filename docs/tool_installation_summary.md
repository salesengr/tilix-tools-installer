# Tool Installation Summary

> 📖 **Wiki:** For quick reference and discovery, see the [GitHub Wiki](https://github.com/salesengr/tilix-tools-installer/wiki).
> This file is the versioned technical reference — it stays in sync with each release.



This reference maps the actions performed by `install_security_tools.sh` to the files and directories that appear on disk. Use it to verify installations, clean up specific stacks, or to explain to approvers exactly what the script touches.

## Directory Legend

The installer keeps everything inside your home directory:

- `~/.local/bin` – user executables and Python/Node wrappers
- `~/.local/share` – Python virtual environments, shared data, Cargo metadata
- `~/.local/state/install_tools` – installer logs and history
- `/usr/local/go` – System Go prerequisite (GOROOT expected by Go tool installs)
- `~/opt/gopath/bin` – compiled Go tools
- `~/opt/node` – Node.js runtime
- `~/opt/src` – temporary build artifacts and downloaded archives

Logs for every tool live in `~/.local/state/install_tools/logs/<tool>-<timestamp>.log` plus an audit trail in `~/.local/state/install_tools/installation_history.log`.

## Build Tools and Runtimes

**Note:** As of v1.1.0, Go is expected to be pre-installed system-wide at `/usr/local/go`. The installer no longer installs Go itself, only uses it to build Go-based tools.

| Component | How it is installed | Resulting files |
|-----------|---------------------|-----------------|
| CMake 3.28.1 | GitHub tarball is downloaded to `~/opt/src`, extracted, and binaries copied into `~/.local/bin` with supporting files in `~/.local/share`. | `~/.local/bin/cmake`, shared modules in `~/.local/share/cmake-*`, man pages in `~/.local/share/man`. |
| GitHub CLI 2.53.0 | Release tarball pulled into `~/opt/src` and extracted. Binary plus man pages are copied into `~/.local/bin` and `~/.local/share/man`. | `~/.local/bin/gh`, docs under `~/.local/share/doc/gh`. |
| Go (system prerequisite) | Expected at `/usr/local/go`; installer uses it to build Go tools and sets `GOPATH` to `~/opt/gopath`. | System toolchain at `/usr/local/go`, user workspace in `~/opt/gopath` (notably `~/opt/gopath/bin`). |
| Node.js (system) | Uses system Node.js pre-installed in image. Falls back to tarball at `~/opt/node` only if system Node absent. npm prefix set to `~/.local`. | `/usr/bin/node` (system) or `~/opt/node/bin/node` (fallback), `~/.local/bin/*` for npm CLIs. |
| Rust (rustup) | `rustup` installer runs with `$CARGO_HOME=$HOME/.local/share/cargo`. | Toolchains and registry caches in `~/.local/share/rustup`/`cargo`, binaries in `~/.local/share/cargo/bin`. |
| Python (pip --user) | `pip install --user <package>` using system Python 3.13. No pip --user created. | Packages in `~/.local/lib/python3.13/site-packages/`, entry points in `~/.local/bin/`. |

## Python OSINT & CTI Tools

All Python tools are installed via `pip install --user` using the system Python 3.13 already present in the Tilix image. No virtual environment is created. Packages land in `~/.local/lib/python3.13/site-packages/` and entry points appear directly in `~/.local/bin/<tool>`.

| Tool | pip package installed | Wrapper command | Notable files |
|------|-----------------------|-----------------|---------------|
| sherlock | `sherlock-project` | `~/.local/bin/sherlock` | pip --user package in `~/.local/lib/python3.13/site-packages/`. |
| holehe | `holehe` | `~/.local/bin/holehe` | pip --user package `holehe`. |
| socialscan | `socialscan` | `~/.local/bin/socialscan` | pip --user package `socialscan`. |
| h8mail | `h8mail` | `~/.local/bin/h8mail` | pip --user package `h8mail`. |
| photon | GitHub clone (`s0md3v/Photon`) + `requirements.txt` | `~/.local/bin/photon` | Source cloned under `~/opt/src/Photon`; wrapper points to user-installed package. |
| sublist3r | `sublist3r` | `~/.local/bin/sublist3r` | pip --user package `sublist3r`. |
| shodan | `shodan` | `~/.local/bin/shodan` | pip --user package `shodan` (with pkg_resources shim). |
| censys | `censys` | `~/.local/bin/censys` | pip --user package `censys`. |
| theHarvester | `theHarvester` | `~/.local/bin/theHarvester` | pip --user package `theHarvester`. |
| spiderfoot | `spiderfoot` | `~/.local/bin/spiderfoot` | pip --user package `spiderfoot`. |
| yara | `yara-python` plus compiled YARA if needed | `~/.local/bin/yara` | If building from source, YARA binaries land in `~/.local/bin`/`~/.local/lib`; Python bindings in `~/.local/lib/python3.13/site-packages/`. |
| wappalyzer | `python-Wappalyzer` | `~/.local/bin/wappalyzer` | pip --user package `python-Wappalyzer`. |

## Go Tools

Go-based applications are built from source via `go install <module>@latest`. Compiled binaries live in `~/opt/gopath/bin`, so ensure that directory stays on `PATH`.

| Tool | `go install` target | Binary produced |
|------|--------------------|-----------------|
| gobuster | `github.com/OJ/gobuster/v3` | `~/opt/gopath/bin/gobuster` |
| ffuf | `github.com/ffuf/ffuf/v2` | `~/opt/gopath/bin/ffuf` |
| httprobe | `github.com/tomnomnom/httprobe` | `~/opt/gopath/bin/httprobe` |
| waybackurls | `github.com/tomnomnom/waybackurls` | `~/opt/gopath/bin/waybackurls` |
| assetfinder | `github.com/tomnomnom/assetfinder` | `~/opt/gopath/bin/assetfinder` |
| subfinder | `github.com/projectdiscovery/subfinder/v2/cmd/subfinder` | `~/opt/gopath/bin/subfinder` |
| nuclei | `github.com/projectdiscovery/nuclei/v3/cmd/nuclei` | `~/opt/gopath/bin/nuclei` |
| virustotal | `github.com/VirusTotal/vt-cli/vt` | `~/opt/gopath/bin/vt` (invoke `vt ...`) |

## Node.js Tools

npm installs run with the prefix set to `~/.local`, so executables appear directly under `~/.local/bin` and supporting packages under `~/.local/lib/node_modules`.

| Tool | npm package | Executable |
|------|-------------|------------|
| trufflehog | `@trufflesecurity/trufflehog` | `~/.local/bin/trufflehog` |
| git-hound | `git-hound` | `~/.local/bin/git-hound` |
| jwt-cracker | `jwt-cracker` | `~/.local/bin/jwt-cracker` |

## Rust Tools

Cargo installs place binaries in `~/.local/share/cargo/bin`. The installer sets `CARGO_HOME`/`RUSTUP_HOME` so no system directories are touched.

| Tool | `cargo install` crate | Binary |
|------|----------------------|--------|
| feroxbuster | `feroxbuster` | `~/.local/share/cargo/bin/feroxbuster` |
| rustscan | `rustscan` | `~/.local/share/cargo/bin/rustscan` |
| ripgrep | `ripgrep` | `~/.local/share/cargo/bin/rg` |
| fd | `fd-find` | `~/.local/share/cargo/bin/fd` |
| bat | `bat` | `~/.local/share/cargo/bin/bat` |
| sd | `sd` | `~/.local/share/cargo/bin/sd` |
| ~~tokei~~ | *Removed in v1.4.0* | — | No pre-built binary available; low security relevance. |
| dog | `dog` | `~/.local/share/cargo/bin/dog` |

## Utility Tools

Utility tools are installed as pre-built binaries into `~/.local/bin` via the system package manager (`apt`) or a static binary fallback. No runtime dependency (Python/Go/Node/Rust) is required.

| Tool | Installation method | Binary | Symlink |
|------|--------------------|----|---------|
| aria2 | `apt-get install aria2` → copy to user-space | `~/.local/bin/aria2c` | `~/.local/bin/aria2 → aria2c` |

**aria2** is a multi-protocol download utility supporting HTTP, HTTPS, FTP, BitTorrent, and Metalink. It was originally included in the Tilix Dockerfile but was commented out; this installer adds it to user-space without requiring root access at runtime.

Common usage patterns:
```bash
# Basic download
aria2c https://example.com/file.iso

# Multi-connection download (8 parallel streams — significantly faster for large files)
aria2c --split=8 --max-connection-per-server=8 https://example.com/large.iso

# Download to specific directory with custom filename
aria2c --dir=/tmp --out=output.iso https://example.com/file.iso

# Resume interrupted download
aria2c --continue=true https://example.com/large.iso

# Download from a list of URLs
aria2c --input-file=urls.txt

# Run as background RPC daemon (for GUI/frontend integration)
aria2c --enable-rpc --rpc-listen-all=true --daemon=true
```

## Re-running or Cleaning Up

- Reinstall any component with `bash install_security_tools.sh <tool-name>`; it reuses the same log locations above.
- Remove a single language stack by deleting its directory (`~/.local/share/cargo`, `~/opt/node`, etc.) and rerunning the installer for that runtime. Note: Go is system-installed and should not be removed.
- Inspect `~/.local/state/install_tools/installation_history.log` to see when a tool was last touched and which log file captured the output.

Use `README.md` and `docs/xdg_setup.md` for usage workflows and environment bootstrap details.

## Web Tools

Web automation tools enable browser-based OSINT, stealth scraping, captcha bypass, and anonymous browsing. All tools are installed to user-space.

| Tool | Installation Method | Binary / Entry Point |
|------|--------------------|--------------------|
| SeleniumBase | `pip install --user seleniumbase` | `~/.local/bin/sbase` |
| Playwright | `pip install --user playwright` + `playwright install chromium` | `~/.local/bin/playwright` + `~/.local/share/ms-playwright/` |
| Yandex Browser | `apt` via `repo.yandex.ru` | `/usr/bin/yandex-browser-beta` + `~/.local/bin/yandex-browser` |
| Tor Browser | tarball from `torproject.org/dist/torbrowser/` | `~/opt/tor-browser/Browser/start-tor-browser` + `~/.local/bin/tor-browser` |
| qTox | AppImage extract from `github.com/TokTok/qTox` | `~/opt/qtox/squashfs-root/AppRun` + `~/.local/bin/qtox` |

### SeleniumBase
Works with the system Chrome already in the Tilix image. Three modes:
- **Standard mode** — fastest, detected by most anti-bot systems
- **UC Mode** (`uc=True`) — undetected-chromedriver base, bypasses most detection
- **CDP Mode** — Chrome DevTools Protocol, stealthiest, handles Cloudflare/reCAPTCHA

Key commands:
```bash
sbase --help                        # CLI help
python3 -m seleniumbase             # Python module usage
```

### Playwright
Cross-browser automation supporting Chromium, Firefox, and WebKit. Browser binaries stored in `~/.local/share/ms-playwright/`.
```bash
playwright install --list           # List installed browsers
playwright install chromium         # Install/update Chromium
playwright codegen https://target   # Record browser actions as code
```

### Yandex Browser
Chromium-based, amd64 only. Installed system-wide via the official Yandex APT repository. Useful for Russian-language OSINT — Yandex Search, reverse image search, Maps, and accessing Russian social media with appropriate locale.

Includes a convenience launcher at `~/.local/bin/yandex-browser` that automatically backgrounds the process using `nohup` + `disown`, so it doesn't block the terminal.
```bash
yandex-browser                      # Launch detached from terminal (requires VNC/display)
yandex-browser-beta --version       # Check version (direct binary)
```

### Tor Browser
Installed to `~/opt/tor-browser/`. All traffic routed through the Tor network. Includes a convenience launcher at `~/.local/bin/tor-browser` that uses Tor's built-in `--detach` flag to separate from the terminal.

**Note:** The Tor Browser bundles its own Tor daemon. For programmatic use (curl, Python requests), start the bundled Tor daemon separately and connect via SOCKS5 on `localhost:9050`.
```bash
tor-browser                         # Launch detached from terminal via --detach (requires VNC)
```

### qTox
Encrypted peer-to-peer chat client using the [Tox protocol](https://tox.chat). No central servers — all communication is end-to-end encrypted. Installed via AppImage extraction (FUSE-free, container-compatible) to `~/opt/qtox/squashfs-root/`.

Includes a convenience launcher at `~/.local/bin/qtox` that automatically backgrounds the process using `nohup` + `disown`, so it doesn't block the terminal.

```bash
qtox                                # Launch qTox (backgrounds automatically)
```
