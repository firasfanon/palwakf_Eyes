#!/usr/bin/env python3
"""Static and artifact gates for governed research narrative staging V1."""

from __future__ import annotations

import argparse
from pathlib import Path

SIDECAR_NAME = 'research_narratives_v1.json'


def require_text(path: Path, needle: str) -> None:
    text = path.read_text(encoding='utf-8')
    if needle not in text:
        raise SystemExit(f'REQUIRED_TEXT_MISSING={path}:{needle}')


def assert_absent(root: Path, name: str) -> None:
    matches = list(root.rglob(name)) if root.exists() else []
    if matches:
        joined = ';'.join(str(item) for item in matches)
        raise SystemExit(f'PRODUCTION_RESEARCH_SIDECAR_PRESENT={joined}')


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument('--repo-root', type=Path, default=Path('.'))
    parser.add_argument('--production-build-dir', type=Path)
    args = parser.parse_args()
    root = args.repo_root.resolve()

    provider = root / 'lib/features/research/application/staging_research_narrative_provider.dart'
    domain = root / 'lib/features/research/domain/staging_research_narrative.dart'
    screen = root / 'lib/features/places/presentation/place_detail_screen.dart'

    require_text(provider, 'if (environment.isProduction)')
    require_text(provider, 'return null;')
    require_text(provider, SIDECAR_NAME)
    require_text(domain, 'PAL_EYES_RESEARCH_NARRATIVE_SIDECAR_V1')
    require_text(screen, 'StagingResearchNarrativePanel(siteId: site.id)')

    committed_sidecars = list(root.rglob(SIDECAR_NAME))
    committed_sidecars = [
        path for path in committed_sidecars
        if '.dart_tool' not in path.parts and 'build' not in path.parts
    ]
    if committed_sidecars:
        joined = ';'.join(str(item) for item in committed_sidecars)
        raise SystemExit(f'RESEARCH_TEXT_SIDECAR_MUST_NOT_BE_COMMITTED={joined}')

    if args.production_build_dir is not None:
        assert_absent(args.production_build_dir.resolve(), SIDECAR_NAME)
        print('PRODUCTION_RESEARCH_SIDECAR_ABSENCE=PASS')

    print('RESEARCH_NARRATIVE_PRODUCTION_GUARD_STATIC=PASS')
    print('RESEARCH_NARRATIVE_GITHUB_TEXT_AUTHORITY=CODE_ONLY_PASS')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
