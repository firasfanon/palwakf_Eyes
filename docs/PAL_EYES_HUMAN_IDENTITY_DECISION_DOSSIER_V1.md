# ملف القرارات البشرية المقترحة للهوية

## بعيون فلسطينية — Palestinian Eyes

```yaml
batch_id: MEGA_BATCH_PAL_EYES_HUMAN_IDENTITY_DECISION_DOSSIER_V1
document_status: recommended_pending_user_approval
queue_records_reviewed: 33
structural_change_recommendations: 23
non_structural_keep_recommendations: 10
unresolved_identity_holds: 4
relation_proposals: 9
canonical_catalog_mutation: false
database_write: false
project_source_mutation: false
publication_approval: blocked
```

## النتيجة

أُعيدت مراجعة طابور الهوية يدوياً، وتبيّن أن بعض الإدخالات كانت إشارات آلية زائدة ناتجة عن كلمات مثل «فصل التقليد عن التأريخ»، وليست تعارضات حقيقية في هوية الموقع.

- **10** سجلات يوصى بالإبقاء على هويتها دون تغيير بنيوي.
- **23** سجلاً تتطلب علاقة مكوّن، إعادة تصنيف، فصل هوية، دمجاً أو تصحيحاً مكانياً.
- **4** سجلات تبقى معلقة لعدم كفاية مصدر الهوية.

## ملخص القرارات

| القرار | العدد |
|---|---:|
| `ACCEPT_COMPONENT_RELATION` | 6 |
| `HOLD_UNRESOLVED_IDENTITY` | 4 |
| `KEEP_CANONICAL_IDENTITY_CLAIM_ONLY` | 4 |
| `KEEP_CANONICAL_IDENTITY_COMPLEX` | 2 |
| `MERGE_ALIAS_OR_COMPONENT` | 1 |
| `REASSIGN_LOCALITY_AND_LINK_CLUSTER` | 1 |
| `RECLASSIFY_TO_GOVERNED_CLUSTER` | 11 |
| `SPLIT_COMPOSITE_IDENTITY` | 4 |

## مصفوفة القرارات

