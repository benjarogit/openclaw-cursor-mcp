# Changelog

All notable changes to this project are documented here.

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

[1.0.0]: https://github.com/benjarogit/openclaw-cursor-mcp/releases/tag/v1.0.0
