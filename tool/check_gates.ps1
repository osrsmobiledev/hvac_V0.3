# File: tool/check_gates.ps1
# Purpose: Single automated script to run Tier 1 automated quality checks.

param(
    [string]$TestPath = "",
    [switch]$FastOnly
)

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

$fastFailed = $false
$failedGates = @()

# Gate 1A: Code Formatting
Write-Host "`n[Gate 1A] Checking Dart Code Formatting..." -ForegroundColor Yellow
& $DartBin format --output=none --set-exit-if-changed lib test
if ($LASTEXITCODE -ne 0) {
    Write-Host "[FAIL] Code formatting issues found. Run 'dart format lib test' to resolve." -ForegroundColor Red
    $fastFailed = $true
    $failedGates += "Gate 1A (Code Formatting)"
} else {
    Write-Host "[PASS] Formatting is clean." -ForegroundColor Green
}

# Gate 1B: Static Analysis (Compiler Linter)
Write-Host "`n[Gate 1B] Running Static Analysis (flutter analyze)..." -ForegroundColor Yellow
& $FlutterBin analyze --no-pub
if ($LASTEXITCODE -ne 0) {
    Write-Host "[FAIL] Static analysis reported errors or warnings." -ForegroundColor Red
    $fastFailed = $true
    $failedGates += "Gate 1B (Static Analysis)"
} else {
    Write-Host "[PASS] Zero static analysis issues." -ForegroundColor Green
}

# Gate 1C: Source File Modularity (Max 250 lines)
Write-Host "`n[Gate 1C] Checking File Length Limits (max 250 lines)..." -ForegroundColor Yellow
$lengthViolations = @()
Get-ChildItem -Path lib,test -Filter *.dart -Recurse | ForEach-Object {
    $lines = (Get-Content $_.FullName | Measure-Object -Line).Lines
    if ($lines -gt 250) {
        $lengthViolations += "$($_.FullName): $lines lines"
    }
}
if ($lengthViolations.Count -gt 0) {
    Write-Host "[FAIL] The following files exceed the 250-line limit:" -ForegroundColor Red
    $lengthViolations | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    $fastFailed = $true
    $failedGates += "Gate 1C (File Length Limits)"
} else {
    Write-Host "[PASS] All source files are <= 250 lines." -ForegroundColor Green
}

# Gate 1D: Mechanical Anti-Pattern & Whitespace Scan
Write-Host "`n[Gate 1D] Checking Mechanical Anti-Patterns & Whitespace..." -ForegroundColor Yellow
$gate1dFailed = $false

# 1. Git diff whitespace check
$prevEAP = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
$wsErrors = (& git diff --check 2>&1) | Where-Object { $_ -notmatch 'warning: in the working copy of' -and $_.Trim() -ne '' }
$gitExit = $LASTEXITCODE
$ErrorActionPreference = $prevEAP
if ($gitExit -ne 0 -and $wsErrors) {
    Write-Host "[FAIL] Whitespace errors detected by 'git diff --check':" -ForegroundColor Red
    $wsErrors | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    $gate1dFailed = $true
} else {
    Write-Host "[PASS] Git whitespace check is clean." -ForegroundColor Green
}

# 2. Anti-pattern scan on lib/
# Get modified and untracked .dart files under lib/ for ratcheted checks
$prevEAP = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
$gitStatusLines = (& git status --porcelain lib/ 2>&1) | Where-Object { $_ -notmatch 'warning: in the working copy of' -and $_.Trim() -ne '' }
$ErrorActionPreference = $prevEAP

