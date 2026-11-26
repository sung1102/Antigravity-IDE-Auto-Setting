<#
.SYNOPSIS
    Non-destructive mount & V1->V2 upgrade tool for Antigravity-IDE-Auto-Setting.
.DESCRIPTION
    Safely installs or updates Antigravity-IDE-Auto-Setting into ~/.gemini/config
    without deleting user-built custom skills, rules, mcp_config.json, plugins, or projects.
    Supports 3 scenarios:
      A. Fresh machine (TargetDir does not exist)
      B. Existing ~/.gemini/config without .git (in-place takeover preserving local files)
      C. Existing git-mounted ~/.gemini/config (V1 -> V2 fast-forward upgrade)
#>
[CmdletBinding()]
param(
    [string]$TargetDir = '',
    [string]$RepoUrl = 'https://github.com/sung1102/Antigravity-IDE-Auto-Setting.git',
    [string]$Branch = 'main',
    [switch]$BackupOnLocalModify,
    [switch]$SkipVerify
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($TargetDir)) {
    $TargetDir = Join-Path $HOME '.gemini\config'
}

$gitCmd = Get-Command git -ErrorAction SilentlyContinue
if ($null -eq $gitCmd) {
    Write-Error 'Git CLI not found in PATH. Please install Git first.'
    exit 1
}

function Invoke-Git {
    param(
        [string]$RepoPath,
        [string[]]$GitArgs
    )
    if ([string]::IsNullOrWhiteSpace($RepoPath)) {
        & git @GitArgs
    }
    else {
        & git -C $RepoPath @GitArgs
    }
    if ($LASTEXITCODE -ne 0) {
        throw "git command failed (exit $LASTEXITCODE): git $($GitArgs -join ' ')"
    }
}

function Repair-VerifySkillCasing {
    param([string]$RootPath)
    $localSkillsPath = Join-Path $RootPath '.agents\skills'
    if (-not (Test-Path -LiteralPath $localSkillsPath)) { return }
    $items = @(Get-ChildItem -LiteralPath $localSkillsPath -Directory -Filter 'verify-*' -ErrorAction SilentlyContinue)
    foreach ($it in $items) {
        $lower = $it.Name.ToLowerInvariant()
        if ($it.Name -cne $lower) {
            $tmpName = "__tmp_case_$PID"
            $tmpPath = Join-Path $localSkillsPath $tmpName
            $finalPath = Join-Path $localSkillsPath $lower
            Move-Item -LiteralPath $it.FullName -Destination $tmpPath
            Move-Item -LiteralPath $tmpPath -Destination $finalPath
            Write-Host "[INFO] Normalized directory case on NTFS: $($it.Name) -> $lower" -ForegroundColor Cyan
        }
    }
}

$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$parentDir = Split-Path -Parent $TargetDir
$gitDir = Join-Path $TargetDir '.git'
$modeLabel = ''

