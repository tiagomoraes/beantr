# Installing Beantr in an AI agent

Beantr does not run as a service. Installation means two things:

1. install the Beantr behavior instructions into your agent; and
2. create a Beantr ledger the agent can read and write.

## Fastest path

If you use Claude Code, install straight from inside the agent — no shell, no clone:

```text
/plugin marketplace add tiagomoraes/beantr
/plugin install beantr@beantr
```

For any other agent (or if you'd rather run one shell command), the bootstrap installer downloads the pack and installs it for you. Beantr installs one agent at a time, so pass the agent name. Run it with no arguments to see which supported agents are detected on your machine and the exact command to install each — it installs nothing on its own. Pass `all` to install for every detected agent in one go:

```bash
curl -fsSL https://beantr.tiagomoraes.cloud/install | bash                              # show detected agents (installs nothing)
curl -fsSL https://beantr.tiagomoraes.cloud/install | bash -s -- claude-code ~/beantr   # one agent
curl -fsSL https://beantr.tiagomoraes.cloud/install | bash -s -- all                    # every detected agent
```

The rest of this page covers the manual install (clone/download + `installers/install.sh`), which the bootstrap script and plugin both wrap — useful if you want to inspect the pack first, run it in CI, or target an agent by name.

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

If no ledger path is supplied, it uses `~/beantr`. Supported `<agent>` values: `hermes`, `claude-code`, `opencode`, `openclaw`, `cowork`, `generic`. Use `all` in place of an agent to install for every detected agent (they share one ledger), or run `install.sh` with no arguments to list detected agents without installing anything.

Every target also creates `${BEANTR_HOME:-~/.beantr}/beantr.md` — a canonical copy of the skill instructions you can point any other tool at — and `${BEANTR_HOME:-~/.beantr}/config` with the ledger path.

## Hermes Agent

Hermes supports skills directly. Install Beantr as a Hermes skill:

```bash
./installers/install.sh hermes ~/beantr
```

What this does:

- copies `skills/beantr/` into `${HERMES_HOME:-~/.hermes}/skills/beantr`;
- creates `~/beantr` from the templates if it does not exist;
- writes `~/.beantr/config` with the selected ledger path.

Use it in Hermes by loading the skill or asking naturally:

```bash
hermes --skills beantr
```

Example prompt:

> Use the Beantr skill. Log this espresso: 18g in, 42g out, 31 seconds, sour but aromatic.

## Claude Code and Claude-style agents

Claude Code discovers Skills automatically from a `SKILL.md` folder — no manual prompt needed. Easiest: install it as a plugin from inside Claude Code itself (see [Fastest path](#fastest-path) above) — this repo is a self-hosted plugin marketplace, so `/plugin marketplace add tiagomoraes/beantr` + `/plugin install beantr@beantr` is the whole install.

Or install it the same way as every other agent here:

```bash
./installers/install.sh claude-code ~/beantr
```

What this does:

- copies `skills/beantr/` into `${CLAUDE_HOME:-~/.claude}/skills/beantr`, so Claude Code loads and auto-invokes it whenever a prompt is coffee-related;
- also appends a managed Beantr block to `~/.claude/CLAUDE.md` (created if missing) as a standing reminder of the ledger path — safe to delete if you only want skill-based invocation;
- creates the Beantr ledger from templates.

If you'd rather keep this project-local instead of installing the skill globally for every Claude Code session, copy `skills/beantr/` into a specific project's `.claude/skills/beantr/` instead, or paste the block from `installers/snippets/claude-code.md` into that project's `CLAUDE.md` (replace `${BEANTR_HOME}` and `${LEDGER_PATH}` with real paths).

## OpenCode

[OpenCode](https://opencode.ai) reads the same `SKILL.md` format as Claude Code and also supports `AGENTS.md`. Install both:

```bash
./installers/install.sh opencode ~/beantr
```

What this does:

- copies `skills/beantr/` into `${OPENCODE_HOME:-~/.config/opencode}/skills/beantr`;
- appends a managed Beantr block to `${OPENCODE_HOME:-~/.config/opencode}/AGENTS.md`;
- creates the Beantr ledger from templates.

OpenCode also reads skills straight out of `~/.claude/skills` and project-level `.claude/skills` / `.opencode/skills` (see [OpenCode's skills docs](https://opencode.ai/docs/skills/)), so if you already ran the `claude-code` installer target on the same machine, OpenCode picks up the same skill with no extra step, unless you've set `OPENCODE_DISABLE_CLAUDE_CODE_SKILLS=1`.

## OpenClaw

[OpenClaw](https://github.com/openclaw/openclaw) is a self-hosted gateway that connects chat apps (Telegram, Slack, Discord, WhatsApp, and more) to an agent runtime. It reads the same `SKILL.md` format directly:

```bash
./installers/install.sh openclaw ~/beantr
```

What this does:

- copies `skills/beantr/` into `${OPENCLAW_HOME:-~/.openclaw}/skills/beantr` — OpenClaw's global skills directory, loaded for every agent;
- creates the Beantr ledger from templates.

OpenClaw resolves skills in this order: `<workspace>/skills`, `<workspace>/.agents/skills`, `~/.agents/skills`, `~/.openclaw/skills`, then bundled/extra directories, so a per-agent workspace install always wins over the global one. If you want Beantr force-loaded into the system prompt every turn instead of relying on skill auto-invocation, paste `installers/snippets/openclaw.md` into your agent workspace's `AGENTS.md` bootstrap file (defaults to `~/.openclaw/workspace/AGENTS.md`, or wherever `agents.defaults.workspace` points).

If your OpenClaw agent is configured to run Claude Code, Codex, or another coding CLI as its backend, that backend's own install target above also applies inside those sessions.

## Claude Cowork

Claude Cowork runs inside the Claude Desktop app and uses the same Skills mechanism as Claude Code, but skills are uploaded through the UI rather than placed on disk directly. Build the upload package:

```bash
./installers/install.sh cowork ~/beantr
```

What this does:

- packages `skills/beantr/` into `dist/beantr-skill.zip`;
- creates the Beantr ledger from templates so you have something to point Cowork at.

Then, in Claude Desktop:

1. Open **Settings → Cowork → Customize → Skills**, click **+ → Create skill → Upload a skill**, and select `dist/beantr-skill.zip`.
2. Grant Cowork access to your `~/beantr` folder (or wherever you passed as `<ledger-path>`) so it can read and write the ledger.
3. Optional: open **Settings → Cowork → Global Instructions** (or a folder-level instruction, scoped to the ledger folder) and paste the text from `installers/snippets/cowork.md`, replacing `${LEDGER_PATH}` with your real path. This is only needed if you want Beantr's ledger path pinned outside of skill auto-invocation.

## Generic file-capable assistants

For any assistant that can read and write files:

```bash
./installers/install.sh generic ~/beantr
```

Then give the assistant this instruction:

> Use Beantr. Read `~/.beantr/beantr.md`, then manage my coffee ledger at `~/beantr` by updating current Markdown files and appending monthly logs.

## Updating

To pull a newer Beantr into an existing install, re-apply the latest pack. Plugin users run `/plugin update beantr@beantr`; everyone else uses the bootstrap updater or the script from a clone. It refreshes every agent you already have installed, at the ledger path recorded at install time, and never touches your coffee data:

```bash
curl -fsSL https://beantr.tiagomoraes.cloud/update | bash                    # update every installed agent
curl -fsSL https://beantr.tiagomoraes.cloud/update | bash -s -- claude-code  # or just one
./installers/update.sh                                                       # or, from a clone/pack after `git pull`
```

See [UPDATE.md](UPDATE.md) for exactly what an update changes and how versions are reported.

## Uninstalling

Uninstalling mirrors installing. If you installed the Claude Code plugin, run `/plugin uninstall beantr@beantr` (and `/plugin marketplace remove beantr` if you don't want the marketplace either). For any other agent, the uninstaller undoes exactly what the installer added — run it with no arguments to see what's installed and how to remove each (it removes nothing), name an agent to remove one, or pass `all`:

```bash
curl -fsSL https://beantr.tiagomoraes.cloud/uninstall | bash              # show what's installed (removes nothing)
curl -fsSL https://beantr.tiagomoraes.cloud/uninstall | bash -s -- all    # remove every detected agent
./installers/uninstall.sh claude-code                                     # or, from a clone/pack: one agent
```

The uninstaller **never** deletes your coffee ledger — it prints the path on the way out so you can remove it by hand if you want to. See [UNINSTALL.md](UNINSTALL.md) for the full guide: what each agent target removes, and step-by-step manual removal.
