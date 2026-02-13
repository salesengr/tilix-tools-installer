# Suggested User-Space Tools

This page gives a quick, customer-facing shortlist of security tools that can often be installed and run without `sudo`.

## Suggested categories and examples

- **OSINT:** SpiderFoot, theHarvester, Maigret, subfinder
- **SOC triage/detections:** sigma-cli, Chainsaw, Hayabusa
- **CTI workflows:** mitreattack-python, stix2, pycti
- **Incident response:** Velociraptor, Volatility 3, YARA, MVT
- **Malware reversing:** Ghidra
- **Local email/phishing analysis:** Thunderbird (for `.eml` review)
- **Lightweight local sandboxing:** Firejail, Bubblewrap (`bwrap`), nsjail, `systemd-run --user`
- **Analyst comms (secure/alt-network):** Element Desktop, Signal Desktop, Session (with policy review), qTox (TokTok fork)

## Install style (typical)

- `pipx install <tool>`
- `python -m pip install --user <tool>`
- `go install <module>@latest`
- Download standalone binaries to `~/.local/bin`
- AppImage/portable app workflow (`chmod +x app.AppImage && ./app.AppImage`)

## Focus additions

### Ghidra (malware reversing)

- **Official:** https://ghidra-sre.org/ · https://github.com/NationalSecurityAgency/ghidra
- **Install pattern (user-space):** Download release ZIP/TAR, extract to `~/tools/ghidra`, run `ghidraRun`.
- **Example:**
  ```bash
  mkdir -p ~/tools && cd ~/tools
  # place downloaded ghidra_<ver>_PUBLIC_*.zip here
  unzip ghidra_*_PUBLIC_*.zip
  ~/tools/ghidra_*/ghidraRun
  ```
- **Caveat:** Requires Java (OpenJDK 17+ for current releases). If Java is missing, Ghidra will not start.

### Thunderbird (local email/phishing analysis)

- **Official:** https://www.thunderbird.net/ · https://support.mozilla.org/en-US/products/thunderbird
- **What it helps with:** Open suspicious `.eml` files in an email client view (headers, body, links, attachments) without executing webmail scripts.
- **Example:**
  ```bash
  thunderbird /path/to/message.eml
  ```
- **Archive notes:** `.eml` is directly supported. MBOX/maildir archives usually need import/add-on workflows first.
- **Caveat:** Opening an email client is not a malware sandbox by itself—avoid opening risky attachments outside isolation.

### Practical default sandbox approach for suspicious files

- **Recommended default:** Use `firejail` profile + disposable work directory first; fall back to `bwrap`/`nsjail`/`systemd-run --user` when Firejail is unavailable.
- **Official docs:**
  - Firejail: https://firejail.wordpress.com/ · https://github.com/netblue30/firejail
  - Bubblewrap: https://github.com/containers/bubblewrap
  - nsjail: https://github.com/google/nsjail
  - systemd-run: https://www.freedesktop.org/software/systemd/man/systemd-run.html
- **Quick examples:**
  ```bash
  # Firejail: desktop file opener in a restricted home/net namespace profile
  firejail --private --net=none xdg-open suspicious.pdf

  # Bubblewrap: no-network shell with temporary writable root pieces
  bwrap --unshare-all --ro-bind /usr /usr --dev /dev --proc /proc --tmpfs /tmp /bin/sh

  # nsjail: simple no-network process jail
  nsjail -Mo --disable_proc --iface_no_lo -- /usr/bin/file suspicious.bin

  # systemd --user transient unit with hardening knobs
  systemd-run --user --pty -p PrivateTmp=yes -p ProtectHome=yes -p NoNewPrivileges=yes /usr/bin/less suspicious.txt
  ```
- **Caveat:** These are containment layers, not perfect malware detonation sandboxes. Kernel-level escapes and parser exploits remain possible; use throwaway VMs for high-risk samples.

## Notes

- Some tools rely on external APIs that require keys and may have paid tiers/rate limits.
- Always respect source terms of service and applicable laws for OSINT collection and scraping.
- User-space install does **not** always mean privileged-free execution for all runtime actions.
- For SOC/CTI operations, validate retention/eDiscovery, identity assurance, and data-handling policy before using P2P/alt-network chat tools.

## Maintainer reference

Detailed evaluated notes (confidence tags, quick commands, caveats) are tracked internally:

- `../.internal/USER_SPACE_TOOL_RESEARCH.md`
