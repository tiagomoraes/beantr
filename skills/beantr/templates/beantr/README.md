# Beantr ledger

This folder is a human-readable coffee ledger for AI agents.

- `beans/current.md`: live bean inventory.
- `gear/current.md`: live brewing equipment and constraints.
- `recipes/current.md`: preferred recipes and defaults.
- `sessions/YYYY-MM.md`: append-only brew sessions.
- `insights/current.md`: distilled recommendations.

Agents should read current files first, append events to monthly logs, and keep recommendations grounded in sessions.
