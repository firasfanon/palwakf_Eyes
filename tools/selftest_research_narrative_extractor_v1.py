#!/usr/bin/env python3
"""Non-network regression tests for the research narrative extractor V1."""

from __future__ import annotations

import importlib.util
from pathlib import Path

MODULE_PATH = Path(__file__).with_name('build_research_narrative_sidecar_v1.py')
spec = importlib.util.spec_from_file_location('extractor_v1', MODULE_PATH)
if spec is None or spec.loader is None:
    raise SystemExit('EXTRACTOR_IMPORT_SPEC_FAILED')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)

sample = {
    'body': {
        'content': [
            {
                'paragraph': {
                    'paragraphStyle': {'namedStyleType': 'TITLE'},
                    'elements': [{'textRun': {'content': 'عنوان البحث\n'}}],
                }
            },
            {
                'paragraph': {
                    'paragraphStyle': {'namedStyleType': 'HEADING_1'},
                    'elements': [{'textRun': {'content': 'القسم الأول\n'}}],
                }
            },
        ]
    }
}

blocks = module._extract_blocks(sample)
assert blocks == [
    {'style': 'TITLE', 'text': 'عنوان البحث'},
    {'style': 'HEADING_1', 'text': 'القسم الأول'},
]

sample_tabs = {
    'tabs': [
        {
            'documentTab': {
                'body': {
                    'content': [
                        {
                            'paragraph': {
                                'paragraphStyle': {'namedStyleType': 'CUSTOM_STYLE'},
                                'elements': [{'textRun': {'content': 'فقرة عادية\n'}}],
                            }
                        }
                    ]
                }
            }
        }
    ]
}
assert module._extract_blocks(sample_tabs) == [
    {'style': 'NORMAL_TEXT', 'text': 'فقرة عادية'}
]
assert len(module._content_hash(blocks)) == 64
print('RESEARCH_NARRATIVE_EXTRACTOR_SELFTEST=PASS')
