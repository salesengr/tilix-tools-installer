# Extending `install_security_tools.sh`

The installer is intentionally data-driven: every tool is described once inside `define_tools()`, and the rest of the script consumes that metadata. Follow the checklist below to add or adjust tools without duplicating work.

## What Already Exists

- **Build tools:** `cmake`, `github_cli`
- **Runtimes:** `go`, `nodejs`, `rust`, `python_venv`
- **Python apps (12):** sherlock, holehe, socialscan, h8mail, photon, sublist3r, shodan, censys, theHarvester, spiderfoot, yara, wappalyzer
- **Go apps (8):** gobuster, ffuf, httprobe, waybackurls, assetfinder, subfinder, nuclei, virustotal
- **Node.js apps (3):** trufflehog, git-hound, jwt-cracker
- **Rust apps (8):** feroxbuster, rustscan, ripgrep, fd, bat, sd, tokei, dog

## Add or Modify a Tool

1. **Describe it once**
   - Inside `define_tools()` add entries to `TOOL_INFO`, `TOOL_SIZES`, `TOOL_DEPENDENCIES`, and `TOOL_INSTALL_LOCATION`.
   - Use the canonical command name as the key (e.g. `TOOL_INFO[feroxbuster]=...`).

2. **Place it in a category**
   - Append the tool name to the relevant array (`PYTHON_RECON_PASSIVE`, `GO_RECON_ACTIVE`, `NODE_TOOLS`, etc.).
   - Categories power the bulk options (`--python-tools`, menu option 12, etc.).

3. **Explain how to detect it**
   - Update `is_installed()` with the proper file location or `command -v` check.
   - Reference the actual binary name (`vt` for VirusTotal, wrappers in `~/.local/bin/<tool>` for Python/Node.js).

4. **Provide the installer**
   - Prefer the generic helpers shown below; only write custom logic when a tool needs bespoke build flags.
   - Keep installers idempotent—rerunning them should safely upgrade or no-op.

5. **Register it**
   - Add a `case` entry for the tool in `install_tool()`.
   - Extend the interactive menu (`show_menu` and `process_menu_selection`) if you want the tool selectable by number.
   - Add a test function in `scripts/test_installation.sh` (or reuse `test_python_tool`, `test_go_tool`, etc.) and wire it into `run_all_tests`/`run_specific_test`.

## Generic Installers

| Stack | Helper | Example |
|-------|--------|---------|
| Python | `install_python_tool "tool" "pip-package"` | `install_shodan() { install_python_tool "shodan" "shodan"; }` |
| Go | `install_go_tool "tool" "module path"` | `install_nuclei() { install_go_tool "nuclei" "github.com/projectdiscovery/nuclei/v3/cmd/nuclei"; }` |
| Node.js | `install_node_tool "tool" "npm-package"` | `install_trufflehog() { install_node_tool "trufflehog" "@trufflesecurity/trufflehog"; }` |
| Rust | `install_rust_tool "tool" "crate"` | `install_ripgrep() { install_rust_tool "ripgrep" "ripgrep"; }` |

These helpers automatically:
- Set the proper environment variables (GOROOT/GOPATH, PATH, npm prefix, CARGO_HOME).
- Create per-tool log files under `~/.local/state/install_tools/logs`.
- Append success/failure lines to the installation history.

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
