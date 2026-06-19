#!/usr/bin/env bash
# Install global Cursor rule so Composer always loads OpenClaw workspace context files.
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

mkdir -p "$CURSOR_RULES"

if [[ -f "$RULE_SRC" ]]; then
  cp "$RULE_SRC" "$RULE_DST"
else
  die "Missing template: $RULE_SRC"
fi

# Personalize home path if not /home/benny
if [[ "$HOME" != "/home/benny" ]]; then
  sed -i "s|/home/benny|$HOME|g" "$RULE_DST"
fi

ok "Installed global Cursor rule: $RULE_DST"
echo
echo "Restart Cursor (or open a new Composer tab) so alwaysApply rules reload."
echo "OpenClaw context files:"
echo "  $OPENCLAW_WORKSPACE/SOUL.md"
echo "  $OPENCLAW_WORKSPACE/USER.md"
echo "  $OPENCLAW_WORKSPACE/AGENTS.md"
