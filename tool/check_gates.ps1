# File: tool/check_gates.ps1
# Purpose: Universal Tier 1 automated quality-gate runner for Flutter projects.
# Optional project-specific Gate 1D rules are loaded from tool/gate_rules.json if present.

param(
    [string]$TestPath = "",
    [switch]$FastOnly,
    [int]$MaxLines = 250,
    [string]$LogName = ""
)

$ErrorActionPreference = "Stop"
$totalStopwatch = [System.Diagnostics.Stopwatch]::StartNew()
$timings = New-Object System.Collections.Generic.List[string]

function Get-RelativeUnixPath {
    param(
        [string]$RootPath,
        [string]$FullPath
    )
    $cleanRoot = $RootPath.TrimEnd('\', '/')
    if ($FullPath.StartsWith($cleanRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
        $rel = $FullPath.Substring($cleanRoot.Length).TrimStart('\', '/')
        return $rel.Replace('\', '/')
    }
    return $FullPath.Replace('\', '/')
}

function Resolve-FlutterToolchain {
    $flutterBin = $null
    $flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
    if ($null -ne $flutterCmd) {
        $flutterBin = $flutterCmd.Source
    } else {
        $candidates = @()
        if ($env:FLUTTER_ROOT) {
            $candidates += (Join-Path $env:FLUTTER_ROOT "bin\flutter.bat")
            $candidates += (Join-Path $env:FLUTTER_ROOT "bin\flutter")
        }
        if ($env:FLUTTER_HOME) {
            $candidates += (Join-Path $env:FLUTTER_HOME "bin\flutter.bat")
            $candidates += (Join-Path $env:FLUTTER_HOME "bin\flutter")
        }
        $candidates += @(
            (Join-Path $HOME "Documents\Flutter-SDK\flutter\bin\flutter.bat"),
            (Join-Path $HOME "flutter\bin\flutter.bat"),
            (Join-Path $HOME "fvm\default\bin\flutter.bat"),
            (Join-Path $HOME "flutter\bin\flutter"),
            (Join-Path $HOME "fvm\default\bin\flutter")
        )
        foreach ($candidate in $candidates) {
            if ($candidate -and (Test-Path $candidate -ErrorAction SilentlyContinue)) {
                $flutterBin = $candidate
                break
            }
        }
    }

    if (-not $flutterBin) {
        Write-Error "Flutter SDK not found in PATH, FLUTTER_ROOT/FLUTTER_HOME, or standard user directories."
        exit 1
    }

    $binDir = Split-Path -Parent $flutterBin
    $dartCandidateBat = Join-Path $binDir "dart.bat"
    $dartCandidateUnix = Join-Path $binDir "dart"
    if (Test-Path $dartCandidateBat) {
        $dartBin = $dartCandidateBat
    } elseif (Test-Path $dartCandidateUnix) {
        $dartBin = $dartCandidateUnix
    } else {
        $dartCmd = Get-Command dart -ErrorAction SilentlyContinue
        if ($null -ne $dartCmd) {
            $dartBin = $dartCmd.Source
        } else {
            Write-Error "Dart SDK binary not found alongside '$flutterBin' or in PATH."
            exit 1
        }
    }

    return @{
        Flutter = $flutterBin
        Dart    = $dartBin
    }
}

function Write-TimingSummary {
    $totalStopwatch.Stop()
    $totalSec = [math]::Round($totalStopwatch.Elapsed.TotalSeconds, 2)
    Write-Host ("`nTiming Summary: " + ($timings -join " | ") + " | Total: ${totalSec}s") -ForegroundColor DarkGray
}

function Invoke-TestRun {
    param(
        [string]$FlutterBin,
        [string]$LogFile,
        [string]$TargetPath
    )

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    if ($TargetPath -ne "") {
        Write-Host "`n[Automated Test Suite] Running Focused Tests: $TargetPath..." -ForegroundColor Yellow
        Write-Host "  Capturing output to: $LogFile (please wait)..." -ForegroundColor DarkGray
        & $FlutterBin test --no-pub $TargetPath *> $LogFile
    } else {
        Write-Host "`n[Automated Test Suite] Running Full Automated Test Suite..." -ForegroundColor Yellow
        Write-Host "  Capturing output to: $LogFile (please wait)..." -ForegroundColor DarkGray
        & $FlutterBin test --no-pub *> $LogFile
    }
    $testExit = $LASTEXITCODE
    $sw.Stop()
    $timings.Add("Tests: $([math]::Round($sw.Elapsed.TotalSeconds, 2))s")

    if ($testExit -ne 0) {
        Write-Host "[FAIL] Automated tests failed (exit code $testExit)." -ForegroundColor Red
        $failHighlights = Select-String -Path $LogFile -Pattern '\[E\]|\bFAILED\b|Some tests failed' -ErrorAction SilentlyContinue | Select-Object -First 15
        if ($failHighlights) {
            Write-Host "Key failure lines:" -ForegroundColor Red
            $failHighlights | ForEach-Object { Write-Host "  $($_.Line.Trim())" -ForegroundColor Red }
        }
        Write-Host "Tail of test failure log ($LogFile):" -ForegroundColor Red
        Get-Content $LogFile -Tail 60
        Write-TimingSummary
        exit $testExit
    }

    $passLine = Select-String -Path $LogFile -Pattern 'All tests passed' | Select-Object -Last 1
    if ($passLine) {
        Write-Host "  $($passLine.Line.Trim())" -ForegroundColor Cyan
    }
    Write-Host "[PASS] All automated tests passed." -ForegroundColor Green
    Write-Host "  Full test log preserved at: $LogFile" -ForegroundColor DarkGray
}

# 1. Locate Flutter and Dart SDK
$toolchain = Resolve-FlutterToolchain
$FlutterBin = $toolchain.Flutter
$DartBin = $toolchain.Dart
$repoRoot = (Get-Location).Path
$repoName = Split-Path -Leaf $repoRoot

Write-Host "========================================" -ForegroundColor Cyan
Write-Host " Running Automated Quality Checks       " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

$fastFailed = $false
$failedGates = @()

# Collect existing Dart source directories
$sourceDirs = @()
if (Test-Path "lib") { $sourceDirs += "lib" }
if (Test-Path "test") { $sourceDirs += "test" }

# Gate 1A: Code Formatting
$sw1a = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "`n[Gate 1A] Checking Dart Code Formatting..." -ForegroundColor Yellow
if ($sourceDirs.Count -eq 0) {
    Write-Host "[PASS] No lib/ or test/ directories found; skipping format check." -ForegroundColor Green
} else {
    & $DartBin format --output=none --set-exit-if-changed @sourceDirs
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[FAIL] Code formatting issues found. Run 'dart format $($sourceDirs -join ' ')' to resolve." -ForegroundColor Red
        $fastFailed = $true
        $failedGates += "Gate 1A (Code Formatting)"
    } else {
        Write-Host "[PASS] Formatting is clean." -ForegroundColor Green
    }
}
$sw1a.Stop()
$timings.Add("1A: $([math]::Round($sw1a.Elapsed.TotalSeconds, 2))s")

# Gate 1B: Static Analysis (Compiler Linter)
$sw1b = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "`n[Gate 1B] Running Static Analysis (flutter analyze)..." -ForegroundColor Yellow
& $FlutterBin analyze --no-pub
if ($LASTEXITCODE -ne 0) {
    Write-Host "[FAIL] Static analysis reported errors or warnings." -ForegroundColor Red
    $fastFailed = $true
    $failedGates += "Gate 1B (Static Analysis)"
} else {
    Write-Host "[PASS] Zero static analysis issues." -ForegroundColor Green
}
$sw1b.Stop()
$timings.Add("1B: $([math]::Round($sw1b.Elapsed.TotalSeconds, 2))s")

# Gate 1C: Source File Modularity (Max lines)
$sw1c = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "`n[Gate 1C] Checking File Length Limits (max $MaxLines lines)..." -ForegroundColor Yellow
$lengthViolations = @()
if ($sourceDirs.Count -gt 0) {
    Get-ChildItem -Path $sourceDirs -Filter *.dart -Recurse | ForEach-Object {
        $lines = (Get-Content $_.FullName | Measure-Object -Line).Lines
        if ($lines -gt $MaxLines) {
            $relPath = Get-RelativeUnixPath -RootPath $repoRoot -FullPath $_.FullName
            $lengthViolations += "${relPath}:1 ($lines lines > $MaxLines)"
        }
    }
}
if ($lengthViolations.Count -gt 0) {
    Write-Host "[FAIL] The following files exceed the $MaxLines-line limit:" -ForegroundColor Red
    $lengthViolations | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    $fastFailed = $true
    $failedGates += "Gate 1C (File Length Limits)"
} else {
    Write-Host "[PASS] All source files are <= $MaxLines lines." -ForegroundColor Green
}
$sw1c.Stop()
$timings.Add("1C: $([math]::Round($sw1c.Elapsed.TotalSeconds, 2))s")

# Gate 1D: Mechanical Anti-Pattern, Test-Integrity & Whitespace Scan
$sw1d = [System.Diagnostics.Stopwatch]::StartNew()
Write-Host "`n[Gate 1D] Checking Anti-Patterns, Test Integrity & Whitespace..." -ForegroundColor Yellow
$gate1dFailed = $false

# 1. Git diff whitespace check
$prevEAP = $ErrorActionPreference
$ErrorActionPreference = 'Continue'
$wsErrors = (& git diff --check 2>&1) | Where-Object { $_ -notmatch 'warning: in the working copy of' -and $_.ToString().Trim() -ne '' }
$gitExit = $LASTEXITCODE
$ErrorActionPreference = $prevEAP
if ($gitExit -ne 0 -and $wsErrors) {
    Write-Host "[FAIL] Whitespace errors detected by 'git diff --check':" -ForegroundColor Red
    $wsErrors | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    $gate1dFailed = $true
} else {
    Write-Host "[PASS] Git whitespace check is clean." -ForegroundColor Green
}

# 2. Universal + optional project rules (tool/gate_rules.json)
$libRules = @(
    @{ name = "Widget Helper"; pattern = "(?<!pw\.)\bWidget\s+_[a-zA-Z0-9_]+\s*\("; excludePathPattern = "" },
    @{ name = "Empty Catch"; pattern = "catch\s*(\([^)]*\))?\s*\{\s*\}"; excludePathPattern = "" },
    @{ name = "No-Op Tap Handler"; pattern = "(onTap|onPressed)\s*:\s*\(\s*\)\s*\{\s*\}"; excludePathPattern = "" },
    @{ name = "Ternary Border Width"; pattern = "Border\.all\([^)]*width\s*:\s*[^,\)]+\?[^,\)]+:"; excludePathPattern = "" }
)
$testRules = @(
    @{ name = "Skipped Test"; pattern = "\bskip\s*:"; excludePathPattern = "" }
)

$rulesFile = Join-Path $repoRoot "tool\gate_rules.json"
if (Test-Path $rulesFile) {
    $customConfig = Get-Content $rulesFile -Raw | ConvertFrom-Json
    if ($null -ne $customConfig.rules) {
        foreach ($r in $customConfig.rules) {
            $ruleEntry = @{
                name               = [string]$r.name
                pattern            = [string]$r.pattern
                excludePathPattern = if ($r.excludePathPattern) { [string]$r.excludePathPattern } else { "" }
            }
            if ($r.scope -eq "test") {
                $testRules += $ruleEntry
            } else {
                $libRules += $ruleEntry
            }
        }
    }
}

$antiPatternViolations = @()

if (Test-Path "lib") {
    Get-ChildItem -Path lib -Filter *.dart -Recurse | ForEach-Object {
        $relPath = Get-RelativeUnixPath -RootPath $repoRoot -FullPath $_.FullName
        $fileLines = @(Get-Content $_.FullName)
        for ($i = 0; $i -lt $fileLines.Length; $i++) {
            $lineNum = $i + 1
            $line = $fileLines[$i].Trim()
            if ($line.StartsWith("//")) { continue }
            if ($line -match '//\s*gate-1d-ok:\s*\S+') { continue }

            foreach ($rule in $libRules) {
                if ($rule.excludePathPattern -and ($relPath -match $rule.excludePathPattern)) { continue }
                if ($line -match $rule.pattern) {
                    $antiPatternViolations += "[$($rule.name)] ${relPath}:${lineNum} : $line"
                }
            }
        }
    }
}

if (Test-Path "test") {
    Get-ChildItem -Path test -Filter *.dart -Recurse | ForEach-Object {
        $relPath = Get-RelativeUnixPath -RootPath $repoRoot -FullPath $_.FullName
        $fileLines = @(Get-Content $_.FullName)
        for ($i = 0; $i -lt $fileLines.Length; $i++) {
            $lineNum = $i + 1
            $line = $fileLines[$i].Trim()
            if ($line.StartsWith("//")) { continue }
            if ($line -match '//\s*gate-1d-ok:\s*\S+') { continue }

            foreach ($rule in $testRules) {
                if ($rule.excludePathPattern -and ($relPath -match $rule.excludePathPattern)) { continue }
                if ($line -match $rule.pattern) {
                    $antiPatternViolations += "[$($rule.name)] ${relPath}:${lineNum} : $line"
                }
            }
        }
    }
}

if ($antiPatternViolations.Count -gt 0) {
    Write-Host "[FAIL] Anti-pattern / test-integrity violations found:" -ForegroundColor Red
    $antiPatternViolations | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    $gate1dFailed = $true
} else {
    Write-Host "[PASS] Zero anti-pattern or test-integrity violations found." -ForegroundColor Green
}

if ($gate1dFailed) {
    $fastFailed = $true
    $failedGates += "Gate 1D (Anti-Patterns, Test Integrity & Whitespace)"
}
$sw1d.Stop()
$timings.Add("1D: $([math]::Round($sw1d.Elapsed.TotalSeconds, 2))s")

# Batch fast check failure summary
if ($fastFailed) {
    Write-Host "`n========================================" -ForegroundColor Red
    Write-Host " [FAIL] FAST QUALITY GATES FAILED" -ForegroundColor Red
    Write-Host " Summary of failing gates:" -ForegroundColor Red
    $failedGates | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    Write-Host " Automated test suite skipped due to fast gate failures." -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Red
    Write-TimingSummary
    exit 1
}

# Check if -FastOnly was requested
if ($FastOnly) {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host " [PASS] FAST CHECKS PASSED (Gates 1A–1D)" -ForegroundColor Green
    Write-Host " Notice: Test suite was skipped (-FastOnly)." -ForegroundColor Yellow
    Write-Host " Run without -FastOnly for full Tier 1 sign-off." -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
    Write-TimingSummary
    exit 0
}

# Automated Test Suite (Focused vs Full)
$resolvedLogName = if ($LogName -ne "") { $LogName } else { "$repoName-test-suite.log" }
$testLog = Join-Path ([System.IO.Path]::GetTempPath()) $resolvedLogName

Invoke-TestRun -FlutterBin $FlutterBin -LogFile $testLog -TargetPath $TestPath

if ($TestPath -ne "") {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host " [PASS] FOCUSED TESTS PASSED" -ForegroundColor Green
    Write-Host " Notice: This was a focused test run ($TestPath)." -ForegroundColor Yellow
    Write-Host " Run without arguments for full Tier 1 sign-off." -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Cyan
} else {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host " [PASS] AUTOMATED CHECKS PASSED (FULL TIER 1)" -ForegroundColor Green
    Write-Host " Complete Tier 2 manual review and" -ForegroundColor Cyan
    Write-Host " remaining Tier 3 focused feature and" -ForegroundColor Cyan
    Write-Host " owner device testing." -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
}
Write-TimingSummary
exit 0
