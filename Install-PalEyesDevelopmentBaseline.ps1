param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectRoot = "C:\Users\DELL\StudioProjects\Pal_Eyes",

    [Parameter(Mandatory=$false)]
    [switch]$WhatIf,

    [Parameter(Mandatory=$false)]
    [switch]$AllowReplaceExisting,

    [Parameter(Mandatory=$false)]
    [switch]$RunFlutterChecks
)

$ErrorActionPreference = "Stop"

$BaselineName = "PAL_EYES_GOVERNED_CONTENT_ADOPTION_TO_PROJECT_PAGES_R5_1_0_20260715"
$PackageRoot = $PSScriptRoot
$ManifestPath = Join-Path $PackageRoot "BASELINE_MANIFEST.json"
$MarkerPath = Join-Path $PackageRoot "PAL_EYES_BASELINE_ID.txt"

function Get-NormalizedFullPath {
    param([Parameter(Mandatory=$true)][string]$Path)
    return [System.IO.Path]::GetFullPath($Path).TrimEnd('\')
}

function Assert-PackageIntegrity {
    if (-not (Test-Path $ManifestPath -PathType Leaf)) {
        throw "BASELINE_MANIFEST_MISSING=$ManifestPath"
    }

    if (-not (Test-Path $MarkerPath -PathType Leaf)) {
        throw "BASELINE_MARKER_MISSING=$MarkerPath"
    }

    $Manifest = Get-Content $ManifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    if ($Manifest.baseline_name -ne $BaselineName) {
        throw "BASELINE_NAME_MISMATCH expected=$BaselineName actual=$($Manifest.baseline_name)"
    }

    $Validated = 0
    foreach ($Item in $Manifest.files) {
        $RelativePath = [string]$Item.path
        $WindowsRelativePath = $RelativePath.Replace('/', '\')
        $FullPath = Join-Path $PackageRoot $WindowsRelativePath

        if (-not (Test-Path $FullPath -PathType Leaf)) {
            throw "PACKAGE_FILE_MISSING=$RelativePath"
        }

        $ActualSize = (Get-Item $FullPath).Length
        if ($ActualSize -ne [int64]$Item.size_bytes) {
            throw "PACKAGE_FILE_SIZE_MISMATCH=$RelativePath"
        }

        $ActualHash = (Get-FileHash -Path $FullPath -Algorithm SHA256).Hash.ToLowerInvariant()
        if ($ActualHash -ne ([string]$Item.sha256).ToLowerInvariant()) {
            throw "PACKAGE_FILE_HASH_MISMATCH=$RelativePath"
        }

        $Validated++
    }

    Write-Host "PACKAGE_INTEGRITY=PASS"
    Write-Host "PACKAGE_FILES_VALIDATED=$Validated"
}

Assert-PackageIntegrity

$PackageFullPath = Get-NormalizedFullPath $PackageRoot
$TargetFullPath = Get-NormalizedFullPath $ProjectRoot

Write-Host "BASELINE_NAME=$BaselineName"
Write-Host "PACKAGE_ROOT=$PackageFullPath"
Write-Host "PROJECT_ROOT=$TargetFullPath"
Write-Host "INSTALL_MODE=FRESH_BASELINE"

if ($PackageFullPath -eq $TargetFullPath) {
    Write-Host "TARGET_IS_PACKAGE_ROOT=TRUE"
    if ($RunFlutterChecks) {
        $Checks = Join-Path $PackageRoot "tools\Invoke-PalEyesRuntimeChecks.ps1"
        & $Checks -ProjectRoot $PackageRoot -BuildWeb
    }
    Write-Host "BASELINE_INSTALL=ALREADY_IN_PLACE"
    exit 0
}

$TargetExists = Test-Path $TargetFullPath
$ExistingItems = @()

if ($TargetExists) {
    $ExistingItems = @(Get-ChildItem -Path $TargetFullPath -Force -ErrorAction SilentlyContinue)
}

$TargetMarker = Join-Path $TargetFullPath "PAL_EYES_BASELINE_ID.txt"
$TargetAlreadyCurrent = $false

if (Test-Path $TargetMarker -PathType Leaf) {
    $TargetMarkerContent = Get-Content $TargetMarker -Raw -Encoding UTF8
    $TargetAlreadyCurrent = $TargetMarkerContent -match [regex]::Escape("BASELINE_NAME=$BaselineName")
}

if ($ExistingItems.Count -gt 0 -and -not $TargetAlreadyCurrent -and -not $AllowReplaceExisting) {
    throw "TARGET_NOT_EMPTY_AND_REPLACE_NOT_AUTHORIZED. Re-run with -AllowReplaceExisting after reviewing the target."
}

if ($WhatIf) {
    Write-Host "WHATIF=TRUE"
    Write-Host "TARGET_EXISTS=$TargetExists"
    Write-Host "TARGET_ITEM_COUNT=$($ExistingItems.Count)"
    Write-Host "TARGET_ALREADY_CURRENT=$TargetAlreadyCurrent"
    Write-Host "ALLOW_REPLACE_EXISTING=$AllowReplaceExisting"
    Write-Host "NO_FILES_CHANGED=TRUE"
    Write-Host "READY_TO_INSTALL=TRUE"
    exit 0
}

if (-not $TargetExists) {
    New-Item -ItemType Directory -Path $TargetFullPath -Force | Out-Null
}

if ($ExistingItems.Count -gt 0 -and -not $TargetAlreadyCurrent) {
    $Timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $ParentDirectory = Split-Path -Parent $TargetFullPath
    $TargetName = Split-Path -Leaf $TargetFullPath
    $BackupPath = Join-Path $ParentDirectory "${TargetName}_backup_before_PAL_EYES_GOVERNED_CONTENT_ADOPTION_TO_PROJECT_PAGES_R5_1_0_20260715_$Timestamp"

    New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
    Get-ChildItem -Path $TargetFullPath -Force |
        Copy-Item -Destination $BackupPath -Recurse -Force

    Write-Host "TARGET_BACKUP=CREATED"
    Write-Host "TARGET_BACKUP_PATH=$BackupPath"
}

Get-ChildItem -Path $PackageRoot -Force |
    Copy-Item -Destination $TargetFullPath -Recurse -Force

$Required = @(
    "PAL_EYES_BASELINE_ID.txt",
    "BASELINE_MANIFEST.json",
    "PAL_EYES_PROJECT_COMPREHENSIVE_GUIDE.md",
    "pubspec.yaml",
    "analysis_options.yaml",
    "lib\main.dart",
    "lib\app\app.dart",
    "lib\app\router\app_router.dart",
    "tools\Verify-PalEyesDevelopmentBaseline.ps1",
    "tools\Invoke-PalEyesRuntimeChecks.ps1"
)

foreach ($RelativePath in $Required) {
    $FullPath = Join-Path $TargetFullPath $RelativePath
    if (-not (Test-Path $FullPath -PathType Leaf)) {
        throw "POST_INSTALL_REQUIRED_FILE_MISSING=$RelativePath"
    }
}

$VerifyScript = Join-Path $TargetFullPath "tools\Verify-PalEyesDevelopmentBaseline.ps1"
& $VerifyScript -ProjectRoot $TargetFullPath

if ($RunFlutterChecks) {
    $Checks = Join-Path $TargetFullPath "tools\Invoke-PalEyesRuntimeChecks.ps1"
    & $Checks -ProjectRoot $TargetFullPath -BuildWeb
}

Write-Host "BASELINE_INSTALL=PASS"
Write-Host "INSTALLED_BASELINE=$BaselineName"
Write-Host "PROJECT_ROOT=$TargetFullPath"
