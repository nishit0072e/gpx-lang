# GPX Automated Local Build & GitHub Release Script
param (
    [Parameter(Mandatory=$true)]
    [string]$Version,       # e.g. "v0.2.0"

    [Parameter(Mandatory=$false)]
    [string]$Notes = "GPX Compiler Release"
)

$ErrorActionPreference = "Stop"

# Always navigate to the project root directory regardless of where the script was invoked from
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
Set-Location $ProjectRoot

# Ensure version starts with 'v' (e.g. 0.2.0 -> v0.2.0)
if (-not $Version.StartsWith("v")) {
    $Version = "v$Version"
}

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  GPX Compiler: Packaging & Release $Version" -ForegroundColor Cyan
Write-Host "  Working Directory: $ProjectRoot" -ForegroundColor DarkGray
Write-Host "=========================================" -ForegroundColor Cyan

# 1. Run local test suite
Write-Host "`n[1/4] Running automated test suite..." -ForegroundColor Yellow
python -m unittest discover tests
if ($LASTEXITCODE -ne 0) {
    Write-Host "Tests failed! Aborting release." -ForegroundColor Red
    exit 1
}
Write-Host "All tests passed successfully!" -ForegroundColor Green

# 2. Build standalone binary (.exe)
Write-Host "`n[2/4] Building standalone gpx.exe binary..." -ForegroundColor Yellow
pyinstaller --onefile --name gpx --distpath dist/bin compiler/main.py --noconfirm
if ($LASTEXITCODE -ne 0) {
    Write-Host "Binary build failed! Aborting release." -ForegroundColor Red
    exit 1
}

# 3. Build cross-platform wheel package
Write-Host "`n[3/4] Building universal Python package wheel..." -ForegroundColor Yellow
pip wheel . -w dist --no-deps
if ($LASTEXITCODE -ne 0) {
    Write-Host "Wheel build failed! Aborting release." -ForegroundColor Red
    exit 1
}

# Find latest wheel in dist/
$wheelFile = Get-ChildItem -Path dist -Filter "*.whl" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

# 4. Publish to GitHub Releases
Write-Host "`n[4/4] Publishing release $Version to GitHub..." -ForegroundColor Yellow
gh release create $Version dist/bin/gpx.exe $wheelFile.FullName --title "GPX Compiler $Version" --notes "$Notes"

Write-Host "`n=========================================" -ForegroundColor Green
Write-Host " Release $Version is successfully live on GitHub!" -ForegroundColor Green
Write-Host " https://github.com/nishit0072e/gpx-lang/releases/tag/$Version" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
