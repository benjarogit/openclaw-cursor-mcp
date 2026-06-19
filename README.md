# OpenClaw + Cursor Integration

Scripts and configuration to run [OpenClaw](https://openclaw.ai/) with your **Cursor subscription** on Linux, plus **MCP integration** so Cursor IDE can talk to the OpenClaw Gateway.

This repo documents the setup we use in production:

- **OpenClaw** uses `cursor-agent` as its model backend (`cursor-cli/auto` → Auto + Composer pool)
- **Cursor IDE** connects to OpenClaw via MCP (`openclaw mcp serve`)
- **On-demand spend** stays disabled in Cursor — usage comes from your plan quotas

## Architecture

```
┌─────────────────────┐         ┌──────────────────────┐
│  Cursor IDE         │  MCP    │  OpenClaw Gateway      │
│  (Composer / Auto)  │ ──────► │  localhost:18789       │
│  ~/.cursor/mcp.json │ stdio   │  channels, sessions    │
└─────────────────────┘         └──────────┬───────────┘
                                           │
┌─────────────────────┐                    │
│  openclaw chat      │◄───────────────────┘
│  (terminal TUI)     │
└─────────┬───────────┘
          │ cursor-cli/auto
          ▼
┌─────────────────────┐
│  cursor-agent CLI   │  ← Cursor Pro / Pro+ subscription
└─────────────────────┘
```

## Requirements

- Linux (tested on **CachyOS / Arch**)
- **Node.js** 22.19+ (installer can bootstrap npm)
- **Cursor subscription** (Pro or Pro+ recommended)
- **Cursor Agent CLI**: `cursor-agent` (`curl -fsSL https://cursor.com/install | bash`)
- Shell: **fish** or bash (fish PATH snippet included)

## Quick start

```bash
git clone https://github.com/benjarogit/openclaw-cursor-mcp.git
cd openclaw-cursor-mcp

# 1) Install OpenClaw + Cursor CLI plugin + gateway daemon
bash scripts/install-openclaw.sh

# 2) Log in Cursor CLI (browser opens — do NOT Ctrl+C)
cursor-agent login
cursor-agent about   # expect Subscription Tier: Pro or Pro+

# 3) Wire OpenClaw MCP into Cursor IDE
bash scripts/setup-mcp.sh

# 4) Restart Cursor IDE, approve MCP tools when prompted
```

### Chat from the terminal

```bash
openclaw chat
# or desktop shortcut: "OpenClaw Chat"
```

### Web dashboard

```bash
openclaw dashboard
# or desktop shortcut: "OpenClaw Dashboard"
```

### Health check

```bash
openclaw-cursor-check
```

## Cursor usage pools (important)

Cursor billing has **two separate pools** ([docs](https://cursor.com/docs/models-and-pricing)):

| Pool | Used for | This setup |
|------|----------|------------|
| **Auto + Composer** | Auto mode, Composer 2.5 | ✅ Default: `cursor-cli/auto` |
| **API** | Premium models (Claude, GPT, …) | ❌ Avoid until API quota resets |

If **API is at 100%** but **Auto + Composer** still has headroom, keep:

```bash
openclaw models set cursor-cli/auto
```

Do **not** switch OpenClaw to premium `cursor-cli/*` models unless you intend to consume API quota.

Keep **on-demand spending disabled** in [Cursor settings](https://cursor.com/settings) to avoid surprise charges.

## MCP in Cursor IDE

After `scripts/setup-mcp.sh`, `~/.cursor/mcp.json` contains an `openclaw` server:

```json
{
  "mcpServers": {
    "openclaw": {
      "command": "/home/YOU/.npm-global/bin/openclaw",
      "args": [
        "mcp", "serve",
        "--url", "ws://127.0.0.1:18789",
        "--token-file", "/home/YOU/.openclaw/gateway.token"
      ]
    }
  }
}
```

The gateway token is written to `~/.openclaw/gateway.token` (mode `600`). **Never commit this file.**

### MCP tools exposed to Cursor

Via [OpenClaw MCP serve](https://docs.openclaw.ai/cli/mcp):

- `conversations_list` — list routed channel conversations
- `conversation_get` — fetch one conversation
- `messages_read` / `messages_send` — read/send on existing routes
- `events_poll` / `events_wait` — live gateway events
- `permissions_list_open` — pending approval requests

Restart Cursor after changing MCP config.

## Manual configuration reference

### OpenClaw plugin snippet

See `config/openclaw-cursor-plugin.example.json` — merge into `~/.openclaw/openclaw.json`:

- Plugin: `clawhub:@jeehou/openclaw-cursor-cli`
- Default model: `cursor-cli/auto`
- `plugins.allow`: `["cursor-cli"]`

### Refresh Cursor models after Cursor updates

```bash
bash ~/.openclaw/extensions/cursor-cli/scripts/refresh-models.sh
```

### Gateway

```bash
openclaw gateway status
openclaw gateway restart
openclaw doctor
```

Dashboard: http://127.0.0.1:18789/

## Troubleshooting

### `Get Cursor Pro` / usage limit in OpenClaw chat

1. Run **outside** OpenClaw chat (normal terminal):

   ```bash
   cursor-agent about
   ```

2. If `Subscription Tier` is `Free`, `Unknown`, or `Not logged in`:

   ```bash
   cursor-agent logout
   cursor-agent login   # wait for browser, do not abort
   ```

3. Confirm the **same email** as your Cursor dashboard.

4. Keep model on `cursor-cli/auto` if API pool is exhausted.

### Commands typed inside `openclaw chat` do nothing

The TUI is a **chat**, not a shell. Run `cursor-agent login` in a normal terminal (`~ ❯`).

### `openclaw: command not found`

```bash
fish_add_path -m -- $HOME/.npm-global/bin $HOME/.local/bin
# or open a new terminal after install-openclaw.sh
```

### MCP not showing in Cursor

1. `openclaw gateway status` → must be **running**
2. Check `~/.cursor/mcp.json`
3. Fully restart Cursor IDE
4. Enable MCP tools for the `openclaw` server in Composer settings

## Repository layout

```
openclaw-cursor-mcp/
├── README.md
├── CHANGELOG.md
├── assets/openclaw.svg
├── config/
│   ├── mcp.json.example
│   └── openclaw-cursor-plugin.example.json
└── scripts/
    ├── install-openclaw.sh
    ├── setup-mcp.sh
    └── install-desktop-shortcuts.sh
```

## Security notes

- `~/.openclaw/gateway.token` authenticates local MCP → gateway access. Keep permissions at `600`.
- Do not commit tokens, `openclaw.json` secrets, or personal `mcp.json` files.
- The Cursor CLI plugin runs `cursor-agent` with `--force --trust` in agent mode — use only in workspaces you trust.

## Links

- [OpenClaw docs](https://docs.openclaw.ai/)
- [OpenClaw MCP CLI](https://docs.openclaw.ai/cli/mcp)
- [Cursor CLI](https://cursor.com/docs/cli/overview)
- [Cursor usage limits](https://cursor.com/help/models-and-usage/usage-limits)
- [cursor-cli OpenClaw plugin](https://clawhub.ai/) — `@jeehou/openclaw-cursor-cli`

## License

MIT — see [LICENSE](LICENSE).
