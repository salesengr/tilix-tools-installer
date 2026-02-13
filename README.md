# Tilix Tools Installer

User-space-first installer for common security/developer tooling in locked-down Linux environments (no sudo required for default flow).

## What this repo gives customers

- Safe default install location: `~/.local/bin`
- Repeatable installer entrypoint (`installer.sh`)
- Tool install script with preflight checks (`install_security_tools.sh`)
- Guidance for extending with custom tools (`scripts/tools.d/`)
- Troubleshooting + environment checks for non-root images

## Quick start

```bash
# optional: run explicit preflight checks first
bash scripts/preflight_env.sh

# list supported tools
bash installer.sh --list

# install defaults (or pass tool names)
bash installer.sh all
bash installer.sh waybackurls assetfinder

# preview without changes
bash installer.sh --dry-run all
```

Verify:

```bash
command -v waybackurls assetfinder
waybackurls --help
assetfinder --help
```

Tool sources (current built-ins):
- `waybackurls`: [GitHub](https://github.com/tomnomnom/waybackurls)
- `assetfinder`: [GitHub](https://github.com/tomnomnom/assetfinder)

If tools are not found, add:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Extend with your own tools

1. Copy `scripts/tools.d/example_custom_tool.sh`
2. Add `install_<toolname>()`
3. Append the name into `TOOL_LIST+=(toolname)`
4. Run `bash installer.sh --list` to confirm registration

Detailed guidance: [`docs/CUSTOM_TOOL_TEMPLATE.md`](docs/CUSTOM_TOOL_TEMPLATE.md)

## Customer docs

- User-space installation and troubleshooting: [`docs/USER_SPACE_INSTALLS.md`](docs/USER_SPACE_INSTALLS.md)
- Preflight vs legacy environment bootstrap comparison: [`docs/PREFLIGHT_VS_XDG_SETUP.md`](docs/PREFLIGHT_VS_XDG_SETUP.md)
- Maintainer/release rules: [`CLAUDE.md`](CLAUDE.md)

## Version summary

- **2.1.0**: Public-release prep with installer entrypoints, extension scaffolding, and customer install/troubleshooting flow.
- **2.0.0**: Major documentation refresh and release framing for user-space-first operation.

For full release details, see [`CHANGELOG.md`](CHANGELOG.md).
