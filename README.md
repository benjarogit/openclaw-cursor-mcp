<p align="center">
  <img src="assets/logo.svg" alt="OpenClaw Cursor MCP — red mascot with cursor pointer, OpenClaw and CURSOR MCP wordmark" width="840">
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue?style=for-the-badge" alt="MIT License"></a>
  <a href="https://github.com/benjarogit/openclaw-cursor-mcp/releases/latest"><img src="https://img.shields.io/github/v/release/benjarogit/openclaw-cursor-mcp?style=for-the-badge&label=Release" alt="Latest release"></a>
  <img src="https://img.shields.io/badge/Platform-Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black" alt="Linux">
  <img src="https://img.shields.io/badge/Open%20Source-Use%20%26%20Extend-2ea44f?style=for-the-badge" alt="Open Source — use and extend">
</p>

<p align="center">
  <a href="https://openclaw.ai/"><img src="https://img.shields.io/badge/OpenClaw-Agent%20Platform-FF5F5F?style=flat-square" alt="OpenClaw"></a>
  <a href="https://cursor.com/"><img src="https://img.shields.io/badge/Cursor-IDE%20%2B%20CLI-000?style=flat-square" alt="Cursor"></a>
  <a href="https://docs.openclaw.ai/cli/mcp"><img src="https://img.shields.io/badge/MCP-Gateway%20Bridge-6366f1?style=flat-square" alt="MCP"></a>
  <img src="https://img.shields.io/badge/Context-SOUL.md%20%7C%20USER.md%20%7C%20AGENTS.md-0ea5e9?style=flat-square" alt="Shared context files">
</p>

<p align="center">
  <strong>Languages:</strong> <a href="README.md"><strong>English</strong></a> · <a href="README.de.md">Deutsch (Anleitung)</a>
</p>

<p align="center">
  Run <a href="https://openclaw.ai/">OpenClaw</a> with your <strong>Cursor Pro / Pro+ subscription</strong> on Linux —<br>
  MCP integration for Cursor IDE · shared agent memory across Telegram, terminal &amp; Composer
</p>

---

> **Open Source — free for everyone.** Clone it, use it, fork it, extend it.  
> MIT licensed ([LICENSE](LICENSE)) — no vendor lock-in. Pull requests and ideas welcome.

