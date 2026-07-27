# الدفعة التشغيلية التالية

## الاسم

`MEGA_BATCH_PAL_EYES_OPERATIONAL_PLACE_DISCOVERY_DOCUMENTATION_AND_REVIEW_V1`

## الهدف

بناء أول مسار رأسي إنتاجي متكامل يبدأ من اكتشاف الموقع وينتهي بتحرير وثيقته ومراجعتها، مع تطوير الواجهة العامة ومساحة الباحث والإدارة بالتوازي.

## المسار التشغيلي

```text
Discover Place
→ Open Place Detail
→ Inspect Historical Narrative
→ Inspect Sources and Claims
→ Edit Draft in Research Workspace
→ Submit for Review
→ Review Decision
→ Return or Approve
```

## النطاق الوظيفي

### 1. الاستكشاف والبحث

- بحث عربي مطبع.
- فلاتر المحافظة والمدينة والنوع والفترة والحالة.
- بطاقات مواقع محسنة.
- حالات Loading/Empty/Error.
- روابط مباشرة إلى التفاصيل والخريطة.

### 2. صفحة الموقع

- Hero وهوية الموقع.
- نظرة عامة.
- فصول الوثيقة التاريخية.
- الخط الزمني.
- الادعاءات والاستشهادات.
- المصادر.
- الخريطة.
- حالة الحفظ والتهديدات.
- المواقع المرتبطة.

### 3. مساحة الباحث

- قائمة المواقع قيد البحث.
- فتح مسودة الموقع.
- تحرير بيانات أساسية وفصول الوثيقة.
- إضافة ادعاء ومصدر تجريبي.
- حفظ Draft محلياً عبر Repository abstraction.
- إرسال للمراجعة.

### 4. المراجعة والإدارة

- Review Queue.
- عرض الفرق والتعليقات.
- قبول أو إرجاع مع سبب.
- سجل قرار واضح.
- لا نشر عام تلقائي.

### 5. UI/UX

- App Shell أكثر إحكاماً.
- Navigation responsive.
- صفحات الهاتف الضيق.
- Dark mode UAT.
- نماذج مريحة بالعربية.
- تقسيم النماذج الطويلة إلى أقسام.
- مؤشرات حالة واضحة.
- منع Overflow.

### 6. البيانات والحوكمة

- Models للرواية والأقسام والادعاءات والمصادر والمراجعة.
- Repository contracts.
- Local fixture adapter أولاً.
- Supabase adapter contract دون تفعيل الكتابة الحية.
- Workflow states.
- Rights and citation validation.
- Audit event model.
- Publication remains blocked.

## بوابات القبول

- Static verifier PASS.
- `flutter analyze` PASS.
- `flutter test` PASS.
- `flutter build web` PASS.
- Desktop UAT.
- Mobile narrow UAT.
- Dark mode UAT.
- Route-by-route UAT.
- لا DB live mutation.
- لا محتوى تاريخي غير موثق منشور.
