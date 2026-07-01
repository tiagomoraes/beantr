# Migration from the old API/MCP Beantr

The old Beantr was a FastAPI/PostgreSQL application with REST endpoints, authentication, Railway deployment, and an MCP server. That architecture has been retired in this repository.

## What was removed

- FastAPI application code.
- SQLAlchemy models and repositories.
- Alembic migrations.
- Docker/Railway deployment files.
- MCP server code and tool schemas.
- Python package/runtime dependency management.
- API-oriented tests.

## Why it was removed

The project goal changed. Beantr is now for personal AI assistants that already have file access. A database and tool server are unnecessary ceremony for the core workflow: maintaining a compact, private, human-readable coffee context.

## Concept mapping

| Old concept | New Beantr equivalent |
|---|---|
| Coffee table | `beans/current.md` |
| Container table | `beans/current.md` container columns / notes |
| Fill table | live bean rows + `beans/history/YYYY-MM.md` |
| Event table | `beans/history/`, `gear/history/`, `sessions/` |
| MCP tools | `skills/beantr-coffee-os/SKILL.md` workflow |
| REST API | agent file reads/writes |
| Database migrations | Markdown template evolution |

## Migrating data manually

If you have an old Beantr export, convert it into the Beantr ledger files:

1. Put current beans and container assignments in `beans/current.md`.
2. Put active gear in `gear/current.md`.
3. Put favorite recipes in `recipes/current.md`.
4. Put historical fills/events in monthly `beans/history/YYYY-MM.md` files.
5. Put brew attempts in monthly `sessions/YYYY-MM.md` files.
6. Ask your agent to review the files and populate `insights/current.md`.

Keep the first migration simple. Beantr works best when the files remain easy to read.
