# ملف توريث — اعتماد المحتوى المحكوم R5.1.1

```text
TARGET_BASELINE=PAL_EYES_GOVERNED_CONTENT_ADOPTION_TO_PROJECT_PAGES_R5_1_1_20260715
SUPERSEDES_PACKAGE=MEGA_BATCH_PAL_EYES_GOVERNED_CONTENT_ADOPTION_TO_PROJECT_PAGES_V1_20260715_BUILT_APPLY_PACKAGE.zip
SOURCE_CONTRACT_LOCAL_SNAPSHOT=ACCEPTED
LIST_TILE_MATERIAL_BOUNDARY_REPAIR=APPLIED_IN_PAYLOAD
SITES=79
GOVERNED_DRAFT_PAGES=57
LIMITED_RESEARCH_PAGES=22
EDITORIAL_RECORDS=92
SOURCES=95
HELD_CLAIMS=211
PUBLIC_MAP_COORDINATES=0
APPROVED_MEDIA_ASSETS=0
DATABASE_IMPORT=BLOCKED
PUBLICATION=BLOCKED
```

## التحقق المحلي المطلوب

1. WhatIf على حزمة R5.1.1 الجديدة.
2. Apply.
3. `python tools\verify_governed_content_adoption.py`
4. `python tools\verify_flutter_runtime_foundation_static.py`
5. `dart format lib test`
6. `flutter analyze`
7. `flutter test`
8. `flutter run -d chrome --target lib/main.dart`

يجب ألا يظهر Assertion الخاص بـ`ListTile` و`ColoredBox`.