| # | الموقع | القرار المقترح | تغيير بنيوي | التوصية |
|---:|---|---|---|---|
| 1 | `site-4b15f14c306f` — كنيسة المهد | `KEEP_CANONICAL_IDENTITY_CLAIM_ONLY` | لا | الإبقاء على هوية كنيسة المهد دون فصل أو إعادة تصنيف. |
| 2 | `site-f9df0c7e708c` — بلدة سلوان | `KEEP_CANONICAL_IDENTITY_CLAIM_ONLY` | لا | الإبقاء على بلدة سلوان كسجل حاكم، مع مراجعة الادعاءات ونطاق الموقع فقط. |
| 3 | `site-f7553f79288f` — قصور المماليك (شارع الواد) | `RECLASSIFY_TO_GOVERNED_CLUSTER` | نعم | إعادة تصنيف قصور المماليك في شارع الواد كعنقود معماري متعدد المكونات. |
| 4 | `site-f60be7cd7d5e` — بيت أمر (خربة النبي متى) | `SPLIT_COMPOSITE_IDENTITY` | نعم | فصل هوية بلدة بيت أمر عن خربة/مقام النبي متى؛ إنشاء المكوّن الثاني يبقى مرهوناً بمصدر مخصص. |
| 5 | `site-2310c1600481` — خان الحطب | `HOLD_UNRESOLVED_IDENTITY` | لا | تعليق خان الحطب وعدم ربطه تلقائياً ببلدة الخليل القديمة حتى العثور على سجل معماري أو وقفي مخصص. |
| 6 | `site-d2c9e9bc9652` — قلعة الكرمل (دير سامت) | `HOLD_UNRESOLVED_IDENTITY` | لا | تعليق سجل قلعة الكرمل/دير سامت بوصفه هوية مركبة غير محسومة. |
| 7 | `site-0dc57168d963` — مغارة البطاركة (جزء من الحرم) | `ACCEPT_COMPONENT_RELATION` | نعم | اعتماد مغارة البطاركة مكوّناً من مجمع الحرم الإبراهيمي ومنعها كسجل نشر أو خريطة مستقل. |
| 8 | `site-63fe9eba7871` — قلعة البرك | `ACCEPT_COMPONENT_RELATION` | نعم | اعتماد قلعة البرك مكوّناً من مجمع برك سليمان. |
| 9 | `site-21150eefdea6` — تل العجول (مدينة غزة القديمة) | `SPLIT_COMPOSITE_IDENTITY` | نعم | فصل تل العجول عن مدينة غزة القديمة، والإبقاء على تل العجول موقعاً أثرياً برونزياً مستقلاً. |
| 10 | `site-5e98cf44d976` — قلعة برقوق | `ACCEPT_COMPONENT_RELATION` | نعم | الإبقاء على قلعة برقوق معلماً مستقلاً وربطها كمكوّن من عنقود خان يونس القديم. |
| 11 | `site-e1e3de7b8519` — كنيسة القديس برفيريوس | `KEEP_CANONICAL_IDENTITY_CLAIM_ONLY` | لا | الإبقاء على هوية كنيسة القديس برفيريوس دون فصل؛ معالجة العمر والتقاليد ضمن الادعاءات. |
| 12 | `site-015f495c4236` — مدينة غزة القديمة | `RECLASSIFY_TO_GOVERNED_CLUSTER` | نعم | إعادة تصنيف مدينة غزة القديمة كعنقود حضري تاريخي ذي مكونات. |
| 13 | `site-0a78d22c1a69` — خان يونس القديم | `RECLASSIFY_TO_GOVERNED_CLUSTER` | نعم | إعادة تصنيف خان يونس القديم كعنقود حضري تاريخي مؤقت الحدود، مع قلعة برقوق كمكوّن أول. |
| 14 | `site-ee0e5bf1f753` — رفح التاريخية | `RECLASSIFY_TO_GOVERNED_CLUSTER` | نعم | الإبقاء على رفح التاريخية كعنقود حضري مؤقت، وإنشاء تل رفح كمكوّن أثري منفصل عند توفر هوية حاكمة. |
| 15 | `site-a9ac192e20c3` — بلدة نابلس القديمة | `RECLASSIFY_TO_GOVERNED_CLUSTER` | نعم | اعتماد بلدة نابلس القديمة عنقوداً حضرياً تاريخياً. |
| 16 | `site-160c60c7b952` — حارة الياسمينة | `ACCEPT_COMPONENT_RELATION` | نعم | اعتماد حارة الياسمينة مكوّناً عمرانياً من بلدة نابلس القديمة. |
| 17 | `site-31c7667ff10e` — خان التجار | `ACCEPT_COMPONENT_RELATION` | نعم | اعتماد خان التجار مكوّناً تجارياً من بلدة نابلس القديمة، مع منعه من الدمج مع خان الوكالة. |
| 18 | `site-d00341226494` — مقام النبي شعيب | `HOLD_UNRESOLVED_IDENTITY` | لا | تعليق مقام النبي شعيب حتى حسم الموقع بين نابلس وسنجل وتحديد المقام المقصود. |
| 19 | `site-f2a7fbbda5a5` — بلدة جنين القديمة | `RECLASSIFY_TO_GOVERNED_CLUSTER` | نعم | اعتماد بلدة جنين القديمة عنقوداً حضرياً تاريخياً مؤقت الحدود. |
| 20 | `site-fe1e2a1605b5` — قصر الكايد | `REASSIGN_LOCALITY_AND_LINK_CLUSTER` | نعم | نقل إسناد قصر الكايد من جنين إلى سبسطية بمحافظة نابلس وربطه بعنقود سبسطية. |
| 21 | `site-be1c2ce90997` — مدينة طولكرم التاريخية | `RECLASSIFY_TO_GOVERNED_CLUSTER` | نعم | الإبقاء على مدينة طولكرم التاريخية كعنقود حضري مؤقت غير محدد الحدود. |
| 22 | `site-69f3ad775733` — خربة دير استيا | `RECLASSIFY_TO_GOVERNED_CLUSTER` | نعم | تغيير هوية خربة دير استيا إلى بلدة دير استيا التاريخية كعنقود حي. |
| 23 | `site-ba91049d51a9` — عيون الماء الأثرية | `RECLASSIFY_TO_GOVERNED_CLUSTER` | نعم | إعادة تصنيف عيون الماء الأثرية كعنقود هيدرولوجي يتطلب سجلاً مستقلاً لكل نبع. |
| 24 | `site-bc56c2f93d66` — عين الفارعة | `HOLD_UNRESOLVED_IDENTITY` | لا | تعليق عين الفارعة كسجل مستقل حتى تمييزها عن وادي وتل الفارعة والمنظومة المائية الأوسع. |
| 25 | `site-e2a5c15f76f6` — بلدة بيرزيت القديمة | `RECLASSIFY_TO_GOVERNED_CLUSTER` | نعم | اعتماد بلدة بيرزيت القديمة عنقوداً عمرانياً تاريخياً. |
| 26 | `site-014e4c4e4845` — خربة عابود | `SPLIT_COMPOSITE_IDENTITY` | نعم | فصل خربة عابود إلى عنقود عابود التاريخي ومكونات مستقلة للكنائس والمقابر والمعاصر والخرب. |
| 27 | `site-28dd528f5f3a` — دير عمار | `RECLASSIFY_TO_GOVERNED_CLUSTER` | نعم | إعادة تصنيف دير عمار كبلدة أو مركز تاريخي حي. |
| 28 | `site-2a3fdab99250` — عين سامية | `SPLIT_COMPOSITE_IDENTITY` | نعم | فصل عين سامية إلى النبع والمقبرة البرونزية وخربة مرجمة وخربة سامية والعناصر المعمارية المرشحة. |
| 29 | `site-12fc185d4b0b` — مقام النبي صالح | `KEEP_CANONICAL_IDENTITY_COMPLEX` | لا | الإبقاء على مقام النبي صالح كمجمع ديني وثقافي، مع جرد مكوناته داخلياً. |
| 30 | `site-cc4465115964` — دير قرنطل | `KEEP_CANONICAL_IDENTITY_CLAIM_ONLY` | لا | الإبقاء على دير قرنطل دون فصل؛ نقل قصة التجربة والفترات غير المثبتة إلى طابور الادعاءات. |
| 31 | `site-b5f00132ee24` — عين السلطان | `ACCEPT_COMPONENT_RELATION` | نعم | اعتماد عين السلطان مكوّناً هيدرولوجياً من عقار تل السلطان ومنع المؤشر العام المكرر. |
| 32 | `site-ce23c41d7641` — قبر النبي موسى | `MERGE_ALIAS_OR_COMPONENT` | نعم | إيقاف قبر النبي موسى كسجل عام مستقل واعتماده اسماً بديلاً أو مكوّناً من مقام النبي موسى. |
| 33 | `site-c4d8c9fdd1f0` — مقام النبي موسى | `KEEP_CANONICAL_IDENTITY_COMPLEX` | لا | الإبقاء على مقام النبي موسى بوصفه السجل الأب للمجمع. |

