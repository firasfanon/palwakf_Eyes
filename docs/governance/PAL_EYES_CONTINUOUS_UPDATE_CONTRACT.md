# عقد التحديث المستمر لذاكرة مشروع بعيون فلسطينية

## القاعدة الإلزامية

كل دفعة تطوير تغير واحداً أو أكثر من العناصر التالية يجب أن تحدث ملفات الذاكرة والتتبع في الدفعة نفسها:

- هوية موقع أو اسمه أو نوعه أو علاقته.
- فقرة أو ادعاء أو حالة تحقق.
- مصدر أو مرجع أو موضع استشهاد.
- إحداثية أو حد جغرافي.
- حق نص أو صورة أو خريطة.
- حالة صفحة أو اختبار أو UAT.
- قرار حوكمة أو نشر أو استيراد.
- أولوية الخطة أو نقطة الاستئناف.

## الملفات الإلزامية

1. `PAL_EYES_PROJECT_MEMORY_CURRENT.md`
2. `PAL_EYES_PROJECT_STATE_SNAPSHOT_CURRENT.json`
3. `PAL_EYES_PROJECT_PLAN_CURRENT.md`
4. `PAL_EYES_MASTER_SITE_STATUS_REGISTRY_CURRENT.json`
5. `PAL_EYES_MASTER_SITE_STATUS_TRACKER_CURRENT.xlsx`
6. `PAL_EYES_CHANGELOG_CURRENT.md`
7. `PAL_EYES_SESSION_HANDOFF_CURRENT.md`
8. `PAL_EYES_PROJECT_UPDATE_LOG.jsonl`

## عقد كل دفعة

يجب أن تسجل الدفعة:

```text
BATCH_ID
DATE
PURPOSE
FILES_CHANGED
SITES_AFFECTED
SOURCES_AFFECTED
CLAIMS_AFFECTED
RIGHTS_AFFECTED
TEST_RESULT
DATABASE_WRITE
PUBLICATION
NEXT_PRIORITY
```

## قواعد عدم النسيان

- لا تُستبدل الملفات الحالية دون نسخة احتياطية.
- يحتفظ الـChangelog بالأثر الزمني ولا يعاد كتابته من الصفر.
- جدول المواقع هو المرجع التشغيلي اليومي.
- JSON هو المرجع الآلي.
- Markdown هو مرجع التوريث البشري.
- لا تُرقى حالة موقع إلى منشور من جدول فقط.
- لا يُعتمد أصل وسائط بلا ملف فعلي وSHA-256 ودليل حقوق.
- لا تُحذف الادعاءات المعلقة؛ تُغلق أو تستبدل مع حفظ الأثر.
- أي اختلاف بين الجدول والكتالوج المرشح يوقف الاعتماد حتى المصالحة.

## إجراء نهاية كل جلسة

```text
UPDATE_MEMORY=REQUIRED
UPDATE_PLAN=REQUIRED
UPDATE_MASTER_TRACKER=REQUIRED
APPEND_CHANGELOG=REQUIRED
WRITE_HANDOFF=REQUIRED
VERIFY_HASHES=REQUIRED
```
