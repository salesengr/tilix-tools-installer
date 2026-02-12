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

- Architecture and OS supported.
- Downloader available (`curl` or `wget`).
- Archive tools available (`tar`, `unzip` if needed).
- Destination is writable (`$HOME/.local` by default).
- Network access to source URLs.

## 4) Validate install success

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