## العلاقات المقترحة

| العلاقة | المصدر | الهدف |
|---|---|---|
| `COMPONENT_OF` | `site-0dc57168d963` — مغارة البطاركة (جزء من الحرم) | `site-899e38be070d` — الحرم الإبراهيمي |
| `COMPONENT_OF` | `site-63fe9eba7871` — قلعة البرك | `site-37c8be50ce73` — برك سليمان |
| `COMPONENT_OF` | `site-5e98cf44d976` — قلعة برقوق | `site-0a78d22c1a69` — خان يونس القديم |
| `COMPONENT_OF` | `site-160c60c7b952` — حارة الياسمينة | `site-a9ac192e20c3` — بلدة نابلس القديمة |
| `COMPONENT_OF` | `site-31c7667ff10e` — خان التجار | `site-a9ac192e20c3` — بلدة نابلس القديمة |
| `COMPONENT_OF` | `site-fe1e2a1605b5` — قصر الكايد | `site-6f6afe87f969` — سبسطية (شمرون) |
| `COMPONENT_OF` | `site-b5f00132ee24` — عين السلطان | `site-a86fc049d470` — تل السلطان (أريحا القديمة) |
| `COMPONENT_OR_ALIAS_OF` | `site-ce23c41d7641` — قبر النبي موسى | `site-c4d8c9fdd1f0` — مقام النبي موسى |
| `NOT_SAME_AS` | `site-21150eefdea6` — تل العجول (مدينة غزة القديمة) | `site-015f495c4236` — مدينة غزة القديمة |

## قيود الموافقة

الموافقة على هذه المصفوفة لا تعدّل الكتالوج مباشرة. وهي تفوض فقط بناء **كتالوج مرشح مصحح غير مطبق** وحزمة فروق قابلة للمراجعة.

```text
AUTO_APPLY=FALSE
CANONICAL_CATALOG_MUTATION=FALSE
DATABASE_WRITE=FALSE
PROJECT_SOURCE_MUTATION=FALSE
PUBLICATION=BLOCKED
```
