#Requires -Version 5.1
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$PythonScript,

    [Parameter(Mandatory = $true, Position = 1)]
    [string]$OutputDir
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $PythonScript -PathType Leaf)) {
    Write-Error "Python script not found: $PythonScript"
    exit 1
}

$PythonScript = (Resolve-Path -LiteralPath $PythonScript).Path
$WorkDir = Split-Path -Parent $PythonScript
$BaseName = [System.IO.Path]::GetFileNameWithoutExtension($PythonScript)
$ScriptName = Split-Path -Leaf $PythonScript

New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
$OutputDir = (Resolve-Path -LiteralPath $OutputDir).Path

Push-Location $WorkDir
try {
    python $ScriptName
    if ($LASTEXITCODE -ne 0) {
        throw "python failed with exit code $LASTEXITCODE"
    }

    pdflatex -interaction=nonstopmode "$BaseName.tex" *> $null
    if ($LASTEXITCODE -ne 0) {
        throw "pdflatex failed with exit code $LASTEXITCODE"
    }

    Remove-Item -Force -ErrorAction SilentlyContinue *.aux, *.log, *.vscodeLog

    Copy-Item -Force "$BaseName.tex", "$BaseName.pdf" -Destination $OutputDir
}
finally {
    Pop-Location
}

Write-Host "Success! Output saved to $OutputDir/$BaseName.pdf"
