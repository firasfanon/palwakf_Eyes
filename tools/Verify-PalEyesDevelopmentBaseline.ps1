param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectRoot = "C:\Users\DELL\StudioProjects\Pal_Eyes",

    [Parameter(Mandatory=$false)]
    [switch]$RunFlutterChecks
)

$ErrorActionPreference = "Stop"
$BaselineName = "PAL_EYES_GOVERNED_CONTENT_ADOPTION_TO_PROJECT_PAGES_R5_1_0_20260715"
$ProjectRoot = (Resolve-Path $ProjectRoot).Path

$ManifestPath = Join-Path $ProjectRoot "BASELINE_MANIFEST.json"
$MarkerPath = Join-Path $ProjectRoot "PAL_EYES_BASELINE_ID.txt"

if (-not (Test-Path $ManifestPath -PathType Leaf)) {
    throw "BASELINE_MANIFEST_MISSING=$ManifestPath"
}

if (-not (Test-Path $MarkerPath -PathType Leaf)) {
    throw "BASELINE_MARKER_MISSING=$MarkerPath"
}

$MarkerContent = Get-Content $MarkerPath -Raw -Encoding UTF8
if ($MarkerContent -notmatch [regex]::Escape("BASELINE_NAME=$BaselineName")) {
    throw "BASELINE_MARKER_MISMATCH=$MarkerPath"
}

$Manifest = Get-Content $ManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
if ($Manifest.baseline_name -ne $BaselineName) {
    throw "BASELINE_MANIFEST_NAME_MISMATCH"
}

$Validated = 0
foreach ($Item in $Manifest.files) {
    $RelativePath = ([string]$Item.path).Replace('/', '\')
    $FullPath = Join-Path $ProjectRoot $RelativePath

    if (-not (Test-Path $FullPath -PathType Leaf)) {
        throw "BASELINE_FILE_MISSING=$RelativePath"
    }

    $ActualSize = (Get-Item $FullPath).Length
    if ($ActualSize -ne [int64]$Item.size_bytes) {
        throw "BASELINE_SIZE_MISMATCH=$RelativePath"
    }

    $ActualHash = (Get-FileHash -Path $FullPath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($ActualHash -ne ([string]$Item.sha256).ToLowerInvariant()) {
        throw "BASELINE_HASH_MISMATCH=$RelativePath"
    }

    $Validated++
}

Write-Host "BASELINE_INTEGRITY=PASS"
Write-Host "BASELINE_NAME=$BaselineName"
Write-Host "BASELINE_FILES_VALIDATED=$Validated"

$Python = Get-Command python -ErrorAction SilentlyContinue
if (-not $Python) {
    $Python = Get-Command py -ErrorAction SilentlyContinue
}
if (-not $Python) {
    throw "PYTHON_NOT_FOUND"
}

$StaticVerifier = Join-Path $ProjectRoot "tools\verify_flutter_runtime_foundation_static.py"
& $Python.Source $StaticVerifier $ProjectRoot
if ($LASTEXITCODE -ne 0) {
    throw "STATIC_SOURCE_CONTRACT_FAILED"
}

Write-Host "STATIC_SOURCE_CONTRACT=PASS"

if ($RunFlutterChecks) {
    $Checks = Join-Path $ProjectRoot "tools\Invoke-PalEyesRuntimeChecks.ps1"
    & $Checks -ProjectRoot $ProjectRoot -BuildWeb
}

Write-Host "PAL_EYES_DEVELOPMENT_BASELINE=PASS"
