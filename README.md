# Beantr

**Beantr is an agent pack for managing a personal coffee context through the filesystem.**

It used to be an API + MCP server. This repository is now intentionally simpler: it gives AI agents a portable skill, a Markdown-based coffee ledger, install snippets, and documentation so tools like Hermes, Claude Code, OpenCode, OpenClaw, Claude Cowork, and other personal assistants can read and update your coffee life without running a database or a service.

## What Beantr is now

Beantr is not a backend. It is a small operating manual for LLM agents:

- a **skill** that teaches an agent how to manage coffee inventory, brew logs, recipes, and recommendations;
- a **filesystem layout** made of Markdown files that humans and agents can both edit;
- **templates** for a fresh coffee ledger;
- **installer snippets** for common agent environments, plus a Claude Code plugin marketplace and a one-line bootstrap installer for near-zero-friction setup;
- a **static landing page** with setup instructions.

The core idea is: give the agent ordinary file tools and a clear contract. The agent becomes the interface.

```text
You ──chat/voice──> Agent ──read/write──> ~/beantr/*.md
```

## Why the filesystem

The old implementation optimized for APIs, auth, Postgres, and MCP tools. That was powerful, but too rigid for the way personal assistants actually work.

The new Beantr optimizes for:

- **low ceremony**: no server, no database, no migrations;
- **agent portability**: works with any assistant that can read and write files;
- **human readability**: every fact lives in Markdown;
- **versionability**: keep the ledger in Git, Obsidian, iCloud, Dropbox, or a plain folder;
- **context quality**: current state is separated from append-only logs and distilled insights.

## Repository layout

```text
beantr/
  skills/beantr/       # Portable skill pack for agents
  templates/beantr/           # Starter ledger files
  installers/                    # Agent-specific install helpers/snippets
  docs/                          # English documentation
  site/                          # Static landing page + bootstrap installer
  .claude-plugin/                # Claude Code plugin/marketplace manifest
  scripts/validate.py            # Repository sanity check only
```

## Quick start

Fastest path: inside Claude Code, install this repo as a plugin (no clone needed):

```text
/plugin marketplace add tiagomoraes/beantr
/plugin install beantr@beantr
```

For any other agent, name the one you want. Run with no agent to see which agents are detected on your machine (this installs nothing), or pass `all` to install for every detected agent at once:

```bash
curl -fsSL https://beantr.tiagomoraes.cloud/install | bash                    # show detected agents + how to install
curl -fsSL https://beantr.tiagomoraes.cloud/install | bash -s -- hermes       # install for one agent
curl -fsSL https://beantr.tiagomoraes.cloud/install | bash -s -- all          # install for every detected agent
```

Or do it by hand. Clone the repository if you have GitHub access:

```bash
git clone https://github.com/tiagomoraes/beantr.git
cd beantr
```

Or download the public agent pack from the landing page:

```bash
curl -L 'https://beantr.tiagomoraes.cloud/beantr-agent-pack-latest.tar.gz?v=20260630-templates' | tar xz
cd beantr
```

Install the skill and create a starter ledger:

```bash
# Hermes Agent
./installers/install.sh hermes ~/beantr

# Claude Code / Claude-style agents
./installers/install.sh claude-code ~/beantr

# OpenCode
./installers/install.sh opencode ~/beantr

# OpenClaw
./installers/install.sh openclaw ~/beantr

# Claude Cowork (packages a skill zip for the Customize panel)
./installers/install.sh cowork ~/beantr

# Generic: just create ~/.beantr/AGENTS.md and ~/beantr
./installers/install.sh generic ~/beantr
```

Then ask your agent things like:

- "Log this espresso shot: 18g in, 42g out, 31s, a bit sour."
- "What coffee is in tube A07?"
- "Recommend a V60 recipe for the washed Ethiopian coffee."
- "Update my current beans and tell me what I should finish first."
- "Summarize what worked best this month."

## The Beantr ledger

A Beantr ledger defaults to `~/beantr`:

```text
beantr/
  README.md
  beans/current.md
  beans/history/YYYY-MM.md
  gear/current.md
  gear/history/YYYY-MM.md
  recipes/current.md
  sessions/YYYY-MM.md
  insights/current.md
```

The `current.md` files answer "what is true now?". Monthly files are append-only logs. `insights/current.md` is where the agent distills recommendations from repeated use.

See [docs/LEDGER.md](docs/LEDGER.md) for the full contract.

## Agent install guides

- [Hermes Agent](docs/INSTALL.md#hermes-agent)
- [Claude Code and Claude-style agents](docs/INSTALL.md#claude-code-and-claude-style-agents)
- [OpenCode](docs/INSTALL.md#opencode)
- [OpenClaw](docs/INSTALL.md#openclaw)
- [Claude Cowork](docs/INSTALL.md#claude-cowork)
- [Generic file-capable assistants](docs/INSTALL.md#generic-file-capable-assistants)

## Updating

Pull a newer Beantr into an existing install by re-applying the latest pack. Plugin users run `/plugin update beantr@beantr`; everyone else uses the bootstrap updater or the script after `git pull`. It refreshes every installed agent at the ledger path recorded at install time and never touches your coffee data:

```bash
curl -fsSL https://beantr.tiagomoraes.cloud/update | bash                    # update every installed agent
curl -fsSL https://beantr.tiagomoraes.cloud/update | bash -s -- claude-code  # or just one
./installers/update.sh                                                       # or, from a clone/pack
```

See [docs/UPDATE.md](docs/UPDATE.md) for what an update changes and how versions are reported.

## Uninstalling

Uninstalling mirrors installing and never touches your coffee ledger. Plugin users run `/plugin uninstall beantr@beantr`; everyone else uses the bootstrap uninstaller or the script from a clone:

```bash
curl -fsSL https://beantr.tiagomoraes.cloud/uninstall | bash              # show what's installed (removes nothing)
curl -fsSL https://beantr.tiagomoraes.cloud/uninstall | bash -s -- all    # remove every detected agent
./installers/uninstall.sh claude-code                                     # or, from a clone/pack: one agent
```

See [docs/UNINSTALL.md](docs/UNINSTALL.md) for per-agent details and manual removal.

## Development

This repository intentionally has no runtime dependencies. The validation script only checks the pack structure and docs links.

```bash
make validate        # structure + doc-link checks
make preview-site    # serve the landing page at http://localhost:8088
```

## Contributing

Beantr is open source and contributions are welcome. Every change starts as a
GitHub issue, then a pull request against `develop` following a gitflow branch
model. See [CONTRIBUTING.md](CONTRIBUTING.md) for the full flow and the
[Code of Conduct](CODE_OF_CONDUCT.md); see [docs/RELEASING.md](docs/RELEASING.md)
for how releases are cut and published.

## Design principles

1. **The filesystem is the API.** Agents should use ordinary file tools.
2. **Current state beats inferred state.** Do not reconstruct today from every historical log when a current file exists.
3. **Logs stay append-only.** History is evidence, not mutable state.
4. **Recommendations must cite evidence.** Good coffee advice should point to recent sessions or stable preferences.
5. **Humans can always edit the files.** Beantr should never require a special UI.

## Status

Beantr is now an agent-native skill/context package. The old FastAPI, PostgreSQL, Railway, and MCP implementation has been deliberately removed from the active repository shape.

## License

Beantr is released under the [MIT License](LICENSE).
