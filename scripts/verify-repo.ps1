<#
.SYNOPSIS
    Deterministic repository verification lever for Antigravity-IDE-Auto-Setting.
.DESCRIPTION
    Validates rules frontmatter, skill schema and folder-name alignment,
    relative path integrity, markdown code fence pairing, GEMINI/README index
    synchronization, and Change_Log.md append-only invariants.
    Compatible with Windows PowerShell 5.1+ and PowerShell 7+.
#>
[CmdletBinding()]
param(
    [string]$RepoRoot = '',
    [switch]$SkipGitAppendCheck,
    [switch]$TrackedOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($RepoRoot)) {
    $scriptDir = if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
        $PSScriptRoot
    }
    elseif ($MyInvocation.MyCommand.Path) {
        Split-Path -Parent $MyInvocation.MyCommand.Path
    }
    else {
        (Get-Location).Path
    }
    $RepoRoot = Split-Path -Parent $scriptDir
}
$RepoRoot = (Resolve-Path $RepoRoot).Path

$script:Failures = New-Object System.Collections.Generic.List[string]
$script:ChecksRun = 0
$script:ChecksPassed = 0

function Add-CheckResult {
    param(
        [string]$Name,
        [bool]$Passed,
        [string]$Detail
    )
    $script:ChecksRun++
    if ($Passed) {
        $script:ChecksPassed++
        Write-Host "[PASS] $Name - $Detail" -ForegroundColor Green
    }
    else {
        $script:Failures.Add("$Name : $Detail")
        Write-Host "[FAIL] $Name - $Detail" -ForegroundColor Red
    }
}

function Get-FrontmatterBlock {
    param([string[]]$Lines)
    if ($null -eq $Lines -or $Lines.Count -lt 3) { return $null }
    if ($Lines[0].Trim() -ne '---') { return $null }
    $endIdx = -1
    for ($i = 1; $i -lt $Lines.Count; $i++) {
        if ($Lines[$i].Trim() -eq '---') {
            $endIdx = $i
            break
        }
    }
    if ($endIdx -lt 1) { return $null }
    $map = @{}
    for ($j = 1; $j -lt $endIdx; $j++) {
        $line = $Lines[$j]
        if ($line -match '^\s*([A-Za-z0-9_-]+)\s*:\s*(.*)$') {
            $key = $Matches[1].Trim()
            $val = $Matches[2].Trim().Trim('"').Trim("'")
            $map[$key] = $val
        }
    }
    return $map
}

