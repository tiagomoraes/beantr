# Changelog

All notable changes to Beantr are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and Beantr adheres to
[Semantic Versioning](https://semver.org/).

## [Unreleased]

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
