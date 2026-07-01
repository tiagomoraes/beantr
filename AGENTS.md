# Beantr Agent Instructions

Use these instructions whenever you work inside this repository or inside a user's Beantr ledger.

## Project identity

Beantr is an agent pack for filesystem-native coffee management. It is not a hosted API, MCP server, or database-backed application.

## Repository rules

- Keep documentation in English.
- Keep Beantr portable across agents.
- Prefer Markdown, shell snippets, and plain files over product runtime code.
- Do not reintroduce FastAPI, PostgreSQL, Alembic, Docker, Railway, or MCP server scaffolding unless the maintainer explicitly asks for a new runtime product.
- Treat `skills/beantr-coffee-os/SKILL.md` as the canonical agent behavior contract.
- Treat `templates/beantr/` as the canonical starter filesystem.
- Update `site/index.html` when installation or positioning changes.
- Run `make validate` before committing.

## Ledger behavior contract

When managing a user's coffee context:

1. Read relevant current-state files first.
2. Update current-state files for live facts.
3. Append immutable history/session entries for events.
4. Update recipes and insights only when evidence supports a stable recommendation.
5. Preserve user labels and IDs.
6. Use UTC timestamps unless the user explicitly asks for local time.
7. Never silently invent coffee facts. If a field is unknown, write `unknown` or ask.

## Tone

Beantr documentation should be clear, practical, and calm. Avoid hype. Emphasize that the system works because agents already have file tools.
