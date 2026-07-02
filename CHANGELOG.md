# Changelog

All notable changes to Beantr are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and Beantr adheres to
[Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- **Uninstaller** (`installers/uninstall.sh`) mirroring the installer: removes a
  single agent's wiring, `all` detected agents, or with no arguments lists
  what's installed and removes nothing. It strips the managed `CLAUDE.md` /
  `AGENTS.md` block without disturbing your other content and cleans up the
  shared `~/.beantr` files once the last agent is removed — but it never deletes
  your coffee ledger, and prints the ledger path on the way out.
- **One-line bootstrap uninstaller** (`site/uninstall`), served at
  `https://beantr.tiagomoraes.cloud/uninstall`, plus a dedicated
  [uninstall guide](docs/UNINSTALL.md) and `make uninstall*` targets.

### Changed
- Install flow refined: install one agent at a time, running the installer or
  bootstrap with no arguments reports detected agents and how to install each
  (installing nothing), and `all` installs for every detected agent sharing one
  ledger.

## [1.0.0] - 2026-07-01

Initial public release.

### Added
- Portable **Coffee OS skill** (`skills/beantr-coffee-os/SKILL.md`) that teaches
  a file-capable agent to track beans, gear, recipes, and brew sessions as
  Markdown.
- Starter **ledger templates** (`templates/beantr/`) created at `~/beantr`.
- **Installers** for Hermes, Claude Code, OpenCode, OpenClaw, Claude Cowork, and
  a generic file-capable target, plus a self-hosted **Claude Code plugin
  marketplace** and a one-line **bootstrap installer**.
- **Landing site** (`site/`) built around installation, with per-agent install
  pages and an agent-driven "paste this to your assistant" flow.
- Documentation: install guide, the ledger contract, migration notes, and this
  release process.

### Notes
- Beantr was previously an API + PostgreSQL + MCP service; that architecture was
  deliberately removed. Beantr is now a dependency-free, file-native agent pack.
