# بعيون فلسطينية — تقرير مرشح Claude البعيد V1

```text
DATE=2026-10-09
ACCESS_MODEL=GITHUB_REMOTE_ONLY (no Futuer-IT local checkout, no local WIP, no shared DB)
BASELINE_MAIN_SHA=b2311f90ed4b2f18035511aaf2e7c9eb6e9f9f8c   (verified exact at start)
BASELINE_MAIN_TREE=fb9e4f43f83adc573cdea56dea6599b03b2c5537  (verified exact at start)
CANDIDATE_BRANCH=task/pal-eyes-claude-editorial-unification-v1
CANDIDATE_SHA=9e21e1e8e88809eb2bd4d37d62b814d607b0703f
CANDIDATE_TREE=2ca1c0d38ad6d4e71c1b6a1fa5298514ceacf8cb
CI_EVIDENCE_REF=evidence/pal-eyes-claude-editorial-unification-v1 (run for 9e21e1e8)
UAT_EVIDENCE_REF=evidence/pal-eyes-claude-editorial-unification-v1-uat
GIT_BUNDLE=pal_eyes_claude_editorial_unification_v1_9e21e1e8e888.bundle (prerequisite b2311f90)
MERGE / PR / BASELINE PROMOTION / RELEASE / PUBLICATION = NOT PERFORMED
```

## 1. البوابات (Flutter 3.44.1 / Dart 3.12.1 على GitHub Actions)

| البوابة | النتيجة |
|---|---|
| dart format (الملفات المتغيرة) | PASS |
| flutter analyze | PASS — No issues |
| flutter test | PASS — 148 (كانت 123 في main؛ +25 جديدة) |
| verify_osm_tile_provider_policy_r9_0_2 | PASS |
| verify_vercel_development_hosting | PASS |
| research narrative staging selftest + verifier | PASS |
| git diff --check | PASS |
| flutter build web (public + internal، `--no-web-resources-cdn`) | PASS |
| حدود الخادم RLS — Postgres 16 معزول، هويات اصطناعية | main: 24/32 — المرشح: 32/32 |

ملاحظة: أضيف سير عمل جديد للأدلة فقط `.github/workflows/claude_remote_candidate_evidence.yml`
يعمل على فروع `task/pal-eyes-claude-**` فقط، بلا نشر ولا Vercel ولا Supabase. يمكن حذفه قبل الدمج إن رغب المالك.

## 2. ما أُنجز

1. **عطل الخط العربي (CONFIRMED FAIL) — مُصلح بالدليل.**
   السبب الجذري: لم يكن في المشروع أي خط مُضمّن؛ Flutter Web يجلب Roboto وNoto Sans Arabic من `fonts.gstatic.com` وقت التشغيل.
   عند تعذّر الشبكة يظهر النص العربي مربعات أو لا يظهر إطلاقاً. لقطات `baseline_main_*` تُظهر main بلا أي نص عربي.
   الإصلاح: تضمين IBM Plex Sans Arabic (نص) وAmiri (عناوين) بترخيص OFL مع ملف مصدر وبصمات SHA-256،
   وربط عائلة الخط بكل أنماط المكوّنات (الأزرار، الرقائق، التلميحات، الحقول) لأنها تستبدل النمط الموروث.
   لقطات `candidate_public_*_research*.png` في متصفح حقيقي مع حجب كل طلب خارجي: العربية سليمة في /research والتفاصيل.
2. **لغة تصميم موحدة.** `PalEyesTokens` مصدر واحد (عاجي/أخضر داكن/ذهبي دافئ، مقاييس المسافات، الأنصاف، الخطوط).
   الألواح الثلاثة القديمة (`AppColors`، `ApprovedReferenceDesign`، `PalEyesVisualV1`) صارت أسماء بديلة له؛ لوحة الكحلي (أغسطس) لم تعد مرجعاً.
   السمة الافتراضية صارت الفاتحة العاجية.
3. **الصفحة الرئيسية — تحسين لا إعادة بناء.** نفس الأقسام والمسارات والمزوّدات، لكنها الآن عناصر حية قابلة للقراءة الآلية بدل صور لقطات ذات نصوص محروقة:
   بطل القدس مع بحث وشرائح أماكن (تنقل إلى `/discover?q=`)، أربعة مداخل (الأماكن/البحوث/الحكايات/الخريطة التفاعلية)،
   قصة مميزة من الكتالوج التحريري، **سجل مصدري حقيقي** من السجل المحكوم بدل وثيقة أرشيفية مولدة (لا صورة وثيقة قبل الحقوق)،
   بطاقة خريطة بلا نقاط مؤقتة (0 إحداثيات عامة معتمدة)، أحدث البحوث، شريط القصص، شريط الزمن، تذييل.
