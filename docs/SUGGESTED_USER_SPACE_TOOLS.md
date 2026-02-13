# Suggested User-Space Tools

This page gives a quick, customer-facing shortlist of security tools that can be installed without `sudo` in many environments.

## Suggested categories and examples

- **OSINT:** SpiderFoot, theHarvester, Maigret, subfinder
- **SOC triage/detections:** sigma-cli, Chainsaw, Hayabusa
- **CTI workflows:** mitreattack-python, stix2, pycti
- **Incident response:** Velociraptor, Volatility 3, YARA, MVT

## Install style (typical)

- `pipx install <tool>`
- `python -m pip install --user <tool>`
- `go install <module>@latest`
- Download standalone binaries to `~/.local/bin`

## Notes

- Some tools rely on external APIs that require keys and may have paid tiers/rate limits.
- Always respect source terms of service and applicable laws for OSINT collection and scraping.
- User-space install does **not** always mean privileged-free execution for all runtime actions.

## Maintainer reference

Detailed evaluated notes (confidence tags, quick commands, caveats) are tracked internally:

- `../.internal/USER_SPACE_TOOL_RESEARCH.md`
