# سياسة التطوير المتوازي: التشغيل + UI/UX + الحوكمة

## القرار الحاكم

لا تُبنى الدفعات القادمة بوصفها حوكمة نظرية فقط. كل Mega Batch يجب أن يقدم في الوقت نفسه:

1. **قيمة تشغيلية ملموسة** للمستخدم أو الباحث أو المحرر.
2. **تحسيناً واضحاً في UI/UX** للسطوح المستخدمة يومياً.
3. **حوكمة لازمة فقط** لحماية البيانات والمراجعة والنشر والحقوق.

## ترتيب الأولويات داخل كل دفعة

```text
Operational User Value
→ Usable UI/UX
→ Data and Repository Contract
→ Required Governance
→ Tests and Evidence
→ Baseline Promotion
```

## قاعدة الواجهة

- الواجهات اليومية بسيطة ومباشرة.
- التفاصيل الحوكمية الثقيلة تُنقل إلى صفحات فرعية أو مساحة الباحث والإدارة.
- لا تعرض المصطلحات التقنية أو القيود السيادية للمستخدم العام إلا عند الحاجة.
- كل شاشة يجب أن تساعد المستخدم على إنجاز مهمة واضحة.

## نمط الدفعة الرأسية

كل دفعة كبيرة يجب أن تشمل:

- Domain model.
- Repository contract.
- Runtime adapter.
- State management.
- Routes and screens.
- Forms and validation.
- Empty/loading/error states.
- Authorization and publication gates.
- Unit/widget/integration tests.
- Browser UAT.
- Changelog/Decision Log/Handoff.
- Full Baseline وUpdates-only.

## الحالات الاستثنائية

يمكن تنفيذ دفعة حوكمة أو أمن فقط عندما يوجد:

- خطر تسريب أو صلاحيات.
- كسر قاعدة بيانات أو RLS.
- خلل حقوق أو نشر.
- Compile/Runtime blocker.
- قرار معماري يمنع استمرار المنتج.

ويجب أن تكون الدفعة ضيقة ومبررة.
