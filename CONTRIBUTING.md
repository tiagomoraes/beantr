# Contributing to Beantr

Thanks for helping improve Beantr. It is a filesystem-native agent pack — a
portable skill, a Markdown ledger contract, installers, and docs — with **no
runtime dependencies**. Contributions should keep it that way.

## Before you start: open an issue

**All changes start as a GitHub issue.** This keeps work visible and avoids
duplicated or unwanted effort.

- Found a bug? Open a [bug report](https://github.com/tiagomoraes/beantr/issues/new?template=bug_report.md).
- Want a feature or a change? Open a [feature request](https://github.com/tiagomoraes/beantr/issues/new?template=feature_request.md) and wait for a maintainer to agree on the approach before writing code.
- Small typo or doc fix? An issue is still appreciated, but a direct PR is fine.

Please don't open a pull request without a linked issue for anything beyond a
trivial fix.

## Ground rules

Beantr has a deliberate shape. Keep contributions inside it:

- **No runtime product code.** Prefer Markdown, shell snippets, and plain files.
  Do not reintroduce FastAPI, PostgreSQL, Alembic, Docker, Railway, or an MCP
  server unless a maintainer explicitly asks for a new runtime product.
- **Docs in English.**
- **Keep it portable** across agents (Hermes, Claude Code, OpenCode, OpenClaw,
  Claude Cowork, and any file-capable assistant).
- `skills/beantr/SKILL.md` is the canonical agent behavior contract;
  `templates/beantr/` is the canonical starter ledger. Change them deliberately.
- **Run `make validate` before every commit.** It checks pack structure, the
  skill frontmatter, plugin manifests, and doc links.

## Branching model (gitflow)

We use a [gitflow](docs/RELEASING.md)-style model.

| Branch | Purpose |
|---|---|
| `main` | Released, stable. What users install. |
| `develop` | Integration branch for the next release. Base your work here. |
| `feature/<slug>` | New capability, branched from `develop`. |
| `fix/<slug>` | Non-urgent bug fix, branched from `develop`. |
| `docs/<slug>`, `chore/<slug>` | Docs / maintenance, branched from `develop`. |
| `release/<version>` | Release preparation, branched from `develop`. |
| `hotfix/<version>` | Urgent production fix, branched from `main`. |

Branch names use a type prefix and a short kebab-case slug, e.g.
`feature/opencode-install`, `fix/bootstrap-bash3-array`, `docs/releasing`.

## Commits

Use [Conventional Commits](https://www.conventionalcommits.org/): `feat:`,
`fix:`, `docs:`, `refactor:`, `chore:`, `test:`. Write in the imperative mood
("add", not "added"). Reference the issue in the body (`Refs #123`).

## Pull requests

1. Branch from `develop` (or `main` for a hotfix).
2. Keep the PR focused on one issue.
3. Fill in the pull request template and link the issue (`Closes #123`).
4. Ensure `make validate` passes — CI runs it on every PR.
5. Open the PR against `develop` (or `main` for a hotfix).
6. At least one maintainer review/approval is required before merge.
7. Squash-merge is preferred to keep `develop` history readable.

## Local development

```bash
make validate        # structure + doc-link checks (run before committing)
make preview-site    # serve the landing page at http://localhost:8088
./installers/install.sh <agent> ~/beantr   # try an install locally
```

Releases and versioning are documented in [docs/RELEASING.md](docs/RELEASING.md).
By participating you agree to the [Code of Conduct](CODE_OF_CONDUCT.md).
