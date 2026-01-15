# Tool Installation Summary

This reference maps the actions performed by `install_security_tools.sh` to the files and directories that appear on disk. Use it to verify installations, clean up specific stacks, or to explain to approvers exactly what the script touches.

## Directory Legend

The installer keeps everything inside your home directory:

- `~/.local/bin` – user executables and Python/Node wrappers
- `~/.local/share` – Python virtual environments, shared data, Cargo metadata
- `~/.local/state/install_tools` – installer logs and history
- `/usr/local/go` – System Go installation (GOROOT)
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
| Go 1.21.5 | System-wide installation expected at `/usr/local/go`; `GOPATH` is set to `~/opt/gopath` for user workspace. | System toolchain at `/usr/local/go`, user workspace in `~/opt/gopath` (notably `~/opt/gopath/bin`). |
| Node.js 20.10.0 | Node tarball extracted to `~/opt/node`. npm global prefix points to `~/.local`, so binaries are linked in `~/.local/bin` and packages in `~/.local/lib/node_modules`. | `~/opt/node/bin/node`, `~/.local/bin/*` for npm-installed CLIs. |
| Rust (rustup) | `rustup` installer runs with `$CARGO_HOME=$HOME/.local/share/cargo`. | Toolchains and registry caches in `~/.local/share/rustup`/`cargo`, binaries in `~/.local/share/cargo/bin`. |
| Python virtual environment | `python3 -m venv $XDG_DATA_HOME/virtualenvs/tools`, pip upgraded, wrapper alias `tools-venv` provided by `xdg_setup.sh`. | Virtual environment at `~/.local/share/virtualenvs/tools`, activation script plus site-packages. |

## Python OSINT & CTI Tools

All Python applications install into the shared virtual environment above. Each gets a wrapper in `~/.local/bin/<tool>` so you never have to activate the venv manually.

| Tool | pip package installed | Wrapper command | Notable files |
|------|-----------------------|-----------------|---------------|
| sherlock | `sherlock-project` | `~/.local/bin/sherlock` | Modules under `~/.local/share/virtualenvs/tools/lib/python*/site-packages/sherlock`. |
| holehe | `holehe` | `~/.local/bin/holehe` | Same venv, package `holehe`. |
| socialscan | `socialscan` | `~/.local/bin/socialscan` | venv package `socialscan`. |
| h8mail | `h8mail` | `~/.local/bin/h8mail` | venv package `h8mail`. |
| photon | `photon-python` | `~/.local/bin/photon` | venv package `photon`. |
| sublist3r | `sublist3r` | `~/.local/bin/sublist3r` | venv package `sublist3r`. |
| shodan | `shodan` | `~/.local/bin/shodan` | venv package `shodan`. |
| censys | `censys` | `~/.local/bin/censys` | venv package `censys`. |
| theHarvester | `theHarvester` | `~/.local/bin/theHarvester` | venv package `theHarvester`. |
| spiderfoot | `spiderfoot` | `~/.local/bin/spiderfoot` | venv package `spiderfoot`. |
| yara | `yara-python` plus compiled YARA if needed | `~/.local/bin/yara` | If building from source, YARA binaries land in `~/.local/bin`/`~/.local/lib`; Python bindings live in the venv. |
| wappalyzer | `python-Wappalyzer` | `~/.local/bin/wappalyzer` | venv package `Wappalyzer`. |

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
| tokei | `tokei` | `~/.local/share/cargo/bin/tokei` |
| dog | `dog` | `~/.local/share/cargo/bin/dog` |

## Re-running or Cleaning Up

- Reinstall any component with `bash install_security_tools.sh <tool-name>`; it reuses the same log locations above.
- Remove a single language stack by deleting its directory (`~/.local/share/cargo`, `~/opt/node`, etc.) and rerunning the installer for that runtime. Note: Go is system-installed and should not be removed.
- Inspect `~/.local/state/install_tools/installation_history.log` to see when a tool was last touched and which log file captured the output.

Use `README.md` and `docs/xdg_setup.md` for usage workflows and environment bootstrap details.
