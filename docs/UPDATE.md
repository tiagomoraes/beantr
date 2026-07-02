# Updating Beantr

Beantr is only files, so an update just re-applies the current pack to the
agents you already have installed — refreshing the skill, the managed
`CLAUDE.md` / `AGENTS.md` block, and the canonical instruction file. **Your
coffee ledger is never moved or overwritten**, and any new starter files a
release adds are seeded alongside your existing ones.

## Fastest path

If you installed the Claude Code plugin, update it from inside Claude Code:

```text
/plugin update beantr-coffee-os@beantr
```

For any other agent (or a shell install), the bootstrap updater downloads the
latest pack and re-applies it to every agent you already have installed. It
reads the ledger path recorded at install time, so you don't re-specify
anything:

```bash
curl -fsSL https://beantr.tiagomoraes.cloud/update | bash                    # update every installed agent
curl -fsSL https://beantr.tiagomoraes.cloud/update | bash -s -- claude-code  # update just one agent
```

## Using the script from a clone or the pack

If you cloned the repository or downloaded a fresh pack (see
[INSTALL.md](INSTALL.md)):

```bash
git pull                             # or re-download the latest pack
./installers/update.sh               # update every installed agent (the common case)
./installers/update.sh all           # same as above
./installers/update.sh claude-code   # update just one agent
```

Supported `<agent>` values: `hermes`, `claude-code`, `opencode`, `openclaw`,
`cowork`, `generic`.

## What an update does

- Detects which agents currently have Beantr installed and re-runs the
  installer for each, at the **ledger path recorded in `~/.beantr/config`** — so
  a custom ledger location is preserved rather than reset to the `~/beantr`
  default.
- Overwrites the installed skill folder and the canonical
  `~/.beantr/beantr-coffee-os.md`, and replaces the managed block in your
  `CLAUDE.md` / `AGENTS.md` with the current one (leaving the rest of the file
  untouched).
- Seeds any **new** ledger template files a release introduces; it never
  overwrites files that already exist, so your beans, sessions, and notes are
  safe.
- Records the new version in `~/.beantr/config` and prints the change, e.g.
  `Beantr updated: v1.1.0 -> v1.2.0`.

Running `./installers/update.sh` with no install present does nothing and points
you at [INSTALL.md](INSTALL.md).

## Cowork and generic targets

`cowork` and `generic` aren't auto-detected, so name them explicitly to update:

```bash
./installers/update.sh cowork    # repackages dist/beantr-coffee-os-skill.zip to re-upload
./installers/update.sh generic   # refreshes ~/.beantr/README.md
```

For Cowork, delete the old skill in **Settings → Cowork → Customize → Skills**
and upload the freshly packaged zip.

## Related

- [INSTALL.md](INSTALL.md) — first-time installation.
- [UNINSTALL.md](UNINSTALL.md) — removing Beantr.
