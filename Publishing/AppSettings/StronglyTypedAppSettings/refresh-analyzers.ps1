<#
refresh-analyzers.ps1

Helper script to clear NuGet caches, remove VS generated temp sources and optionally restart Visual Studio.

Usage examples:
 # Clear caches and temp files only
 .\refresh-analyzers.ps1

 # Clear and restart Visual Studio (requires providing devenv.exe path or will try to restart the same instance if possible)
 .\refresh-analyzers.ps1 -RestartVs -VsExePath 'C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe'

#>
param(
 [switch]$ClearNuGet = $true,
 [switch]$ClearTempGenerated = $true,
 [switch]$RestartVs = $false,
 [string]$VsExePath = ""
)

function Run-Command($cmd) {
 Write-Host "> $cmd" -ForegroundColor Cyan
 $proc = Start-Process -FilePath powershell -ArgumentList "-NoProfile -Command $cmd" -NoNewWindow -PassThru -Wait
 return $proc.ExitCode
}

Write-Host "=== Refresh Analyzers Helper ===" -ForegroundColor Green

if ($ClearNuGet) {
 Write-Host "Clearing NuGet local caches..." -ForegroundColor Yellow
 # Use dotnet to clear all nuget locals
 $exit = Run-Command "dotnet nuget locals all --clear"
 if ($exit -eq0) { Write-Host "NuGet caches cleared." -ForegroundColor Green } else { Write-Host "dotnet nuget locals returned exit code $exit" -ForegroundColor Red }
}

if ($ClearTempGenerated) {
 $vsGenPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Temp\VSGeneratedDocuments"
 if (Test-Path $vsGenPath) {
 Write-Host "Removing VSGeneratedDocuments at: $vsGenPath" -ForegroundColor Yellow
 try {
 Get-ChildItem -Path $vsGenPath -Force -ErrorAction Stop | Remove-Item -Recurse -Force -ErrorAction Stop
 Write-Host "Removed VSGeneratedDocuments contents." -ForegroundColor Green
 } catch {
 Write-Host "Warning: could not remove some files under $vsGenPath: $($_.Exception.Message)" -ForegroundColor Yellow
 }
 } else {
 Write-Host "No VSGeneratedDocuments folder found at $vsGenPath" -ForegroundColor Gray
 }
}

if ($RestartVs) {
 Write-Host "Restarting Visual Studio instances..." -ForegroundColor Yellow
 # Find running devenv processes
 $devenv = Get-Process -Name devenv -ErrorAction SilentlyContinue
 if (-not $devenv) {
 Write-Host "No running Visual Studio (devenv.exe) processes found." -ForegroundColor Gray
 if (-not [string]::IsNullOrWhiteSpace($VsExePath)) {
 Write-Host "Starting Visual Studio from provided path: $VsExePath" -ForegroundColor Cyan
 try { Start-Process -FilePath $VsExePath; Write-Host "Visual Studio started." -ForegroundColor Green } catch { Write-Host "Failed to start Visual Studio: $($_.Exception.Message)" -ForegroundColor Red }
 } else {
 Write-Host "Provide -VsExePath to start Visual Studio after clearing caches." -ForegroundColor Gray
 }
 } else {
 # capture first executable path if possible
 $exePath = $null
 foreach ($p in $devenv) {
 try {
 if (-not $exePath) {
 $exePath = $p.Path
 }
 } catch {
 # ignore - may not have Path in some environments
 }
 Write-Host "Stopping Visual Studio process Id=$($p.Id)" -ForegroundColor Cyan
 try { Stop-Process -Id $p.Id -Force -ErrorAction Stop; Write-Host "Stopped PID $($p.Id)" -ForegroundColor Green } catch { Write-Host "Failed to stop PID $($p.Id): $($_.Exception.Message)" -ForegroundColor Red }
 }

 # Start Visual Studio again
 $startPath = $VsExePath
 if ([string]::IsNullOrWhiteSpace($startPath) -and $exePath) { $startPath = $exePath }

 if (-not [string]::IsNullOrWhiteSpace($startPath)) {
 Write-Host "Starting Visual Studio from: $startPath" -ForegroundColor Cyan
 try { Start-Process -FilePath $startPath; Write-Host "Visual Studio restarted." -ForegroundColor Green } catch { Write-Host "Failed to start Visual Studio: $($_.Exception.Message)" -ForegroundColor Red }
 } else {
 Write-Host "Could not determine path to devenv.exe. Provide -VsExePath to start Visual Studio." -ForegroundColor Yellow
 }
 }
}

Write-Host "Done." -ForegroundColor Green
