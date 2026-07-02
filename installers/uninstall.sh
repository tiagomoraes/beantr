#!/usr/bin/env bash
set -euo pipefail

# Beantr uninstaller. The mirror of install.sh — it only removes the wiring
# install.sh adds (skill folders, managed CLAUDE.md/AGENTS.md blocks, the
# canonical instruction file, and the config). It NEVER deletes your coffee
# ledger; that is your data and is left untouched, with the path printed so you
# can remove it by hand if you really want to.
#
#   ./installers/uninstall.sh <agent>    remove Beantr for one agent
#   ./installers/uninstall.sh all        remove Beantr for every detected agent
#   ./installers/uninstall.sh            show what's installed + how to remove it (removes nothing)
#
# Supported <agent> values: hermes, claude-code, opencode, openclaw, cowork, generic.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BEANTR_HOME="${BEANTR_HOME:-$HOME/.beantr}"

# Report the ledger path recorded at install time, if we can find it.
ledger_path() {
  if [ -f "$BEANTR_HOME/config" ]; then
    sed -n 's/^BEANTR_LEDGER=//p' "$BEANTR_HOME/config" | head -n1
  fi
}

remove_skill_dir() {
  local skills_root="$1"
  local dir="$skills_root/beantr"
  if [ -d "$dir" ]; then
    rm -rf "$dir"
    echo "Removed $dir"
    # Tidy up the skills root if we left it empty.
    rmdir "$skills_root" 2>/dev/null || true
  fi
}

# Strip the managed block (between the BEGIN/END markers) install.sh inserted,
# leaving any other content in the file intact. Removes the file entirely if it
# is empty afterwards.
remove_managed_block() {
  local target="$1"
  [ -f "$target" ] || return 0
  python3 - "$target" <<'PY'
from pathlib import Path
import sys

target = Path(sys.argv[1])
text = target.read_text(encoding='utf-8')
start = '<!-- BEGIN BEANTR -->'
end = '<!-- END BEANTR -->'
if start in text and end in text:
    before = text.split(start, 1)[0].rstrip()
    after = text.split(end, 1)[1].lstrip()
    remaining = (before + ("\n\n" if before and after else "") + after).strip()
    if remaining:
        target.write_text(remaining + "\n", encoding='utf-8')
        print(f"Removed Beantr block from {target}")
    else:
        target.unlink()
        print(f"Removed {target} (only held the Beantr block)")
else:
    print(f"No Beantr block found in {target} (left as-is)")
PY
}

# Remove the shared Beantr home (instruction file + config + generic readme),
# but never the ledger. Only runs when no agent install remains.
remove_shared_home() {
  local removed=0
  for f in beantr.md config README.md; do
    if [ -e "$BEANTR_HOME/$f" ]; then
      rm -f "$BEANTR_HOME/$f"
      removed=1
    fi
  done
  if [ "$removed" -eq 1 ]; then
    echo "Removed shared Beantr files from $BEANTR_HOME"
  fi
  # Drop the directory too if nothing else lives there.
  rmdir "$BEANTR_HOME" 2>/dev/null || true
}

# Print the supported agents that currently have Beantr installed, one per line.
detect_installed() {
  local hermes_home="${HERMES_HOME:-$HOME/.hermes}"
  local claude_home="${CLAUDE_HOME:-$HOME/.claude}"
  local opencode_home="${OPENCODE_HOME:-$HOME/.config/opencode}"
  local openclaw_home="${OPENCLAW_HOME:-$HOME/.openclaw}"

  [ -d "$hermes_home/skills/beantr" ] && echo hermes
  if [ -d "$claude_home/skills/beantr" ] || grep -q 'BEGIN BEANTR' "$claude_home/CLAUDE.md" 2>/dev/null; then
    echo claude-code
  fi
  if [ -d "$opencode_home/skills/beantr" ] || grep -q 'BEGIN BEANTR' "$opencode_home/AGENTS.md" 2>/dev/null; then
    echo opencode
  fi
  [ -d "$openclaw_home/skills/beantr" ] && echo openclaw
  return 0
}

