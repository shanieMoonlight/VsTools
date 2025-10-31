# publish-local.ps1

# Navigate to project directory
Set-Location -Path 'C:\Users\Shaneyboy\source\repos\VsTools\Apps\AppSettings\StronglyTypedAppSettings'

# Ensure output directory exists for local feed
$localNugetPath = "C:\LocalNuget"
if (-not (Test-Path -Path $localNugetPath)) {
    New-Item -ItemType Directory -Path $localNugetPath | Out-Null
    Write-Host "Created directory: $localNugetPath" -ForegroundColor Green
}

# Pack output folder (deterministic)
$packOut = Join-Path -Path (Get-Location) -ChildPath "nupkgs"
if (-not (Test-Path -Path $packOut)) {
    New-Item -ItemType Directory -Path $packOut | Out-Null
}

# Pack the project
Write-Host "Packing project to $packOut..." -ForegroundColor Cyan
dotnet pack -c Release -o $packOut
if ($LASTEXITCODE -ne 0) {
    Write-Host "dotnet pack failed" -ForegroundColor Red
    exit 1
}

# Find the newest package file
$package = Get-ChildItem -Path $packOut -Filter "*.nupkg" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $package) {
    Write-Host "No packages found in $packOut" -ForegroundColor Red
    exit 1
}

# Push to local NuGet feed
Write-Host "Pushing $($package.Name) to local NuGet feed $localNugetPath..." -ForegroundColor Cyan
# Use --skip-duplicate to avoid errors if same version already exists
dotnet nuget push $package.FullName -s $localNugetPath --skip-duplicate
if ($LASTEXITCODE -ne 0) {
    Write-Host "dotnet nuget push failed" -ForegroundColor Red
    exit 1
}

# Delete the package file from the project output directory after successful push
try {
    Remove-Item $package.FullName -Force -ErrorAction Stop
    Write-Host "Local package file deleted: $($package.Name)" -ForegroundColor Yellow
} catch {
    Write-Host "Warning: could not delete package file: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host "Package published successfully to local feed!" -ForegroundColor Green