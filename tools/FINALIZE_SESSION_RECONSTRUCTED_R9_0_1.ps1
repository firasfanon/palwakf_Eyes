$ErrorActionPreference = "Stop"
Set-StrictMode -Version 2.0

$ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
$Stamp = Get-Date -Format "yyyyMMdd_HHmmss"
$EvidenceRoot = Join-Path `
    $ProjectRoot `
    "evidence\local_r9_0_1_session_reconstruction_finalization_$Stamp"

New-Item -ItemType Directory -Path $EvidenceRoot -Force |
    Out-Null
Set-Location $ProjectRoot

$Targets = @(
    "lib/app/theme/app_theme.dart"
    "lib/core/widgets/public_experience_maturity.dart"
    "lib/core/widgets/direct_flutter_maturity_r9.dart"
    "lib/features/discovery/presentation/discovery_screen.dart"
    "lib/features/home/presentation/home_screen.dart"
    "lib/features/map/presentation/map_screen.dart"
    "lib/features/places/presentation/place_detail_screen.dart"
    "lib/features/places/presentation/places_screen.dart"
    "lib/features/stories/presentation/stories_screen.dart"
    "lib/features/stories/presentation/story_detail_screen.dart"
    "test/pal_eyes_media_stage_bounded_layout_test.dart"
    "test/direct_flutter_maturity_r9_contract_test.dart"
    "test/direct_flutter_maturity_r9_widget_test.dart"
)

foreach ($Command in @("flutter", "dart", "git")) {
    if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) {
        throw "REQUIRED_COMMAND_NOT_FOUND=$Command"
    }
}

Remove-Item Env:PYTHONHOME -ErrorAction SilentlyContinue
Remove-Item Env:PYTHONPATH -ErrorAction SilentlyContinue

$Python = $null
$PythonPrefix = @()
$PythonCandidates = @()

foreach ($CommandName in @("python", "python3")) {
    $Command = Get-Command `
        $CommandName `
        -ErrorAction SilentlyContinue |
        Select-Object -First 1

    if ($null -ne $Command) {
        $CommandPath = $Command.Source

        if (
            $Command.PSObject.Properties.Name -contains "Path" -and
            -not [string]::IsNullOrWhiteSpace($Command.Path)
        ) {
            $CommandPath = $Command.Path
        }

        if (-not [string]::IsNullOrWhiteSpace($CommandPath)) {
            $PythonCandidates += [pscustomobject]@{
                Path = $CommandPath
                Prefix = @()
            }
        }
    }
}

$PyLauncher = Get-Command `
    "py" `
    -ErrorAction SilentlyContinue |
    Select-Object -First 1

if ($null -ne $PyLauncher) {
    $PythonCandidates += [pscustomobject]@{
        Path = $PyLauncher.Source
        Prefix = @("-3")
    }
}

foreach ($Candidate in $PythonCandidates) {
    $ProbeArguments = @()
    $ProbeArguments += $Candidate.Prefix
    $ProbeArguments += "-c"
    $ProbeArguments += "import sys; print(sys.executable)"

    $PreviousErrorPreference = $ErrorActionPreference
    $ErrorActionPreference = "Continue"

    try {
        $ProbeOutput = @(
            & $Candidate.Path @ProbeArguments 2>&1
        )

        $ProbeExitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $PreviousErrorPreference
    }

    if ($ProbeExitCode -ne 0) {
        continue
    }

    $ResolvedExecutable = (
        $ProbeOutput |
        ForEach-Object {
            ([string]$_).Trim()
        } |
        Where-Object {
            -not [string]::IsNullOrWhiteSpace($_)
        } |
        Select-Object -Last 1
    )

    if (
        -not [string]::IsNullOrWhiteSpace($ResolvedExecutable) -and
        (Test-Path -LiteralPath $ResolvedExecutable -PathType Leaf)
    ) {
        $Python = (
            Resolve-Path -LiteralPath $ResolvedExecutable
        ).Path

        $PythonPrefix = @()
        break
    }
}

if ($null -eq $Python) {
    throw "NO_WORKING_PYTHON_RUNTIME_FOUND"
}

