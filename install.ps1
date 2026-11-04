# Install the design-language skill into ~\.agents\skills (Codex and other agents)
# and link it into ~\.claude\skills (Claude Code).
#   irm https://raw.githubusercontent.com/aravind-n/design-language/main/install.ps1 | iex
$ErrorActionPreference = 'Stop'
$Name = 'design-language'
$Url  = "https://raw.githubusercontent.com/aravind-n/$Name/main/SKILL.md"
$Dest = Join-Path $HOME ".agents\skills\$Name"

New-Item -ItemType Directory -Force -Path $Dest | Out-Null
Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile (Join-Path $Dest 'SKILL.md')
Write-Host "installed $Dest"

$Skills = Join-Path $HOME '.claude\skills'
if (Test-Path (Join-Path $HOME '.claude')) {
  $Link = Join-Path $Skills $Name
  New-Item -ItemType Directory -Force -Path $Skills | Out-Null
  # Skip when the link already leads to the copy above: a probe file made there shows up here.
  $Probe = ".probe-$PID"
  New-Item -ItemType File -Path (Join-Path $Dest $Probe) | Out-Null
  $Same = Test-Path (Join-Path $Link $Probe)
  Remove-Item (Join-Path $Dest $Probe)
  if ($Same) {
    Write-Host "already linked $Link"
  } else {
    $Item = Get-Item $Link -Force -ErrorAction SilentlyContinue
    if ($Item) {
      # Delete a link itself, never what it points to.
      if ($Item.Attributes -band [IO.FileAttributes]::ReparsePoint) { $Item.Delete() } else { Remove-Item $Link -Recurse -Force }
    }
    # A junction needs no admin rights, unlike a symlink.
    New-Item -ItemType Junction -Path $Link -Target $Dest | Out-Null
    Write-Host "linked $Link -> $Dest"
  }
}
