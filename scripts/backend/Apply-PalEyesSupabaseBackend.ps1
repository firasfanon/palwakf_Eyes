param(
  [Parameter(Mandatory = $true)]
  [string]$DatabaseUrl,

  [string]$ProjectRoot = "C:\Users\DELL\StudioProjects\Pal_Eyes",

  [string]$EnvironmentName = "staging",

  [switch]$ConfirmApply
)

$ErrorActionPreference = "Stop"

if (-not $ConfirmApply) {
  throw "CONFIRM_APPLY_REQUIRED"
}

if ($EnvironmentName -ieq "production") {
  throw "PRODUCTION_APPLY_NOT_APPROVED"
}

if (-not (Get-Command psql -ErrorAction SilentlyContinue)) {
  throw "PSQL_NOT_FOUND"
}

$Migration = Join-Path $ProjectRoot "supabase\migrations\202607190001_pal_eyes_operational_backend.sql"
$Seed = Join-Path $ProjectRoot "supabase\seed\202607190001_pal_eyes_r7_0_0_seed.sql"

if (-not (Test-Path -LiteralPath $Migration -PathType Leaf)) {
  throw "MIGRATION_NOT_FOUND=$Migration"
}
if (-not (Test-Path -LiteralPath $Seed -PathType Leaf)) {
  throw "SEED_NOT_FOUND=$Seed"
}

& psql $DatabaseUrl -v ON_ERROR_STOP=1 -f $Migration
if ($LASTEXITCODE -ne 0) { throw "MIGRATION_APPLY_FAILED" }

& psql $DatabaseUrl -v ON_ERROR_STOP=1 -f $Seed
if ($LASTEXITCODE -ne 0) { throw "SEED_APPLY_FAILED" }

Write-Host "PAL_EYES_SUPABASE_BACKEND_APPLY=PASS" -ForegroundColor Green
Write-Host "ENVIRONMENT=$EnvironmentName"
Write-Host "PUBLICATION=BLOCKED"
Write-Host "PRODUCTION=NOT_APPROVED"
