#!/usr/bin/env bash
# Install OpenClaw + Cursor CLI integration (Cursor subscription as model backend).
# Tested on CachyOS / Arch Linux with fish shell and KDE.
set -euo pipefail

OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"
NPM_PREFIX="${NPM_PREFIX:-$HOME/.npm-global}"
LOCAL_BIN="${LOCAL_BIN:-$HOME/.local/bin}"
PATH="$NPM_PREFIX/bin:$LOCAL_BIN:$PATH"

info() { printf '\033[1;36m→\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m✓\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m✗\033[0m %s\n' "$*" >&2; exit 1; }

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "Missing dependency: $1"
}

info "Checking prerequisites…"
need_cmd curl
need_cmd git

if ! command -v npm >/dev/null 2>&1; then
  warn "npm not found — installing via pacman (requires sudo)…"
  sudo pacman -S --noconfirm npm
fi
need_cmd node
need_cmd npm

# User-local npm prefix (avoid sudo for global packages)
if ! npm config get prefix 2>/dev/null | rg -q "$NPM_PREFIX"; then
  info "Configuring npm prefix: $NPM_PREFIX"
  mkdir -p "$NPM_PREFIX/bin"
  npm config set prefix "$NPM_PREFIX"
fi

# Ensure PATH in fish
FISH_CONFIG="$HOME/.config/fish/config.fish"
if [[ -f "$FISH_CONFIG" ]]; then
  if ! rg -q 'npm-global' "$FISH_CONFIG" 2>/dev/null; then
    info "Adding npm-global and ~/.local/bin to fish PATH"
    cat >> "$FISH_CONFIG" <<'EOF'

# OpenClaw + Cursor Agent CLI
fish_add_path -m -- $HOME/.npm-global/bin $HOME/.local/bin
EOF
  fi
fi

info "Installing OpenClaw…"
curl -fsSL --proto '=https' --tlsv1.2 https://openclaw.ai/install.sh | bash -s -- --no-onboard

info "Running OpenClaw onboarding (gateway daemon, local mode)…"
openclaw onboard --non-interactive --accept-risk --auth-choice skip \
  --flow quickstart --install-daemon --skip-channels --skip-skills --skip-search

info "Installing Cursor CLI plugin for OpenClaw…"
openclaw plugins install clawhub:@jeehou/openclaw-cursor-cli

info "Refreshing Cursor model catalog…"
bash "$OPENCLAW_HOME/extensions/cursor-cli/scripts/refresh-models.sh"

info "Setting default model to cursor-cli/auto (Auto + Composer pool, not API)…"
openclaw models set cursor-cli/auto
openclaw config set 'plugins.allow' '["cursor-cli"]'
openclaw config set 'plugins.entries.cursor-cli.config.command' "$LOCAL_BIN/cursor-agent"
openclaw config set 'plugins.entries.cursor-cli.config.mode' 'agent'

info "Installing Cursor Agent CLI if missing…"
if ! command -v cursor-agent >/dev/null 2>&1; then
  curl -fsSL https://cursor.com/install | bash
fi

if ! cursor-agent status 2>/dev/null | rg -q 'Logged in'; then
  warn "Cursor CLI is not logged in yet."
  warn "Run: cursor-agent login"
  warn "Then verify: cursor-agent about  (should show your Pro/Pro+ tier)"
fi

openclaw gateway restart || openclaw gateway start

ok "OpenClaw + Cursor CLI plugin installed."
echo
echo "Next steps:"
echo "  1. cursor-agent login"
echo "  2. cursor-agent about          # Subscription Tier should NOT be Free/Unknown"
echo "  3. openclaw chat               # Terminal chat"
echo "  4. Run scripts/setup-mcp.sh    # Connect OpenClaw MCP to Cursor IDE"
echo "  5. openclaw-cursor-check       # Optional: install from scripts/"
