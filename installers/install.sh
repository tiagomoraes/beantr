#!/usr/bin/env bash
set -euo pipefail

# Beantr installer.
#
#   ./installers/install.sh <agent> [ledger-path]   install for one agent
#   ./installers/install.sh all [ledger-path]        install for every detected agent
#   ./installers/install.sh                          show detected agents + how to install (installs nothing)
#
# Supported <agent> values: hermes, claude-code, opencode, openclaw, cowork, generic.

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BEANTR_HOME="${BEANTR_HOME:-$HOME/.beantr}"
SKILL_SRC="$REPO_DIR/skills/beantr-coffee-os"
TEMPLATE_SRC="$REPO_DIR/templates/beantr"

copy_templates() {
  # Seed starter ledger files, skipping any that already exist. Never fails on
  # reinstall. The old `tar xkf` exits 2 under GNU tar when a file exists
  # (Linux/Hermes) though bsdtar exits 0 (macOS) — under `set -e` that aborted
  # any repeat install and any second agent sharing the same ledger.
  ( cd "$TEMPLATE_SRC" && find . -type f -print ) | while IFS= read -r rel; do
    dest="$LEDGER_PATH/${rel#./}"
    if [ ! -e "$dest" ]; then
      mkdir -p "$(dirname "$dest")"
      cp "$TEMPLATE_SRC/$rel" "$dest"
    fi
  done
}

install_instruction_file() {
  cp "$SKILL_SRC/SKILL.md" "$BEANTR_HOME/beantr-coffee-os.md"
}

replace_managed_block() {
  local target="$1"
  local snippet="$2"
  mkdir -p "$(dirname "$target")"
  touch "$target"
  python3 - "$target" "$snippet" "$BEANTR_HOME" "$LEDGER_PATH" <<'PY'
from pathlib import Path
import sys

target = Path(sys.argv[1])
snippet_path = Path(sys.argv[2])
beantr_home = sys.argv[3]
ledger_path = sys.argv[4]
text = target.read_text(encoding='utf-8') if target.exists() else ''
snippet = snippet_path.read_text(encoding='utf-8')
snippet = snippet.replace('${BEANTR_HOME}', beantr_home).replace('${LEDGER_PATH}', ledger_path)
start = '<!-- BEGIN BEANTR -->'
end = '<!-- END BEANTR -->'
if start in text and end in text:
    before = text.split(start, 1)[0].rstrip()
    after = text.split(end, 1)[1].lstrip()
    new_text = f"{before}\n\n{snippet.strip()}\n\n{after}".strip() + "\n"
else:
    new_text = (text.rstrip() + "\n\n" + snippet.strip() + "\n").lstrip()
target.write_text(new_text, encoding='utf-8')
PY
}

install_skill_dir() {
  local skills_root="$1"
  mkdir -p "$skills_root"
  rm -rf "$skills_root/beantr-coffee-os"
  cp -R "$SKILL_SRC" "$skills_root/beantr-coffee-os"
}

package_cowork_zip() {
  local out_base="$REPO_DIR/dist/beantr-coffee-os-skill"
  mkdir -p "$REPO_DIR/dist"
  python3 - "$SKILL_SRC" "$out_base" <<'PY'
from pathlib import Path
import shutil
import sys

skill_src = Path(sys.argv[1])
out_base = sys.argv[2]
shutil.make_archive(out_base, 'zip', root_dir=skill_src.parent, base_dir=skill_src.name)
PY
}

# Print the supported agents detected on this machine, one per line.
detect_agents() {
  if [ -d "$HOME/.hermes" ] && command -v hermes >/dev/null 2>&1; then echo hermes; fi
  if [ -d "$HOME/.claude" ]; then echo claude-code; fi
  if command -v opencode >/dev/null 2>&1; then echo opencode; fi
  if [ -d "$HOME/.openclaw" ]; then echo openclaw; fi
}

