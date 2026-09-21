# Changelog

All notable changes to Beantr are documented here. The format is based on
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and Beantr adheres to
[Semantic Versioning](https://semver.org/).

## [Unreleased]

## [2.1.0] - 2026-09-21

### Added
- Physical-container integrity rules in the Beantr skill. A named reusable jar,
  tube, or canister can have at most one active coffee, and the agent must
  resolve the prior occupant before assigning a different coffee.
- Stable `container_id` and exact `container_members` fields for new ledgers,
  including batch-to-individual overlap checks and leading-zero preservation.
- A worked physical-container audit and correction guide at
  `skills/beantr/references/physical-container-integrity.md`.

### Changed
- The installer now reports the pack version it installed.
- The landing page and ledger documentation now explain how Beantr prevents
  physically impossible container assignments.

## [2.0.2] - 2026-09-21

### Fixed
- Stylesheet and script URLs now carry the release version (`/beantr.css?v=2.0.2`),
  so a page is never served with a stale cached stylesheet after a redesign.
  Cloudflare caches static assets for four hours, and the HTML is not cached.

## [2.0.1] - 2026-09-21

### Changed
- Redesigned the site around one dark page ("Crema on black"): coffee-first,
  plain-language copy, a question-and-answer section that shows everyday use,
  and the install prompt as the primary call to action with the one-line
  command as the secondary path. `DESIGN.md` documents the new system.
- Restyled the per-agent install pages (`/hermes/`, `/claude-code/`,
  `/opencode/`, `/openclaw/`, `/cowork/`) to match, each leading with the
  prompt for that agent.

### Added
- `/guide/`, a full install guide page: the prompt, the one-line command,
  every agent, manual install from a clone or the pack, where the notes live,
  updating and uninstalling.
- A GitHub star badge in the site nav, shown only once the repository has more
  than 100 stars.

## [2.0.0] - 2026-07-02

### Changed
- **BREAKING — renamed the skill and plugin from `beantr-coffee-os` to
  `beantr`.** The skill now installs and is invoked as `beantr`.
  - Claude Code plugin: `/plugin install beantr@beantr` (was
    `beantr-coffee-os@beantr`).
  - Installer target path is now `<agent>/skills/beantr` (was
    `.../skills/beantr-coffee-os`), and the canonical instruction file is
    `~/.beantr/beantr.md` (was `~/.beantr/beantr-coffee-os.md`).
  - The Cowork package is now `dist/beantr-skill.zip` (was
    `dist/beantr-coffee-os-skill.zip`).

### Migration
- Existing installs do not rename in place. Uninstall the old skill first
  (`/plugin uninstall beantr-coffee-os@beantr`, or
  `./installers/uninstall.sh <agent>` from a pre-2.0.0 clone), then reinstall
  with the new name. Your coffee ledger at `~/beantr` is never touched.

## [1.2.0] - 2026-07-02

### Added
- **Updater** (`installers/update.sh`) that re-applies the current pack to the
  agents you already have installed, refreshing the skill, managed
  `CLAUDE.md` / `AGENTS.md` block, and instruction file. It reuses the ledger
  path recorded at install time (so a custom ledger is never reset to the
  default), seeds only new template files, never overwrites your coffee data,
  and reports the version change (e.g. `v1.1.0 -> v1.2.0`).
- **One-line bootstrap updater** (`site/update`), served at
  `https://beantr.tiagomoraes.cloud/update`, plus a dedicated
  [update guide](docs/UPDATE.md) and `make update*` targets.

### Changed
- The installer now records `BEANTR_VERSION` in `~/.beantr/config` so updates
  can report what you upgraded from and to.

## [1.1.0] - 2026-07-02

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
