param(
  [Parameter(Mandatory=$true)][string]$BatchId,
  [Parameter(Mandatory=$true)][string]$Summary,
  [Parameter(Mandatory=$true)][string]$NextPriority,
  [string]$ProjectRoot = (Get-Location).Path,
  [string]$Status = "PASS",
  [int]$SitesAffected = 0,
  [int]$SourcesAffected = 0,
  [int]$ClaimsAffected = 0,
  [int]$AssetsAffected = 0
)

$ErrorActionPreference = "Stop"
$timestamp = Get-Date -Format "yyyy-MM-ddTHH:mm:ssK"
$logPath = Join-Path $ProjectRoot "data\governance\PAL_EYES_PROJECT_UPDATE_LOG.jsonl"
$changePath = Join-Path $ProjectRoot "docs\planning\PAL_EYES_CHANGELOG_CURRENT.md"

$entry = [ordered]@{
  timestamp = $timestamp
  batch_id = $BatchId
  status = $Status
  summary = $Summary
  sites_affected = $SitesAffected
  sources_affected = $SourcesAffected
  claims_affected = $ClaimsAffected
  assets_affected = $AssetsAffected
  next_priority = $NextPriority
}

$json = $entry | ConvertTo-Json -Compress
Add-Content -LiteralPath $logPath -Value $json -Encoding UTF8

$md = @"

## $timestamp - $BatchId

- Status: ``$Status``
- Summary: $Summary
- Sites affected: $SitesAffected
- Sources affected: $SourcesAffected
- Claims affected: $ClaimsAffected
- Assets affected: $AssetsAffected
- Next priority: ``$NextPriority``
"@

Add-Content -LiteralPath $changePath -Value $md -Encoding UTF8
Write-Host "PAL_EYES_PROJECT_UPDATE_REGISTERED=PASS" -ForegroundColor Green