if (-not (Test-Path -LiteralPath $TargetDir)) {
    # Case A: Fresh install
    $modeLabel = 'Fresh Install'
    if (-not (Test-Path -LiteralPath $parentDir)) {
        New-Item -ItemType Directory -Force -Path $parentDir | Out-Null
    }
    Write-Host "[INFO] Mode: $modeLabel -> Cloning $RepoUrl ($Branch) into $TargetDir" -ForegroundColor Cyan
    Invoke-Git -RepoPath '' -GitArgs @('clone', '--branch', $Branch, $RepoUrl, $TargetDir)
}
elseif (-not (Test-Path -LiteralPath $gitDir)) {
    # Case B: Existing directory without .git (preserve mcp_config.json, plugins, custom skills)
    $modeLabel = 'In-Place Non-Destructive Mount'
    Write-Host "[INFO] Mode: $modeLabel -> Preserving local IDE files & custom skills in $TargetDir" -ForegroundColor Cyan
    Invoke-Git -RepoPath $TargetDir -GitArgs @('init')
    $remotes = @(& git -C $TargetDir remote)
    if ($remotes -contains 'origin') {
        Invoke-Git -RepoPath $TargetDir -GitArgs @('remote', 'set-url', 'origin', $RepoUrl)
    }
    else {
        Invoke-Git -RepoPath $TargetDir -GitArgs @('remote', 'add', 'origin', $RepoUrl)
    }
    Invoke-Git -RepoPath $TargetDir -GitArgs @('fetch', 'origin', $Branch)

    $trackedRaw = & git -C $TargetDir -c core.quotepath=false ls-tree -r --name-only "origin/$Branch"
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to inspect files in origin/$Branch"
    }

    $backupDir = Join-Path $parentDir "backup_pre_mount_$timestamp"
    $backedUpCount = 0
    foreach ($rel in $trackedRaw) {
        if ([string]::IsNullOrWhiteSpace($rel)) { continue }
        $nativeRel = $rel -replace '/', [System.IO.Path]::DirectorySeparatorChar
        $destFile = Join-Path $TargetDir $nativeRel
        if (Test-Path -LiteralPath $destFile -PathType Leaf) {
            $backupDest = Join-Path $backupDir $nativeRel
            $backupParent = Split-Path -Parent $backupDest
            if (-not (Test-Path -LiteralPath $backupParent)) {
                New-Item -ItemType Directory -Force -Path $backupParent | Out-Null
            }
            Copy-Item -LiteralPath $destFile -Destination $backupDest -Force
            $backedUpCount++
        }
    }
    if ($backedUpCount -gt 0) {
        Write-Host "[BACKUP] Backed up $backedUpCount colliding tracked file(s) to $backupDir" -ForegroundColor Yellow
    }

    Invoke-Git -RepoPath $TargetDir -GitArgs @('checkout', '-f', '-B', $Branch, "origin/$Branch")
    Invoke-Git -RepoPath $TargetDir -GitArgs @('branch', "--set-upstream-to=origin/$Branch", $Branch)
}
else {
    # Case C: Existing git-mounted config (V1 -> V2 upgrade)
    $modeLabel = 'Git Fast-Forward Upgrade'
    $remoteTarget = 'origin'
    if ($PSBoundParameters.ContainsKey('RepoUrl')) {
        $remoteTarget = $RepoUrl
    }
    else {
        $remotes = @(& git -C $TargetDir remote)
        if (-not ($remotes -contains 'origin')) {
            Invoke-Git -RepoPath $TargetDir -GitArgs @('remote', 'add', 'origin', $RepoUrl)
        }
        else {
            $originUrl = (& git -C $TargetDir remote get-url origin).Trim()
            Write-Host "[INFO] Using configured origin: $originUrl" -ForegroundColor Cyan
        }
    }

    # Check only TRACKED modifications so untracked custom skills / mcp_config.json never block update
    $dirtyTracked = @(& git -C $TargetDir -c core.quotepath=false status --porcelain --untracked-files=no)
    if ($LASTEXITCODE -ne 0) {
        throw 'Failed to check git status on target directory.'
    }
    if ($dirtyTracked.Count -gt 0) {
        if (-not $BackupOnLocalModify) {
            Write-Host '[ERROR] Tracked governance files have local modifications:' -ForegroundColor Red
            $dirtyTracked | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
            Write-Host 'Re-run with -BackupOnLocalModify to back up modified tracked files and upgrade safely (untracked custom skills are always preserved).' -ForegroundColor Yellow
            exit 2
        }
        $backupEditDir = Join-Path $parentDir "backup_local_edits_$timestamp"
        $modPaths = @(& git -C $TargetDir -c core.quotepath=false diff --name-only; & git -C $TargetDir -c core.quotepath=false diff --cached --name-only) | Select-Object -Unique
        foreach ($mp in $modPaths) {
            if ([string]::IsNullOrWhiteSpace($mp)) { continue }
            $nativeMp = $mp -replace '/', [System.IO.Path]::DirectorySeparatorChar
            $srcPath = Join-Path $TargetDir $nativeMp
            if (Test-Path -LiteralPath $srcPath -PathType Leaf) {
                $dstPath = Join-Path $backupEditDir $nativeMp
                $dstParent = Split-Path -Parent $dstPath
                if (-not (Test-Path -LiteralPath $dstParent)) {
                    New-Item -ItemType Directory -Force -Path $dstParent | Out-Null
                }
                Copy-Item -LiteralPath $srcPath -Destination $dstPath -Force
            }
        }
        Write-Host "[BACKUP] Saved local tracked modifications to $backupEditDir" -ForegroundColor Yellow
        Invoke-Git -RepoPath $TargetDir -GitArgs @('reset', '--hard', 'HEAD')
    }

    Write-Host "[INFO] Mode: $modeLabel -> Fetching $Branch from $remoteTarget" -ForegroundColor Cyan
    Invoke-Git -RepoPath $TargetDir -GitArgs @('fetch', $remoteTarget, $Branch)
    Invoke-Git -RepoPath $TargetDir -GitArgs @('checkout', $Branch)
    Invoke-Git -RepoPath $TargetDir -GitArgs @('merge', '--ff-only', 'FETCH_HEAD')
}

Repair-VerifySkillCasing -RootPath $TargetDir
Invoke-Git -RepoPath $TargetDir -GitArgs @('config', 'core.hooksPath', '.githooks')

$headSha = (& git -C $TargetDir rev-parse --short HEAD).Trim()
Write-Host "[PASS] Synced ($modeLabel) at commit $headSha -> $TargetDir" -ForegroundColor Green
Write-Host '[INFO] Untracked personal skills, rules, mcp_config.json, plugins, and projects remain untouched.' -ForegroundColor Cyan

if (-not $SkipVerify) {
    $verifyPath = Join-Path $TargetDir 'scripts\verify-repo.ps1'
    if (Test-Path -LiteralPath $verifyPath) {
        Write-Host '[INFO] Running repository verification (-TrackedOnly)...' -ForegroundColor Cyan
        & powershell -ExecutionPolicy Bypass -File $verifyPath -RepoRoot $TargetDir -TrackedOnly
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Verification failed on $TargetDir (exit $LASTEXITCODE)."
            exit $LASTEXITCODE
        }
    }
}

exit 0