# Install for exactly one agent. Args: <agent> [ledger-path].
install_one() {
  AGENT="$1"
  LEDGER_PATH="${2:-$HOME/beantr}"

  mkdir -p "$BEANTR_HOME"
  mkdir -p "$LEDGER_PATH"
  copy_templates
  install_instruction_file
  cat > "$BEANTR_HOME/config" <<EOF
BEANTR_LEDGER=$LEDGER_PATH
BEANTR_INSTRUCTIONS=$BEANTR_HOME/beantr-coffee-os.md
EOF

  case "$AGENT" in
    hermes|hermes-agent)
      HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
      install_skill_dir "$HERMES_HOME/skills"
      echo "Installed Beantr skill to $HERMES_HOME/skills/beantr-coffee-os"
      ;;
    claude|claude-code)
      CLAUDE_HOME_DIR="${CLAUDE_HOME:-$HOME/.claude}"
      install_skill_dir "$CLAUDE_HOME_DIR/skills"
      replace_managed_block "$CLAUDE_HOME_DIR/CLAUDE.md" "$REPO_DIR/installers/snippets/claude-code.md"
      echo "Installed Beantr skill to $CLAUDE_HOME_DIR/skills/beantr-coffee-os"
      echo "Installed Beantr Claude instructions to $CLAUDE_HOME_DIR/CLAUDE.md"
      ;;
    opencode|agents-md)
      OPENCODE_HOME_DIR="${OPENCODE_HOME:-$HOME/.config/opencode}"
      install_skill_dir "$OPENCODE_HOME_DIR/skills"
      replace_managed_block "$OPENCODE_HOME_DIR/AGENTS.md" "$REPO_DIR/installers/snippets/opencode.md"
      echo "Installed Beantr skill to $OPENCODE_HOME_DIR/skills/beantr-coffee-os"
      echo "Installed Beantr AGENTS.md instructions to $OPENCODE_HOME_DIR/AGENTS.md"
      ;;
    openclaw)
      OPENCLAW_HOME="${OPENCLAW_HOME:-$HOME/.openclaw}"
      install_skill_dir "$OPENCLAW_HOME/skills"
      echo "Installed Beantr skill to $OPENCLAW_HOME/skills/beantr-coffee-os"
      echo "Optional: add installers/snippets/openclaw.md to your OpenClaw workspace AGENTS.md to force-load it every turn."
      ;;
    cowork|claude-cowork)
      package_cowork_zip
      echo "Packaged $REPO_DIR/dist/beantr-coffee-os-skill.zip"
      echo "In Claude Desktop: Settings > Cowork > Customize > Skills > + > Upload a skill, then select that zip."
      ;;
    generic)
      cp "$REPO_DIR/installers/snippets/generic.md" "$BEANTR_HOME/README.md"
      echo "Installed generic Beantr instructions to $BEANTR_HOME"
      ;;
    *)
      echo "Unknown agent '$AGENT'. Use: hermes, claude-code, opencode, openclaw, cowork, generic, all." >&2
      return 2
      ;;
  esac

  echo "Beantr ledger: $LEDGER_PATH"
  echo "Beantr instruction file: $BEANTR_HOME/beantr-coffee-os.md"
}

# No agent named: install nothing, report what's here and how to install it.
show_guidance() {
  local detected
  detected="$(detect_agents)"
  echo "Beantr installs one agent at a time — nothing was installed." >&2
  echo >&2
  if [ -n "$detected" ]; then
    echo "Agents detected on this machine:" >&2
    echo "$detected" | sed 's/^/  - /' >&2
  else
    echo "No known agent auto-detected (you can still name one below)." >&2
  fi
  echo >&2
  echo "Re-run naming the agent you want, e.g.:" >&2
  echo "  install.sh hermes ~/beantr" >&2
  echo "  install.sh claude-code ~/beantr" >&2
  echo "  install.sh opencode | openclaw | cowork | generic" >&2
  echo "  install.sh all             # every detected agent, sharing one ledger" >&2
  echo >&2
  echo "Docs: https://github.com/tiagomoraes/beantr" >&2
}

# Install for every detected agent. Args: [ledger-path].
install_all() {
  local ledger="${1:-$HOME/beantr}"
  local detected
  detected="$(detect_agents)"
  if [ -z "$detected" ]; then
    echo "No agents detected to install for. Name one explicitly instead (see: install.sh)." >&2
    return 1
  fi
  local failed=0
  while IFS= read -r a; do
    [ -n "$a" ] || continue
    echo "==> Installing Beantr for $a" >&2
    if ! install_one "$a" "$ledger"; then
      echo "!! $a install failed (continuing with the rest)" >&2
      failed=1
    fi
  done <<< "$detected"
  return "$failed"
}

main() {
  if [ "$#" -eq 0 ]; then
    show_guidance
    exit 0
  fi
  case "$1" in
    all)
      shift
      install_all "$@"
      ;;
    *)
      install_one "$@"
      ;;
  esac
}

main "$@"
