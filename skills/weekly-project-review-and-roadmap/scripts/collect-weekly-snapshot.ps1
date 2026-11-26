<#
.SYNOPSIS
    Read-only weekly project snapshot collector for weekly-project-review-and-roadmap.
.DESCRIPTION
    Collects recent Git commits, top changed files, working tree status, backup branches,
    Change_Log tail headings, VerificationCoverageMatrix gaps, Feature_Map drift date,
    available verify levers, and technical-debt markers (TODO/FIXME/HACK/DEPRECATED)
    strictly across Git-tracked files (skipping .git, node_modules, bin, obj, .runs).
    CP950/Big5-safe via UTF-8 ProcessStartInfo.
#>
[CmdletBinding()]
param(
    [string]$ProjectRoot = '.',
    [int]$Days = 7,
    [int]$MaxTodoFindings = 40
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [Console]::OutputEncoding = $utf8NoBom
    $OutputEncoding = $utf8NoBom
}
catch {
    # Ignore when running without an attached console handle
}

$resolvedRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path

function Invoke-GitUtf8 {
    param(
        [string]$RepoPath,
        [string]$Arguments
    )
    $gitExe = (Get-Command git -ErrorAction Stop).Source
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $gitExe
    $psi.Arguments = "-C `"$RepoPath`" $Arguments"
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.StandardOutputEncoding = [System.Text.Encoding]::UTF8
    $psi.StandardErrorEncoding = [System.Text.Encoding]::UTF8
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true

    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $psi
    [void]$proc.Start()
    $errTask = $proc.StandardError.ReadToEndAsync()
    $stdOut = $proc.StandardOutput.ReadToEnd()
    $proc.WaitForExit()
    $stdErr = $errTask.GetAwaiter().GetResult()
    return [PSCustomObject]@{
        ExitCode = $proc.ExitCode
        Output   = $stdOut
        Error    = $stdErr
    }
}

function Read-Utf8Text {
    param([string]$Path)
    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}

Write-Host "# Weekly Project Snapshot"
Write-Host "- Generated At: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
Write-Host "- Project Root: $resolvedRoot"
Write-Host "- Window: Last $Days day(s)"
Write-Host ""

$isGit = Test-Path -LiteralPath (Join-Path $resolvedRoot '.git')
if ($isGit) {
    $branchRes = Invoke-GitUtf8 -RepoPath $resolvedRoot -Arguments 'status -sb'
    $headRes = Invoke-GitUtf8 -RepoPath $resolvedRoot -Arguments 'rev-parse --short HEAD'
    Write-Host "## 1. Git Status & Branches"
    Write-Host "- HEAD: $($headRes.Output.Trim())"
    Write-Host '```text'
    Write-Host $branchRes.Output.TrimEnd()
    Write-Host '```'

    $backupRes = Invoke-GitUtf8 -RepoPath $resolvedRoot -Arguments 'branch --list "backup/*"'
    $backupLines = @($backupRes.Output -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    Write-Host "- Backup Branches ($($backupLines.Count)): $(if ($backupLines.Count -eq 0) { 'None' } else { ($backupLines | ForEach-Object { $_.Trim() }) -join ', ' })"
    Write-Host ""

    Write-Host "## 2. Commits in Last $Days Day(s)"
    $logRes = Invoke-GitUtf8 -RepoPath $resolvedRoot -Arguments "log --since=`"$Days days ago`" --oneline --no-decorate"
    $logLines = @($logRes.Output -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($logLines.Count -eq 0) {
        Write-Host "- No commits in the last $Days day(s)."
    }
    else {
        Write-Host "- Commit Count: $($logLines.Count)"
        Write-Host '```text'
        $logLines | ForEach-Object { Write-Host $_ }
        Write-Host '```'
    }

    $filesRes = Invoke-GitUtf8 -RepoPath $resolvedRoot -Arguments "log --since=`"$Days days ago`" --name-only --pretty=format:"
    $changedList = @($filesRes.Output -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    if ($changedList.Count -gt 0) {
        Write-Host "### Most Frequently Modified Files (Last $Days Day(s))"
        $changedList | Group-Object | Sort-Object Count -Descending | Select-Object -First 15 | ForEach-Object {
            Write-Host "- ($($_.Count)x) $($_.Name)"
        }
    }
    Write-Host ""
}
else {
    Write-Host "## 1. Git Status"
    Write-Host "- [WARN] Not a Git repository."
    Write-Host ""
}

Write-Host "## 3. Governance, Matrix & Feature Map Status"
$changeLog = Join-Path $resolvedRoot 'Change_Log.md'
if (Test-Path -LiteralPath $changeLog) {
    $clLines = (Read-Utf8Text -Path $changeLog) -split "`r?`n"
    $headings = @($clLines | Where-Object { $_ -match '^## \[' } | Select-Object -Last 5)
    Write-Host "### Change_Log.md (Latest $($headings.Count) Entries)"
    foreach ($h in $headings) { Write-Host "- $h" }
}
else {
    Write-Host "- Change_Log.md: [MISSING]"
}

$matrixPath = Join-Path $resolvedRoot 'VerificationCoverageMatrix.md'
if (Test-Path -LiteralPath $matrixPath) {
    $mLines = (Read-Utf8Text -Path $matrixPath) -split "`r?`n"
    $openRows = @($mLines | Where-Object { $_ -match '^\|' -and $_ -match '\b(FAIL|BLOCKED|NOT RUN)\b' })
    Write-Host "### VerificationCoverageMatrix.md Non-PASS Items ($($openRows.Count))"
    if ($openRows.Count -eq 0) {
        Write-Host "- All recorded items are PASS."
    }
    else {
        foreach ($r in $openRows) { Write-Host $r }
    }
}
else {
    Write-Host "- VerificationCoverageMatrix.md: [MISSING]"
}

$featureMap = Join-Path $resolvedRoot 'docs\Feature_Map.md'
if (Test-Path -LiteralPath $featureMap) {
    $fmLines = (Read-Utf8Text -Path $featureMap) -split "`r?`n"
    $auditLines = @($fmLines | Where-Object { $_ -match '核對日期|上次巡檢|Drift' } | Select-Object -First 3)
    Write-Host "### docs/Feature_Map.md: Present"
    foreach ($al in $auditLines) { Write-Host "- $($al.Trim())" }
}
else {
    Write-Host "- docs/Feature_Map.md: [MISSING]"
}
Write-Host ""

Write-Host "## 4. Detected Verification Levers"
$levers = New-Object System.Collections.Generic.List[string]
$agentVerify = @(Get-ChildItem -Path (Join-Path $resolvedRoot '.agents\skills') -Directory -Filter 'verify-*' -ErrorAction SilentlyContinue)
foreach ($av in $agentVerify) { $levers.Add(".agents/skills/$($av.Name)/SKILL.md") }
foreach ($cand in @('scripts\verify-repo.ps1', 'scripts\verify.ps1', 'scripts\verify.sh', 'Makefile')) {
    if (Test-Path -LiteralPath (Join-Path $resolvedRoot $cand)) {
        $levers.Add(($cand -replace '\\', '/'))
    }
}
if ($levers.Count -eq 0) {
    Write-Host "- [NONE DETECTED] Suggest creating verification lever via verification-harness-builder."
}
else {
    foreach ($lv in $levers) { Write-Host "- $lv" }
}
Write-Host ""

Write-Host "## 5. Technical-Debt Markers (TODO / FIXME / HACK / DEPRECATED)"
$markerFindings = New-Object System.Collections.Generic.List[string]
if ($isGit) {
    $lsRes = Invoke-GitUtf8 -RepoPath $resolvedRoot -Arguments '-c core.quotepath=false ls-files'
    $trackedFiles = @($lsRes.Output -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
    $textExts = @('.cs', '.cpp', '.c', '.h', '.hpp', '.v', '.sv', '.vhd', '.py', '.ts', '.tsx', '.js', '.ps1', '.sh', '.md', '.json', '.xml', '.props', '.xdc', '.sdc')
    foreach ($rel in $trackedFiles) {
        if ($rel -match 'collect-weekly-snapshot|weekly-project-review-and-roadmap|Change_Log\.md') { continue }
        $ext = [System.IO.Path]::GetExtension($rel).ToLowerInvariant()
        if ($textExts -notcontains $ext) { continue }
        $full = Join-Path $resolvedRoot ($rel -replace '/', '\')
        if (-not (Test-Path -LiteralPath $full -PathType Leaf)) { continue }
        $fileLines = (Read-Utf8Text -Path $full) -split "`r?`n"
        for ($i = 0; $i -lt $fileLines.Count; $i++) {
            if ($fileLines[$i] -match '\b(TODO|FIXME|HACK|DEPRECATED)\b') {
                $snippet = $fileLines[$i].Trim()
                if ($snippet.Length -gt 120) { $snippet = $snippet.Substring(0, 120) + '...' }
                $markerFindings.Add("${rel}:$($i + 1): $snippet")
                if ($markerFindings.Count -ge $MaxTodoFindings) { break }
            }
        }
        if ($markerFindings.Count -ge $MaxTodoFindings) { break }
    }
}
if ($markerFindings.Count -eq 0) {
    Write-Host "- None found in tracked source/docs."
}
else {
    Write-Host "- Findings (capped at $MaxTodoFindings): $($markerFindings.Count)"
    foreach ($mf in $markerFindings) { Write-Host "  - $mf" }
}
