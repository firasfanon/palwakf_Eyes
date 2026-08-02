# تقرير إغلاق نطاق الادعاءات والمصادر

## بعيون فلسطينية — Palestinian Eyes

```yaml
batch_id: MEGA_BATCH_PAL_EYES_CLAIM_AND_BIBLIOGRAPHIC_CLOSURE_ON_R1_0_1_CANDIDATE_V1
candidate_catalog: PAL_EYES_CORRECTED_CANONICAL_CATALOG_CANDIDATE_R1_0_1_20260715
execution_status: PASS
closure_mode: CLAIM_SCOPE_AND_BIBLIOGRAPHIC_IDENTITY_ONLY
candidate_catalog_mutation: false
database_write: false
project_source_mutation: false
database_import_approval: blocked
publication_approval: blocked
```

## تعريف الإغلاق

الإغلاق في هذه الدفعة له مستويان محدودان:

1. **إغلاق الهوية الببليوغرافية:** تثبيت عنوان المصدر والجهة والفئة ورابط قابل للتعقب، مع موضع الاستشهاد حيث أمكن.
2. **إغلاق نطاق الادعاء:** إثبات أن الادعاء الضيق مدعوم داخل نطاق المصدر ونوعه وحدوده، دون اعتباره اعتماداً تاريخياً نهائياً.

لا يشمل ذلك حقوق إعادة الاستخدام أو الإقرار بصحة كل محتوى المصدر أو اعتماد النص العربي أو السماح بالنشر.

## النتائج الكمية

| المؤشر | العدد |
|---|---:|
| `candidate_sites` | 79 |
| `source_ids_reviewed` | 76 |
| `unique_source_resources` | 73 |
| `source_alias_groups` | 3 |
| `bibliographic_identities_closed` | 76 |
| `confirmed_claims_reviewed` | 96 |
| `confirmed_claim_scopes_closed` | 95 |
| `confirmed_claim_scopes_open` | 1 |
| `held_claim_groups_carried_forward` | 211 |
| `sites_with_closed_confirmed_claims` | 60 |
| `sites_with_no_closed_confirmed_claims` | 19 |
| `rights_approved_sources` | 0 |
| `publication_ready_sites` | 0 |

## تطبيع المصادر المكررة

جرى التعرف على ثلاثة موارد لها معرّفات داخلية مكررة. لم يُحذف أي معرّف؛ بل أضيفت علاقة alias إلى المصدر المرجعي:

| المورد | المصدر المرجعي | الأسماء البديلة |
|---|---|---|
| `SRCRES-025` | `AUTH-UNESCO-HEBRON-001` | `W2-AUTH-UNESCO-HEBRON-001` |
| `SRCRES-027` | `AUTH-UNESCO-JERICHO-001` | `W5-AUTH-UNESCO-JERICHO-001` |
| `SRCRES-048` | `W4-AUTH-RIWAQ-50-CENTRES` | `W5-AUTH-RIWAQ-50-CENTRES-001` |

## الادعاء الذي لم يُغلق

`site-c6731a990917-W4-C02` — **تل الفارعة**

النص الحالي يدعي أن مرجع Cambridge يحدد مراحل استيطان مرتبة ومحصنة في تل الفارعة الشمالي. الصفحة المفحوصة للفصل تشرح العمران والتحصين في جنوب بلاد الشام عموماً، لكن لم يُعثر فيها على موضع خاص بتل الفارعة يدعم هذه الصياغة. لذلك:

```text
CLAIM_SCOPE=OPEN
CURRENT_SOURCE_IDENTITY=CLOSED
SITE_SPECIFIC_EVIDENCE=NOT_LOCATED
SOURCE_REPLACEMENT_OR_EXACT_PAGE=REQUIRED
ARABIC_REWRITE=BLOCKED
PUBLICATION=BLOCKED
```

يبقى سجل corpus حفريات المدرسة الكتابية والآثارية الفرنسية صالحاً لإثبات وجود تاريخ بحث ونشر للموقع، لكنه لا يغلق هذا الادعاء التفصيلي وحده.

## مواضع الاستشهاد التي ثُبتت

- تقييم ICOMOS للخليل: الصفحات 6، 8–9، 12 و16.
- تقرير مراقبة القدس: الصفحتان 49–50.
- حفريات مغارة الحليب الإسعافية: الصفحة 32.
- دراسة تل العجول: الصفحة الأولى للموقع والسياق البرونزي.
- دراسة مقام النبي يوسف: الصفحتان 33–34.
- تقرير أضرار غزة المنسوب إلى الجهة الفلسطينية: الصفحات 67–69 و71.
- دليل المسارات الفلسطيني: الصفحتان 20 و68 لمشهد عين سامية.
- مقالة قبر عين سامية 204: الصفحات 73–77 ببليوغرافياً.

## الادعاءات المعلقة

بقيت **211** مجموعة ادعاءات في طابور البحث. لم تُحوَّل إلى نصوص تحريرية، ولم يُنشأ لها دعم افتراضي من مواد DeepSeek.

## بوابات الاعتماد

```text
BIBLIOGRAPHIC_SOURCE_IDS_REVIEWED=76
UNIQUE_SOURCE_RESOURCES=73
BIBLIOGRAPHIC_IDENTITIES_CLOSED=76
CONFIRMED_CLAIMS_REVIEWED=96
CONFIRMED_CLAIM_SCOPES_CLOSED=95
CONFIRMED_CLAIM_SCOPES_OPEN=1
HELD_CLAIM_GROUPS_OPEN=211
RIGHTS_APPROVED_SOURCES=0
PUBLICATION_READY_SITES=0
CANDIDATE_CATALOG_MUTATION=FALSE
DATABASE_WRITE=FALSE
PROJECT_SOURCE_MUTATION=FALSE
DATABASE_IMPORT=BLOCKED
PUBLICATION=BLOCKED
NEXT_PRIORITY=ARABIC_EDITORIAL_REWRITE_FOR_95_CLOSED_CLAIMS_PLUS_RIGHTS_TRIAGE
```
