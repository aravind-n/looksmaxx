# From a local clone: .\install.ps1 [-Destination DIRECTORY] [-NoLink]
# Or: irm https://raw.githubusercontent.com/aravind-n/looksmaxx/main/install.ps1 | iex
param(
    [string]$Destination = (Join-Path $HOME '.agents/skills/looksmaxx'),
    [switch]$NoLink
)

$ErrorActionPreference = 'Stop'
$Name = 'looksmaxx'
$Source = $null
$InstallerPath = $MyInvocation.MyCommand.Path
if ($InstallerPath -and (Test-Path -LiteralPath $InstallerPath -PathType Leaf)) {
    $CandidateSource = Split-Path -Parent $InstallerPath
    if (Test-Path -LiteralPath (Join-Path $CandidateSource 'runtime-files.txt') -PathType Leaf) {
        $Source = $CandidateSource
    }
}

if ([string]::IsNullOrWhiteSpace($Destination)) { throw 'Destination must name a skill directory.' }
$Dest = [IO.Path]::GetFullPath($Destination).TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
$Root = [IO.Path]::GetPathRoot([IO.Path]::GetFullPath($Destination)).TrimEnd([IO.Path]::DirectorySeparatorChar, [IO.Path]::AltDirectorySeparatorChar)
if ($Dest -eq $Root) { throw 'Destination must name a skill directory.' }