function Read-Utf8Lines {
    param([string]$Path)
    $raw = [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
    $normalized = $raw -replace "`r`n", "`n" -replace "`r", "`n"
    if ($normalized.EndsWith("`n")) {
        $normalized = $normalized.Substring(0, $normalized.Length - 1)
    }
    if ($normalized.Length -eq 0) { return @() }
    return , ($normalized -split "`n")
}

Write-Host "Running repository verification lever on: $RepoRoot" -ForegroundColor Cyan

$trackedSet = $null
if ($TrackedOnly) {
    $trackedList = @(& git -C $RepoRoot -c core.quotepath=false ls-files)
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to list tracked files with git ls-files on $RepoRoot"
    }
    $trackedSet = New-Object System.Collections.Generic.HashSet[string] ([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($tp in $trackedList) {
        if (-not [string]::IsNullOrWhiteSpace($tp)) {
            [void]$trackedSet.Add(($tp -replace '/', '\'))
        }
    }
}

# 1. Rules YAML Frontmatter Check
$rulesDir = Join-Path $RepoRoot 'rules'
$ruleFiles = @(Get-ChildItem -Path $rulesDir -Filter '*.md' -File -ErrorAction SilentlyContinue)
if ($TrackedOnly) {
    $ruleFiles = @($ruleFiles | Where-Object { $trackedSet.Contains($_.FullName.Substring($RepoRoot.Length + 1)) })
}
if ($ruleFiles.Count -eq 0) {
    Add-CheckResult -Name 'Rules Frontmatter' -Passed $false -Detail 'No markdown files found in rules/'
}
else {
    $ruleErrors = @()
    foreach ($rf in $ruleFiles) {
        $lines = Read-Utf8Lines -Path $rf.FullName
        $fm = Get-FrontmatterBlock -Lines $lines
        if ($null -eq $fm) {
            $ruleErrors += "$($rf.Name): missing YAML frontmatter"
            continue
        }
        if (-not $fm.ContainsKey('description') -or [string]::IsNullOrWhiteSpace($fm['description'])) {
            $ruleErrors += "$($rf.Name): missing 'description'"
        }
        if (-not $fm.ContainsKey('trigger') -or [string]::IsNullOrWhiteSpace($fm['trigger'])) {
            $ruleErrors += "$($rf.Name): missing 'trigger'"
        }
    }
    Add-CheckResult -Name 'Rules Frontmatter' -Passed ($ruleErrors.Count -eq 0) -Detail $(if ($ruleErrors.Count -eq 0) { "$($ruleFiles.Count) rule file(s) valid" } else { $ruleErrors -join '; ' })
}

# 2. Skills Directory & Frontmatter Schema Check (Global skills/ + Project .agents/skills/)
$skillsDir = Join-Path $RepoRoot 'skills'
$skillDirs = @(Get-ChildItem -Path $skillsDir -Directory -ErrorAction SilentlyContinue | Sort-Object Name)
$localSkillsDir = Join-Path $RepoRoot '.agents\skills'
$localSkillDirs = @(Get-ChildItem -Path $localSkillsDir -Directory -ErrorAction SilentlyContinue | Sort-Object Name)
if ($TrackedOnly) {
    $skillDirs = @($skillDirs | Where-Object { $trackedSet.Contains("skills\$($_.Name)\SKILL.md") })
    $localSkillDirs = @($localSkillDirs | Where-Object { $trackedSet.Contains(".agents\skills\$($_.Name)\SKILL.md") })
}
$skillErrors = @()

function Test-SkillDirectorySet {
    param(
        [System.IO.DirectoryInfo[]]$Dirs,
        [string]$Prefix
    )
    $errs = @()
    foreach ($sd in $Dirs) {
        $skillMd = Join-Path $sd.FullName 'SKILL.md'
        if (-not (Test-Path $skillMd)) {
            $errs += "$Prefix$($sd.Name): missing SKILL.md"
            continue
        }
        $lines = Read-Utf8Lines -Path $skillMd
        $fm = Get-FrontmatterBlock -Lines $lines
        if ($null -eq $fm) {
            $errs += "$Prefix$($sd.Name)/SKILL.md: missing YAML frontmatter"
            continue
        }
        if (-not $fm.ContainsKey('name') -or $fm['name'] -cne $sd.Name) {
            $actual = if ($fm.ContainsKey('name')) { $fm['name'] } else { '<missing>' }
            $errs += "$Prefix$($sd.Name)/SKILL.md: frontmatter name '$actual' != folder '$($sd.Name)'"
        }
        if ($sd.Name -cnotmatch '^[a-z0-9]+(-[a-z0-9]+)*$') {
            $errs += "$Prefix$($sd.Name): skill folder name must be lowercase-hyphenated"
        }
        if (-not $fm.ContainsKey('description') -or [string]::IsNullOrWhiteSpace($fm['description'])) {
            $errs += "$Prefix$($sd.Name)/SKILL.md: missing 'description'"
        }
    }
    return , $errs
}

if ($skillDirs.Count -eq 0) {
    $skillErrors += 'No skill directories found in skills/'
}
else {
    $skillErrors += Test-SkillDirectorySet -Dirs $skillDirs -Prefix 'skills/'
}
if ($localSkillDirs.Count -gt 0) {
    $skillErrors += Test-SkillDirectorySet -Dirs $localSkillDirs -Prefix '.agents/skills/'
}
$totalSkillCount = $skillDirs.Count + $localSkillDirs.Count
Add-CheckResult -Name 'Skills Schema' -Passed ($skillErrors.Count -eq 0) -Detail $(if ($skillErrors.Count -eq 0) { "$($skillDirs.Count) global + $($localSkillDirs.Count) local skill(s) match folder names & schema ($totalSkillCount total)" } else { $skillErrors -join '; ' })

# 3. Relative Resource & Cross-Skill Link Integrity Check
$geminiPath = Join-Path $RepoRoot 'GEMINI.md'
$readmePath = Join-Path $RepoRoot 'README.md'
$linkErrors = @()
$checkedLinks = 0
$pattern = '`((?:\.\./|resources/|scripts/|rules/|templates/|skills/)[^`\s]+)`'
$filesToScan = @()
foreach ($sd in ($skillDirs + $localSkillDirs)) {
    $skillMd = Join-Path $sd.FullName 'SKILL.md'
    if (Test-Path $skillMd) { $filesToScan += Get-Item $skillMd }
}
foreach ($rootDoc in @('GEMINI.md', 'README.md', 'docs\Feature_Map.md', 'docs\Architecture_and_Workflow.md')) {
    $p = Join-Path $RepoRoot $rootDoc
    if (Test-Path $p) { $filesToScan += Get-Item $p }
}

foreach ($f in $filesToScan) {
    $lines = Read-Utf8Lines -Path $f.FullName
    $isGeminiRoot = ($f.FullName -eq $geminiPath)
    foreach ($line in $lines) {
        $rowSkillDir = $null
        if ($isGeminiRoot -and $line -match '`(skills/[A-Za-z0-9_-]+)/?`') {
            $rowSkillDir = Join-Path $RepoRoot ($Matches[1] -replace '/', [System.IO.Path]::DirectorySeparatorChar)
        }
        $rxMatches = [regex]::Matches($line, $pattern)
        foreach ($m in $rxMatches) {
            $rel = $m.Groups[1].Value.TrimEnd('/', '.', ',', ';', ':')
            # Skip template placeholders or wildcard globs
            if ($rel -match '[\*<>]' -or $rel -match 'XXXX' -or $rel -match '\.\.\.' -or $rel -eq 'skills' -or $rel -eq 'rules' -or $rel -eq 'templates' -or $rel -eq 'scripts' -or $rel -eq 'resources') {
                continue
            }
            if ($rel.StartsWith('../')) {
                $baseDir = $f.DirectoryName
            }
            elseif ($rel.StartsWith('resources/')) {
                if ($isGeminiRoot -and $null -ne $rowSkillDir) {
                    $baseDir = $rowSkillDir
                }
                else {
                    $baseDir = $f.DirectoryName
                }
            }
            else {
                $baseDir = $RepoRoot
            }
            $resolved = Join-Path $baseDir ($rel -replace '/', [System.IO.Path]::DirectorySeparatorChar)
            $checkedLinks++
            if (-not (Test-Path $resolved)) {
                $linkErrors += "$($f.FullName.Substring($RepoRoot.Length + 1)): broken ref '$rel'"
            }
        }
    }
}
Add-CheckResult -Name 'Link Integrity' -Passed ($linkErrors.Count -eq 0) -Detail $(if ($linkErrors.Count -eq 0) { "$checkedLinks relative reference(s) verified" } else { $linkErrors -join '; ' })

# 4. Markdown Code Fence Pairing Check
$mdFiles = @(Get-ChildItem -Path $RepoRoot -Filter '*.md' -Recurse -File | Where-Object { $_.FullName -notmatch '\\\.git\\' })
if ($TrackedOnly) {
    $mdFiles = @($mdFiles | Where-Object { $trackedSet.Contains($_.FullName.Substring($RepoRoot.Length + 1)) })
}
$fenceErrors = @()
foreach ($mf in $mdFiles) {
    $lines = Read-Utf8Lines -Path $mf.FullName
    $fenceCount = 0
    foreach ($ln in $lines) {
        if ($ln -match '^\s*```') {
            $fenceCount++
        }
    }
    if (($fenceCount % 2) -ne 0) {
        $relPath = $mf.FullName.Substring($RepoRoot.Length + 1)
        $fenceErrors += "$relPath (unbalanced code fences: $fenceCount)"
    }
}
Add-CheckResult -Name 'Markdown Fences' -Passed ($fenceErrors.Count -eq 0) -Detail $(if ($fenceErrors.Count -eq 0) { "$($mdFiles.Count) markdown file(s) have balanced fences" } else { $fenceErrors -join '; ' })

# 5. SSOT Index Synchronization (GEMINI.md & README.md vs skills/ & scripts/)
$indexErrors = @()
$geminiText = if (Test-Path $geminiPath) { [System.IO.File]::ReadAllText($geminiPath, [System.Text.Encoding]::UTF8) } else { '' }
$readmeText = if (Test-Path $readmePath) { [System.IO.File]::ReadAllText($readmePath, [System.Text.Encoding]::UTF8) } else { '' }

foreach ($sd in $skillDirs) {
    if ($geminiText -notmatch [regex]::Escape($sd.Name)) {
        $indexErrors += "GEMINI.md missing skill '$($sd.Name)'"
    }
    if ($readmeText -notmatch [regex]::Escape($sd.Name)) {
        $indexErrors += "README.md missing skill '$($sd.Name)'"
    }
}
foreach ($assetName in @('verify-repo.ps1', 'sync-config.ps1', 'sync-config.sh')) {
    $scriptPath = Join-Path $RepoRoot "scripts\$assetName"
    if (Test-Path $scriptPath) {
        $esc = [regex]::Escape($assetName)
        if ($geminiText -notmatch $esc) {
            $indexErrors += "GEMINI.md missing scripts/$assetName"
        }
        if ($readmeText -notmatch $esc) {
            $indexErrors += "README.md missing scripts/$assetName"
        }
    }
}
$requiredAssets = @('Feature_Map\.md', 'Architecture_and_Workflow\.md', 'pre-commit', '\.gitattributes')
foreach ($lsd in $localSkillDirs) {
    $requiredAssets += [regex]::Escape($lsd.Name)
}
foreach ($assetPattern in $requiredAssets) {
    if ($geminiText -notmatch $assetPattern) {
        $indexErrors += "GEMINI.md missing reference matching '$assetPattern'"
    }
    if ($readmeText -notmatch $assetPattern) {
        $indexErrors += "README.md missing reference matching '$assetPattern'"
    }
}
Add-CheckResult -Name 'SSOT Index Sync' -Passed ($indexErrors.Count -eq 0) -Detail $(if ($indexErrors.Count -eq 0) { "GEMINI.md and README.md cover all $($skillDirs.Count) global skills, $($localSkillDirs.Count) local verify skill(s), docs, .gitattributes, pre-commit, and scripts" } else { $indexErrors -join '; ' })

# 6. Change_Log.md Append-Only Invariant Check
$changeLogPath = Join-Path $RepoRoot 'Change_Log.md'
if ($SkipGitAppendCheck) {
    Write-Host '[INFO] Change_Log Append-Only - Skipped via -SkipGitAppendCheck' -ForegroundColor Yellow
}
elseif (-not (Test-Path $changeLogPath)) {
    Add-CheckResult -Name 'Change_Log Append-Only' -Passed $false -Detail 'Change_Log.md not found'
}
else {
    $gitExists = Get-Command git -ErrorAction SilentlyContinue
    if ($null -eq $gitExists -or -not (Test-Path (Join-Path $RepoRoot '.git'))) {
        Add-CheckResult -Name 'Change_Log Append-Only' -Passed $false -Detail 'Git repository not detected for append-only verification'
    }
    else {
        $headRaw = (& git -C $RepoRoot show 'HEAD:Change_Log.md' 2>$null) -join "`n"
        if ($LASTEXITCODE -ne 0) {
            Add-CheckResult -Name 'Change_Log Append-Only' -Passed $false -Detail 'Unable to read HEAD:Change_Log.md'
        }
        else {
            $headNorm = ($headRaw -replace "`r`n", "`n" -replace "`r", "`n").TrimEnd("`n")
            $headLines = if ($headNorm.Length -eq 0) { @() } else { , ($headNorm -split "`n") }
            $currLines = Read-Utf8Lines -Path $changeLogPath
            $appendOk = $true
            $mismatchMsg = ''
            if ($currLines.Count -lt $headLines.Count) {
                $appendOk = $false
                $mismatchMsg = "Current line count ($($currLines.Count)) < HEAD line count ($($headLines.Count))"
            }
            else {
                for ($k = 0; $k -lt $headLines.Count; $k++) {
                    if ($currLines[$k] -ne $headLines[$k]) {
                        $appendOk = $false
                        $mismatchMsg = "Historical line $($k + 1) modified (violates APPEND ONLY)"
                        break
                    }
                }
            }
            Add-CheckResult -Name 'Change_Log Append-Only' -Passed $appendOk -Detail $(if ($appendOk) { "All $($headLines.Count) historical line(s) preserved; total lines: $($currLines.Count)" } else { $mismatchMsg })
        }
    }
}

# 7. Self-Dogfooding & Readme Drift Gate
$dogfoodErrors = @()
$featureMapPath = Join-Path $RepoRoot 'docs\Feature_Map.md'
$archGuidePath = Join-Path $RepoRoot 'docs\Architecture_and_Workflow.md'
$preCommitHook = Join-Path $RepoRoot '.githooks\pre-commit'
$gitAttrsPath = Join-Path $RepoRoot '.gitattributes'
$syncPsPath = Join-Path $RepoRoot 'scripts\sync-config.ps1'
$syncShPath = Join-Path $RepoRoot 'scripts\sync-config.sh'
$verifyLocalSkills = @($localSkillDirs | Where-Object { $_.Name -like 'verify-*' })

if (-not (Test-Path $featureMapPath)) { $dogfoodErrors += 'Missing docs/Feature_Map.md' }
if (-not (Test-Path $archGuidePath)) { $dogfoodErrors += 'Missing docs/Architecture_and_Workflow.md' }
if ($verifyLocalSkills.Count -eq 0) { $dogfoodErrors += 'Missing .agents/skills/verify-* skill' }
if (-not (Test-Path $preCommitHook)) { $dogfoodErrors += 'Missing .githooks/pre-commit' }
if (-not (Test-Path $gitAttrsPath)) { $dogfoodErrors += 'Missing .gitattributes' }
if (-not (Test-Path $syncPsPath)) { $dogfoodErrors += 'Missing scripts/sync-config.ps1' }
if (-not (Test-Path $syncShPath)) { $dogfoodErrors += 'Missing scripts/sync-config.sh' }
if ($readmeText -match '01~03') {
    $dogfoodErrors += "README.md contains stale '01~03' reference (expected 01~04 + Feature_Map)"
}
Add-CheckResult -Name 'Dogfooding & Drift Gate' -Passed ($dogfoodErrors.Count -eq 0) -Detail $(if ($dogfoodErrors.Count -eq 0) { 'Self-dogfooding assets, .gitattributes, Architecture guide, and README drift check all pass' } else { $dogfoodErrors -join '; ' })

Write-Host ''
Write-Host "Summary: $($script:ChecksPassed)/$($script:ChecksRun) checks passed." -ForegroundColor $(if ($script:Failures.Count -eq 0) { 'Green' } else { 'Red' })
if ($script:Failures.Count -gt 0) {
    exit 1
}
exit 0
