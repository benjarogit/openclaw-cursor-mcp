#!/usr/bin/env bash
# Optional KDE desktop entries + helper commands in ~/.local/bin
set -euo pipefail

NPM_PREFIX="${NPM_PREFIX:-$HOME/.npm-global}"
LOCAL_BIN="${LOCAL_BIN:-$HOME/.local/bin}"
ICON_DIR="$HOME/.local/share/icons"
APPS_DIR="$HOME/.local/share/applications"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p "$LOCAL_BIN" "$ICON_DIR" "$APPS_DIR"

cat > "$LOCAL_BIN/openclaw-dashboard" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:$PATH"
exec openclaw dashboard --yes "$@"
EOF

cat > "$LOCAL_BIN/openclaw-chat" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:$PATH"
exec openclaw tui "$@"
EOF

cat > "$LOCAL_BIN/openclaw-cursor-check" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
export PATH="$HOME/.npm-global/bin:$HOME/.local/bin:$PATH"
echo "=== OpenClaw + Cursor diagnose ==="
openclaw models 2>&1 | rg -i 'default|cursor-cli' | head -5 || true
echo
cursor-agent about 2>&1 || true
echo
tier="$(cursor-agent about --format json 2>/dev/null | rg -o '"subscriptionTier":\s*"[^"]+"' || true)"
if echo "$tier" | rg -q 'Free|Unknown'; then
  echo "⚠ CLI subscription not recognized — run: cursor-agent logout && cursor-agent login"
fi
EOF

chmod +x "$LOCAL_BIN/openclaw-dashboard" "$LOCAL_BIN/openclaw-chat" "$LOCAL_BIN/openclaw-cursor-check"

if [[ -f "$REPO_ROOT/assets/logo.svg" ]]; then
  cp "$REPO_ROOT/assets/logo.svg" "$ICON_DIR/openclaw-cursor-mcp.svg"
fi

cat > "$APPS_DIR/openclaw-dashboard.desktop" <<EOF
[Desktop Entry]
Name=OpenClaw Dashboard
Comment=OpenClaw web control UI
Exec=$LOCAL_BIN/openclaw-dashboard
Icon=$ICON_DIR/openclaw-cursor-mcp.svg
Terminal=false
Type=Application
Categories=Development;Utility;
EOF

cat > "$APPS_DIR/openclaw-chat.desktop" <<EOF
[Desktop Entry]
Name=OpenClaw Chat
Comment=OpenClaw terminal chat (TUI)
Exec=konsole --separate -p tabtitle=OpenClaw -e $LOCAL_BIN/openclaw-chat
Icon=$ICON_DIR/openclaw-cursor-mcp.svg
Terminal=false
Type=Application
Categories=Development;Utility;
EOF

update-desktop-database "$APPS_DIR" 2>/dev/null || true
echo "Desktop shortcuts installed."
