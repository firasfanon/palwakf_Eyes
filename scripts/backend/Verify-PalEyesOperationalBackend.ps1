param(
  [string]$ProjectRoot = "C:\Users\DELL\StudioProjects\Pal_Eyes"
)

$ErrorActionPreference = "Stop"
Set-Location -LiteralPath $ProjectRoot

python tools\verify_operational_backend_and_workflow_activation.py
if ($LASTEXITCODE -ne 0) { throw "OPERATIONAL_STATIC_VERIFY_FAILED" }

python tools\verify_product_ux_phases_1_to_4.py
if ($LASTEXITCODE -ne 0) { throw "PRODUCT_UX_STATIC_VERIFY_FAILED" }

python tools\verify_original_historical_draft_dual_surface.py
if ($LASTEXITCODE -ne 0) { throw "ORIGINAL_DRAFT_STATIC_VERIFY_FAILED" }

Write-Host "PAL_EYES_OPERATIONAL_BACKEND_VERIFY=PASS" -ForegroundColor Green
