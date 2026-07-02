# Uninstalling Beantr

Beantr is only files: behavior instructions copied into your agent, plus a
coffee ledger you own. Uninstalling means undoing the wiring the installer
added. **Your ledger is your data — nothing here deletes it unless you run the
command yourself.**

## Fastest path

If you installed the Claude Code plugin, remove it from inside Claude Code:

```text
/plugin uninstall beantr-coffee-os@beantr
/plugin marketplace remove beantr
```

The second line is optional — drop it if you want to keep the marketplace for
reinstalling later.

For any other agent (or a shell install), the bootstrap uninstaller mirrors the
installer. Run it with no arguments to see what's installed and the command to
remove each — it removes nothing on its own. Name an agent to remove one, or
pass `all` to remove every detected agent:

```bash
curl -fsSL https://beantr.tiagomoraes.cloud/uninstall | bash                    # show what's installed (removes nothing)
curl -fsSL https://beantr.tiagomoraes.cloud/uninstall | bash -s -- claude-code  # remove one agent
curl -fsSL https://beantr.tiagomoraes.cloud/uninstall | bash -s -- all          # remove every detected agent
```

## Using the script from a clone or the pack

If you cloned the repository or downloaded the pack (see [INSTALL.md](INSTALL.md)),
run the uninstaller directly — it is the mirror of `installers/install.sh` and
the bootstrap above wraps it:

```bash
./installers/uninstall.sh <agent>    # remove Beantr for one agent
./installers/uninstall.sh all        # remove Beantr for every detected agent
./installers/uninstall.sh            # list what's installed, remove nothing
```

Supported `<agent>` values: `hermes`, `claude-code`, `opencode`, `openclaw`,
`cowork`, `generic`.

## What gets removed

| Agent | Removed |
|---|---|
| `hermes` | `${HERMES_HOME:-~/.hermes}/skills/beantr-coffee-os` |
| `claude-code` | `${CLAUDE_HOME:-~/.claude}/skills/beantr-coffee-os` and the managed block in `~/.claude/CLAUDE.md` |
| `opencode` | `${OPENCODE_HOME:-~/.config/opencode}/skills/beantr-coffee-os` and the managed block in that agent's `AGENTS.md` |
| `openclaw` | `${OPENCLAW_HOME:-~/.openclaw}/skills/beantr-coffee-os` (remove any snippet you pasted into a workspace `AGENTS.md` by hand) |
| `cowork` | `dist/beantr-coffee-os-skill.zip`; delete the uploaded skill from **Settings → Cowork → Customize → Skills** in Claude Desktop |
| `generic` | `${BEANTR_HOME:-~/.beantr}/README.md` |

Removing the managed block leaves the rest of your `CLAUDE.md` / `AGENTS.md`
untouched; if the block was the only thing in the file, the empty file is
removed. When the **last** agent is uninstalled, the shared files in
`${BEANTR_HOME:-~/.beantr}` (`beantr-coffee-os.md` and `config`) are cleaned up
too. `uninstall.sh all` does this in one pass.

## Manual removal

If you'd rather remove things by hand — or the script can't reach an agent it
doesn't auto-detect — delete the folders directly:

```bash
rm -rf ~/.hermes/skills/beantr-coffee-os
rm -rf ~/.claude/skills/beantr-coffee-os
rm -rf ~/.config/opencode/skills/beantr-coffee-os
rm -rf ~/.openclaw/skills/beantr-coffee-os
rm -rf ~/.beantr
```

Also remove the managed block (between `<!-- BEGIN BEANTR -->` and
`<!-- END BEANTR -->`) from `~/.claude/CLAUDE.md` or
`~/.config/opencode/AGENTS.md` if you added one, and delete the uploaded skill
from Cowork's Customize panel.

## Your coffee data

The ledger (default `~/beantr`, or wherever you pointed the installer) is
**never** deleted by the uninstaller — the script prints its location on the way
out so you can find it. Delete it yourself only if you truly want your coffee
history gone:

```bash
rm -rf ~/beantr
```
