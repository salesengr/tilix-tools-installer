# User-Space Security Tool Research (OSINT / SOC / CTI / IR)

> Scope: tools installable without `sudo` by default (pipx/pip user, standalone binaries, Go/Cargo user-space, etc.).
>
> Source verification method: `web_fetch` against official project repos/docs. `web_search` could not be used in this environment due missing Brave API key (`missing_brave_api_key`).

## 1) OSINT collectors / analysts

### [High] SpiderFoot
- **Why useful:** Broad OSINT automation (domains, IPs, emails, social, breach and reputation pivots) with many modules.
- **Install method:** `pipx install spiderfoot`
- **User-space suitability:** Excellent via pipx/venv; no root required.
- **Official URL:** https://github.com/smicallef/spiderfoot
- **Quick starter:** `spiderfoot -l 127.0.0.1:5001`

### [High] theHarvester
- **Why useful:** Recon for emails/subdomains/hosts from many passive data sources.
- **Install method:** `pipx install theHarvester` (or clone + `uv sync` upstream)
- **User-space suitability:** Good in pipx/venv; API keys optional per source.
- **Official URL:** https://github.com/laramies/theHarvester
- **Quick starter:** `theHarvester -d example.com -b anubis,crtsh`

### [High] Maigret
- **Why useful:** Username-centric OSINT across thousands of sites; useful for persona mapping.
- **Install method:** `pipx install maigret`
- **User-space suitability:** Excellent; no-root Python install.
- **Official URL:** https://github.com/soxoj/maigret
- **Quick starter:** `maigret target_username --html`

### [High] subfinder
- **Why useful:** Fast passive subdomain discovery; good building block for attack surface mapping.
- **Install method:** `go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest`
- **User-space suitability:** Excellent with `$GOPATH/bin` in user PATH.
- **Official URL:** https://github.com/projectdiscovery/subfinder
- **Quick starter:** `subfinder -d example.com -silent`

---

## 2) SOC analysts (detection / triage)

### [High] sigma-cli
- **Why useful:** Convert/manage Sigma rules for SIEM/EDR backends; practical for detection engineering.
- **Install method:** `pipx install sigma-cli`
- **User-space suitability:** Excellent; plugin model works in user profile.
- **Official URL:** https://github.com/SigmaHQ/sigma-cli
- **Quick starter:** `sigma list targets`

### [High] Chainsaw
- **Why useful:** Very fast EVTX/MFT hunting and Sigma-based triage for Windows investigations.
- **Install method:** Download release binary (or `cargo install chainsaw` if preferred)
- **User-space suitability:** Excellent as standalone binary in `~/.local/bin`.
- **Official URL:** https://github.com/WithSecureLabs/chainsaw
- **Quick starter:** `chainsaw hunt ./evtx/ -s ./sigma/ --mapping ./mappings/sigma-event-logs-all.yml`

### [High] Hayabusa
- **Why useful:** High-speed Windows event-log timeline generation and Sigma hunting.
- **Install method:** Download release binary from GitHub Releases.
- **User-space suitability:** Excellent (single binary workflow).
- **Official URL:** https://github.com/Yamato-Security/hayabusa
- **Quick starter:** `hayabusa csv-timeline -d ./logs -o timeline.csv`

---

## 3) CTI analysts

### [High] mitreattack-python
- **Why useful:** Programmatic ATT&CK/STIX workflows, mapping detections to techniques, enrichment pipelines.
- **Install method:** `pipx install mitreattack-python` (or `python -m pip install --user mitreattack-python`)
- **User-space suitability:** Excellent in pipx/user site-packages.
- **Official URL:** https://github.com/mitre-attack/mitreattack-python
- **Quick starter:** `python -c "from mitreattack.stix20 import MitreAttackData; print('ok')"`

### [High] stix2 (cti-python-stix2)
- **Why useful:** Canonical Python STIX 2 object/serialization tooling for CTI pipelines.
- **Install method:** `pipx install stix2` (or `python -m pip install --user stix2`)
- **User-space suitability:** Excellent; pure Python package.
- **Official URL:** https://pypi.org/project/stix2/
- **Quick starter:** `python -c "from stix2 import Indicator; print(Indicator(name='x', pattern_type='stix', pattern='[file:hashes.MD5 = \"d41d8cd98f00b204e9800998ecf8427e\"]', indicator_types=['malicious-activity']))"`

### [High] pycti (OpenCTI Python client)
- **Why useful:** Automates OpenCTI ingestion, enrichment, and object operations for intel teams.
- **Install method:** `pipx install pycti`
- **User-space suitability:** Excellent; no root needed. Requires reachable OpenCTI instance + token.
- **Official URL:** https://pypi.org/project/pycti/
- **Quick starter:** `python -c "import pycti; print(pycti.__name__)"`

---

## 4) Incident response responders

### [High] Velociraptor
- **Why useful:** Endpoint collection, VQL hunts, enterprise-scale triage and artifact acquisition.
- **Install method:** Download platform binary from releases.
- **User-space suitability:** Good for local triage/server testing in user dirs; fleet deployment may need privileged service modes.
- **Official URL:** https://github.com/Velocidex/velociraptor
- **Quick starter:** `velociraptor gui`

### [High] Volatility 3
- **Why useful:** Memory forensics framework for extracting runtime artifacts from RAM images.
- **Install method:** `pipx install volatility3` (or clone + `pip install --user -e .[full]`)
- **User-space suitability:** Excellent in virtualenv/pipx for analyst workstation use.
- **Official URL:** https://github.com/volatilityfoundation/volatility3
- **Quick starter:** `vol -h`

