# PAL_EYES_HOME_DRAFT_BANNER_SMOKE_TEST_IDENTITY_HOTFIX_V1

## العيب

كان اختبار Home يعتمد على `scrollUntilVisible` نحو Sliver كسول،
ثم يفترض أن النص «مسودة خاضعة للتدقيق» يظهر مرة واحدة، مع أن
`DraftContentBanner` يعرضه في Badge والعنوان.

## الإصلاح

```text
BANNER_LOCATION=FIRST_HERO_SURFACE
BANNER_KEY=home-governed-draft-banner
SMOKE_ASSERTION=BY_KEY
LABEL_ASSERTION=FINDS_WIDGETS
SCROLL_UNTIL_VISIBLE=REMOVED
```

لا تغيير في بيانات الكتالوج.
