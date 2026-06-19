# Changelog

All notable changes to this project are documented here.

## [1.2.0] - 2026-06-19

### Changed

- **`config/openclaw-context.mdc`** — mandatory session-start read list (matches OpenClaw turn injection); ordered file table; `memory/YYYY-MM-DD.md`; `BOOTSTRAP.md` noted as obsolete; `__OPENCLAW_WORKSPACE__` placeholder
- **`scripts/setup-cursor-rules.sh`** — substitutes workspace path; validates `USER.md`; clearer post-install output

### Added

- **`README.de.md`** — full German guide with table of contents (OpenClaw, Cursor, MCP, shared context, daily use, FAQ)
- README: language switcher; clearer OpenClaw vs Cursor context loading comparison

## [1.1.0] - 2026-06-19

### Added

- **`scripts/setup-cursor-rules.sh`** — installs global Cursor rule at `~/.cursor/rules/openclaw-context.mdc`
- **`config/openclaw-context.mdc`** — `alwaysApply: true` rule; Composer reads OpenClaw workspace files (`SOUL.md`, `USER.md`, `AGENTS.md`, `IDENTITY.md`, `TOOLS.md`, …)
- README: full documentation for OpenClaw, Cursor, MCP, shared context, Telegram, scripts, and config
- FAQ: **global vs project scope** — context rule applies to all Cursor workspaces, not only this repo

### Changed

- Quick start extended with step 4 (shared context) and optional desktop shortcuts
- Architecture diagram updated (workspace files + MCP + global Cursor rules)

## [1.0.0] - 2026-06-19

### Added

- Initial release: OpenClaw + Cursor subscription integration for Linux
- `scripts/install-openclaw.sh` — installs OpenClaw, cursor-cli plugin, gateway daemon, sets `cursor-cli/auto`
- `scripts/setup-mcp.sh` — configures Cursor IDE MCP (`openclaw mcp serve`) with secure token file
- `scripts/install-desktop-shortcuts.sh` — KDE desktop entries and helper commands
- Example configs under `config/`
- `openclaw-cursor-check` diagnostic helper
- English README with architecture, quota guidance, and troubleshooting

### Notes

- Default model uses **Auto + Composer pool** (`cursor-cli/auto`), not API premium models
- Tested on CachyOS with fish, Konsole, KDE Plasma, Cursor Pro+

[1.2.0]: https://github.com/benjarogit/openclaw-cursor-mcp/releases/tag/v1.2.0
[1.1.0]: https://github.com/benjarogit/openclaw-cursor-mcp/releases/tag/v1.1.0
[1.0.0]: https://github.com/benjarogit/openclaw-cursor-mcp/releases/tag/v1.0.0
