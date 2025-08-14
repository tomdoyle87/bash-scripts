# ==============================
# UpdateChromium.ps1
# Gracefully updates Chromium, clears crash markers, opens 3 tabs. 
# Generated using chatgpt and google gemini
# ==============================

# -----------------------------
# Settings
# -----------------------------
$installerPath   = "$env:TEMP\mini_installer.exe"
$chromiumExePath = "$env:LOCALAPPDATA\Chromium\Application\chrome.exe"
$chromeProfile   = "$env:LOCALAPPDATA\Chromium\User Data\Default"
$restoreFiles    = @("Last Session", "Last Tabs")
$maxRetries      = 3
$retryDelay      = 5  # seconds

# Set the security protocol for all web requests to TLS 1.2
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

# URLs to open on launch (customize)
$startupUrls = @(
    "https://example.com",
    "https://example.net",
    "https://example.org"
)

# -----------------------------
# 1. Close Chromium gracefully
# -----------------------------
$chromeProcs = Get-Process chrome -ErrorAction SilentlyContinue
if ($chromeProcs) {
    Write-Host "Closing Chromium forcefully..."
    Stop-Process -Name "chrome" -Force -ErrorAction SilentlyContinue
}

# -----------------------------
# 2. Fetch latest Chromium revision
# -----------------------------
try {
    $latestRevisionUrl = "https://storage.googleapis.com/chromium-browser-snapshots/Win_x64/LAST_CHANGE"
    
    # Use Invoke-WebRequest and access the Content property directly
    $response = Invoke-WebRequest -Uri $latestRevisionUrl -UseBasicParsing
    $latestRevision = $response.Content.Trim() # .Trim() to remove any whitespace

    $chromiumUrl = "https://commondatastorage.googleapis.com/chromium-browser-snapshots/Win_x64/$latestRevision/mini_installer.exe"
    Write-Host "Latest Chromium revision: $latestRevision"
    Write-Host "Download URL: $chromiumUrl"
}
catch {
    Write-Host "ERROR: Could not fetch latest revision - $_"
    exit 1
}

# -----------------------------
# 3. Download Chromium installer with retry
# -----------------------------
function Download-WithRetry {
    param (
        [string]$Url,
        [string]$Destination,
        [int]$Retries,
        [int]$Delay
    )
    for ($i = 1; $i -le $Retries; $i++) {
        try {
            Write-Host "Attempt ${i} of ${Retries}: Downloading Chromium..."
            
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFile($Url, $Destination)
            
            if (Test-Path $Destination) {
                Write-Host "Download successful."
                return $true
            }
        }
        catch {
            Write-Host ("Download failed: " + $_.Exception.Message)
        }
        
        if ($i -lt $Retries) {
            Write-Host ("Retrying in " + $Delay + " seconds...")
            Start-Sleep -Seconds $Delay
        }
    }
    return $false
}

# Run the download function
if (-not (Download-WithRetry -Url $chromiumUrl -Destination $installerPath -Retries $maxRetries -Delay $retryDelay)) {
    Write-Host "ERROR: Failed to download Chromium after $maxRetries attempts."
    exit 1
}

# -----------------------------
# 4. Install Chromium silently
# -----------------------------
try {
    Write-Host "Installing Chromium..."
    Start-Process -FilePath $installerPath -ArgumentList "/silent" -Wait -ErrorAction Stop
}
catch {
    Write-Host ("ERROR: Installation failed - " + $_.Exception.Message)
    exit 1
}

# -----------------------------
# 5. Delete installer
# -----------------------------
try {
    Write-Host "Deleting installer..."
    Remove-Item $installerPath -Force -ErrorAction Stop
}
catch {
    Write-Host ("WARNING: Failed to delete installer - " + $_.Exception.Message)
}

# -----------------------------
# 6. Clear crash restore markers
# -----------------------------
foreach ($file in $restoreFiles) {
    $fullPath = Join-Path $chromeProfile $file
    if (Test-Path $fullPath) {
        Write-Host ("Removing crash restore file: " + $file)
        Remove-Item $fullPath -Force
    }
}

# -----------------------------
# 7. Launch Chromium with startup URLs
# -----------------------------
Write-Host "Launching Chromium with specified URLs..."
Start-Process -FilePath $chromiumExePath -ArgumentList $startupUrls
