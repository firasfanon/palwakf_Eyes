# دليل تثبيت Baseline التطوير

## Baseline

`PAL_EYES_DEVELOPMENT_BASELINE_R1_0_1_20260714`

## الغرض

هذه الحزمة مخصصة لتأسيس مشروع جديد مباشرة، ولا تشترط وجود Parent Baseline.

## WhatIf

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

.\Install-PalEyesDevelopmentBaseline.ps1 `
  -ProjectRoot "C:\Users\DELL\StudioProjects\Pal_Eyes" `
  -WhatIf
```

## التثبيت

```powershell
.\Install-PalEyesDevelopmentBaseline.ps1 `
  -ProjectRoot "C:\Users\DELL\StudioProjects\Pal_Eyes"
```

## مجلد غير فارغ

التثبيت يتوقف Fail-closed إذا كان المجلد غير فارغ. بعد مراجعة المحتويات يمكن التفويض الصريح:

```powershell
.\Install-PalEyesDevelopmentBaseline.ps1 `
  -ProjectRoot "C:\Users\DELL\StudioProjects\Pal_Eyes" `
  -AllowReplaceExisting
```

ينشئ السكربت Backup في المجلد الأب قبل النسخ.

## تحقق كامل

```powershell
.\tools\Verify-PalEyesDevelopmentBaseline.ps1 `
  -ProjectRoot "C:\Users\DELL\StudioProjects\Pal_Eyes" `
  -RunFlutterChecks
```

## علامات النجاح

```text
PACKAGE_INTEGRITY=PASS
BASELINE_INSTALL=PASS
BASELINE_INTEGRITY=PASS
STATIC_SOURCE_CONTRACT=PASS
PAL_EYES_DEVELOPMENT_BASELINE=PASS
```
