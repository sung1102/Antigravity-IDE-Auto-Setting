<#
.SYNOPSIS
    Cross-platform (Windows PowerShell 5.1+ / pwsh 7+) Release Bundle & Manifest Builder.
    Collects SW executables and/or RTL/FPGA flashing artifacts, enforces Clean Worktree
    traceability, computes SHA-256 checksums, and generates release-manifest.json +
    Release_Notes_DRAFT.md.
#>
[CmdletBinding()]
param(
    [string]$ProjectRoot = '.',
    [Parameter(Mandatory = $true)]
    [string]$Version,
    [string[]]$ArtifactPaths = @(),
    [string]$ArtifactDir = '',
    [string]$OutDir = '',
    [string]$SinceTag = '',
    [string]$ProjectName = '',
    [string]$SwVersion = '',
    [string]$FwVersion = '',
    [string]$RtlVersion = '',
    [switch]$AllowDirty,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$ExtraArtifactPaths = @()
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Force UTF-8 console IO so CP950/Big5 terminals never corrupt UTF-8 commit messages or paths
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

function Invoke-GitUtf8 {
    param(
        [Parameter(Mandatory = $true)][string]$RepoDir,
        [Parameter(Mandatory = $true)][string[]]$GitArgs
    )

    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = 'git'
    $escapedArgs = foreach ($a in $GitArgs) {
        if ($a -match '[\s"]') {
            '"' + ($a -replace '"', '\"') + '"'
        } else {
            $a
        }
    }
    $psi.Arguments = "-C `"$RepoDir`" " + ($escapedArgs -join ' ')
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.StandardOutputEncoding = [System.Text.Encoding]::UTF8
    $psi.StandardErrorEncoding = [System.Text.Encoding]::UTF8

    $proc = New-Object System.Diagnostics.Process
    $proc.StartInfo = $psi

    $errBuilder = New-Object System.Text.StringBuilder
    $errEvent = Register-ObjectEvent -InputObject $proc -EventName ErrorDataReceived -Action {
        if ($null -ne $EventArgs.Data) {
            [void]$Event.MessageData.AppendLine($EventArgs.Data)
        }
    } -MessageData $errBuilder

    try {
        [void]$proc.Start()
        $proc.BeginErrorReadLine()
        $stdout = $proc.StandardOutput.ReadToEnd()
        $proc.WaitForExit()
        return [PSCustomObject]@{
            ExitCode = $proc.ExitCode
            StdOut   = $stdout
            StdErr   = $errBuilder.ToString()
        }
    } finally {
        if ($null -ne $errEvent) {
            Unregister-Event -SourceIdentifier $errEvent.Name -ErrorAction SilentlyContinue
            Remove-Job -Id $errEvent.Id -Force -ErrorAction SilentlyContinue
        }
        $proc.Dispose()
    }
}

function Get-ArtifactKind {
    param([string]$Extension)
    $map = @{
        '.bit'   = 'fpga_bitstream'
        '.mcs'   = 'fpga_flash_image'
        '.pdi'   = 'fpga_versal_pdi'
        '.sof'   = 'fpga_sram_object'
        '.pof'   = 'fpga_prog_object'
        '.ltx'   = 'fpga_debug_probes'
        '.xsa'   = 'fpga_hw_platform'
        '.bin'   = 'binary_image'
        '.hex'   = 'firmware_hex'
        '.elf'   = 'firmware_elf'
        '.uf2'   = 'firmware_uf2'
        '.exe'   = 'software_executable'
        '.msi'   = 'software_installer'
        '.whl'   = 'python_wheel'
        '.zip'   = 'archive_bundle'
        '.7z'    = 'archive_bundle'
        '.gz'    = 'archive_bundle'
        '.dll'   = 'shared_library'
        '.so'    = 'shared_library'
        '.dylib' = 'shared_library'
    }
    $key = if ($null -eq $Extension) { '' } else { $Extension.ToLowerInvariant() }
    if ($map.ContainsKey($key)) { return $map[$key] }
    return 'other_artifact'
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Error 'git command not found in PATH.'
    exit 1
}

if (-not (Test-Path -LiteralPath $ProjectRoot -PathType Container)) {
    Write-Error "ProjectRoot not found: $ProjectRoot"
    exit 1
}

$resolvedRoot = (Resolve-Path -LiteralPath $ProjectRoot).Path
$callerCwd = (Get-Location).Path

if ([string]::IsNullOrWhiteSpace($ProjectName)) {
    $ProjectName = Split-Path -Leaf $resolvedRoot
}

$insideCheck = Invoke-GitUtf8 -RepoDir $resolvedRoot -GitArgs @('rev-parse', '--is-inside-work-tree')
if ($insideCheck.ExitCode -ne 0 -or $insideCheck.StdOut.Trim() -ne 'true') {
    Write-Error "ProjectRoot is not a valid Git working tree: $resolvedRoot"
    exit 1
}

# 1. Clean Worktree Release Gate
$statusRes = Invoke-GitUtf8 -RepoDir $resolvedRoot -GitArgs @('status', '--porcelain')
if ($statusRes.ExitCode -ne 0) {
    Write-Error "Failed to check git status: $($statusRes.StdErr)"
    exit 1
}

$isDirty = ($statusRes.StdOut.Trim().Length -gt 0)
if ($isDirty -and -not $AllowDirty) {
    Write-Host "[FAIL] Clean Worktree Release Gate blocked release '$Version'." -ForegroundColor Red
    Write-Host "       Uncommitted or untracked files exist (ensure 'releases/' and build artifacts are committed or gitignored), or pass -AllowDirty for draft testing:" -ForegroundColor Yellow
    Write-Host $statusRes.StdOut
    exit 2
}
if ($isDirty) {
    Write-Host "[WARN] Dirty worktree allowed via -AllowDirty; release marked is_dirty=true (NOT valid for GA)." -ForegroundColor Yellow
}

# 2. Collect and validate artifact paths (supports comma-separated string or multi-arg CLI tokens)
$collectedFiles = New-Object System.Collections.Generic.List[System.IO.FileInfo]
$seenFullPaths = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)

$expandedInputPaths = New-Object System.Collections.Generic.List[string]
foreach ($entry in (@($ArtifactPaths) + @($ExtraArtifactPaths))) {
    if ([string]::IsNullOrWhiteSpace($entry)) { continue }
    foreach ($part in ($entry -split ',')) {
        $trimmed = $part.Trim()
        if (-not [string]::IsNullOrWhiteSpace($trimmed)) {
            [void]$expandedInputPaths.Add($trimmed)
        }
    }
}

foreach ($rawPath in $expandedInputPaths) {
    $candidate = $rawPath
    if (-not [System.IO.Path]::IsPathRooted($candidate)) {
        $fromCwd = Join-Path $callerCwd $candidate
        $fromRoot = Join-Path $resolvedRoot $candidate
        if (Test-Path -LiteralPath $fromCwd -PathType Leaf) {
            $candidate = $fromCwd
        } elseif (Test-Path -LiteralPath $fromRoot -PathType Leaf) {
            $candidate = $fromRoot
        }
    }
    if (-not (Test-Path -LiteralPath $candidate -PathType Leaf)) {
        Write-Error "Artifact file not found: $rawPath"
        exit 3
    }
    $fi = Get-Item -LiteralPath (Resolve-Path -LiteralPath $candidate).Path
    if ($seenFullPaths.Add($fi.FullName)) {
        [void]$collectedFiles.Add($fi)
    }
}

if (-not [string]::IsNullOrWhiteSpace($ArtifactDir)) {
    $dirCandidate = $ArtifactDir
    if (-not [System.IO.Path]::IsPathRooted($dirCandidate)) {
        $fromCwd = Join-Path $callerCwd $dirCandidate
        $fromRoot = Join-Path $resolvedRoot $dirCandidate
        if (Test-Path -LiteralPath $fromCwd -PathType Container) {
            $dirCandidate = $fromCwd
        } elseif (Test-Path -LiteralPath $fromRoot -PathType Container) {
            $dirCandidate = $fromRoot
        }
    }
    if (-not (Test-Path -LiteralPath $dirCandidate -PathType Container)) {
        Write-Error "ArtifactDir not found: $ArtifactDir"
        exit 3
    }
    $skipNames = @('SHA256SUMS.txt', 'release-manifest.json', 'Release_Notes_DRAFT.md', 'Release_Notes.md')
    foreach ($fi in (Get-ChildItem -LiteralPath $dirCandidate -File | Sort-Object Name)) {
        if ($skipNames -contains $fi.Name) { continue }
        if ($seenFullPaths.Add($fi.FullName)) {
            [void]$collectedFiles.Add($fi)
        }
    }
}

if ($collectedFiles.Count -eq 0) {
    Write-Error 'No artifact files provided. Specify -ArtifactPaths and/or -ArtifactDir.'
    exit 3
}

$seenNames = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
foreach ($fi in $collectedFiles) {
    if (-not $seenNames.Add($fi.Name)) {
        Write-Error "Duplicate artifact filename detected in bundle: $($fi.Name)"
        exit 3
    }
}

# 3. Resolve output bundle path & verify .gitignore coverage
$safeProject = $ProjectName -replace '[^\w\.\-\+]', '_'
$safeVersion = $Version -replace '[^\w\.\-\+]', '_'
if ([string]::IsNullOrWhiteSpace($OutDir)) {
    $OutDir = Join-Path (Join-Path $resolvedRoot 'releases') "${safeProject}_${safeVersion}"
} elseif (-not [System.IO.Path]::IsPathRooted($OutDir)) {
    $OutDir = Join-Path $callerCwd $OutDir
}

if (-not (Test-Path -LiteralPath $OutDir)) {
    [void](New-Item -ItemType Directory -Path $OutDir -Force)
}
$resolvedOutDir = (Resolve-Path -LiteralPath $OutDir).Path

$ignoreCheck = Invoke-GitUtf8 -RepoDir $resolvedRoot -GitArgs @('check-ignore', '-q', $resolvedOutDir)
if ($ignoreCheck.ExitCode -ne 0) {
    Write-Host "[WARN] Output bundle folder '$resolvedOutDir' is NOT ignored by .gitignore. Add 'releases/' to .gitignore before committing Git tracking files." -ForegroundColor Yellow
}

# 4. Gather Git metadata & commits since previous tag
$commitSha = (Invoke-GitUtf8 -RepoDir $resolvedRoot -GitArgs @('rev-parse', 'HEAD')).StdOut.Trim()
$shortSha  = (Invoke-GitUtf8 -RepoDir $resolvedRoot -GitArgs @('rev-parse', '--short', 'HEAD')).StdOut.Trim()
$branch    = (Invoke-GitUtf8 -RepoDir $resolvedRoot -GitArgs @('rev-parse', '--abbrev-ref', 'HEAD')).StdOut.Trim()

if ([string]::IsNullOrWhiteSpace($SinceTag)) {
    $descRes = Invoke-GitUtf8 -RepoDir $resolvedRoot -GitArgs @('describe', '--tags', '--abbrev=0', 'HEAD')
    if ($descRes.ExitCode -eq 0) {
        $SinceTag = $descRes.StdOut.Trim()
    }
}

$logArgs = @('-c', 'i18n.logOutputEncoding=utf-8', 'log')
if (-not [string]::IsNullOrWhiteSpace($SinceTag)) {
    $logArgs += "$SinceTag..HEAD"
    $logArgs += '--pretty=format:%h|%ad|%an|%s'
    $logArgs += '--date=short'
    $logArgs += '-n'
    $logArgs += '200'
} else {
    $logArgs += '--pretty=format:%h|%ad|%an|%s'
    $logArgs += '--date=short'
    $logArgs += '-n'
    $logArgs += '50'
}

$logRes = Invoke-GitUtf8 -RepoDir $resolvedRoot -GitArgs $logArgs
$commitLines = @()
if ($logRes.ExitCode -eq 0 -and -not [string]::IsNullOrWhiteSpace($logRes.StdOut)) {
    $commitLines = @($logRes.StdOut -split "`r?`n" | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
}

# 5. Copy artifacts and compute SHA-256
$manifestArtifacts = New-Object System.Collections.Generic.List[object]
$checksumLines = New-Object System.Collections.Generic.List[string]
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)

foreach ($fi in $collectedFiles) {
    $destPath = Join-Path $resolvedOutDir $fi.Name
    if ($fi.FullName -ne $destPath) {
        Copy-Item -LiteralPath $fi.FullName -Destination $destPath -Force
    }
    $hash = (Get-FileHash -LiteralPath $destPath -Algorithm SHA256).Hash.ToLowerInvariant()
    $kind = Get-ArtifactKind -Extension $fi.Extension
    [void]$checksumLines.Add("$hash  $($fi.Name)")
    [void]$manifestArtifacts.Add([ordered]@{
        filename   = $fi.Name
        kind       = $kind
        size_bytes = [int64]$fi.Length
        sha256     = $hash
    })
}

$shaFile = Join-Path $resolvedOutDir 'SHA256SUMS.txt'
[System.IO.File]::WriteAllText($shaFile, (($checksumLines -join "`n") + "`n"), $utf8NoBom)

# 6. Build release-manifest.json
$stage = if ($isDirty) { 'draft-dirty' } elseif ($Version -match '-rc|-alpha|-beta') { 'pre-release' } else { 'release-candidate-pending-review' }
$releasedAt = Get-Date -Format 'yyyy-MM-ddTHH:mm:ssK'

$manifestObj = [ordered]@{
    schema_version = '1.0'
    project        = $ProjectName
    release_tag    = $Version
    release_stage  = $stage
    released_at    = $releasedAt
    git            = [ordered]@{
        branch       = $branch
        commit_sha   = $commitSha
        short_sha    = $shortSha
        is_dirty     = $isDirty
        previous_tag = if ([string]::IsNullOrWhiteSpace($SinceTag)) { $null } else { $SinceTag }
    }
    compatibility  = [ordered]@{
        software_version = if ([string]::IsNullOrWhiteSpace($SwVersion)) { 'TBD' } else { $SwVersion }
        firmware_version = if ([string]::IsNullOrWhiteSpace($FwVersion)) { 'TBD' } else { $FwVersion }
        rtl_hw_ver       = if ([string]::IsNullOrWhiteSpace($RtlVersion)) { 'TBD' } else { $RtlVersion }
    }
    artifacts      = @($manifestArtifacts.ToArray())
}

$manifestPath = Join-Path $resolvedOutDir 'release-manifest.json'
$manifestJson = ($manifestObj | ConvertTo-Json -Depth 6) + "`n"
[System.IO.File]::WriteAllText($manifestPath, $manifestJson, $utf8NoBom)

# 7. Generate Release_Notes_DRAFT.md
$draftLines = New-Object System.Collections.Generic.List[string]
[void]$draftLines.Add("# Release Notes DRAFT — $ProjectName $Version")
[void]$draftLines.Add('')
[void]$draftLines.Add("- **Generated At**: ``$releasedAt``")
[void]$draftLines.Add("- **Git Baseline**: ``$shortSha`` (branch: ``$branch``, full SHA: ``$commitSha``)")
[void]$draftLines.Add("- **Dirty Worktree**: ``$isDirty``")
[void]$draftLines.Add("- **Previous Tag**: ``$(if ([string]::IsNullOrWhiteSpace($SinceTag)) { 'N/A (Initial)' } else { $SinceTag })``")
[void]$draftLines.Add('')
[void]$draftLines.Add('## 1. SW / FW / RTL Compatibility')
[void]$draftLines.Add("| Layer | Version / Register | Notes |")
[void]$draftLines.Add('|---|---|---|')
[void]$draftLines.Add("| Software | ``$($manifestObj.compatibility.software_version)`` | Verify embedded version string |")
[void]$draftLines.Add("| Firmware | ``$($manifestObj.compatibility.firmware_version)`` | Verify protocol match |")
[void]$draftLines.Add("| RTL / FPGA | ``$($manifestObj.compatibility.rtl_hw_ver)`` | Verify STA WNS>=0, TNS=0 & HW_VER register |")
[void]$draftLines.Add('')
[void]$draftLines.Add('## 2. Packaged Artifacts & SHA-256 Checksums')
[void]$draftLines.Add('| Filename | Kind | Size (Bytes) | SHA-256 |')
[void]$draftLines.Add('|---|---|---:|---|')
foreach ($art in $manifestArtifacts) {
    [void]$draftLines.Add("| ``$($art.filename)`` | ``$($art.kind)`` | $($art.size_bytes) | ``$($art.sha256)`` |")
}
[void]$draftLines.Add('')
[void]$draftLines.Add('## 3. Git Commits Included Since Previous Tag')
if ($commitLines.Count -eq 0) {
    [void]$draftLines.Add('- *(No new commits since previous tag)*')
} else {
    foreach ($cl in $commitLines) {
        $parts = $cl -split '\|', 4
        if ($parts.Count -eq 4) {
            [void]$draftLines.Add("- ``$($parts[0])`` ($($parts[1]), $($parts[2])): $($parts[3])")
        } else {
            [void]$draftLines.Add("- $cl")
        }
    }
}
[void]$draftLines.Add('')
[void]$draftLines.Add('## 4. Verification & Rollback Checklist (Complete Before Finalizing)')
[void]$draftLines.Add('- [ ] Confirm Software build/unit tests (`PASS` / `NOT RUN`)')
[void]$draftLines.Add('- [ ] Confirm RTL STA (`WNS >= 0`, `TNS == 0`) & hardware board test (`PASS` / `NOT RUN` / `BLOCKED`)')
[void]$draftLines.Add('- [ ] Append summary to `Change_Log.md` (APPEND ONLY) and copy polished notes to `docs/releases/`')
[void]$draftLines.Add("- [ ] Create annotated tag: ``git tag -a $Version -m `"Release $Version`"``")

$draftPath = Join-Path $resolvedOutDir 'Release_Notes_DRAFT.md'
[System.IO.File]::WriteAllText($draftPath, (($draftLines -join "`n") + "`n"), $utf8NoBom)

Write-Host "[PASS] Release bundle created -> $resolvedOutDir" -ForegroundColor Green
Write-Host "       Artifacts packaged : $($manifestArtifacts.Count)"
Write-Host "       SHA-256 checksums  : $shaFile"
Write-Host "       Release manifest   : $manifestPath"
Write-Host "       Notes draft        : $draftPath"
exit 0
