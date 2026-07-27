param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectRoot = ".",

    [Parameter(Mandatory=$false)]
    [string]$SupabaseUrl = "",

    [Parameter(Mandatory=$false)]
    [string]$SupabasePublishableKey = ""
)

$ErrorActionPreference = "Stop"
Set-Location (Resolve-Path $ProjectRoot).Path

$Flutter = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $Flutter) {
    throw "Flutter was not found in PATH."
}

$Arguments = @("run", "-d", "chrome", "--target", "lib/main.dart")

if (-not [string]::IsNullOrWhiteSpace($SupabaseUrl) -and
    -not [string]::IsNullOrWhiteSpace($SupabasePublishableKey)) {
    $Arguments += "--dart-define=SUPABASE_URL=$SupabaseUrl"
    $Arguments += "--dart-define=SUPABASE_PUBLISHABLE_KEY=$SupabasePublishableKey"
}

Write-Host "PAL_EYES_CHROME_MODE=LOCAL"
Write-Host "SUPABASE_ENABLED=$(-not [string]::IsNullOrWhiteSpace($SupabaseUrl))"

& flutter @Arguments
if ($LASTEXITCODE -ne 0) {
    throw "flutter run failed."
}
