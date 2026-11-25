# Installa il Rapporto di Sopralluogo Artesia su questo PC
$ErrorActionPreference = 'Stop'
$src = Split-Path -Parent $MyInvocation.MyCommand.Path
$dst = Join-Path $env:LOCALAPPDATA 'RapportoSopralluogo'
New-Item -ItemType Directory -Force -Path $dst | Out-Null
Get-ChildItem -Path $src -File | Where-Object { $_.Name -notin @('Installa_su_PC.cmd', 'installa.ps1') } | Copy-Item -Destination $dst -Force

$browser = $null
foreach ($n in @('msedge.exe', 'chrome.exe')) {
  foreach ($root in @('HKCU', 'HKLM')) {
    $k = "Registry::$root\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\$n"
    try { $p = (Get-ItemProperty -Path $k -ErrorAction Stop).'(default)'; if ($p -and (Test-Path $p)) { $browser = $p; break } } catch {}
  }
  if ($browser) { break }
}
if (-not $browser) {
  foreach ($p in @("${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe", "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe")) { if (Test-Path $p) { $browser = $p; break } }
}
if (-not $browser) { Write-Host 'Non trovo Microsoft Edge o Google Chrome: installane uno e riprova.' -ForegroundColor Red; exit 1 }

$url = ([Uri](Join-Path $dst 'index.html')).AbsoluteUri
$ws = New-Object -ComObject WScript.Shell
$dirs = @([Environment]::GetFolderPath('Desktop'), [Environment]::GetFolderPath('Programs'))
foreach ($dir in $dirs) {
  $lnk = $ws.CreateShortcut((Join-Path $dir 'Rapporto di Sopralluogo.lnk'))
  $lnk.TargetPath = $browser
  $lnk.Arguments = "--app=`"$url`""
  $lnk.IconLocation = (Join-Path $dst 'icona.ico') + ',0'
  $lnk.WorkingDirectory = $dst
  $lnk.Description = 'Rapporto di Sopralluogo Artesia'
  $lnk.Save()
}
Write-Host ''
Write-Host 'Installazione completata.' -ForegroundColor Green
Write-Host 'Trovi "Rapporto di Sopralluogo" sul Desktop e nel menu Start.'
Write-Host ''
