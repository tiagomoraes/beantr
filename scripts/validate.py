#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]

REQUIRED = [
    'README.md',
    'AGENTS.md',
    'Makefile',
    'skills/beantr/SKILL.md',
    'skills/beantr/references/physical-container-integrity.md',
    'skills/beantr/templates/beantr/beans/current.md',
    'templates/beantr/README.md',
    'templates/beantr/beans/current.md',
    'templates/beantr/beans/history/YYYY-MM.md',
    'templates/beantr/gear/current.md',
    'templates/beantr/gear/history/YYYY-MM.md',
    'templates/beantr/recipes/current.md',
    'templates/beantr/sessions/YYYY-MM.md',
    'templates/beantr/insights/current.md',
    'installers/install.sh',
    'installers/update.sh',
    'installers/uninstall.sh',
    'docs/INSTALL.md',
    'docs/UPDATE.md',
    'docs/UNINSTALL.md',
    'docs/LEDGER.md',
    'docs/AGENTS.md',
    'docs/MIGRATION.md',
    'site/index.html',
    'site/install',
    'site/update',
    'site/uninstall',
    '.claude-plugin/plugin.json',
    '.claude-plugin/marketplace.json',
]

RETIRED = [
    'app',
    'migrations',
    'docker-compose.yml',
    'Dockerfile',
    'railway.toml',
    'poetry.lock',
    'pyproject.toml',
    'alembic.ini',
]


def fail(message: str) -> None:
    print(f'ERROR: {message}', file=sys.stderr)
    sys.exit(1)


def check_required() -> None:
    missing = [p for p in REQUIRED if not (ROOT / p).exists()]
    if missing:
        fail('missing required files: ' + ', '.join(missing))


def check_retired() -> None:
    present = [p for p in RETIRED if (ROOT / p).exists()]
    if present:
        fail('retired API/MCP artifacts still present: ' + ', '.join(present))


def check_skill_frontmatter() -> None:
    text = (ROOT / 'skills/beantr/SKILL.md').read_text(encoding='utf-8')
    if not text.startswith('---\n'):
        fail('SKILL.md must start with YAML frontmatter')
    if '\n---\n' not in text[4:]:
        fail('SKILL.md frontmatter is not closed')
    for token in [
        'name: beantr',
        'description:',
        'version:',
        '## Update workflow',
        '### Physical-container identity and exclusivity',
        '## Verification checklist',
    ]:
        if token not in text:
            fail(f'SKILL.md missing token: {token}')


def check_plugin_manifests() -> None:
    plugin = json.loads((ROOT / '.claude-plugin/plugin.json').read_text(encoding='utf-8'))
    if 'name' not in plugin:
        fail('.claude-plugin/plugin.json missing required field: name')

    marketplace = json.loads((ROOT / '.claude-plugin/marketplace.json').read_text(encoding='utf-8'))
    for field in ['name', 'owner', 'plugins']:
        if field not in marketplace:
            fail(f'.claude-plugin/marketplace.json missing required field: {field}')
    names = [entry.get('name') for entry in marketplace['plugins']]
    if plugin['name'] not in names:
        fail(f"marketplace.json plugins list does not include plugin.json's name '{plugin['name']}'")
    for entry in marketplace['plugins']:
        if entry.get('name') == plugin['name'] and entry.get('version') != plugin.get('version'):
            fail('plugin.json and marketplace.json versions must match')
        source = entry.get('source')
        if isinstance(source, str) and source.startswith('./'):
            if not (ROOT / source).exists():
                fail(f"marketplace.json plugin source does not exist: {source}")


def check_templates() -> None:
    for rel in REQUIRED:
        if rel.startswith('templates/') and rel != 'templates/beantr/README.md':
            text = (ROOT / rel).read_text(encoding='utf-8')
            if 'unknown' not in text.lower() and rel.endswith('.md'):
                fail(f'{rel} should model unknown values rather than invented values')

    for rel in [
        'templates/beantr/beans/current.md',
        'skills/beantr/templates/beantr/beans/current.md',
    ]:
        text = (ROOT / rel).read_text(encoding='utf-8')
        for token in ['container_id', 'container_members', 'Never assign two active coffees']:
            if token not in text:
                fail(f'{rel} missing physical-container token: {token}')


def check_relative_links() -> None:
    link_re = re.compile(r'\[[^\]]+\]\(([^)]+)\)')
    for path in [ROOT / 'README.md', *sorted((ROOT / 'docs').glob('*.md'))]:
        text = path.read_text(encoding='utf-8')
        for target in link_re.findall(text):
            if '://' in target or target.startswith('#') or target.startswith('mailto:'):
                continue
            clean = target.split('#', 1)[0]
            if not clean:
                continue
            if not (path.parent / clean).exists():
                fail(f'broken relative link in {path.relative_to(ROOT)}: {target}')


def check_site() -> None:
    text = (ROOT / 'site/index.html').read_text(encoding='utf-8')
    for token in ['Beantr', 'installers/install.sh hermes', 'beans', 'filesystem']:
        if token not in text:
            fail(f'site/index.html missing token: {token}')

    plugin = json.loads((ROOT / '.claude-plugin/plugin.json').read_text(encoding='utf-8'))
    version = plugin['version']
    pages = [
        'site/index.html',
        'site/guide/index.html',
        'site/hermes/index.html',
        'site/claude-code/index.html',
        'site/opencode/index.html',
        'site/openclaw/index.html',
        'site/cowork/index.html',
    ]
    for rel in pages:
        page = (ROOT / rel).read_text(encoding='utf-8')
        for asset in [f'/beantr.css?v={version}', f'/beantr.js?v={version}']:
            if asset not in page:
                fail(f'{rel} does not reference current-version asset: {asset}')

    pack_users = [
        'README.md',
        'docs/INSTALL.md',
        'site/guide/index.html',
        'site/install',
        'site/update',
        'site/uninstall',
    ]
    for rel in pack_users:
        body = (ROOT / rel).read_text(encoding='utf-8')
        if f'beantr-agent-pack-latest.tar.gz?v={version}-' not in body:
            fail(f'{rel} does not reference the current-version pack cache key')


def main() -> None:
    check_required()
    check_retired()
    check_skill_frontmatter()
    check_plugin_manifests()
    check_templates()
    check_relative_links()
    check_site()
    print('Beantr pack validation passed.')


if __name__ == '__main__':
    main()
