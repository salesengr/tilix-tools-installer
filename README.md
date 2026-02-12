# Tilix Tools Installer

Practical scripts and guidance for installing developer tools in Linux environments, with a **user-space first** approach (no required sudo).

## Quick start

1. Review user-space setup guide: [`docs/USER_SPACE_INSTALLS.md`](docs/USER_SPACE_INSTALLS.md)
2. Choose/install tools using project scripts (when present).
3. Verify PATH and tool resolution with:

```bash
command -v <tool>
<tool> --version
```

## Principles

- Default installation target should be `${HOME}/.local` unless explicitly overridden.
- Installer behavior should be idempotent and safe to rerun.
- Documentation and script behavior must stay in sync.

## Add a custom tool installer

Use the extension template: [`docs/CUSTOM_TOOL_TEMPLATE.md`](docs/CUSTOM_TOOL_TEMPLATE.md)

It includes:
- preflight checks,
- user-space install defaults,
- PATH/wrapper validation,
- version pinning hooks.

## Troubleshooting

See: [`docs/USER_SPACE_INSTALLS.md#troubleshooting`](docs/USER_SPACE_INSTALLS.md#troubleshooting)

## Maintainer rules

Project maintenance and contribution guardrails are in [`CLAUDE.md`](CLAUDE.md).