function Assert-InstallDestination {
    $Existing = Get-Item -LiteralPath $Dest -Force -ErrorAction SilentlyContinue
    if ($Existing -and ($Existing.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
        throw "Destination is a link; leaving it unchanged: $Dest"
    }
    if ($Existing -and -not $Existing.PSIsContainer) { throw "Destination is not a directory: $Dest" }
}

Assert-InstallDestination
$Parent = Split-Path -Parent $Dest
$Leaf = Split-Path -Leaf $Dest
New-Item -ItemType Directory -Force -Path $Parent | Out-Null
$Stage = Join-Path $Parent ('.looksmaxx-stage-' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $Stage | Out-Null
$Bundle = Join-Path $Stage 'bundle'
$Backup = $null
$BackupRoot = $null
try {
    New-Item -ItemType Directory -Path $Bundle | Out-Null
    $Manifest = Join-Path $Stage 'runtime-files.txt'
    if ($Source) {
        Copy-Item -LiteralPath (Join-Path $Source 'runtime-files.txt') -Destination $Manifest
    } else {
        # Pin all downloads to one immutable tree, even if main advances.
        $RevisionFile = Join-Path $Stage 'revision.txt'
        Invoke-WebRequest -UseBasicParsing -Uri "https://api.github.com/repos/aravind-n/$Name/commits/main" -Headers @{ Accept = 'application/vnd.github.sha' } -OutFile $RevisionFile
        $Revision = [IO.File]::ReadAllText($RevisionFile).TrimEnd([char[]]"`r`n")
        if ($Revision -cnotmatch '\A[0-9a-fA-F]{40}\z') { throw 'GitHub returned an invalid commit SHA.' }
        $BaseUrl = "https://raw.githubusercontent.com/aravind-n/$Name/$Revision"
        Invoke-WebRequest -UseBasicParsing -Uri "$BaseUrl/runtime-files.txt" -OutFile $Manifest
    }

    # Validate every manifest path before copying or downloading runtime files.
    $Files = @()
    foreach ($File in (Get-Content -LiteralPath $Manifest -Encoding UTF8)) {
        if ($File -eq '') { continue }
        if ($File -notmatch '^[A-Za-z0-9._/-]+$' -or $File.StartsWith('/') -or
            $File.EndsWith('/') -or $File.Contains('//') -or
            (@($File.Split('/') | Where-Object { $_ -eq '.' -or $_ -eq '..' }).Count -gt 0)) {
            throw "Invalid runtime path: $File"
        }
        if ($Files -contains $File) { throw "Duplicate runtime path: $File" }
        $Files += $File
    }
    if ($Files -cnotcontains 'SKILL.md') { throw 'Runtime manifest must include SKILL.md.' }

    foreach ($File in $Files) {
        $Target = Join-Path $Bundle $File
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $Target) | Out-Null
        if ($Source) {
            $LocalFile = Join-Path $Source $File
            $Item = Get-Item -LiteralPath $LocalFile -Force -ErrorAction SilentlyContinue
            if (-not $Item -or $Item.PSIsContainer -or ($Item.Attributes -band [IO.FileAttributes]::ReparsePoint)) {
                throw "Missing regular runtime file: $File"
            }
            Copy-Item -LiteralPath $LocalFile -Destination $Target
        } else {
            Invoke-WebRequest -UseBasicParsing -Uri "$BaseUrl/$File" -OutFile $Target
        }
    }

    # All acquisition has succeeded. Never replace a link or unrelated file.
    Assert-InstallDestination
    if (Test-Path -LiteralPath $Dest -PathType Container) {
        $BackupRoot = Join-Path $Parent ('.looksmaxx-backup-' + [Guid]::NewGuid().ToString('N'))
        New-Item -ItemType Directory -Path $BackupRoot | Out-Null
        $Backup = Join-Path $BackupRoot $Leaf
        Move-Item -LiteralPath $Dest -Destination $Backup
        Write-Host "backup: $Backup"
    }
    Move-Item -LiteralPath $Bundle -Destination $Dest
    Write-Host "installed $Dest"
} finally {
    try {
        # Restore even when an exception happens after the backup move and
        # before publication. Forced termination/power loss cannot run finally.
        if ($Backup -and (Test-Path -LiteralPath $Backup -PathType Container) -and
            -not (Get-Item -LiteralPath $Dest -Force -ErrorAction SilentlyContinue)) {
            Move-Item -LiteralPath $Backup -Destination $Dest
            Write-Host "restored previous installation: $Dest"
        }
        if ($BackupRoot -and (Test-Path -LiteralPath $BackupRoot) -and
            @(Get-ChildItem -LiteralPath $BackupRoot -Force).Count -eq 0) {
            Remove-Item -LiteralPath $BackupRoot
        }
    } finally {
        # Only the unique staging directory created above is removed recursively.
        if (Test-Path -LiteralPath $Stage) { Remove-Item -LiteralPath $Stage -Recurse -Force }
    }
}

if (-not $NoLink -and (Test-Path -LiteralPath (Join-Path $HOME '.claude') -PathType Container)) {
    $Skills = Join-Path $HOME '.claude/skills'
    $Link = Join-Path $Skills $Name
    try {
        New-Item -ItemType Directory -Force -Path $Skills | Out-Null
        # A unique probe also recognizes a shared parent-directory junction.
        $ProbeName = '.looksmaxx-probe-' + [Guid]::NewGuid().ToString('N')
        $Probe = Join-Path $Dest $ProbeName
        try {
            New-Item -ItemType File -Path $Probe | Out-Null
            $Same = Test-Path -LiteralPath (Join-Path $Link $ProbeName)
        } finally {
            if (Test-Path -LiteralPath $Probe) { Remove-Item -LiteralPath $Probe }
        }
        if ($Same) {
            Write-Host "already linked $Link"
        } elseif (Get-Item -LiteralPath $Link -Force -ErrorAction SilentlyContinue) {
            Write-Host "skipped occupied Claude compatibility path: $Link"
        } else {
            # Junctions do not require administrator rights on Windows.
            $LinkType = if ([Environment]::OSVersion.Platform -eq [PlatformID]::Win32NT) { 'Junction' } else { 'SymbolicLink' }
            New-Item -ItemType $LinkType -Path $Link -Target $Dest | Out-Null
            Write-Host "linked $Link -> $Dest"
        }
    } catch {
        Write-Warning "Skipped Claude compatibility link at ${Link}: $_"
    }
}
