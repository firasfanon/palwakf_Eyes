# تقرير المصالحة العابرة للموجات وإعادة الكتابة الحاكمة

## بعيون فلسطينية — Palestinian Eyes

```yaml
batch_id: MEGA_BATCH_PAL_EYES_CROSS_WAVE_RECONCILIATION_AND_GOVERNED_REWRITE_V1
execution_status: PASS
canonical_catalog_coverage: 79_OF_79
database_write: false
project_source_mutation: false
canonical_catalog_mutation: false
canonical_coordinate_mutation: false
external_coordinate_promotion: false
database_import_approval: blocked
publication_approval: blocked
```

## النتائج الكمية

| المؤشر | العدد |
|---|---:|
| `canonical_sites` | 79 |
| `sites_reconciled` | 79 |
| `source_records` | 76 |
| `confirmed_claims` | 96 |
| `held_claim_groups` | 211 |
| `identity_review_queue` | 33 |
| `relation_proposals` | 6 |
| `external_coordinate_candidates` | 4 |
| `canonical_coordinates_available_for_review` | 3 |
| `canonical_coordinate_gaps` | 76 |
| `bibliographic_queue` | 76 |
| `rights_queue` | 79 |
| `publication_ready_sites` | 0 |

## نتيجة المصالحة

- تم دمج سجلات التحقق الخمس في سجل موحد يغطي جميع المعرّفات الحاكمة.
- لم تُغيّر هوية أو Slug أو إحداثية داخل الكتالوج.
- فُصلت الادعاءات المدعومة ضمن نطاقها عن الادعاءات المعلقة أو غير المسندة.
- أُنشئت طوابير مستقلة للهوية والادعاءات والصفحات الببليوغرافية والإحداثيات والحقوق.
- أُنشئت مسودة مراجعة بشرية لكل موقع دون إعلان أي موقع جاهزاً للنشر.

## مقترحات العلاقات البنيوية

| proposal_id | العلاقة | المصدر | الهدف | الحالة |
|---|---|---|---|---|
| `REL-001` | `COMPONENT_OF` | `site-0dc57168d963` — مغارة البطاركة (جزء من الحرم) | `site-899e38be070d` — الحرم الإبراهيمي | `PROPOSED_REQUIRES_HUMAN_APPROVAL` |
| `REL-002` | `COMPONENT_OF` | `site-63fe9eba7871` — قلعة البرك | `site-37c8be50ce73` — برك سليمان | `PROPOSED_REQUIRES_HUMAN_APPROVAL` |
| `REL-003` | `COMPONENT_OF` | `site-b5f00132ee24` — عين السلطان | `site-a86fc049d470` — تل السلطان (أريحا القديمة) | `PROPOSED_REQUIRES_HUMAN_APPROVAL` |
| `REL-004` | `COMPONENT_OR_ALIAS_OF` | `site-ce23c41d7641` — قبر النبي موسى | `site-c4d8c9fdd1f0` — مقام النبي موسى | `PROPOSED_REQUIRES_HUMAN_APPROVAL` |
| `REL-005` | `IDENTITY_SPLIT_REQUIRED` | `site-21150eefdea6` — تل العجول (مدينة غزة القديمة) | `site-015f495c4236` — مدينة غزة القديمة | `PROPOSED_REQUIRES_HUMAN_APPROVAL` |
| `REL-006` | `REASSIGN_OR_LINK_TO_CLUSTER` | `site-fe1e2a1605b5` — قصر الكايد | `site-6f6afe87f969` — سبسطية (شمرون) | `PROPOSED_REQUIRES_HUMAN_APPROVAL` |

## عدادات الإجراءات المطلوبة

| الإجراء | عدد السجلات |
|---|---:|
| `CANONICAL_IDENTITY_OR_LOCALITY_REVIEW` | 2 |
| `CLAIM_LEVEL_REVIEW_QUEUE` | 73 |
| `COMPONENT_RELATION_MODELING` | 12 |
| `DEDICATED_SOURCE_DISCOVERY` | 20 |
| `DUPLICATE_OR_COMPONENT_RECONCILIATION` | 6 |
| `GOVERNED_REWRITE_ONLY` | 5 |
| `IDENTITY_SPLIT_OR_CONFLATION_REPAIR` | 12 |
| `NO_CONFIRMED_CLAIM_PUBLICATION_HOLD` | 19 |
| `SITE_TYPE_OR_CLUSTER_RECLASSIFICATION` | 14 |

## بوابات الاعتماد

```text
CROSS_WAVE_RECONCILIATION=PASS
CANONICAL_IDS_PRESERVED=TRUE
CANONICAL_SLUGS_PRESERVED=TRUE
SOURCE_REFERENCES_RESOLVE=TRUE
ALL_79_SITES_RECONCILED=TRUE
IDENTITY_RELATIONS_AUTO_APPLIED=FALSE
CANONICAL_COORDINATES_MUTATED=FALSE
EXTERNAL_COORDINATES_PROMOTED=FALSE
PUBLICATION_READY_SITES=0
DATABASE_IMPORT=BLOCKED
PUBLICATION=BLOCKED
NEXT_PRIORITY=HUMAN_IDENTITY_DECISIONS_THEN_CLAIM_AND_BIBLIOGRAPHIC_CLOSURE
```
