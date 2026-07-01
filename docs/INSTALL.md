# Installing Beantr in an AI agent

Beantr does not run as a service. Installation means two things:

1. install the Beantr behavior instructions into your agent; and
2. create a Beantr ledger the agent can read and write.

## Fastest path

If you use Claude Code, install straight from inside the agent — no shell, no clone:

```text
/plugin marketplace add tiagomoraes/beantr
/plugin install beantr-coffee-os@beantr
```

For any other agent (or if you'd rather run one shell command), the bootstrap installer downloads the pack and installs it for you. With no arguments it detects whichever supported agents are present on your machine; pass an agent name to install for just one:

```bash
curl -fsSL https://beantr.tiagomoraes.cloud/install | bash
curl -fsSL https://beantr.tiagomoraes.cloud/install | bash -s -- claude-code ~/beantr
```

The rest of this page covers the manual install (clone/download + `installers/install.sh`), which the bootstrap script and plugin both wrap — useful if you want to inspect the pack first, run it in CI, or target an agent not auto-detected.

Clone the repository first if you have GitHub access:

```bash
git clone https://github.com/tiagomoraes/beantr.git
cd beantr
```

Or download the public agent pack from the landing page:

```bash
curl -L 'https://beantr.tiagomoraes.cloud/beantr-agent-pack-latest.tar.gz?v=20260630-templates' | tar xz
cd beantr
```

The installer is intentionally simple. It only copies Markdown/shell assets into paths each agent already reads (skills directories, `CLAUDE.md`, `AGENTS.md`) or, for GUI-only agents, packages a ZIP you upload by hand.

```bash
./installers/install.sh <agent> <ledger-path>
```

If no ledger path is supplied, it uses `~/beantr`. Supported `<agent>` values: `hermes`, `claude-code`, `opencode`, `openclaw`, `cowork`, `generic`.

Every target also creates `${BEANTR_HOME:-~/.beantr}/beantr-coffee-os.md` — a canonical copy of the skill instructions you can point any other tool at — and `${BEANTR_HOME:-~/.beantr}/config` with the ledger path.

## Hermes Agent

Hermes supports skills directly. Install Beantr as a Hermes skill:

```bash
./installers/install.sh hermes ~/beantr
```

What this does:

- copies `skills/beantr-coffee-os/` into `${HERMES_HOME:-~/.hermes}/skills/beantr-coffee-os`;
- creates `~/beantr` from the templates if it does not exist;
- writes `~/.beantr/config` with the selected ledger path.

Use it in Hermes by loading the skill or asking naturally:

```bash
hermes --skills beantr-coffee-os
```

Example prompt:

> Use the Beantr skill. Log this espresso: 18g in, 42g out, 31 seconds, sour but aromatic.

## Claude Code and Claude-style agents

Claude Code discovers Skills automatically from a `SKILL.md` folder — no manual prompt needed. Easiest: install it as a plugin from inside Claude Code itself (see [Fastest path](#fastest-path) above) — this repo is a self-hosted plugin marketplace, so `/plugin marketplace add tiagomoraes/beantr` + `/plugin install beantr-coffee-os@beantr` is the whole install.

Or install it the same way as every other agent here:

```bash
./installers/install.sh claude-code ~/beantr
```

What this does:

- copies `skills/beantr-coffee-os/` into `${CLAUDE_HOME:-~/.claude}/skills/beantr-coffee-os`, so Claude Code loads and auto-invokes it whenever a prompt is coffee-related;
- also appends a managed Beantr block to `~/.claude/CLAUDE.md` (created if missing) as a standing reminder of the ledger path — safe to delete if you only want skill-based invocation;
- creates the Beantr ledger from templates.

If you'd rather keep this project-local instead of installing the skill globally for every Claude Code session, copy `skills/beantr-coffee-os/` into a specific project's `.claude/skills/beantr-coffee-os/` instead, or paste the block from `installers/snippets/claude-code.md` into that project's `CLAUDE.md` (replace `${BEANTR_HOME}` and `${LEDGER_PATH}` with real paths).

## OpenCode

[OpenCode](https://opencode.ai) reads the same `SKILL.md` format as Claude Code and also supports `AGENTS.md`. Install both:

```bash
./installers/install.sh opencode ~/beantr
```

What this does:

- copies `skills/beantr-coffee-os/` into `${OPENCODE_HOME:-~/.config/opencode}/skills/beantr-coffee-os`;
- appends a managed Beantr block to `${OPENCODE_HOME:-~/.config/opencode}/AGENTS.md`;
- creates the Beantr ledger from templates.

OpenCode also reads skills straight out of `~/.claude/skills` and project-level `.claude/skills` / `.opencode/skills` (see [OpenCode's skills docs](https://opencode.ai/docs/skills/)), so if you already ran the `claude-code` installer target on the same machine, OpenCode picks up the same skill with no extra step, unless you've set `OPENCODE_DISABLE_CLAUDE_CODE_SKILLS=1`.

## OpenClaw

[OpenClaw](https://github.com/openclaw/openclaw) is a self-hosted gateway that connects chat apps (Telegram, Slack, Discord, WhatsApp, and more) to an agent runtime. It reads the same `SKILL.md` format directly:

```bash
./installers/install.sh openclaw ~/beantr
```

What this does:

- copies `skills/beantr-coffee-os/` into `${OPENCLAW_HOME:-~/.openclaw}/skills/beantr-coffee-os` — OpenClaw's global skills directory, loaded for every agent;
- creates the Beantr ledger from templates.

OpenClaw resolves skills in this order: `<workspace>/skills`, `<workspace>/.agents/skills`, `~/.agents/skills`, `~/.openclaw/skills`, then bundled/extra directories, so a per-agent workspace install always wins over the global one. If you want Beantr force-loaded into the system prompt every turn instead of relying on skill auto-invocation, paste `installers/snippets/openclaw.md` into your agent workspace's `AGENTS.md` bootstrap file (defaults to `~/.openclaw/workspace/AGENTS.md`, or wherever `agents.defaults.workspace` points).

If your OpenClaw agent is configured to run Claude Code, Codex, or another coding CLI as its backend, that backend's own install target above also applies inside those sessions.

## Claude Cowork

Claude Cowork runs inside the Claude Desktop app and uses the same Skills mechanism as Claude Code, but skills are uploaded through the UI rather than placed on disk directly. Build the upload package:

```bash
./installers/install.sh cowork ~/beantr
```

What this does:

- packages `skills/beantr-coffee-os/` into `dist/beantr-coffee-os-skill.zip`;
- creates the Beantr ledger from templates so you have something to point Cowork at.

Then, in Claude Desktop:

1. Open **Settings → Cowork → Customize → Skills**, click **+ → Create skill → Upload a skill**, and select `dist/beantr-coffee-os-skill.zip`.
2. Grant Cowork access to your `~/beantr` folder (or wherever you passed as `<ledger-path>`) so it can read and write the ledger.
3. Optional: open **Settings → Cowork → Global Instructions** (or a folder-level instruction, scoped to the ledger folder) and paste the text from `installers/snippets/cowork.md`, replacing `${LEDGER_PATH}` with your real path. This is only needed if you want Beantr's ledger path pinned outside of skill auto-invocation.

## Generic file-capable assistants

For any assistant that can read and write files:

```bash
./installers/install.sh generic ~/beantr
```

Then give the assistant this instruction:

> Use Beantr. Read `~/.beantr/beantr-coffee-os.md`, then manage my coffee ledger at `~/beantr` by updating current Markdown files and appending monthly logs.

## Uninstalling

Beantr is only files. If you installed the Claude Code plugin, run `/plugin uninstall beantr-coffee-os@beantr` (and `/plugin marketplace remove beantr` if you don't want the marketplace either). Otherwise, remove the skill/snippet for whichever agent you installed:

```bash
rm -rf ~/.hermes/skills/beantr-coffee-os
rm -rf ~/.claude/skills/beantr-coffee-os
rm -rf ~/.config/opencode/skills/beantr-coffee-os
rm -rf ~/.openclaw/skills/beantr-coffee-os
rm -rf ~/.beantr
```

Also remove the managed block (between `<!-- BEGIN BEANTR -->` and `<!-- END BEANTR -->`) from `~/.claude/CLAUDE.md` or `~/.config/opencode/AGENTS.md` if you added one, and delete the uploaded skill from Cowork's Customize panel.

Do **not** delete the Beantr ledger unless you intentionally want to remove your coffee data.
