param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectRoot = ".",

    [Parameter(Mandatory=$false)]
    [switch]$BuildWeb,

    [Parameter(Mandatory=$false)]
    [switch]$AllowMissingFlutter
)

$ErrorActionPreference = "Stop"
$ProjectRoot = (Resolve-Path $ProjectRoot).Path
Set-Location $ProjectRoot

Write-Host "PAL_EYES_RUNTIME_CHECKS_ROOT=$ProjectRoot"

$Python = Get-Command python -ErrorAction SilentlyContinue
if (-not $Python) {
    $Python = Get-Command py -ErrorAction SilentlyContinue
}
if (-not $Python) {
    throw "Python was not found in PATH."
}

& $Python.Source ".\tools\verify_flutter_runtime_foundation_static.py" "."
if ($LASTEXITCODE -ne 0) {
    throw "Static verification failed."
}

Write-Host "STATIC_SOURCE_CONTRACT=PASS"

$Flutter = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $Flutter) {
    if ($AllowMissingFlutter) {
        Write-Host "FLUTTER_RUNTIME_CHECKS=SKIPPED_FLUTTER_NOT_FOUND"
        exit 0
    }
    throw "Flutter was not found in PATH. Run with -AllowMissingFlutter only for static-only verification."
}

flutter --version
if ($LASTEXITCODE -ne 0) {
    throw "flutter --version failed."
}

flutter pub get
if ($LASTEXITCODE -ne 0) {
    throw "flutter pub get failed."
}

flutter analyze
if ($LASTEXITCODE -ne 0) {
    throw "flutter analyze failed."
}

flutter test
if ($LASTEXITCODE -ne 0) {
    throw "flutter test failed."
}

if ($BuildWeb) {
    flutter build web
    if ($LASTEXITCODE -ne 0) {
        throw "flutter build web failed."
    }
}

Write-Host "FLUTTER_PUB_GET=PASS"
Write-Host "FLUTTER_ANALYZE=PASS"
Write-Host "FLUTTER_TEST=PASS"
if ($BuildWeb) {
    Write-Host "FLUTTER_BUILD_WEB=PASS"
}
Write-Host "PAL_EYES_RUNTIME_CHECKS=PASS"
