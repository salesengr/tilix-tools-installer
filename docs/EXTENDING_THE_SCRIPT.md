# Extending `install_security_tools.sh`

**Version:** 1.3.0 (Modular Architecture)

The installer is intentionally data-driven and modular: every tool is described once in `lib/data/tool-definitions.sh`, and the rest of the system consumes that metadata. The modular architecture (v1.3.0) separates concerns across 11 focused library modules, making it easy to extend without touching the main script.

## What Already Exists

- **Build tools:** `cmake`, `github_cli`
- **Runtimes:** `go`, `nodejs`, `rust`, `python_venv`
- **Python apps (12):** sherlock, holehe, socialscan, h8mail, photon, sublist3r, shodan, censys, theHarvester, spiderfoot, yara, wappalyzer
- **Go apps (8):** gobuster, ffuf, httprobe, waybackurls, assetfinder, subfinder, nuclei, virustotal
- **Node.js apps (3):** trufflehog, git-hound, jwt-cracker
- **Rust apps (8):** feroxbuster, rustscan, ripgrep, fd, bat, sd, tokei, dog

## Add or Modify a Tool (v1.3.0 Modular Process)

### File Locations

With the modular architecture, you'll work with these specific files:

| Task | File Location |
|------|---------------|
| **Define tool metadata** | `lib/data/tool-definitions.sh` |
| **Add installation check** | `lib/core/verification.sh` |
| **Create wrapper function** | `lib/installers/tools.sh` |
| **Add to dispatcher** | `lib/ui/orchestration.sh` |
| **Update menu** | `lib/ui/menu.sh` |
| **Add test** | `scripts/test_installation.sh` |

### Step-by-Step Process

1. **Describe it once** (`lib/data/tool-definitions.sh`)
   - Inside `define_tools()` add entries to `TOOL_INFO`, `TOOL_SIZES`, `TOOL_DEPENDENCIES`, and `TOOL_INSTALL_LOCATION`.
   - Use the canonical command name as the key (e.g. `TOOL_INFO[feroxbuster]=...`).

2. **Place it in a category** (`lib/data/tool-definitions.sh`)
   - Append the tool name to the relevant array (`PYTHON_RECON_PASSIVE`, `GO_RECON_ACTIVE`, `NODE_TOOLS`, etc.).
   - Categories power the bulk options (`--python-tools`, menu option 12, etc.).

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

6. **Add test** (`scripts/test_installation.sh`)
   - Add a test function (or reuse `test_python_tool`, `test_go_tool`, etc.) and wire it into `run_all_tests`/`run_specific_test`.

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

# Run the verification suite
bash scripts/test_installation.sh newtool
bash scripts/test_installation.sh               # Everything
```

## Tips and Troubleshooting

- Keep tool names lowercase and shell-friendly; they become menu identifiers and command-line arguments.
- If the installed binary name differs from the tool key, document it in `TOOL_INSTALL_LOCATION` and handle it inside `is_installed()` and the test file.
- When a tool requires multiple prerequisites (e.g., runtime plus an external library), encode them via `TOOL_DEPENDENCIES[newtool]="go libspecial"` and implement `install_libspecial()` like any other tool.
- Capture anything unusual (patches, extra env vars) in comments near the installer function; this doc focuses on the happy path and should stay concise.