**Repository:** [github.com/benjarogit/openclaw-cursor-mcp](https://github.com/benjarogit/openclaw-cursor-mcp)

---

## Table of contents

- [What you get](#what-you-get)
- [Architecture](#architecture)
- [OpenClaw](#openclaw)
- [Cursor](#cursor)
- [MCP bridge (Cursor IDE ↔ Gateway)](#mcp-bridge-cursor-ide--gateway)
- [Shared OpenClaw context (SOUL.md, USER.md, …)](#shared-openclaw-context-soulmd-usermd-)
- [Global vs project scope (FAQ)](#global-vs-project-scope-faq)
- [Requirements](#requirements)
- [Quick start](#quick-start)
- [Cursor usage pools](#cursor-usage-pools-important)
- [Telegram & other channels](#telegram--other-channels)
- [Scripts reference](#scripts-reference)
- [Configuration files](#configuration-files)
- [Troubleshooting](#troubleshooting)
- [Security](#security)
- [Links](#links)

---

## What you get

| Layer | What | Where |
|-------|------|--------|
| **OpenClaw** | Local AI agent + gateway, channels (Telegram, …), workspace memory | `~/.openclaw/` |
| **Cursor CLI** | Model backend using your **Pro / Pro+** quota (not a separate API key bill) | `cursor-agent` |
| **MCP** | Optional tools in Cursor IDE to read/send OpenClaw conversations | `~/.cursor/mcp.json` |
| **Shared context** | Same personality & user profile in Cursor and OpenClaw | `~/.openclaw/workspace/*.md` + `~/.cursor/rules/` |

After the full setup you can:

- Chat in **Telegram** or **`openclaw chat`** with the same agent that knows your `USER.md`
- Code in **Cursor Composer** with the same `SOUL.md` / `AGENTS.md` rules
- Optionally use **MCP tools** from Cursor to inspect or reply on OpenClaw channels

---

## Architecture

```
                    ┌─────────────────────────────────────────┐
                    │  ~/.openclaw/workspace/                  │
                    │  SOUL.md  USER.md  AGENTS.md  TOOLS.md … │
                    └───────────────┬─────────────────────────┘
                                    │ read every turn (OpenClaw)
                                    │ read via global rule (Cursor)
          ┌─────────────────────────┼─────────────────────────┐
          │                         │                         │
          ▼                         ▼                         ▼
┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
│  Telegram /     │       │  openclaw chat  │       │  Cursor IDE     │
│  other channels │       │  (terminal TUI) │       │  Composer/Agent │
└────────┬────────┘       └────────┬────────┘       └────────┬────────┘
         │                         │                         │
         └─────────────────────────┼─────────────────────────┘
                                   ▼
                    ┌──────────────────────────────┐
                    │  OpenClaw Gateway             │
                    │  ws://127.0.0.1:18789         │
                    │  ~/.openclaw/openclaw.json    │
                    └──────────────┬───────────────┘
                                   │ cursor-cli/auto
                                   ▼
                    ┌──────────────────────────────┐
                    │  cursor-agent CLI             │
                    │  (Cursor Pro / Pro+ sub)      │
                    └──────────────────────────────┘

Cursor IDE ── MCP (stdio) ──► openclaw mcp serve ──► Gateway
              ~/.cursor/mcp.json
```

**Important:** MCP and shared context are **independent**:

- **MCP** = Cursor can *call tools* on the gateway (list chats, send messages, …). It does **not** auto-load `SOUL.md` into every message.
- **Shared context** = global Cursor rule tells Composer to *read* `~/.openclaw/workspace/*.md` — same baseline as OpenClaw, without MCP.

---

## OpenClaw

[OpenClaw](https://openclaw.ai/) is a local-first agent platform: gateway, plugins, channels, and a **workspace** of markdown files that define who the agent is and who you are.

### Key paths

| Path | Purpose |
|------|---------|
| `~/.openclaw/openclaw.json` | Main config (plugins, models, channels) |
| `~/.openclaw/workspace/` | Agent context files (see below) |
| `~/.openclaw/gateway.token` | Local auth token for MCP / API (mode `600`) |
| `~/.npm-global/bin/openclaw` | CLI (after install script) |

### Workspace context files

OpenClaw injects these into agent turns automatically:

| File | Role |
|------|------|
| **`SOUL.md`** | Personality, tone, boundaries — *who the agent is* |
| **`USER.md`** | Your name, timezone, projects, preferences — *who you are* |
| **`IDENTITY.md`** | Agent name, emoji, vibe (e.g. “CachyClaw 🦞”) |
| **`AGENTS.md`** | Operating rules, memory policy, red lines, heartbeats |
| **`TOOLS.md`** | Environment-specific notes (SSH hosts, devices, voices, …) |
| **`HEARTBEAT.md`** | Optional proactive reminders |
| **`memory/YYYY-MM-DD.md`** | Daily scratch notes |
| **`MEMORY.md`** | Long-term curated memory (private sessions only) |

Edit these once under `~/.openclaw/workspace/`. OpenClaw (Telegram, TUI, cron) always uses them.

### This repo’s OpenClaw setup

`scripts/install-openclaw.sh` installs OpenClaw, the **cursor-cli** plugin (`clawhub:@jeehou/openclaw-cursor-cli`), enables the gateway daemon, and sets:

```bash
openclaw models set cursor-cli/auto   # Auto + Composer pool
```

See `config/openclaw-cursor-plugin.example.json` for the JSON snippet.

---

## Cursor

[Cursor](https://cursor.com/) is the IDE; **`cursor-agent`** is the CLI that uses your **subscription** (Pro / Pro+), not pay-per-token API billing by default.

### Two usage pools

Cursor billing has **separate quotas** ([docs](https://cursor.com/docs/models-and-pricing)):

| Pool | Used for | This setup |
|------|----------|------------|
| **Auto + Composer** | Auto mode, Composer | ✅ `cursor-cli/auto` |
| **API** | Premium models (Claude, GPT, …) | ❌ Avoid unless intentional |

Keep **on-demand spending disabled** in [Cursor settings](https://cursor.com/settings).

### Login (required once)

```bash
cursor-agent login
cursor-agent about   # Subscription Tier: Pro or Pro+
```

Run this in a **normal terminal**, not inside `openclaw chat` (the TUI is chat-only, not a shell).

### Where Cursor is used here

1. **OpenClaw backend** — every `openclaw chat` / Telegram reply goes through `cursor-agent`
2. **Cursor IDE** — your daily coding; optionally MCP + shared context from this repo

---

## MCP bridge (Cursor IDE ↔ Gateway)

[MCP](https://docs.openclaw.ai/cli/mcp) (Model Context Protocol) lets **Cursor IDE** talk to the **OpenClaw Gateway** over stdio.

### Install

```bash
bash scripts/setup-mcp.sh
```

Writes `~/.cursor/mcp.json` (see `config/mcp.json.example`). Restart Cursor and approve the `openclaw` MCP server.

### What MCP does

| Tool | Purpose |
|------|---------|
| `conversations_list` | List routed channel conversations |
| `conversation_get` | Fetch one conversation |
| `messages_read` / `messages_send` | Read or send on existing routes |
| `events_poll` / `events_wait` | Live gateway events |
| `permissions_list_open` | Pending approval requests |

**What MCP does *not* do:** It does not replace OpenClaw’s workspace files in Cursor, and it does not make OpenClaw “think along” in every Composer message unless you explicitly use those tools.

### Prerequisites

```bash
openclaw gateway status   # must be running
```

Token file: `~/.openclaw/gateway.token` — **never commit**.

---

## Shared OpenClaw context (SOUL.md, USER.md, …)

Telegram and `openclaw chat` already load workspace markdown on every turn. **Cursor IDE does not** — unless you add a rule.

### Install global Cursor rule

```bash
bash scripts/setup-cursor-rules.sh
```

This copies `config/openclaw-context.mdc` to:

```
~/.cursor/rules/openclaw-context.mdc
```

with **`alwaysApply: true`**.

Composer is instructed to **read** the workspace files at the start of substantive sessions (coding, planning, multi-step work) and align tone/rules with OpenClaw.

### How it works technically

| Channel | How context is loaded |
|---------|------------------------|
| **OpenClaw / Telegram** | Workspace `.md` files are **injected automatically** on every turn |
| **Cursor Composer** | Global rule (`alwaysApply: true`) **requires reading** the same files at **every new chat** before the first reply — same content, active load via Read tool |

| Mechanism | Scope | Behavior |
|-----------|--------|----------|
| OpenClaw workspace | OpenClaw channels | Automatic injection each turn |
| `~/.cursor/rules/openclaw-context.mdc` | **All Cursor projects globally** | Mandatory session-start read list |
| Project `.cursor/rules/` | Single repo only | Only that workspace |

This repo installs the **user-level** rule under `~/.cursor/`, not under a project folder.

### Keeping channels in sync

1. Edit `~/.openclaw/workspace/SOUL.md`, `USER.md`, etc.
2. OpenClaw picks up changes immediately on the next message
3. Cursor picks them up on the next Composer session (after reading the files per the rule)

If you change preferences in Cursor, update the matching `.md` file so Telegram stays consistent.

### Limitations (honest)

- Cursor loads via **Read tool on session start** (mandatory per rule), not byte-for-byte token injection like OpenClaw — content and behavior should match once files are read
- If the agent skips reads, re-run `setup-cursor-rules.sh` and restart Cursor; start a **new** Composer tab
- `MEMORY.md` stays private (rule mirrors OpenClaw AGENTS.md policy)

---

## Global vs project scope (FAQ)

**Are OpenClaw context files active globally in Cursor, not only in one project?**

**Yes.** After `setup-cursor-rules.sh`, the rule lives in **`~/.cursor/rules/`**, which is **user-wide**. It applies in **every workspace and project** you open in Cursor (e.g. `~/Dokumente/kodi`, `~/Dokumente/test`, anything else).

It is **not** tied to cloning this GitHub repo or opening the `openclaw-cursor-mcp` folder.

| Setup | Scope |
|-------|--------|
| `~/.cursor/rules/openclaw-context.mdc` | ✅ Global — all projects |
| `.cursor/rules/` inside a git repo | ❌ Only that repository |
| `~/.cursor/mcp.json` | ✅ Global — MCP available everywhere |
| `~/.openclaw/workspace/` | ✅ Global — one OpenClaw workspace for all channels |

To disable globally: remove or rename `~/.cursor/rules/openclaw-context.mdc` and restart Cursor.

---

## Requirements

- Linux (tested on **CachyOS / Arch**)
- **Node.js** 22.19+ (installer can bootstrap npm)
- **Cursor subscription** (Pro or Pro+ recommended)
- **Cursor Agent CLI**: `cursor-agent` (`curl -fsSL https://cursor.com/install | bash`)
- Shell: **fish** or bash (fish PATH snippet in install script)

---

## Quick start

```bash
git clone https://github.com/benjarogit/openclaw-cursor-mcp.git
cd openclaw-cursor-mcp

# 1) OpenClaw + cursor-cli plugin + gateway daemon
bash scripts/install-openclaw.sh

# 2) Cursor CLI login (browser — do NOT Ctrl+C)
cursor-agent login
cursor-agent about

# 3) MCP: Cursor IDE ↔ OpenClaw Gateway
bash scripts/setup-mcp.sh

# 4) Shared context: SOUL.md, USER.md, … in all Composer sessions
bash scripts/setup-cursor-rules.sh

# 5) Optional: KDE desktop shortcuts
bash scripts/install-desktop-shortcuts.sh

# 6) Restart Cursor IDE; enable MCP tools when prompted
```

### Daily use

```bash
openclaw chat              # terminal
openclaw dashboard         # http://127.0.0.1:18789/
openclaw-cursor-check      # diagnostics
```

---

## Cursor usage pools (important)

If **API is at 100%** but **Auto + Composer** still has headroom:

```bash
openclaw models set cursor-cli/auto
```

Do **not** switch to premium `cursor-cli/*` models unless you intend to use API quota.

---

## Telegram & other channels

Channels are configured in OpenClaw, not in this repo’s scripts. Typical steps:

```bash
openclaw plugins enable telegram
openclaw config set 'plugins.allow' '["cursor-cli","telegram"]'
openclaw channels login telegram
openclaw channels status --probe
```

Telegram uses the **same** `~/.openclaw/workspace/` files and the **same** `cursor-cli/auto` model as terminal chat.

See [OpenClaw channels docs](https://docs.openclaw.ai/).

---

## Scripts reference

| Script | Purpose |
|--------|---------|
| `scripts/install-openclaw.sh` | Install OpenClaw, cursor-cli plugin, gateway, `cursor-cli/auto`, PATH |
| `scripts/setup-mcp.sh` | Write `~/.cursor/mcp.json` with `openclaw mcp serve` |
| `scripts/setup-cursor-rules.sh` | Install global `~/.cursor/rules/openclaw-context.mdc` |
| `scripts/install-desktop-shortcuts.sh` | KDE `.desktop` entries for dashboard & chat |

Helper installed to `~/.local/bin/openclaw-cursor-check`.

---

## Configuration files

```
openclaw-cursor-mcp/
├── README.md
├── README.de.md
├── CHANGELOG.md
├── assets/
│   ├── logo.svg                # Project logo (README + desktop icons)
│   └── banner.png              # PNG export (840×588, optional)
├── config/
│   ├── mcp.json.example
│   ├── openclaw-context.mdc      # template → ~/.cursor/rules/
│   └── openclaw-cursor-plugin.example.json
└── scripts/
    ├── install-openclaw.sh
    ├── setup-mcp.sh
    ├── setup-cursor-rules.sh
    └── install-desktop-shortcuts.sh
```

Example MCP snippet (`config/mcp.json.example`):

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

Refresh Cursor models after Cursor app updates:

```bash
bash ~/.openclaw/extensions/cursor-cli/scripts/refresh-models.sh
```

Gateway maintenance:

```bash
openclaw gateway status
openclaw gateway restart
openclaw doctor
```

---

## Troubleshooting

### `Get Cursor Pro` / usage limit in OpenClaw chat

```bash
cursor-agent about
cursor-agent logout && cursor-agent login
openclaw models set cursor-cli/auto
```

Confirm the same email as your Cursor dashboard.

### Commands inside `openclaw chat` do nothing

Use a normal shell prompt (`~ ❯`), not the chat TUI.

### `openclaw: command not found`

```bash
fish_add_path -m -- $HOME/.npm-global/bin $HOME/.local/bin
```

### MCP not showing in Cursor

1. `openclaw gateway status` → running  
2. Check `~/.cursor/mcp.json`  
3. Full Cursor restart  
4. Enable MCP for server `openclaw` in Composer settings  

### Shared context not felt in Cursor

1. Confirm file exists: `~/.cursor/rules/openclaw-context.mdc`  
2. Restart Cursor after install  
3. Check workspace files exist: `ls ~/.openclaw/workspace/SOUL.md`  
4. Re-run: `bash scripts/setup-cursor-rules.sh`  

---

## Security

- `~/.openclaw/gateway.token` — local gateway auth; keep mode `600`, never commit
- Do not commit tokens, personal `openclaw.json` secrets, or live `mcp.json`
- cursor-cli plugin runs `cursor-agent` with `--force --trust` in agent mode — use only in trusted workspaces
- `MEMORY.md` is for private 1:1 context; do not expose via group chats or public snippets

---

## License & contributing

This project is **[MIT licensed](LICENSE)**. You may use, copy, modify, merge, publish, and distribute it — commercially or privately — as long as you include the license notice.

- **Use** the scripts as-is on your machine  
- **Extend** configs, rules, and docs for your workflow  
- **Fork** and publish your own variant  
- **Contribute** via issues or pull requests on [GitHub](https://github.com/benjarogit/openclaw-cursor-mcp)

No warranty — see LICENSE. Secrets (`gateway.token`, personal `mcp.json`) stay on your machine only.

---

## Links

- [OpenClaw docs](https://docs.openclaw.ai/)
- [OpenClaw MCP CLI](https://docs.openclaw.ai/cli/mcp)
- [OpenClaw agent workspace](https://docs.openclaw.ai/concepts/agent-workspace)
- [Cursor CLI](https://cursor.com/docs/cli/overview)
- [Cursor usage limits](https://cursor.com/help/models-and-usage/usage-limits)
- [cursor-cli plugin](https://clawhub.ai/) — `@jeehou/openclaw-cursor-cli`
- [This repository](https://github.com/benjarogit/openclaw-cursor-mcp)
