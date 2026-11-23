# File: tool/check_gates.ps1
# Purpose: Single automated script to run Tier 1 automated quality checks.

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
Write-Host " Running Automated Quality Checks       " -ForegroundColor Cyan
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

# Full Automated Test Suite
Write-Host "`n[Automated Test Suite] Running Full Automated Test Suite..." -ForegroundColor Yellow
$testLog = Join-Path $env:TEMP "hvac-test-suite.log"
Write-Host "  Capturing output to: $testLog (please wait)..." -ForegroundColor DarkGray
& $FlutterBin test --no-pub *> $testLog
$testExit = $LASTEXITCODE
if ($testExit -ne 0) {
    Write-Host "[FAIL] One or more automated tests failed (exit code $testExit)." -ForegroundColor Red
    Write-Host "Tail of test failure log ($testLog):" -ForegroundColor Red
    Get-Content $testLog -Tail 60
    exit $testExit
}
$passLine = Select-String -Path $testLog -Pattern 'All tests passed' | Select-Object -Last 1
if ($passLine) {
    Write-Host "  $($passLine.Line.Trim())" -ForegroundColor Cyan
}
Write-Host "[PASS] All automated tests passed." -ForegroundColor Green
Write-Host "  Full test log preserved at: $testLog" -ForegroundColor DarkGray

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host " [PASS] AUTOMATED CHECKS PASSED" -ForegroundColor Green
Write-Host " Complete Tier 2 manual review and" -ForegroundColor Cyan
Write-Host " remaining Tier 3 focused feature and" -ForegroundColor Cyan
Write-Host " owner device testing." -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
exit 0
