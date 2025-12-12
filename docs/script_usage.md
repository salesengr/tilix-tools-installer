# Using the Tilix Installer Scripts

This guide condenses everything you need to operate the helper scripts that ship with Tilix. Follow the steps sequentially the first time, then jump to the sections you need for maintenance.

## 1. Bootstrap the Environment (`xdg_setup.sh`)

Run inside the repository root:

```bash
bash xdg_setup.sh
source ~/.bashrc
```

What it does:
- Builds the XDG directory tree under `~/.local`, `~/.config`, `~/.cache`, and `~/.local/state`
- Configures language-specific environment variables (Go, Node.js, Python, Rust, npm, pip)
- Adds helper aliases such as `tools-venv` (activate the shared Python virtualenv)
- Creates documentation at `~/.local/share/XDG_STRUCTURE.md`

Re-run this script if you need to repair the directory tree or you want to regenerate `.bashrc` entries after a manual edit.

## 2. Install and Update Tools (`install_security_tools.sh`)

### Interactive Menu

```bash
bash install_security_tools.sh
```

Use the arrow keys/number prompts to:
- Install individual tools, categories, or every option (`30`)
- Display currently installed tools (`40`)
- Inspect log locations (`41`)

### Command-Line Mode

```bash
# Install explicit tools
bash install_security_tools.sh sherlock nuclei feroxbuster

# Category helpers
bash install_security_tools.sh --python-tools
bash install_security_tools.sh --go-tools
bash install_security_tools.sh --node-tools
bash install_security_tools.sh --rust-tools

# Install everything without prompts
bash install_security_tools.sh all

# Preview without changing the system
bash install_security_tools.sh --dry-run gobuster ffuf
```

Important behaviors:
- Each tool logs to `~/.local/state/install_tools/logs/<tool>-<timestamp>.log`
- Failed installs are referenced in `~/.local/state/install_tools/installation_history.log`
- Dependencies (for example `python_venv`, `go`, `nodejs`, `rust`) are installed automatically when missing
- Go tools land in `~/opt/gopath/bin`, Node.js tools in `~/.local/bin`, Rust tools in `~/.local/share/cargo/bin`, and Python tools inside the shared virtualenv (`~/.local/share/virtualenvs/tools`)

## 3. Verify Installations (`test_installation.sh`)

```bash
# Test everything that is currently in PATH
bash test_installation.sh

# Test a single tool
bash test_installation.sh sherlock
```

What gets checked:
- Presence of binaries/wrappers
- Ability to run `--version` or `--help`
- Key environment variables (`GOROOT`, `GOPATH`, `CARGO_HOME`, etc.)

Use this script after large installations or when you troubleshoot PATH issues.

## 4. Maintenance Tips

- **Updating tools:** rerun `install_security_tools.sh <tool name>` to pull the latest release. Go/Rust builds always compile the newest tag because the script uses the `@latest` specifiers.
- **Removing a stack:** delete its install directory (`~/opt/go`, `~/.local/share/cargo`, `~/.local/share/virtualenvs/tools`, etc.) and rerun the installer for that runtime or tool group.
- **Log review:** `tail -n 50 ~/.local/state/install_tools/installation_history.log` shows recent successes/failures; open the referenced log files for full command output.
- **Environment reload:** after any script run, execute `source ~/.bashrc` to refresh PATH/variables in the current shell session.

For a per-tool breakdown of what gets copied where, see `docs/tool_installation_summary.md`.