$modifiedLibFiles = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
foreach ($statusLine in $gitStatusLines) {
    if ($statusLine -match '^(?:[ MADRCU?]{2})\s+(?:.*->\s+)?(.*\.dart)$') {
        $p = $matches[1].Trim().Replace('/', '\')
        [void]$modifiedLibFiles.Add($p)
    }
}

$antiPatternViolations = @()
Get-ChildItem -Path lib -Filter *.dart -Recurse | ForEach-Object {
    $filePath = $_.FullName
    $relPath = $filePath.Replace((Get-Location).Path + "\", "")
    $relPathNorm = $relPath.Replace('/', '\')
    $isModified = $modifiedLibFiles.Contains($relPathNorm)
    $fileLines = Get-Content $filePath
    for ($i = 0; $i -lt $fileLines.Length; $i++) {
        $lineNum = $i + 1
        $line = $fileLines[$i].Trim()
        if ($line.StartsWith("//")) { continue }

        # Explicit inline escape hatch for verified intentional exceptions: // gate-1d-ok: <reason>
        if ($line -match '//\s*gate-1d-ok:\s*\S+') { continue }

        # Private Flutter widget helper methods (ratcheted: checked on modified/untracked files only)
        if ($isModified -and $line -match '(?<!pw\.)\bWidget\s+_[a-zA-Z0-9_]+\s*\(') {
            $antiPatternViolations += "[Widget Helper] ${relPath}:${lineNum} : $line"
        }

        # Raw .showSnackBar calls outside tactical_feedback.dart (scans all lib/)
        if ($line -match '\.showSnackBar\(' -and $relPath -notmatch 'tactical_feedback\.dart') {
            $antiPatternViolations += "[Raw SnackBar] ${relPath}:${lineNum} : $line"
        }

        # pw.Spacer usage inside PDF builders (scans all lib/)
        if ($line -match 'pw\.Spacer\(') {
            $antiPatternViolations += "[pw.Spacer] ${relPath}:${lineNum} : $line"
        }

        # Empty catch blocks (scans all lib/)
        if ($line -match 'catch\s*(\([^)]*\))?\s*\{\s*\}') {
            $antiPatternViolations += "[Empty Catch] ${relPath}:${lineNum} : $line"
        }
    }
}

if ($antiPatternViolations.Count -gt 0) {
    Write-Host "[FAIL] Anti-pattern violations found in lib/:" -ForegroundColor Red
    $antiPatternViolations | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    $gate1dFailed = $true
} else {
    Write-Host "[PASS] Zero anti-pattern violations found in lib/." -ForegroundColor Green
}

if ($gate1dFailed) {
    $fastFailed = $true
    $failedGates += "Gate 1D (Anti-Patterns & Whitespace)"
}

# Batch fast check failure summary
if ($fastFailed) {
    Write-Host "`n========================================" -ForegroundColor Red
    Write-Host " [FAIL] FAST QUALITY GATES FAILED" -ForegroundColor Red
    Write-Host " Summary of failing gates:" -ForegroundColor Red
    $failedGates | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    Write-Host " Automated test suite skipped due to fast gate failures." -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Red
    exit 1
}

# Check if -FastOnly was requested
if ($FastOnly) {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host " [PASS] FAST CHECKS PASSED (Gates 1A–1D)" -ForegroundColor Green
    Write-Host " Notice: Test suite was skipped (-FastOnly)." -ForegroundColor Yellow
    Write-Host " Run without -FastOnly for full Tier 1 sign-off." -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    exit 0
}

# Automated Test Suite (Focused vs Full)
$testLog = Join-Path $env:TEMP "hvac-test-suite.log"
if ($TestPath -ne "") {
    Write-Host "`n[Automated Test Suite] Running Focused Tests: $TestPath..." -ForegroundColor Yellow
    Write-Host "  Capturing output to: $testLog (please wait)..." -ForegroundColor DarkGray
    & $FlutterBin test --no-pub $TestPath *> $testLog
    $testExit = $LASTEXITCODE
    if ($testExit -ne 0) {
        Write-Host "[FAIL] Focused test run failed (exit code $testExit)." -ForegroundColor Red
        Write-Host "Tail of test failure log ($testLog):" -ForegroundColor Red
        Get-Content $testLog -Tail 60
        exit $testExit
    }
    $passLine = Select-String -Path $testLog -Pattern 'All tests passed' | Select-Object -Last 1
    if ($passLine) {
        Write-Host "  $($passLine.Line.Trim())" -ForegroundColor Cyan
    }
    Write-Host "[PASS] Focused tests passed." -ForegroundColor Green
    Write-Host "  Full test log preserved at: $testLog" -ForegroundColor DarkGray
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host " [PASS] FOCUSED TESTS PASSED" -ForegroundColor Green
    Write-Host " Notice: This was a focused test run ($TestPath)." -ForegroundColor Yellow
    Write-Host " Run without arguments for full Tier 1 sign-off." -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    exit 0
} else {
    Write-Host "`n[Automated Test Suite] Running Full Automated Test Suite..." -ForegroundColor Yellow
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
    Write-Host " [PASS] AUTOMATED CHECKS PASSED (FULL TIER 1)" -ForegroundColor Green
    Write-Host " Complete Tier 2 manual review and" -ForegroundColor Cyan
    Write-Host " remaining Tier 3 focused feature and" -ForegroundColor Cyan
    Write-Host " owner device testing." -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    exit 0
}
