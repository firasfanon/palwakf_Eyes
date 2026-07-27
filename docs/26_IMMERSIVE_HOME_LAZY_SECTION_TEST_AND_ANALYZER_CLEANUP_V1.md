# PAL_EYES_IMMERSIVE_HOME_LAZY_SECTION_TEST_AND_ANALYZER_CLEANUP_HOTFIX_V1

## Observed state

- The immersive R4 interface renders successfully in Chrome.
- Analyzer reports two `unnecessary_underscores` infos.
- The dedicated Home test checks a lazy Sliver section before it is
  built.

## Repair

```text
SEPARATOR_WILDCARDS=(_, _)
STORIES_SECTION_KEY=home-stories-section
EVIDENCE_SECTION_KEY=home-evidence-section
TEST_SCROLL_UNTIL_VISIBLE=ENABLED
```

The visual design, catalog, sources and governorate content remain
unchanged.
