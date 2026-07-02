# Agent integration notes

Beantr is deliberately not tied to one agent runtime. The integration surface is a set of files.

## Minimum capabilities

An agent needs only:

- read text files;
- write or patch text files;
- search within a folder;
- follow the Beantr update workflow.

No HTTP calls, MCP tools, database credentials, or background service are required.

## Recommended system instruction

Use this core instruction when your agent does not support installable skills:

```text
You have access to Beantr, a filesystem-native coffee ledger. Read the Beantr instructions at ~/.beantr/beantr.md. Manage the user's coffee context at ~/beantr. Current Markdown files are the source of truth for live state. Monthly history/session files are append-only evidence. Update insights and recipes only when evidence supports a stable recommendation. Never invent unknown coffee facts.
```

## Hermes Agent

Hermes can load the skill directly from `~/.hermes/skills/beantr`.

Recommended command:

```bash
hermes --skills beantr
```

## Claude Code

This repo is itself a Claude Code plugin marketplace (`.claude-plugin/marketplace.json` + `.claude-plugin/plugin.json` at the root): `/plugin marketplace add tiagomoraes/beantr` then `/plugin install beantr@beantr` is the whole install, no shell needed. Equivalently, copy `skills/beantr/` into `~/.claude/skills/beantr` (or a project's `.claude/skills/`) — Claude Code discovers `SKILL.md` folders on its own and auto-invokes them when a prompt is relevant, no managed block required, though `installers/snippets/claude-code.md` is available if you want the ledger path pinned in `CLAUDE.md` as well.

## OpenCode

OpenCode reads the same `SKILL.md` format directly from `~/.config/opencode/skills/` (or `~/.claude/skills/`, which it also scans by default) and additionally supports an `AGENTS.md` block for a standing reminder of the ledger path.

## OpenClaw

[OpenClaw](https://github.com/openclaw/openclaw) — the self-hosted gateway connecting chat apps to agent backends — also reads `SKILL.md` directly, from `~/.openclaw/skills/` globally or `<workspace>/skills/` per agent. Its workspace `AGENTS.md` bootstrap file is the equivalent of a managed block if you want Beantr force-loaded every turn. If the OpenClaw agent delegates to Claude Code or another coding CLI as its backend, that backend's own integration applies inside the session too.

## Claude Cowork

Cowork runs the same agentic architecture as Claude Code inside Claude Desktop, but skills are installed through the UI: Settings → Cowork → Customize → Skills → upload a zipped `skills/beantr/` folder (`./installers/install.sh cowork` builds it). Grant Cowork folder access to the ledger path, and optionally paste `installers/snippets/cowork.md` into Global or folder-level Instructions.

## Other assistants

If the assistant has no persistent instruction file or skill mechanism, paste the recommended system instruction at the start of a session and provide the ledger path.
