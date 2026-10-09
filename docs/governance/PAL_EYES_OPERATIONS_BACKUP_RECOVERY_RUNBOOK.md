# دليل التشغيل: Staging، النسخ الاحتياطي، الاستعادة، التراجع، المراقبة

الحالة: **جاهز إجرائيًا؛ التنفيذ على Staging حقيقي BLOCKED** (D1/D2: لا يمكن إنشاء مشروع Supabase ثالث مجاني دون تغيير خطة أو مساس بمشاريع أنظمة أخرى).

## 1. البيئات

| البيئة | قاعدة البيانات | المصادقة | الفهرسة | الخريطة |
|---|---|---|---|---|
| local / CI | Supabase CLI محلي (`supabase/config.toml`) + Postgres 17 | حسابات اصطناعية `@synthetic.example.invalid` | noindex | OSM للتطوير |
| staging | مشروع Supabase مستقل غير إنتاجي (لم يُنشأ — BLOCKED) | دعوات فقط، MFA للأدوار الحساسة | noindex + robots Disallow | OSM/مزود تجريبي |
| production | غير موجود — يتطلب قرارًا سياديًا | دعوات فقط، MFA إلزامي للنشر والأدوار | indexable للمنشور فقط | Fail-Closed حتى D4 |

## 2. تطبيق migrations على Staging

1. المالك ينشئ بيئة GitHub محمية `pal-eyes-staging` بمراجع مطلوب، ويضيف الأسرار:
   `SUPABASE_ACCESS_TOKEN`, `SUPABASE_STAGING_PROJECT_REF`, `SUPABASE_STAGING_DB_PASSWORD`،
   والمتغير `PAL_EYES_FORBIDDEN_PROJECT_REFS` (معرّفات مشاريع الأنظمة الأخرى مفصولة بفواصل).
2. تشغيل `Pal Eyes staging migrations` يدويًا بـ `apply=false` و`STAGING_ONLY` → يتحقق من الترتيب والبصمات وملفات rollback، يأخذ **نقطة استعادة** (dump مخطط + بيانات كـ artifact مع SHA256)، ثم dry-run.
3. مراجعة `dry_run.txt`، ثم إعادة التشغيل بـ `apply=true`.
4. بعد التطبيق: تشغيل `tools/supabase_local_e2e/api_e2e.py` ضد staging (يرفض حاليًا غير loopback — يجب إضافة allowlist صريحة لمرجع staging عند الإنشاء) وسيناريوهات RLS السلبية.

## 3. التراجع (Rollback)

ترتيب عكسي:

```
psql "$DB_URL" -v ON_ERROR_STOP=1 -f supabase/rollback/202610090004_down.sql
psql "$DB_URL" -v ON_ERROR_STOP=1 -f supabase/rollback/202610090003_down.sql
```

- `0004_down` يُبقي أعمدة provenance (لا فقد بيانات) ويزيل المحفزات والسياسات والدوال.
- تم إثبات الدورة كاملة محليًا وفي CI: seed → بصمة md5 → down 0004/0003 → re-apply → reseed → **بصمة مطابقة** و0 مواقع غير محجوبة (`tools/rls_boundary/run_local_rls_boundary_tests.sh --rollback-cycle`).
- التراجع عن الواجهة: إعادة نشر بناء الويب السابق (artifact `web-builds` من التشغيل السابق)؛ لا يوجد نشر إنتاجي حاليًا.

## 4. الاستعادة من نقطة الاستعادة

```
psql "$DB_URL" -v ON_ERROR_STOP=1 -f restore_point/schema.sql
psql "$DB_URL" -v ON_ERROR_STOP=1 -f restore_point/data.sql
sha256sum -c restore_point/SHA256SUMS
```

اختبار الاستعادة على Staging الحقيقي: **BLOCKED** حتى إنشاء المشروع. النسخ الاحتياطي اليومي المُدار وPITR يتطلبان خطة Supabase مدفوعة — قرار مالي.

## 5. المراقبة (D6 معلّق)

- `lib/core/observability/error_reporting.dart`: التقاط أخطاء Flutter وأخطاء المنصة في مخزن دائري (50) مع `ConsoleErrorSink`؛ الوضع عبر `PAL_EYES_ERROR_REPORTING`.
- ربط مزود خارجي (Sentry/غيره) = تنفيذ `ErrorSink` جديد فقط — **BLOCKED** على اختيار المزود والموافقة (D6).
- سجلات قاعدة البيانات: جدول التدقيق append-only (`pal_eyes.audit_events`) يسجل كل تغيير تشغيلي مع الفاعل المختوم من الخادم.

## 6. ملاحظة Vercel

`vercel.json` يعطّل النشر التلقائي من git. عند تفعيل المعاينة: إعادة كتابة SPA ترجع `index.html` حتى للأصول المفقودة (`.js`/`.woff2`) فتخفي أخطاء 404؛ يجب استثناء المسارات ذات الامتدادات من إعادة الكتابة، واستخدام ملفات `<route>/index.html` المولدة لـ SEO بدل إعادة الكتابة للمسارات العامة.
