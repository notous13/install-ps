Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
Write-Host "Execution policy for this session set to Bypass." -ForegroundColor Yellow

Write-Host "Checking for Chocolatey installation..." -ForegroundColor Green
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Chocolatey not found. Installing Chocolatey..." -ForegroundColor Cyan
    try {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Host "Chocolatey installed successfully." -ForegroundColor Green
        Start-Sleep -Seconds 5
    }
    catch {
        Write-Host "Error installing Chocolatey: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Chocolatey is already installed." -ForegroundColor Green
}

# List of applications
$applicationsToInstall = @(
    "GoogleChrome",
    "Firefox",
    "vlc",
    "7zip",
    "vscode",
    "notepadplusplus",
    "googleearth-pro",
    "foxitreader",
    "omnissa-horizon-client",
    "thunderbird",
    #"dwgtrueview",
    "designreview",
    "discord.install",
    "snipaste"
)

# --- Prompt for install mode ---
Write-Host ""
Write-Host "Choose installation mode:" -ForegroundColor Cyan
Write-Host "1. Full installation (all apps)" -ForegroundColor Yellow
Write-Host "2. Select apps by number (comma separated)" -ForegroundColor Yellow

$choice = Read-Host "Enter 1 or 2"
$selectedApps = @()
$cachePath = "Z:\Auto_install\choco\install-ps\cache"

if ($choice -eq "1") {
    $selectedApps = $applicationsToInstall
} elseif ($choice -eq "2") {
    Write-Host "`nAvailable applications:" -ForegroundColor Cyan
    for ($i = 0; $i -lt $applicationsToInstall.Count; $i++) {
        Write-Host ("{0}. {1}" -f ($i + 1), $applicationsToInstall[$i]) -ForegroundColor Yellow
    }

    $inputNumbers = Read-Host "Enter the numbers of apps to install (comma separated, e.g. 1,3,5)"
    if ($inputNumbers) {
        $indices = $inputNumbers -split "," | ForEach-Object { ($_ -as [int]) - 1 }
        foreach ($i in $indices) {
            if ($i -ge 0 -and $i -lt $applicationsToInstall.Count) {
                $selectedApps += $applicationsToInstall[$i].Trim()
            }
        }
    }

    if (-not $selectedApps -or $selectedApps.Count -eq 0) {
        Write-Host "No applications selected. Exiting." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Invalid choice. Exiting." -ForegroundColor Red
    exit 1
}

# --- Install loop ---
foreach ($app in $selectedApps) {
    $installed = choco list --local-only --exact $app | Select-String "^$app"
    if ($installed) {
        Write-Host "$app already installed, skipping." -ForegroundColor Yellow
        continue
    }

    Write-Host "Installing $app..." -ForegroundColor Cyan
    try {
        choco install $app -y --source $cachePath --no-progress --ignore-checksums
        if ($LASTEXITCODE -eq 0) {
            Write-Host "$app installed successfully." -ForegroundColor Green
        } else {
            Write-Host "Warning: $app may have failed (Exit Code: $LASTEXITCODE)." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host ("Error installing {0}: {1}" -f $app, $_.Exception.Message) -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "--- Installation complete ---" -ForegroundColor Green
