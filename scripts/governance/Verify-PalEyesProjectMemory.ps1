param(
  [string]$ProjectRoot = (Get-Location).Path
)

$ErrorActionPreference = "Stop"
$manifestPath = Join-Path $ProjectRoot "data\governance\PAL_EYES_PROJECT_MEMORY_FILE_MANIFEST_CURRENT.json"

if (-not (Test-Path -LiteralPath $manifestPath)) {
  throw "Manifest not found: $manifestPath"
}

$manifest = Get-Content -LiteralPath $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
$failures = @()

foreach ($item in $manifest.files) {
  $path = Join-Path $ProjectRoot $item.relative_path
  if (-not (Test-Path -LiteralPath $path)) {
    $failures += "MISSING: $($item.relative_path)"
    continue
  }
  $actual = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
  if ($actual -ne $item.sha256.ToLowerInvariant()) {
    $failures += "HASH_MISMATCH: $($item.relative_path)"
  }
}

if ($failures.Count -gt 0) {
  $failures | ForEach-Object { Write-Host $_ -ForegroundColor Red }
  Write-Host "PAL_EYES_PROJECT_MEMORY_VERIFY=FAIL" -ForegroundColor Red
  exit 1
}

Write-Host "PAL_EYES_PROJECT_MEMORY_VERIFY=PASS" -ForegroundColor Green
Write-Host "VERIFIED_FILE_COUNT=$($manifest.files.Count)"
