# Changelog

All notable changes to this project are documented here.

## [Unreleased]

### Added

- **`config/git-no-cursor-coauthor.mdc`** — global Cursor rule: never `Co-authored-by: Cursor <cursoragent@cursor.com>` on commits
- `setup-cursor-rules.sh` installs git identity rule alongside OpenClaw context rule

### Fixed

- Removed erroneous `Co-authored-by: Cursor <cursoragent@cursor.com>` trailers from entire git history (GitHub Contributors)

## [1.3.1] - 2026-06-19

### Changed

- **New logo** `assets/logo.svg` — OpenClaw mascot + cursor pointer + “CURSOR MCP” wordmark (transparent background, as designed)
- README & README.de.md use SVG logo (840px wide, crisp on all displays)
- `banner.png` regenerated from logo (840×588)
- Desktop shortcuts use `logo.svg` as icon

### Removed

- Legacy `assets/openclaw.svg`

## [1.3.0] - 2026-06-19

### Added

- **`assets/banner.png`** — README hero banner (1200×458, optimized for GitHub)
- README & README.de.md — centered banner, badges (MIT, Linux, Open Source, Release), open-source / contributing sections

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

[1.3.1]: https://github.com/benjarogit/openclaw-cursor-mcp/releases/tag/v1.3.1
[1.3.0]: https://github.com/benjarogit/openclaw-cursor-mcp/releases/tag/v1.3.0
[1.2.0]: https://github.com/benjarogit/openclaw-cursor-mcp/releases/tag/v1.2.0
[1.1.0]: https://github.com/benjarogit/openclaw-cursor-mcp/releases/tag/v1.1.0
[1.0.0]: https://github.com/benjarogit/openclaw-cursor-mcp/releases/tag/v1.0.0
