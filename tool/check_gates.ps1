# File: tool/check_gates.ps1
# Purpose: Single automated script to verify all 3 Pre-Handoff Quality Gates in one command.

$ErrorActionPreference = "Stop"

# 1. Locate Flutter and Dart SDK
$FlutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
if ($null -ne $FlutterCmd) {
    $FlutterBin = "flutter"
    $DartBin = "dart"
} elseif (Test-Path "C:\Users\Admin\Documents\Flutter-SDK\flutter\bin\flutter.bat") {
    $FlutterBin = "C:\Users\Admin\Documents\Flutter-SDK\flutter\bin\flutter.bat"
    $DartBin = "C:\Users\Admin\Documents\Flutter-SDK\flutter\bin\dart.bat"
} else {
    Write-Error "Flutter SDK not found in PATH or standard directory."
    exit 1
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Running Automated 3-Gate Quality Check" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Gate 1A: Code Formatting
Write-Host "`n[Gate 1A] Checking Dart Code Formatting..." -ForegroundColor Yellow
& $DartBin format --output=none --set-exit-if-changed lib test
if ($LASTEXITCODE -ne 0) {
    Write-Host "[FAIL] Code formatting issues found. Run 'dart format lib test' to resolve." -ForegroundColor Red
    exit 1
}
Write-Host "[PASS] Formatting is clean." -ForegroundColor Green

# Gate 1B: Static Analysis (Compiler Linter)
Write-Host "`n[Gate 1B] Running Static Analysis (flutter analyze)..." -ForegroundColor Yellow
& $FlutterBin analyze --no-pub
if ($LASTEXITCODE -ne 0) {
    Write-Host "[FAIL] Static analysis reported errors or warnings." -ForegroundColor Red
    exit 1
}
Write-Host "[PASS] Zero static analysis issues." -ForegroundColor Green

# Gate 1C: Source File Modularity (Max 250 lines)
Write-Host "`n[Gate 1C] Checking File Length Limits (max 250 lines)..." -ForegroundColor Yellow
$violations = @()
Get-ChildItem -Path lib,test -Filter *.dart -Recurse | ForEach-Object {
    $lines = (Get-Content $_.FullName | Measure-Object -Line).Lines
    if ($lines -gt 250) {
        $violations += "$($_.FullName): $lines lines"
    }
}
if ($violations.Count -gt 0) {
    Write-Host "[FAIL] The following files exceed the 250-line limit:" -ForegroundColor Red
    $violations | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}
Write-Host "[PASS] All source files are <= 250 lines." -ForegroundColor Green

# Gate 2 & 3: Automated Test Suite & Boundaries
Write-Host "`n[Gate 2 & 3] Running Automated Test Suite..." -ForegroundColor Yellow
& $FlutterBin test --no-pub
if ($LASTEXITCODE -ne 0) {
    Write-Host "[FAIL] One or more automated tests failed." -ForegroundColor Red
    exit 1
}
Write-Host "[PASS] All automated tests passed." -ForegroundColor Green

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " [SUCCESS] ALL QUALITY GATES PASSED!    " -ForegroundColor Green
Write-Host " Ready for physical device handoff.     " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
exit 0
