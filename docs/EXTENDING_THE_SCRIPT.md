# Extending `install_security_tools.sh`

> 📖 **Wiki:** For quick reference and discovery, see the [GitHub Wiki](https://github.com/salesengr/tilix-tools-installer/wiki).
> This file is the versioned technical reference — it stays in sync with each release.



**Version:** 1.4.1

The installer is intentionally data-driven and modular: every tool is described once in `lib/data/tool-definitions.sh`, and the rest of the system consumes that metadata. The modular architecture (v1.4.0) separates concerns across 11 focused library modules, making it easy to extend without touching the main script.

## What Already Exists

- **Build tools:** `cmake`, `github_cli`
- **Runtimes:** `go_runtime`, `nodejs`, `rust`, `python_venv`
- **Passive OSINT (12):** sherlock, holehe, socialscan, h8mail, photon, wappalyzer, theHarvester, spiderfoot, waybackurls, assetfinder, subfinder, git-hound
- **Domain Enum (3):** sublist3r, gobuster, ffuf
- **Active Recon (4):** httprobe, rustscan, feroxbuster, nuclei
- **CTI (5):** shodan, censys, yara, trufflehog, virustotal
- **Security Testing (1):** jwt-cracker
- **Utilities (6):** ripgrep, fd, bat, sd, dog, aria2
- **Web Tools (5):** seleniumbase, playwright, yandex_browser, tor_browser, qtox

## Add or Modify a Tool (v1.4.0 Modular Process)

### File Locations

With the modular architecture, you'll work with these specific files:

| Task | File Location |
|------|---------------|
| **Define tool metadata** | `lib/data/tool-definitions.sh` |
| **Add installation check** | `lib/core/verification.sh` |
| **Create wrapper function** | `lib/installers/tools.sh` |
| **Add to dispatcher** | `lib/ui/orchestration.sh` |
| **Update menu** | `lib/ui/menu.sh` |
| **Add smoke check** | `install_security_tools.sh --dry-run <tool>` |

### Step-by-Step Process

1. **Describe it once** (`lib/data/tool-definitions.sh`)
   - Inside `define_tools()` add entries to `TOOL_INFO`, `TOOL_SIZES`, `TOOL_DEPENDENCIES`, and `TOOL_INSTALL_LOCATION`.
   - Use the canonical command name as the key (e.g. `TOOL_INFO[feroxbuster]=...`).

2. **Place it in a category** (`lib/data/tool-definitions.sh`)
   - Append the tool name to the relevant use-case array (`PASSIVE_OSINT`, `DOMAIN_ENUM`, `ACTIVE_RECON`, `CTI_TOOLS`, `UTILITY_TOOLS`, `WEB_TOOLS`).
   - Categories power the bulk options (`--osint-tools`, `--domain-tools`, etc. and menu bulk options 42-48).

3. **Explain how to detect it** (`lib/core/verification.sh`)
   - Update `is_installed()` with the proper file location or `command -v` check.
   - Reference the actual binary name (`vt` for VirusTotal, wrappers in `~/.local/bin/<tool>` for Python/Node.js).

4. **Provide the installer** (`lib/installers/tools.sh`)
   - Prefer the generic helpers from `lib/installers/generic.sh`; only write custom logic when a tool needs bespoke build flags.
   - Keep installers idempotent—rerunning them should safely upgrade or no-op.
   - Example: `install_newtool() { install_python_tool "newtool" "newtool-package"; }`

5. **Register it** (`lib/ui/orchestration.sh` and `lib/ui/menu.sh`)
   - Add a `case` entry for the tool in `install_tool()` function in `lib/ui/orchestration.sh`.
   - Extend the interactive menu (`show_menu` and `process_menu_selection` in `lib/ui/menu.sh`) if you want the tool selectable by number.

6. **Add smoke validation**
   - Validate the new tool path with dry run first:
     - `bash install_security_tools.sh --dry-run <tool>`
   - Then run a real install for just that tool and verify binary/wrapper resolution.

## Generic Installers

The modular architecture provides reusable generic installers in `lib/installers/generic.sh`:

| Stack | Helper | Example |
|-------|--------|---------|
| Python | `install_python_tool "tool" "pip-package"` | `install_shodan() { install_python_tool "shodan" "shodan"; }` |
| Go | `install_go_tool "tool" "module path"` | `install_nuclei() { install_go_tool "nuclei" "github.com/projectdiscovery/nuclei/v3/cmd/nuclei"; }` |
| Node.js | `install_node_tool "tool" "npm-package"` | `install_trufflehog() { install_node_tool "trufflehog" "@trufflesecurity/trufflehog"; }` |
| Rust | `install_rust_tool "tool" "crate"` | `install_ripgrep() { install_rust_tool "ripgrep" "ripgrep"; }` |

These helpers (defined in `lib/installers/generic.sh`) automatically:
- Set the proper environment variables (GOROOT/GOPATH, PATH, npm prefix, CARGO_HOME).
- Create per-tool log files under `~/.local/state/install_tools/logs` (via `lib/core/logging.sh`).
- Append success/failure lines to the installation history.
- Handle errors and return appropriate exit codes.

## Testing Your Changes

```bash
# Dry-run without modifying the system
bash install_security_tools.sh --dry-run newtool

# Install just the new tool (and its dependencies)
bash install_security_tools.sh newtool

# Run dry-run validation first
bash install_security_tools.sh --dry-run newtool

# Then run full dry-run for broader verification
bash install_security_tools.sh --dry-run all

# Optional quality checks
make lint
make fmt-check
```

## GUI Tool Launchers (nohup pattern)

If the tool you're adding opens as a separate GUI window or web server — not a CLI that reads/writes stdin/stdout — create a detached launcher so it doesn't keep the terminal attached.

### When to use this pattern

- **GUI window tools:** browsers, chat clients, desktop apps (Yandex Browser, qTox, Chrome)
- **Web server tools:** tools that start a local HTTP server the user accesses via browser (SpiderFoot)

### Standard launcher template

```bash
cat > "$HOME/.local/bin/mytool" << 'WRAPPER'
#!/usr/bin/env bash
# mytool launcher — runs detached from terminal
nohup /path/to/mytool-binary "$@" &>/dev/null &
disown
WRAPPER
chmod +x "$HOME/.local/bin/mytool"
```

### Web server variant

For tools that start a local web server, print the URL and how to open it before detaching:

```bash
cat > "$HOME/.local/bin/mytool" << 'WRAPPER'
#!/usr/bin/env bash
# mytool launcher — starts web UI detached from terminal
MYTOOL_HOST="${MYTOOL_HOST:-127.0.0.1}"
MYTOOL_PORT="${MYTOOL_PORT:-8080}"

echo ""
echo "Starting mytool web UI..."
echo "  URL : http://${MYTOOL_HOST}:${MYTOOL_PORT}"
echo ""
echo "  Open in Chrome:"
echo "  chrome http://${MYTOOL_HOST}:${MYTOOL_PORT}"
echo ""

nohup /path/to/mytool-binary --listen "${MYTOOL_HOST}:${MYTOOL_PORT}" "$@" &>/dev/null &
MYTOOL_PID=$!
disown

echo "mytool started (PID ${MYTOOL_PID})"
echo "To stop: kill ${MYTOOL_PID}  or  pkill -f mytool-binary"
echo ""
WRAPPER
chmod +x "$HOME/.local/bin/mytool"
```

### Notes

- Always use `nohup ... &>/dev/null &` followed by `disown` — this combination ignores SIGHUP, suppresses output, and removes the process from the shell's job table.
- Set `TOOL_INSTALL_LOCATION` in `tool-definitions.sh` to the wrapper path (`$HOME/.local/bin/mytool`), not the underlying binary.
- The `is_installed()` check in `verification.sh` should check for the wrapper file, not the system binary, so verification reflects the full setup.
- For tools with configurable ports, expose them via environment variables (`MYTOOL_PORT`) so they can be overridden without editing the wrapper.

---

## Tips and Troubleshooting

- Keep tool names lowercase and shell-friendly; they become menu identifiers and command-line arguments.
- If the installed binary name differs from the tool key, document it in `TOOL_INSTALL_LOCATION` and handle it inside `is_installed()` and the test file.
- When a tool requires multiple prerequisites (e.g., runtime plus an external library), encode them via `TOOL_DEPENDENCIES[newtool]="go libspecial"` and implement `install_libspecial()` like any other tool.
- Capture anything unusual (patches, extra env vars) in comments near the installer function; this doc focuses on the happy path and should stay concise.
