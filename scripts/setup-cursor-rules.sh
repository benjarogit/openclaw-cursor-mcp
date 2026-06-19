#!/usr/bin/env bash
# Install global Cursor rule so Composer loads OpenClaw workspace context like OpenClaw does.
set -euo pipefail

CURSOR_RULES="${CURSOR_RULES:-$HOME/.cursor/rules}"
OPENCLAW_WORKSPACE="${OPENCLAW_WORKSPACE:-$HOME/.openclaw/workspace}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RULE_SRC="$REPO_ROOT/config/openclaw-context.mdc"
RULE_DST="$CURSOR_RULES/openclaw-context.mdc"

info() { printf '\033[1;36m→\033[0m %s\n' "$*"; }
ok()   { printf '\033[1;32m✓\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m✗\033[0m %s\n' "$*" >&2; exit 1; }

[[ -d "$OPENCLAW_WORKSPACE" ]] || die "OpenClaw workspace not found: $OPENCLAW_WORKSPACE (run install-openclaw.sh first)"
[[ -f "$OPENCLAW_WORKSPACE/SOUL.md" ]] || die "Missing $OPENCLAW_WORKSPACE/SOUL.md"
[[ -f "$OPENCLAW_WORKSPACE/USER.md" ]] || die "Missing $OPENCLAW_WORKSPACE/USER.md"

mkdir -p "$CURSOR_RULES"

[[ -f "$RULE_SRC" ]] || die "Missing template: $RULE_SRC"

info "Installing global Cursor rule…"
cp "$RULE_SRC" "$RULE_DST"
sed -i "s|__OPENCLAW_WORKSPACE__|$OPENCLAW_WORKSPACE|g" "$RULE_DST"

ok "Installed: $RULE_DST"
echo
echo "Scope: ALL Cursor projects (user-wide ~/.cursor/rules/, not per-repo)."
echo
echo "Context files (read at every new Composer/Agent session):"
echo "  $OPENCLAW_WORKSPACE/SOUL.md"
echo "  $OPENCLAW_WORKSPACE/USER.md"
echo "  $OPENCLAW_WORKSPACE/IDENTITY.md"
echo "  $OPENCLAW_WORKSPACE/AGENTS.md"
echo "  $OPENCLAW_WORKSPACE/TOOLS.md"
echo "  $OPENCLAW_WORKSPACE/HEARTBEAT.md"
echo "  $OPENCLAW_WORKSPACE/memory/$(date +%Y-%m-%d).md  (if present)"
echo
echo "Restart Cursor or open a new Composer tab to reload rules."
