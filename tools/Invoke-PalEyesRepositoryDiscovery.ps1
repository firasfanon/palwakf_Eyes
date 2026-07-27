param(
    [Parameter(Mandatory=$false)]
    [string]$ProjectRoot = ".",

    [Parameter(Mandatory=$false)]
    [string]$OutputPath = ""
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PythonScript = Join-Path $ScriptDir "pal_eyes_repository_discovery.py"

if (-not (Test-Path $PythonScript)) {
    throw "Discovery script not found: $PythonScript"
}

$Python = Get-Command python -ErrorAction SilentlyContinue
if (-not $Python) {
    $Python = Get-Command py -ErrorAction SilentlyContinue
}
if (-not $Python) {
    throw "Python was not found in PATH."
}

if ([string]::IsNullOrWhiteSpace($OutputPath)) {
    & $Python.Source $PythonScript $ProjectRoot
} else {
    & $Python.Source $PythonScript $ProjectRoot --output $OutputPath
}

if ($LASTEXITCODE -ne 0) {
    throw "Repository discovery failed with exit code $LASTEXITCODE"
}
