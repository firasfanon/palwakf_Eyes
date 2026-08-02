# بعيون فلسطينية — Direct Flutter Public Experience R9.0.1

```text
BASELINE=PAL_EYES_DIRECT_FLUTTER_PUBLIC_EXPERIENCE_MATURITY_R9_0_1_20260802
PARENT=PAL_EYES_DIRECT_FLUTTER_PUBLIC_EXPERIENCE_MATURITY_R9_0_0_20260802
VERSION=9.0.1+30
STATUS=SESSION_RECONSTRUCTED_GITHUB_CANDIDATE_PENDING_FORMAT_REPLAY
```

## النتيجة

- هوية عامة مترابطة: أطلس المكان، متحف الحكاية، مجلة الذاكرة.
- افتتاحيات تحريرية للأطلس والمجلة.
- بوصلة محتوى لتفاصيل الموقع.
- دليل فصول وإطار قراءة طويل لتفاصيل القصة.
- خريطة عامة Fail-closed عند صفر إحداثيات معتمدة.
- RTL وتجربة محمولة ضيقة دون Overflow مرئي.
- Chrome وEdge runtime smoke ناجحان.

## التحقق

```text
TARGETED_DART_FORMAT=PASS_12_FILES
STATIC_VERIFY=PASS
FLUTTER_ANALYZE=PASS
FLUTTER_TEST=PASS_65
GIT_DIFF_CHECK=PASS
DESKTOP_BROWSER_UAT=PASS
DESKTOP_DETAIL_SURFACES_UAT=PASS
NARROW_MOBILE_VISUAL_UAT=PASS
RUNTIME_EXCEPTIONS=0
VISIBLE_RENDER_OVERFLOWS=0
```

## حدود السيادة والإنتاج

```text
DATABASE_WRITE=FALSE
SUPABASE_APPLY=FALSE
PUBLIC_COORDINATES=0
APPROVED_MEDIA=0
PUBLICATION=BLOCKED
PRODUCTION_DEPLOYMENT=NOT_APPROVED
OSM_TILE_POLICY_WARNING=OPEN_PRODUCTION_READINESS_BLOCKER
```

## ملاحظة قبول محكومة

أغلق المشغل Browser UAT صراحةً بعد مراجعة الأدلة المرئية. لم تُحفظ لقطة قياس telemetry مستقلة لـ`390×844` ولا لقطة مستقلة لتركيز لوحة المفاتيح؛ قُبل ذلك كاستثناء توثيقي لهذه الـbaseline فقط، دون ادعاء وجود دليل غير ملتقط.

## بيان إعادة البناء من الجلسة

هذه الشجرة أُعيد بناؤها من مصدر R9.0.0 الكامل المرفوع في
بداية الجلسة، ثم أضيفت إليها بيانات إغلاق R9.0.1 وأدلة UAT
المسجلة.

لم تكن نسخة العمل بعد `dart format` على جهاز `Firas_Fanon`
متاحة للنسخ البايتي. قبل دمج الفرع في `main` يجب تشغيل:

```text
tools/FINALIZE_SESSION_RECONSTRUCTED_R9_0_1.ps1
```

يعيد السكربت تطبيق التنسيق على النطاق نفسه، ثم يشغّل
Analyzer والاختبارات والمدقق ويعيد إنشاء الـmanifest.