4. **إغلاق ثغرة صلاحيات مثبتة.** في main كان `/workspace` و`/admin` مفتوحين لأي زائر في البناء العام (لقطة `baseline_main_*_workspace.png`).
   أضيفت بوابة في الموجّه: الزائر المجهول أو الحساب بلا دور يُحوّل إلى `/access-restricted`؛ أدوار من `pal_eyes.user_roles` (فشل مغلق)؛
   هوية «المعاين الداخلي» الاصطناعية فقط في بناء غير إنتاجي بوضع internal، ومستحيلة في production. البوابة دفاع إضافي؛ الحد الحاكم هو RLS.
5. **حدود الخادم.** أداة `tools/rls_boundary` تطبق الترحيلات على Postgres محلي مؤقت (ترفض أي مضيف غير محلي) وتختبر 32 مسباراً بهويات اصطناعية.
   ثغرات مثبتة في main: المحرر ينشر موقعاً مباشرة أو يُدرجه منشوراً أو يعتمد إحداثيات عامة؛ الباحث ينشر مصدراً؛ أي دور (حتى system_admin) يعيد كتابة سجل التدقيق.
   الإصلاح: ترحيل مرشح **مصدري فقط وغير مطبّق** `202610090003_pal_eyes_publication_fail_closed_guard.sql`.
6. **إصلاحات وظيفية مثبتة أخرى:** ListTile في لوحة مساحة العمل بلا Material (تأكيد إطار في وضع debug)، تداخل لوحة الأطلس مع شريط الطبقات في RTL على /map،
   تمييز بنيوي بين مساحة العمل (حافة ذهبية) والحوكمة (حافة بنية وعنوان «صلاحيات إدارية»)، شعار مقروء على شريط مساحة العمل.

## 3. بوابات معلّقة / محجوبة (بلا ادعاء)

| البند | الحالة |
|---|---|
| تسجيل دخول Supabase حقيقي + قراءة الأدوار end-to-end | BLOCKED — لا توجد بيئة Supabase غير إنتاجية متاحة؛ لا شاشة دخول في التطبيق بعد |
| تطبيق ترحيل الحماية على أي قاعدة مشتركة | NOT AUTHORIZED — مصدري فقط |
| CRUD على بيانات حقيقية | NOT PERFORMED — فقط تجهيزات اصطناعية في Postgres مؤقت |
| مطابقة بكسلية لصورة المرجع | PENDING — صورة المرجع وصلت لـ Claude كمرفق محادثة فقط، والتطبيق تحسين اتجاهي لا نسخة مطابقة |
| بلاطات OSM في لقطات /map | غير ظاهرة لأن أداة الالتقاط تحجب كل الشبكة الخارجية عمداً؛ سياسة OSM للإنتاج ما زالت مانعاً مفتوحاً |
| UAT محلي على Windows/Chrome/Edge ومقارنة WIP المحلي | لدى ChatGPT + Futuer-IT |
| تحقق لوحة المفاتيح/قارئ الشاشة يدوياً | PENDING — أضيفت تسميات Semantics لكن لم يُجرَ فحص يدوي |

ملاحظات بصرية صغيرة متبقية: أثر حرفين من التسمية المحروقة يظهر عند حافة بطاقة «الأماكن» على 390px؛ عنوان المصدر المختار إنجليزي لأن السجل المحكوم كذلك.
صور البطل والقصص ما زالت أصول `visual_reference_v1` نفسها الموجودة في main (لا صور جديدة ولا أصول غير موثقة).

## 4. لم يُمس

لا تعديل لنسخة Futuer-IT المحلية ولا لملفات WIP الستة؛ لا دفع من جهاز محلي؛ لا دمج تاريخي؛ لا كتابة على قاعدة مشتركة؛ لا Vercel؛ لا نشر بحثي؛ لا PR.

## 5. توصية الدمج

مرشح جاهز للمراجعة. التوصية: فتح PR من الفرع بعد تفويض المالك على SHA `9e21e1e8…`، مع تشغيل UAT المحلي على سطح المكتب و390،
ثم قرار منفصل بشأن تطبيق ترحيل الحماية على بيئة غير إنتاجية أولاً وإعادة تشغيل `tools/rls_boundary` عليها.