Write-Host "PYTHON_RUNTIME=$Python"
Write-Host "PYTHON_RUNTIME_SELECTION=PORTABLE_PROBED_EXECUTABLE"
Write-Host "=== RECONSTRUCTION PREFLIGHT ===" `
    -ForegroundColor Cyan

& $Python @PythonPrefix `
    ".\tools\verify_session_reconstructed_r9_0_1.py" `
    2>&1 |
    Tee-Object -FilePath (
        Join-Path $EvidenceRoot "01_PREFLIGHT_VERIFY.log"
    )

if ($LASTEXITCODE -ne 0) {
    throw "PREFLIGHT_VERIFY_FAILED=$LASTEXITCODE"
}

Write-Host "=== FLUTTER PUB GET ===" -ForegroundColor Cyan

& flutter pub get 2>&1 |
    Tee-Object -FilePath (
        Join-Path $EvidenceRoot "02_FLUTTER_PUB_GET.log"
    )

if ($LASTEXITCODE -ne 0) {
    throw "FLUTTER_PUB_GET_FAILED=$LASTEXITCODE"
}

Write-Host "=== TARGETED DART FORMAT REPLAY ===" `
    -ForegroundColor Cyan

& dart format @Targets 2>&1 |
    Tee-Object -FilePath (
        Join-Path $EvidenceRoot "03_TARGETED_DART_FORMAT.log"
    )

if ($LASTEXITCODE -ne 0) {
    throw "DART_FORMAT_FAILED=$LASTEXITCODE"
}

& dart format `
    --output=none `
    --set-exit-if-changed `
    @Targets `
    2>&1 |
    Tee-Object -FilePath (
        Join-Path $EvidenceRoot "04_TARGETED_DART_FORMAT_CHECK.log"
    )

if ($LASTEXITCODE -ne 0) {
    throw "DART_FORMAT_CHECK_FAILED=$LASTEXITCODE"
}

Write-Host "=== FLUTTER ANALYZE ===" -ForegroundColor Cyan

& flutter analyze --no-pub 2>&1 |
    Tee-Object -FilePath (
        Join-Path $EvidenceRoot "05_FLUTTER_ANALYZE.log"
    )

if ($LASTEXITCODE -ne 0) {
    throw "FLUTTER_ANALYZE_FAILED=$LASTEXITCODE"
}

Write-Host "=== FLUTTER TEST ===" -ForegroundColor Cyan

& flutter test --no-pub --reporter expanded 2>&1 |
    Tee-Object -FilePath (
        Join-Path $EvidenceRoot "06_FLUTTER_TEST.log"
    )

if ($LASTEXITCODE -ne 0) {
    throw "FLUTTER_TEST_FAILED=$LASTEXITCODE"
}

Write-Host "=== GIT DIFF CHECK ===" -ForegroundColor Cyan

& git -c core.safecrlf=false diff --check 2>&1 |
    Tee-Object -FilePath (
        Join-Path $EvidenceRoot "07_GIT_DIFF_CHECK.log"
    )

if ($LASTEXITCODE -ne 0) {
    throw "GIT_DIFF_CHECK_FAILED=$LASTEXITCODE"
}

Write-Host "=== FINALIZE METADATA ===" -ForegroundColor Cyan

& $Python @PythonPrefix `
    ".\tools\finalize_session_reconstructed_r9_0_1.py" `
    --project-root $ProjectRoot `
    2>&1 |
    Tee-Object -FilePath (
        Join-Path $EvidenceRoot "08_FINALIZE_METADATA.log"
    )

if ($LASTEXITCODE -ne 0) {
    throw "METADATA_FINALIZATION_FAILED=$LASTEXITCODE"
}

& $Python @PythonPrefix `
    ".\tools\verify_session_reconstructed_r9_0_1.py" `
    --require-finalized `
    2>&1 |
    Tee-Object -FilePath (
        Join-Path $EvidenceRoot "09_FINAL_VERIFY.log"
    )

if ($LASTEXITCODE -ne 0) {
    throw "FINAL_VERIFY_FAILED=$LASTEXITCODE"
}

& git -c core.safecrlf=false diff --check 2>&1 |
    Tee-Object -FilePath (
        Join-Path $EvidenceRoot "10_FINAL_GIT_DIFF_CHECK.log"
    )

if ($LASTEXITCODE -ne 0) {
    throw "FINAL_GIT_DIFF_CHECK_FAILED=$LASTEXITCODE"
}

& git status --short 2>&1 |
    Tee-Object -FilePath (
        Join-Path $EvidenceRoot "11_GIT_STATUS.log"
    )

Write-Host ""
Write-Host `
    "PAL_EYES_R9_0_1_SESSION_RECONSTRUCTION_FINALIZATION=PASS" `
    -ForegroundColor Green
Write-Host "BASELINE=PAL_EYES_DIRECT_FLUTTER_PUBLIC_EXPERIENCE_MATURITY_R9_0_1_20260802"
Write-Host "VERSION=9.0.1+30"
Write-Host "STATUS=ACCEPTED_LOCAL_BASELINE_AFTER_FORMAT_REPLAY"
Write-Host "NEXT_GATE=COMMIT_PUSH_PR_AND_GITHUB_CI"
Write-Host "EVIDENCE_ROOT=$EvidenceRoot"
