# PAL_EYES_UI_UX_PRODUCTIVE_SURFACES_COMPILE_HOTFIX_V1_0_2

## العيب

الإصدار V1.0.1 استخدم الصيغة غير الصحيحة:

```dart
trailing?,
```

ففسرها محلل Dart كشرط غير Boolean.

## الإصلاح

الصيغة الصحيحة للعنصر nullable داخل Collection literal هي:

```dart
?trailing,
```

## Regression gate

يتحقق الفاحص الساكن من:

```text
PREFIX_NULL_AWARE_ELEMENT_PRESENT=TRUE
POSTFIX_NULL_AWARE_ELEMENT_ABSENT=TRUE
LEGACY_IF_NULL_CHECK_ABSENT=TRUE
```

## الحدود

لا تغيير وظيفي أو محتوى أو قاعدة بيانات أو نشر.
