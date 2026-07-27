# ملف توريث — اعتماد المحتوى المحكوم R5.1.2

```text
TARGET_BASELINE=PAL_EYES_GOVERNED_CONTENT_ADOPTION_TO_PROJECT_PAGES_R5_1_2_20260715
PARENT_BASELINE=PAL_EYES_GOVERNED_CONTENT_ADOPTION_TO_PROJECT_PAGES_R5_1_1_20260715
COMPILE_BLOCKER_REPAIR=BUILT
LEGACY_EXPANDED_NARRATIVES=47
LEGACY_REVIEW_COORDINATES=3
PUBLIC_MAP_COORDINATES=0
GOVERNED_DRAFT_PAGES=57
LIMITED_RESEARCH_PAGES=22
EDITORIAL_RECORDS=92
SOURCES=95
HELD_CLAIMS=211
DATABASE_IMPORT=BLOCKED
PUBLICATION=BLOCKED
```

## التحقق المطلوب

1. تطبيق الحزمة التصحيحية.
2. `python tools\verify_governed_content_compile_contract.py`
3. `python tools\verify_governed_content_adoption.py`
4. `python tools\verify_flutter_runtime_foundation_static.py`
5. `dart format lib test`
6. `flutter analyze`
7. `flutter test`
8. `flutter run -d chrome --target lib/main.dart`