# Uninstall exactly one agent. Args: <agent>.
uninstall_one() {
  AGENT="$1"

  case "$AGENT" in
    hermes|hermes-agent)
      remove_skill_dir "${HERMES_HOME:-$HOME/.hermes}/skills"
      ;;
    claude|claude-code)
      CLAUDE_HOME_DIR="${CLAUDE_HOME:-$HOME/.claude}"
      remove_skill_dir "$CLAUDE_HOME_DIR/skills"
      remove_managed_block "$CLAUDE_HOME_DIR/CLAUDE.md"
      ;;
    opencode|agents-md)
      OPENCODE_HOME_DIR="${OPENCODE_HOME:-$HOME/.config/opencode}"
      remove_skill_dir "$OPENCODE_HOME_DIR/skills"
      remove_managed_block "$OPENCODE_HOME_DIR/AGENTS.md"
      ;;
    openclaw)
      remove_skill_dir "${OPENCLAW_HOME:-$HOME/.openclaw}/skills"
      echo "If you pasted installers/snippets/openclaw.md into a workspace AGENTS.md, remove that block by hand."
      ;;
    cowork|claude-cowork)
      rm -f "$REPO_DIR/dist/beantr-skill.zip" 2>/dev/null || true
      echo "Cowork skills live in the app, not on disk."
      echo "In Claude Desktop: Settings > Cowork > Customize > Skills, then delete the Beantr skill."
      echo "Also clear any Beantr text from Global/folder Instructions if you added it."
      ;;
    generic)
      rm -f "$BEANTR_HOME/README.md" 2>/dev/null || true
      echo "Removed generic Beantr instructions from $BEANTR_HOME"
      ;;
    *)
      echo "Unknown agent '$AGENT'. Use: hermes, claude-code, opencode, openclaw, cowork, generic, all." >&2
      return 2
      ;;
  esac
  echo "Uninstalled Beantr for $AGENT."
}

# If nothing is installed anymore, clean up the shared home too.
cleanup_if_last() {
  local remaining
  remaining="$(detect_installed)"
  if [ -z "$remaining" ]; then
    remove_shared_home
  fi
}

# No agent named: remove nothing, report what's installed and how to remove it.
show_guidance() {
  local installed
  installed="$(detect_installed)"
  echo "Beantr uninstalls one agent at a time — nothing was removed." >&2
  echo >&2
  if [ -n "$installed" ]; then
    echo "Beantr is installed for:" >&2
    echo "$installed" | sed 's/^/  - /' >&2
  else
    echo "No installed agent auto-detected (you can still name one below)." >&2
  fi
  echo >&2
  echo "Re-run naming the agent to remove, e.g.:" >&2
  echo "  uninstall.sh claude-code" >&2
  echo "  uninstall.sh hermes | opencode | openclaw | cowork | generic" >&2
  echo "  uninstall.sh all          # every detected agent" >&2
  echo >&2
  local ledger
  ledger="$(ledger_path)"
  if [ -n "$ledger" ]; then
    echo "Your coffee ledger is never touched. It lives at: $ledger" >&2
    echo "Delete it yourself only if you want your data gone: rm -rf \"$ledger\"" >&2
  fi
  echo "Docs: https://github.com/tiagomoraes/beantr/blob/main/docs/UNINSTALL.md" >&2
}

# Uninstall every detected agent.
uninstall_all() {
  local installed
  installed="$(detect_installed)"
  if [ -z "$installed" ]; then
    echo "No installed agents detected to remove. Name one explicitly instead (see: uninstall.sh)." >&2
    remove_shared_home
    return 0
  fi
  local failed=0
  while IFS= read -r a; do
    [ -n "$a" ] || continue
    echo "==> Removing Beantr for $a" >&2
    if ! uninstall_one "$a"; then
      echo "!! $a uninstall failed (continuing with the rest)" >&2
      failed=1
    fi
  done <<< "$installed"
  remove_shared_home
  return "$failed"
}

main() {
  if [ "$#" -eq 0 ]; then
    show_guidance
    exit 0
  fi
  # Capture the ledger path before config is (possibly) removed so we can still
  # report it afterwards.
  local ledger
  ledger="$(ledger_path)"
  case "$1" in
    all)
      uninstall_all
      ;;
    *)
      uninstall_one "$1"
      cleanup_if_last
      ;;
  esac
  if [ -n "$ledger" ] && [ -d "$ledger" ]; then
    echo
    echo "Your coffee ledger was left untouched at: $ledger"
    echo "Remove it yourself only if you want your data gone: rm -rf \"$ledger\""
  fi
}

main "$@"
