# D4 — مقارنة مزودي بلاطات الخريطة (MAP_PROVIDER = PENDING_FINAL_SELECTION)

الحالة: **مقارنة موثقة؛ لم يُختر مزود إنتاج.** `PRODUCTION_MAP_FAIL_CLOSED = TRUE`.
تاريخ جمع الأسعار: 2026-10-09 (من صفحات الأسعار الرسمية؛ يجب إعادة التحقق عند القرار).

## طبقة التكامل المرنة (منفذة)

`lib/core/config/map_tile_provider_policy.dart`:

- الأوضاع: `osm_standard` (تطوير/مراجعة فقط)، `approved_external` (أي مزود بقالب `https://…/{z}/{x}/{y}…`)، `disabled`.
- الإنتاج: يُغلق تلقائيًا ما لم يكن الوضع `approved_external` **و** `MAP_TILE_PROVIDER_APPROVED=true` **و** القالب/الإسناد/رابط البلاغ كلها HTTPS صالحة.
- تبديل المزود = تغيير `--dart-define` فقط، دون تعديل كود.
- الأطلس يعمل محليًا بدون بلاطات: تصفية الفئات الحقيقية وقائمة الوصول البديلة (`map-list-toggle`) تعملان حتى في وضع `disabled`.

## المقارنة

| المزود | النموذج | المجاني | أول خطة تجارية | تجاري في المجاني؟ | ملاحظات الترخيص/الاعتمادية |
|---|---|---|---|---|---|
| OSM Standard (tile.openstreetmap.org) | تبرعي | مجاني | — | سياسة الاستخدام تمنع الاستخدام الكثيف ولا SLA | **غير مناسب للإنتاج**؛ مسموح للتطوير فقط (منفذ كذلك) |
| MapTiler Cloud | جلسات + طلبات | 5k جلسة، 100k طلب؛ يتوقف عند النفاد | Flex ‏$30/شهر: 25k جلسة، 500k طلب | لا (للاختبار وغير التجاري) | شعار MapTiler مطلوب في المجاني |
| Stadia Maps | رصيد (بلاطة = 1) | 200k رصيد | Starter ‏$20/شهر: 1M؛ +3¢/1000 | لا | خطط أعلى: Standard ‏$80 (7.5M) |
| Mapbox | لكل 1000 طلب | Raster Tiles 750k/شهر مجانًا | $0.25/1000 بعد ذلك | نعم ضمن الشروط | يتطلب حسابًا وبطاقة؛ شروط تخزين مؤقت مقيّدة |
| Protomaps (PMTiles ذاتي الاستضافة) | ملف واحد على تخزين ساكن | البيانات مجانية (ODbL) | كلفة التخزين/النقل فقط (R2 بلا رسوم خروج) | نعم (مع إسناد OSM) | يحتاج `flutter_map` vector/PMTiles plugin — تغيير معماري صغير؛ تحكم كامل وسيادة بيانات |

## توصية فنية (غير ملزمة — القرار سيادي)

1. **للسيادة والكلفة المنخفضة على المدى الطويل**: Protomaps ذاتي الاستضافة (يتطلب حساب تخزين/CDN — مورد خارجي غير مصرح به حاليًا).
2. **لأسرع إطلاق دون تغيير معماري**: Stadia Starter أو MapTiler Flex عبر `approved_external` (مدفوع — يحتاج موافقة).

كل الخيارات أعلاه تتطلب **موافقة مالية/حساب** → `BLOCKED_PENDING_SOVEREIGN_SELECTION`.

## اختبارات الأداء/الترخيص

- اختبارات السياسة: `test/map_tile_provider_policy_test.dart`, `test/map_tile_policy_surface_test.dart` (الإنتاج مغلق، HTTPS إلزامي، الإسناد إلزامي).
- E2E المتصفح: سياسة الشبكة تسمح فقط بـ `https://tile.openstreetmap.org/` في بناء staging، ولا أي أصل خارجي آخر.
- قياس الأداء الحقيقي لمزود مدفوع: **BLOCKED** حتى توفر مفتاح تجريبي معتمد.

## المصادر

- https://www.maptiler.com/cloud/pricing/
- https://stadiamaps.com/pricing/
- https://www.mapbox.com/pricing
- https://protomaps.com/faq
- https://operations.osmfoundation.org/policies/tiles/
