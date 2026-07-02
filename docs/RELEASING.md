# Releasing Beantr

Beantr ships three ways, all from this repo:

1. **Claude Code plugin** — `/plugin marketplace add tiagomoraes/beantr` then
   `/plugin install beantr@beantr`. Served from the repository's
   **default branch**.
2. **One-line bootstrap** — `curl -fsSL https://beantr.tiagomoraes.cloud/install | bash`,
   which downloads the latest packaged tarball.
3. **Manual** — clone or download the tarball and run `installers/install.sh`.

Because installs come from the default branch and a hosted tarball, "releasing"
means: land changes on `main`, tag a version, and republish the site + tarball.

## Branching model (gitflow)

| Branch | Base | Merges into | Purpose |
|---|---|---|---|
| `main` | — | — | Released, stable. The default branch users install from. |
| `develop` | `main` | `main` (via release) | Integration of the next release. |
| `feature/<slug>` | `develop` | `develop` | New capability. |
| `fix/<slug>` | `develop` | `develop` | Non-urgent bug fix. |
| `release/<version>` | `develop` | `main` **and** `develop` | Version bump + changelog. |
| `hotfix/<version>` | `main` | `main` **and** `develop` | Urgent production fix. |

Everyday work: branch off `develop`, PR back into `develop` (see
[CONTRIBUTING.md](../CONTRIBUTING.md)). `main` only ever moves through a
`release/*` or `hotfix/*` merge.

## Versioning

Beantr follows [Semantic Versioning](https://semver.org/). The version of
record lives in `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`
(keep them in sync).

- **MAJOR** — a breaking change to the ledger contract (`SKILL.md`,
  `templates/beantr/` layout) or to an installer's target paths.
- **MINOR** — a new agent target, a new capability, backward-compatible additions.
- **PATCH** — bug fixes, docs, copy, and site changes.

## Cutting a release

1. Confirm `develop` is green: `make validate` (CI runs it on every PR).
2. Create the release branch: `git switch -c release/vX.Y.Z develop`.
3. Bump the version in `.claude-plugin/plugin.json` and
   `.claude-plugin/marketplace.json`.
4. Move the `Unreleased` notes in [CHANGELOG.md](../CHANGELOG.md) under a new
   `## [X.Y.Z] - YYYY-MM-DD` heading.
5. Open a PR from `release/vX.Y.Z` into `main`, get a review, and merge.
6. Tag the release on `main`:
   ```bash
   git switch main && git pull
   git tag -a vX.Y.Z -m "vX.Y.Z"
   git push origin vX.Y.Z
   ```
7. Merge `main` back into `develop` so the version bump and changelog are shared.

## Publishing (maintainer only)

The site and tarball are served from the maintainer's host, so this step is run
by the maintainer, not in CI:

```bash
make site-deploy   # packages the tarball and publishes site/ + the pack
```

This refreshes `https://beantr.tiagomoraes.cloud` (landing page, per-agent
pages, `beantr.css`/`beantr.js`, the bootstrap `install` script, and the
cache-busted `beantr-agent-pack-latest.tar.gz`). The Claude Code plugin needs
no separate publish — it resolves from the default branch as soon as the release
is on `main`.

To build only the tarball locally: `make package` (writes `dist/`).
