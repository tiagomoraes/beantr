# Security Policy

Beantr is a filesystem-native agent pack: Markdown, shell snippets, and plain
files, with no server, database, or runtime service. The main security surface
is the install path — `installers/install.sh` and the hosted bootstrap script
(`site/install`), which write files into an agent's skills directory and create
a Markdown ledger.

## Reporting a vulnerability

Please **do not open a public issue** for security problems.

- Preferred: use GitHub's private vulnerability reporting on this repository
  (**Security → Report a vulnerability**).
- Otherwise: email the maintainer at **me@tiagomoraes.cloud**.

Include what you found, how to reproduce it, and the impact you expect. We will
acknowledge your report, investigate, and coordinate a fix and disclosure with
you.

## Scope

In scope:

- The installer (`installers/install.sh`) and bootstrap installer (`site/install`)
  — e.g. path handling, unexpected file overwrites, or command injection.
- The Claude Code plugin manifest and marketplace definition.

Out of scope:

- Behavior of third-party agents (Hermes, Claude Code, OpenCode, OpenClaw,
  Claude Cowork) themselves.
- Anything a user's own agent does with their ledger once installed.