### [High] YARA
- **Why useful:** Rule-based malware/content pattern matching for triage and hunting.
- **Install method:** standalone binary from distro/release, or compile in user prefix (`./configure --prefix=$HOME/.local && make && make install`)
- **User-space suitability:** Medium-good; compile path works without sudo but needs build deps.
- **Official URL:** https://github.com/VirusTotal/yara
- **Quick starter:** `yara rules.yar sample.bin`

### [Medium] MVT (Mobile Verification Toolkit)
- **Why useful:** Mobile compromise triage workflows for Android/iOS artifacts and IOC checks.
- **Install method:** `pipx install mvt`
- **User-space suitability:** Good in Python user-space; data acquisition from devices can require extra platform tooling/permissions.
- **Official URL:** https://github.com/mvt-project/mvt
- **Quick starter:** `mvt-android --help`

---

## Recommended starter bundle (balanced, 14 tools)

1. SpiderFoot
2. theHarvester
3. Maigret
4. subfinder
5. sigma-cli
6. Chainsaw
7. Hayabusa
8. mitreattack-python
9. stix2
10. pycti
11. Velociraptor
12. Volatility 3
13. YARA
14. MVT

**Why this bundle:** covers passive collection, rule engineering, Windows triage, CTI data handling, memory and endpoint IR, and mobile triage while staying mostly user-space friendly.

## Caveats / operational notes

- **API keys / paid tiers:**
  - theHarvester, SpiderFoot, subfinder can use many external sources with API keys and rate limits.
  - Some providers are paid or heavily rate-limited on free tiers.
- **Legal / ToS:**
  - Respect provider terms, robots rules, and jurisdictional privacy/computer misuse laws.
  - OSINT collection can still violate ToS or local law if done aggressively or without authorization.
- **Data sensitivity:**
  - CTI/IR outputs may include PII, credentials, or victim data—store and share under policy.
- **Privilege boundaries:**
  - User-space install is possible for most tools, but some live-response actions (kernel memory/device access, endpoint services) may still require elevated rights at execution time.

## 5) Analyst communication/collaboration (P2P / alt-network)

> Added per user request. Focus: user-space installability + operational fit for SOC/CTI teams.

### [High] Element Desktop (Matrix)
- **Why useful:** Strong team collaboration, E2EE support, bridges/integrations available; good for distributed analyst cells.
- **Install method:** Official Linux packages and downloadable desktop builds; can also run user-space unpacked builds.
- **User-space suitability:** Good (no-root execution possible if using portable unpack/extracted build).
- **Official URL:** https://github.com/element-hq/element-desktop
- **Quick starter:** `element-desktop` (or run extracted binary from user dir)

### [High] Signal Desktop
- **Why useful:** Widely used secure messaging; useful out-of-band coordination channel.
- **Install method:** Official desktop releases/packages.
- **User-space suitability:** Medium-good (portable/user-space execution possible depending on packaging policy/environment).
- **Official URL:** https://github.com/signalapp/Signal-Desktop
- **Quick starter:** `signal-desktop`

### [Medium] Session Desktop
- **Why useful:** Alt-network private messenger model (onion-routed architecture); useful where metadata resistance is prioritized.
- **Install method:** Official download page provides desktop binaries; verify signatures before use.
- **User-space suitability:** Good for non-root execution from user directories.
- **Official URL:** https://getsession.org/download
- **Quick starter:** launch downloaded desktop binary/app bundle

### [Medium] qTox (TokTok fork)
- **Why useful:** Encrypted P2P Tox communications; no central account model.
- **Install method:** Use TokTok-maintained fork releases/flatpak/build instructions.
- **User-space suitability:** Good for portable/flatpak/user-local execution.
- **Official URL:** https://github.com/TokTok/qTox
- **Quick starter:** `qtox`
- **Maintenance note:** Original `qTox/qTox` repo states unmaintained and points to TokTok fork.

### [Medium] Briar (primarily mobile, crisis/offline-friendly)
- **Why useful:** Resilient sync model (Tor/Bluetooth/Wi-Fi) valuable for degraded-network scenarios.
- **Install method:** Official app distributions (Android-focused); desktop analyst workflows are limited.
- **User-space suitability:** Primarily relevant on mobile endpoints rather than Linux SOC workstations.
- **Official URL:** https://github.com/briar/briar
- **Quick starter:** Install Briar on supported mobile platform

## User-space packaging patterns (portable deployment)

- **AppImage (Linux):** single executable artifact, no root install required.
  - Typical run flow: `chmod +x tool.AppImage && ./tool.AppImage`
  - References: https://appimage.org/ and https://docs.appimage.org/introduction/quickstart.html
- **Standalone static binaries:** place in `~/.local/bin`, set executable bit.
- **Portable tar/zip builds:** unpack under `~/tools/<name>` and run binary directly.
- **Language user-space package managers:** `pipx`, `pip --user`, `go install`, `cargo install`, `npm --prefix ~/.local`.

## Security/operational caveats for SOC/CTI teams

- **Evidence handling:** do not discuss case-sensitive IOCs or victim identifiers in uncontrolled external networks.
- **Retention/governance:** decentralized or P2P tools may not satisfy enterprise retention/eDiscovery requirements.
- **Identity assurance:** some alt-network systems are pseudonymous; enforce analyst identity verification out-of-band.
- **Endpoint hardening:** run portable apps with least privilege; restrict plugin loading and uncontrolled auto-updates.
- **Supply-chain checks:** prefer official project downloads, verify checksums/signatures, pin versions for investigations.
- **Network policy:** coordinate with SOC network controls (proxy, TLS inspection, Tor restrictions) before operational use.

## Confidence rubric

- **High:** active project + clear install path documented in official repo/docs.
- **Medium:** install is workable user-space but dependencies/operational friction likely.
- **Low:** uncertain maintenance or unclear install path (none selected here intentionally).