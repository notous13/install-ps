# --- Prompt for install mode ---
Write-Host ""
Write-Host "Choose installation mode:" -ForegroundColor Cyan
Write-Host "1. Full installation (all apps)" -ForegroundColor Yellow
Write-Host "2. Select apps by number (comma separated)" -ForegroundColor Yellow

$choice = Read-Host "Enter 1 or 2"

$selectedApps = @()

if ($choice -eq "1") {
    $selectedApps = $applicationsToInstall
} elseif ($choice -eq "2") {
    Write-Host "`nAvailable applications:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $applicationsToInstall.Count; $i++) {
        $num = $i + 1
        Write-Host ("{0}. {1}" -f $num, $applicationsToInstall[$i]) -ForegroundColor Yellow
    }

    $selection = Read-Host "Enter the numbers of apps to install (comma separated, e.g. 1,3,5)"
    $indices = $selection -split "," | ForEach-Object { ($_ -as [int]) - 1 }

    foreach ($i in $indices) {
        if ($i -ge 0 -and $i -lt $applicationsToInstall.Count) {
            $selectedApps += $applicationsToInstall[$i]
        }
    }
} else {
    Write-Host "Invalid choice. Exiting." -ForegroundColor Red
    exit 1
}

if ($selectedApps.Count -eq 0) {
    Write-Host "No applications selected. Exiting." -ForegroundColor Red
    exit 1
}

Write-Host "`nYou selected:" -ForegroundColor Green
$selectedApps | ForEach-Object { Write-Host " - $_" -ForegroundColor Yellow }
