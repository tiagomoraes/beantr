#!/usr/bin/env bash
set -euo pipefail

AGENT="${1:-generic}"
LEDGER_PATH="${2:-$HOME/beantr}"
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BEANTR_HOME="${BEANTR_HOME:-$HOME/.beantr}"
SKILL_SRC="$REPO_DIR/skills/beantr-coffee-os"
TEMPLATE_SRC="$REPO_DIR/templates/beantr"

mkdir -p "$BEANTR_HOME"
mkdir -p "$LEDGER_PATH"

copy_templates() {
  (cd "$TEMPLATE_SRC" && tar cf - .) | (cd "$LEDGER_PATH" && tar xkf -)
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
    echo "Unknown agent '$AGENT'. Use: hermes, claude-code, opencode, openclaw, cowork, generic." >&2
    exit 2
    ;;
esac

echo "Beantr ledger: $LEDGER_PATH"
echo "Beantr instruction file: $BEANTR_HOME/beantr-coffee-os.md"
