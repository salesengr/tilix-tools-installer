# User-Space Installs (No sudo)

This project is designed to work in restricted environments where you may not have root access.

## 1) Use a user-owned prefix

Recommended default:

```bash
export TOOLS_PREFIX="${HOME}/.local"
mkdir -p "${TOOLS_PREFIX}/bin"
```

Ensure PATH includes it:

```bash
export PATH="${TOOLS_PREFIX}/bin:${PATH}"
```

Persist for future shells (example for bash):

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
```

## 2) Check what is already installed in the base image

Before installing, verify existing tools:

```bash
for t in curl wget tar unzip git bash; do
  printf "%-8s -> %s\n" "$t" "$(command -v "$t" || echo missing)"
done
```

Check versions:

```bash
<tool> --version
```

## 3) Preflight checklist

Run the preflight helper (safe to run repeatedly):

```bash
bash scripts/preflight_env.sh
# preview only
bash scripts/preflight_env.sh --dry-run --verbose
```

What it checks:
- Required shell commands are present.
- Downloader available (`curl` or `wget`).
- User-space destination directories exist (or are created).
- Destination directories are writable (`$HOME/.local` by default).

## 4) Built-in tools in this installer (current)

The current `install_security_tools.sh` ships with these tool installers:

### `waybackurls`
- Source: [GitHub](https://github.com/tomnomnom/waybackurls)
- Install (user space):

```bash
bash installer.sh waybackurls
```

- Quick use:

```bash
echo example.com | waybackurls
cat domains.txt | waybackurls > urls.txt
```

- Docs: project README + package docs: [pkg.go.dev](https://pkg.go.dev/github.com/tomnomnom/waybackurls)

### `assetfinder`
- Source: [GitHub](https://github.com/tomnomnom/assetfinder)
- Install (user space):

```bash
bash installer.sh assetfinder
```

- Quick use:

```bash
assetfinder --subs-only example.com
assetfinder example.com > assets.txt
```

- Docs: project README + package docs: [pkg.go.dev](https://pkg.go.dev/github.com/tomnomnom/assetfinder)

## 5) Validate install success

```bash
command -v <tool>
<tool> --version
```

If tool is not found:
- re-check PATH in current shell (`echo "$PATH"`),
- confirm binary permissions (`chmod +x ...`),
- reopen shell or source profile file.

## Troubleshooting

### "Permission denied"
Install into `${HOME}/.local` or another user-owned directory. Avoid `/usr/local` without root.

### "command not found" after install
PATH is not updated in active shell. Run:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

Then persist in your shell profile.

### Download failures / TLS / proxy issues
- Test with `curl -I <url>`.
- Check corporate proxy environment variables (`HTTP_PROXY`, `HTTPS_PROXY`, `NO_PROXY`).
- Retry with alternate source mirror if available.

### Wrong architecture binary
Verify with:

```bash
uname -m
uname -s
```

Install matching artifact only.

## High-quality external references

- XDG Base Directory Specification: https://specifications.freedesktop.org/basedir-spec/latest/
- GNU Bash startup files: https://www.gnu.org/software/bash/manual/bash.html#Bash-Startup-Files
- Arch Wiki PATH: https://wiki.archlinux.org/title/Environment_variables
- Debian Policy (filesystem/layout context): https://www.debian.org/doc/debian-policy/
- ShellCheck (shell linting): https://www.shellcheck.net/
