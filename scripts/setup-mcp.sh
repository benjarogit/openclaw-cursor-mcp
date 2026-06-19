#!/usr/bin/env bash
# Wire OpenClaw Gateway into Cursor IDE via MCP (stdio bridge).
set -euo pipefail

NPM_PREFIX="${NPM_PREFIX:-$HOME/.npm-global}"
LOCAL_BIN="${LOCAL_BIN:-$HOME/.local/bin}"
OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"
CURSOR_DIR="${CURSOR_DIR:-$HOME/.cursor}"
OPENCLAW_BIN="${OPENCLAW_BIN:-$NPM_PREFIX/bin/openclaw}"
GATEWAY_PORT="${GATEWAY_PORT:-18789}"
GATEWAY_URL="${GATEWAY_URL:-ws://127.0.0.1:${GATEWAY_PORT}}"
TOKEN_FILE="$OPENCLAW_HOME/gateway.token"
MCP_JSON="$CURSOR_DIR/mcp.json"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

info() { printf '\033[1;36m→\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m✓\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m✗\033[0m %s\n' "$*" >&2; exit 1; }

export PATH="$NPM_PREFIX/bin:$LOCAL_BIN:$PATH"

[[ -x "$OPENCLAW_BIN" ]] || die "openclaw not found at $OPENCLAW_BIN — run scripts/install-openclaw.sh first"

info "Ensuring OpenClaw Gateway is running…"
if ! openclaw gateway status 2>/dev/null | rg -q 'Runtime: running'; then
  openclaw gateway start || openclaw gateway restart
fi

export OPENCLAW_HOME TOKEN_FILE OPENCLAW_BIN GATEWAY_URL MCP_JSON

info "Writing gateway token file (mode 600)…"
python3 <<'PY'
import json, os, pathlib
cfg = pathlib.Path(os.environ["OPENCLAW_HOME"]) / "openclaw.json"
data = json.loads(cfg.read_text())
token = data.get("gateway", {}).get("auth", {}).get("token")
if not token:
    raise SystemExit("No gateway.auth.token in openclaw.json — run openclaw onboard first")
path = pathlib.Path(os.environ["TOKEN_FILE"])
path.write_text(token.strip() + "\n")
path.chmod(0o600)
print(f"Wrote {path}")
PY

mkdir -p "$CURSOR_DIR"

MCP_BLOCK=$(python3 - <<PY
import json, os
print(json.dumps({
  "command": os.environ["OPENCLAW_BIN"],
  "args": [
    "mcp", "serve",
    "--url", os.environ["GATEWAY_URL"],
    "--token-file", os.environ["TOKEN_FILE"],
  ],
}, indent=2))
PY
)

export MCP_BLOCK

if [[ -f "$MCP_JSON" ]]; then
  info "Merging openclaw server into existing $MCP_JSON…"
  python3 <<PY
import json, pathlib, os
path = pathlib.Path(os.environ["MCP_JSON"])
data = json.loads(path.read_text()) if path.read_text().strip() else {}
servers = data.setdefault("mcpServers", {})
servers["openclaw"] = json.loads(os.environ["MCP_BLOCK"])
path.write_text(json.dumps(data, indent=2) + "\n")
print(f"Updated {path}")
PY
else
  info "Creating $MCP_JSON…"
  python3 <<PY
import json, pathlib, os
path = pathlib.Path(os.environ["MCP_JSON"])
data = {"mcpServers": {"openclaw": json.loads(os.environ["MCP_BLOCK"])}}
path.write_text(json.dumps(data, indent=2) + "\n")
print(f"Created {path}")
PY
fi

# Install desktop helpers (optional)
if [[ -f "$REPO_ROOT/scripts/install-desktop-shortcuts.sh" ]]; then
  bash "$REPO_ROOT/scripts/install-desktop-shortcuts.sh"
fi

ok "Cursor MCP configured for OpenClaw."
echo
echo "Restart Cursor IDE to load MCP servers."
echo "In Composer, enable the 'openclaw' MCP tools when prompted."
echo
echo "Gateway dashboard: http://127.0.0.1:${GATEWAY_PORT}/"
echo "Verify gateway:    openclaw gateway status"
