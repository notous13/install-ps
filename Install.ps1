Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
Write-Host "Execution policy for this session set to Bypass." -ForegroundColor Yellow

Write-Host "Checking for Chocolatey installation..." -ForegroundColor Green
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "Chocolatey not found. Installing Chocolatey..." -ForegroundColor Cyan
    try {
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Host "Chocolatey installed successfully." -ForegroundColor Green

        Write-Host "Waiting a few seconds for Chocolatey to initialize..." -ForegroundColor Yellow
        Start-Sleep -Seconds 5

        if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
            Write-Host "Chocolatey command still not found after installation. Please restart PowerShell and try again, or manually verify installation." -ForegroundColor Red
            exit 1
        }
    }
    catch {
        Write-Host "Error installing Chocolatey: $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "Chocolatey is already installed." -ForegroundColor Green
}

Write-Host "Starting common application installation..." -ForegroundColor Green

$applicationsToInstall = @(
    "googlechrome",
    "firefox",
    "vlc",
    "7zip",
    "vscode",
    "notepadplusplus",
    "googleearth-pro",
    "foxitreader",
    "omnissa-horizon-client",
    "thunderbird",
    "dwgtrueview",
    "designreview",
    "discord.install",
    "snipaste"
    #"wps-office-free"
)

foreach ($app in $applicationsToInstall) {
    Write-Host "Installing ${app}..." -ForegroundColor Cyan
    try {
        choco install ${app} --force -y --no-progress --ignore-checksums
        if ($LASTEXITCODE -eq 0) {
            Write-Host "${app} installed successfully." -ForegroundColor Green
        } else {
            Write-Host "Warning: ${app} installation might have failed or completed with issues (Exit Code: $LASTEXITCODE)." -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "Error installing ${app}: $($_.Exception.Message)" -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "--- Installation attempts complete. ---" -ForegroundColor Green
Write-Host "You may need to restart your computer for some changes to take effect." -ForegroundColor Yellow
