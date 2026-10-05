#!/usr/bin/env python3
"""Read a project's explicit coordination declaration. Never write or contact GitHub."""

import argparse
import json
from pathlib import Path
import re
import subprocess

MARKER = re.compile(r'\s*<!--\s*coordination-model:\s*(plan|github|hybrid)\s*-->\s*')
START = re.compile(r'<!--\s*coordination-model\b', re.I)
FENCE = re.compile(r'^ {0,3}(`{3,}|~{3,})')


def project_root(cwd):
    root = Path(cwd).resolve()
    if not root.is_dir():
        raise ValueError('Project directory is unavailable')
    result = subprocess.run(
        ['git', '-C', str(root), 'rev-parse', '--show-toplevel'],
        capture_output=True, text=True, check=False,
    )
    return Path(result.stdout.strip()).resolve() if result.returncode == 0 else root


def declarations(path):
    """Ignore fenced/indented examples; reject malformed real declaration lines."""
    if not path.exists() and not path.is_symlink():
        return []
    lines = path.read_text(encoding='utf-8').splitlines()
    found, fence = [], None
    for number, line in enumerate(lines, 1):
        match = FENCE.match(line)
        if match:
            token = match.group(1)
            if fence is None:
                fence = token
            elif (token[0] == fence[0] and len(token) >= len(fence)
                  and not line[match.end():].strip(' \t')):
                fence = None
            continue
        if fence or line.startswith(('    ', '\t')):
            continue
        # Inline code can document a marker without declaring project configuration.
        visible = re.sub(r'(`+).*?\1', '', line)
        if START.search(visible):
            match = MARKER.fullmatch(line)
            found.append({'path': str(path), 'line': number,
                          'model': match.group(1) if match else None})
    return found


def inspect(cwd, discover_git=True):
    result = {'model': 'invalid', 'root': None, 'sources': [], 'reason': ''}
    try:
        if not cwd:
            raise ValueError('An explicit project directory is required')
        root = project_root(cwd) if discover_git else Path(cwd).resolve()
        if not root.is_dir():
            raise ValueError('Project directory is unavailable')
        result['root'] = str(root)
        canonical_paths = [root / '.claude/CLAUDE.md', root / 'CLAUDE.md']
        canonical = [item for path in canonical_paths for item in declarations(path)]
        adapter = declarations(root / 'AGENTS.md')
        override = declarations(root / 'AGENTS.override.md')
        local = [item for name in ['CLAUDE.local.md', '.claude/CLAUDE.local.md',
                                  '.claude/AGENTS.override.md']
                 for item in declarations(root / name)]
        result['sources'] = canonical + adapter + override + local
        if local:
            raise ValueError('A local/override declaration needs an explicit project-level reconciliation')
        if len(canonical) > 1 or len(adapter) > 1:
            raise ValueError('Duplicate coordination declarations')
        if any(item['model'] is None for item in result['sources']):
            raise ValueError('Malformed coordination declaration')
        if canonical:
            model = canonical[0]['model']
            if adapter and adapter[0]['model'] != model:
                raise ValueError('Claude and Codex declarations conflict')
        elif adapter:
            if any(path.exists() for path in canonical_paths):
                raise ValueError('AGENTS.md declares a model but the existing Claude instructions do not')
            model = adapter[0]['model']
        else:
            model = 'undeclared'
        if override:
            raise ValueError('A local/override declaration needs an explicit project-level reconciliation')
        result.update(model=model, reason='')
    except (OSError, UnicodeError, ValueError) as error:
        result['reason'] = str(error)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    location = parser.add_mutually_exclusive_group(required=True)
    location.add_argument('--cwd', help='Project checkout or a directory inside it')
    location.add_argument('--root', help='Exact project root, including setup before git init')
    parser.add_argument('--format', choices=['json', 'model'], default='json')
    args = parser.parse_args()
    result = inspect(args.root if args.root is not None else args.cwd,
                     discover_git=args.root is None)
    print(result['model'] if args.format == 'model' else json.dumps(result))
    return 2 if result['model'] == 'invalid' else 0


if __name__ == '__main__':
    raise SystemExit(main())
