#!/usr/bin/env bash
set -euo pipefail

# Beantr updater. Re-applies the current pack to the agents you already have
# installed, so a skill, managed block, or instruction-file change ships to your
# machine. It reuses install.sh for the actual work, but drives it from the
# ledger path recorded at install time — so your ledger is never moved, reset to
# the default, or lost. New template files are seeded; existing ones are kept.
#
#   ./installers/update.sh          update every installed agent (the common case)
#   ./installers/update.sh all      same as above
#   ./installers/update.sh <agent>  update just one agent
#
# Supported <agent> values: hermes, claude-code, opencode, openclaw, cowork, generic.
#
# Claude Code plugin users update from inside the agent instead:
#   /plugin update beantr-coffee-os@beantr

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
INSTALL_SH="$SCRIPT_DIR/install.sh"
BEANTR_HOME="${BEANTR_HOME:-$HOME/.beantr}"

# Read a KEY=value line from the recorded config, if present.
config_get() {
  local key="$1"
  [ -f "$BEANTR_HOME/config" ] || return 0
  sed -n "s/^${key}=//p" "$BEANTR_HOME/config" | head -n1
}

# Version of the pack we're updating to, from the plugin manifest.
plugin_version() {
  local manifest="$REPO_DIR/.claude-plugin/plugin.json"
  [ -f "$manifest" ] || return 0
  sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$manifest" | head -n1
}

# Print the supported agents that currently have Beantr installed, one per line.
detect_installed() {
  local hermes_home="${HERMES_HOME:-$HOME/.hermes}"
  local claude_home="${CLAUDE_HOME:-$HOME/.claude}"
  local opencode_home="${OPENCODE_HOME:-$HOME/.config/opencode}"
  local openclaw_home="${OPENCLAW_HOME:-$HOME/.openclaw}"

  [ -d "$hermes_home/skills/beantr-coffee-os" ] && echo hermes
  if [ -d "$claude_home/skills/beantr-coffee-os" ] || grep -q 'BEGIN BEANTR' "$claude_home/CLAUDE.md" 2>/dev/null; then
    echo claude-code
  fi
  if [ -d "$opencode_home/skills/beantr-coffee-os" ] || grep -q 'BEGIN BEANTR' "$opencode_home/AGENTS.md" 2>/dev/null; then
    echo opencode
  fi
  [ -d "$openclaw_home/skills/beantr-coffee-os" ] && echo openclaw
  return 0
}

LEDGER=""
OLD_VERSION=""
NEW_VERSION=""
UPDATED=0

report_version() {
  [ -n "$NEW_VERSION" ] || return 0
  echo
  if [ -n "$OLD_VERSION" ] && [ "$OLD_VERSION" != "$NEW_VERSION" ]; then
    echo "Beantr updated: v$OLD_VERSION -> v$NEW_VERSION"
  elif [ -n "$OLD_VERSION" ] && [ "$OLD_VERSION" = "$NEW_VERSION" ]; then
    echo "Beantr was already v$NEW_VERSION — files refreshed to match this pack."
  else
    echo "Beantr updated to v$NEW_VERSION"
  fi
  echo "Ledger left in place at: $LEDGER"
}

# Nothing installed: update nothing, explain how to install.
show_guidance() {
  echo "No Beantr install detected — nothing to update." >&2
  echo >&2
  echo "Install it first (then re-running update keeps it current):" >&2
  echo "  install.sh claude-code ~/beantr    # see: install.sh" >&2
  echo >&2
  echo "Claude Code plugin users update from inside the agent instead:" >&2
  echo "  /plugin update beantr-coffee-os@beantr" >&2
  echo >&2
  echo "Docs: https://github.com/tiagomoraes/beantr/blob/main/docs/UPDATE.md" >&2
}

# Update every installed agent, reusing the recorded ledger path.
update_all() {
  local detected
  detected="$(detect_installed)"
  if [ -z "$detected" ]; then
    show_guidance
    return 0
  fi
  UPDATED=1
  local failed=0
  while IFS= read -r a; do
    [ -n "$a" ] || continue
    echo "==> Updating Beantr for $a" >&2
    if ! "$INSTALL_SH" "$a" "$LEDGER"; then
      echo "!! $a update failed (continuing with the rest)" >&2
      failed=1
    fi
  done <<< "$detected"
  return "$failed"
}

# Update one named agent. Installs it fresh if it wasn't set up yet.
update_one() {
  local agent="$1"
  if ! detect_installed | grep -qx "$agent"; then
    case "$agent" in
      hermes|claude-code|opencode|openclaw)
        echo "Note: $agent was not previously installed — installing it fresh at the current version." >&2
        ;;
    esac
  fi
  UPDATED=1
  "$INSTALL_SH" "$agent" "$LEDGER"
}

main() {
  # Capture the ledger path and installed version BEFORE install.sh rewrites the
  # config, so we can keep the ledger where it is and report the version delta.
  LEDGER="$(config_get BEANTR_LEDGER)"
  [ -n "$LEDGER" ] || LEDGER="$HOME/beantr"
  OLD_VERSION="$(config_get BEANTR_VERSION)"
  NEW_VERSION="$(plugin_version)"

  local rc=0
  case "${1:-}" in
    ""|all)
      update_all || rc=$?
      ;;
    *)
      update_one "$1" || rc=$?
      ;;
  esac

  [ "$UPDATED" = 1 ] && report_version
  return "$rc"
}

main "$@"
