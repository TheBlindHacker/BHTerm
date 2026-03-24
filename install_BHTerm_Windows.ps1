# ==============================================================================
# BlindHacker Terminal Installer for Windows (Standalone)
# High-Speed, High-Contrast, Accessible Pentesting Shell
# Optimized for Windows PowerShell 5.1+ and PowerShell 7+
# ==============================================================================

Write-Host "=====================================================" -ForegroundColor Yellow
Write-Host "[+] BHTerm Windows Standalone Installer" -ForegroundColor Green
Write-Host "=====================================================" -ForegroundColor Yellow
Write-Host ""

# 0. Administrator Prerequisite Check
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "[!] CRITICAL ERROR: Installer must be run as Administrator." -ForegroundColor Red
    Write-Host "[*] BHTerm requires an elevated prompt to configure your system, install tools (like Nmap via Winget), and modify profile scripts." -ForegroundColor Red
    Write-Host "[*] Please close this window, right-click PowerShell -> 'Run as Administrator', and try again." -ForegroundColor Yellow
    Exit
}

# 1. Dependency Check and Installation
Write-Host "[*] Checking for Package Managers (winget/choco)..." -ForegroundColor Cyan
$pm = ""
if (Get-Command winget -ErrorAction SilentlyContinue) {
    $pm = "winget"
    Write-Host "[+] Found Winget" -ForegroundColor Green
} elseif (Get-Command choco -ErrorAction SilentlyContinue) {
    $pm = "choco"
    Write-Host "[+] Found Chocolatey" -ForegroundColor Green
} else {
    Write-Host "[-] Neither Winget nor Chocolatey found. Manual installation of tools like Nmap may be required." -ForegroundColor Red
}

Write-Host "[*] Executing System-Wide Updates..." -ForegroundColor Cyan
if ($pm -eq "winget") {
    Write-Host "[+] Running winget upgrade --all (System Update)..." -ForegroundColor Yellow
    winget upgrade --all
} elseif ($pm -eq "choco") {
    Write-Host "[+] Running choco upgrade all -y (System Update)..." -ForegroundColor Yellow
    choco upgrade all -y
}

Write-Host ""
Write-Host "[*] Checking for Nmap..." -ForegroundColor Cyan
if (-not (Get-Command nmap -ErrorAction SilentlyContinue)) {
    Write-Host "[-] Nmap not found. Attempting installation via $pm..." -ForegroundColor Yellow
    if ($pm -eq "winget") {
        winget install -e --id Insecure.Nmap
        Write-Host "[+] Nmap installation triggered via Winget." -ForegroundColor Green
    } elseif ($pm -eq "choco") {
        choco install nmap -y
        Write-Host "[+] Nmap installation triggered via Choco." -ForegroundColor Green
    } else {
        Write-Host "[-] Could not automatically install Nmap. Please install it manually from nmap.org." -ForegroundColor Red
    }
} else {
    Write-Host "[+] Nmap is already installed." -ForegroundColor Green
}
Write-Host ""

# 2. Manage and Backup Profile
if (-not (Test-Path -Path $PROFILE)) {
    Write-Host "[-] No `$PROFILE found. Creating one..." -ForegroundColor Yellow
    New-Item -Path $PROFILE -ItemType File -Force | Out-Null
} else {
    $BackupFile = "$PROFILE.bak_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    Copy-Item -Path $PROFILE -Destination $BackupFile -Force
    Write-Host "[+] Found existing profile: $PROFILE" -ForegroundColor Cyan
    Write-Host "[+] Backed up existing `$PROFILE to: $BackupFile" -ForegroundColor Green
}

# 3. Write the BlindHacker configuration
$BlindHackerScript = Join-Path (Split-Path $PROFILE -Parent) "BHTerm_Profile.ps1"
Write-Host "[+] Writing BHTerm configuration to $BlindHackerScript..." -ForegroundColor Cyan

$BHTermConfig = @'
# ==============================================================================
# 💀 BHTerm Configuration for Windows
# ==============================================================================

# --- Functionally Accessible Branding ---
function Show-Banner {
    Write-Host "=================================================" -ForegroundColor Yellow
    Write-Host " 💀 BHTerm : High-Contrast Pentesting Shell 💀 " -ForegroundColor Green
    Write-Host "=================================================" -ForegroundColor Yellow
}

function Get-BlindHackerMotd {
    Show-Banner
    
    $isElevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if ($isElevated) {
        Write-Host " [!] WARNING: You are running in an ELEVATED (Administrator) session." -ForegroundColor Black -BackgroundColor DarkYellow
    }

    Write-Host ""
    Write-Host " --- CORE COMMANDS ---" -ForegroundColor Cyan
    Write-Host " new-client [Name] : Setup /scans, /loot, /targets" -ForegroundColor Green
    Write-Host " set-target [IPs]  : Define `$global:T1 and `$global:T_ALL" -ForegroundColor Green
    Write-Host " nscan [IP]        : Verbose Nmap in new window + Audio Alert" -ForegroundColor Green
    Write-Host " cht [Command]     : Get instant syntax cheat codes (via cheat.sh)" -ForegroundColor Green
    Write-Host " upnow             : Turbo-update all software via winget/choco" -ForegroundColor Green
    Write-Host " restore-profile   : Restore `$PROFILE from the latest backup" -ForegroundColor Green
    Write-Host " help-bh           : Show this help command list" -ForegroundColor Green
    Write-Host ""
}

Set-Alias help-bh Get-BlindHackerMotd
Set-Alias banner Show-Banner

# --- Audio Cues for Accessibility ---
function Notify-Success { [Console]::Beep(1000, 200) }
function Notify-Fail { [Console]::Beep(500, 200); Start-Sleep -Milliseconds 200; [Console]::Beep(500, 200) }

# --- Cheat Codes Integration (cheat.sh) ---
function cht {
    param([string]$CommandName)
    if ([string]::IsNullOrWhiteSpace($CommandName)) {
        Write-Host "[-] Usage: cht [command] (e.g., cht nmap)" -ForegroundColor Red
        return
    }
    Write-Host "[*] Fetching cheat sheet for '$CommandName'..." -ForegroundColor Cyan
    $url = "https://cht.sh/$CommandName?T"
    try {
        $response = Invoke-RestMethod -Uri $url -UseBasicParsing
        Write-Host ""
        Write-Host $response -ForegroundColor Yellow
        Write-Host ""
    } catch {
        Write-Host "[-] Failed to fetch cheat code. Are you online?" -ForegroundColor Red
        Notify-Fail
    }
}

# --- Multi-Targeting Logic ---
function set-target {
    param([Parameter(ValueFromRemainingArguments=$true)]$Addresses)
    $global:T_ALL = ""
    for ($i=1; $i -le 20; $i++) { Remove-Variable -Name "T$i" -Scope Global -ErrorAction SilentlyContinue }
    $count = 1
    foreach ($addr in $Addresses) {
        Set-Variable -Name "T$count" -Value $addr -Scope Global
        $global:T_ALL += "$addr "
        Write-Host "[+] TARGET $count -> $addr" -ForegroundColor Green
        $count++
    }
    $global:T_ALL = $global:T_ALL.TrimEnd()
    $global:T = $global:T1
    Notify-Success
}

# --- Workspace & Offensive Tools ---
function new-client {
    param([string]$Name = "Engagement_$(Get-Date -Format 'yyyyMMdd')")
    $directories = @("scans", "exploits", "loot", "notes", "logs", "creds", "targets")
    foreach ($dir in $directories) {
        $path = Join-Path $Name $dir
        New-Item -Path $path -ItemType Directory -Force | Out-Null
    }
    Set-Location -Path $Name
    New-Item -Path "targets\scope.txt" -ItemType File -Force | Out-Null
    Write-Host "[+] Workspace Ready: $Name" -ForegroundColor Green
    Notify-Success
}

function nscan {
    param([string]$Target = $global:T)
    if ([string]::IsNullOrWhiteSpace($Target)) {
        Write-Host "[!] No target IP set. Use 'set-target [IP]' first." -ForegroundColor Red
        Notify-Fail
        return
    }
    if (-not (Get-Command nmap -ErrorAction SilentlyContinue)) {
        Write-Host "[!] 'nmap' is not installed." -ForegroundColor Red
        Notify-Fail
        return
    }
    if (-not (Test-Path scans)) { New-Item -Path scans -ItemType Directory -Force | Out-Null }

    $logname = "scans\nmap_$( [DateTimeOffset]::Now.ToUnixTimeSeconds() ).log"
    $scriptBlock = "nmap -vv -A -Pn $Target | Tee-Object -FilePath $logname -Append; [Console]::Beep(1000, 200); Write-Host 'Scan Finished.'; Read-Host 'Press Enter to exit...'"
    
    Start-Process powershell -ArgumentList "-NoProfile", "-Command", $scriptBlock
    Write-Host "[+] Nmap scan started in background window." -ForegroundColor Green
}

function upnow {
    Write-Host "[*] Starting System Update..." -ForegroundColor Yellow
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget upgrade --all
        Notify-Success
    } elseif (Get-Command choco -ErrorAction SilentlyContinue) {
        choco upgrade all -y
        Notify-Success
    } else {
        Write-Host "[-] Neither Winget nor Choco found." -ForegroundColor Red
        Notify-Fail
    }
}

# --- Restore Backup ---
function restore-profile {
    $backupFolder = Split-Path $PROFILE -Parent
    $latestBackup = Get-ChildItem -Path "$backupFolder\*_profile.ps1.bak_*" -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    
    if (-not $latestBackup) {
        # Check standard profile naming fallback
        $latestBackup = Get-ChildItem -Path "$backupFolder\*.bak_*" -File | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    }

    if (-not $latestBackup) {
        Write-Host "[-] No profile backup found in $backupFolder." -ForegroundColor Red
        Notify-Fail
        return
    }

    Copy-Item -Path $latestBackup.FullName -Destination $PROFILE -Force
    Write-Host "[+] Restored `$PROFILE from $($latestBackup.Name)" -ForegroundColor Green
    Write-Host "[*] Please run '. `$PROFILE' or restart your terminal to apply the restoration." -ForegroundColor Yellow
    Notify-Success
}

# --- Quality of Life Formatting & Aliases ---
function Get-FormatSize {
    param([long]$Bytes)
    $FormatString = "{0:N2} {1}"
    if ($Bytes -ge 1TB) { return $FormatString -f ($Bytes / 1TB), "TB" }
    if ($Bytes -ge 1GB) { return $FormatString -f ($Bytes / 1GB), "GB" }
    if ($Bytes -ge 1MB) { return $FormatString -f ($Bytes / 1MB), "MB" }
    if ($Bytes -ge 1KB) { return $FormatString -f ($Bytes / 1KB), "KB" }
    return "{0} B" -f $Bytes
}

function ll {
    Get-ChildItem | Select-Object Mode, @{Name="LastWriteTime";Expression={$_.LastWriteTime.ToString("yyyy-MM-dd HH:mm")}}, @{Name="Length";Expression={if ($_.PSIsContainer) { "<DIR>" } else { Get-FormatSize $_.Length }}}, Name | Format-Table -AutoSize
}

function df {
    Get-Volume | Where-Object DriveLetter | Select-Object DriveLetter, FileSystemLabel, @{Name="Size";Expression={Get-FormatSize $_.Size}}, @{Name="SizeRemaining";Expression={Get-FormatSize $_.SizeRemaining}} | Format-Table -AutoSize
}

function procps {
    Get-Process | Select-Object Id, ProcessName, @{Name="Memory";Expression={Get-FormatSize $_.WorkingSet}} | Sort-Object WorkingSet -Descending | Select-Object -First 20 | Format-Table -AutoSize
}

# Remove existing defaults to prevent conflict if they exist
Remove-Item Alias:\ll -ErrorAction SilentlyContinue 
Remove-Item Alias:\df -ErrorAction SilentlyContinue

# --- High-Contrast Prompt for Accessibility ---
function Get-IPAddress {
    $ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notmatch "Loopback" } | Select-Object -First 1 -ErrorAction SilentlyContinue).IPAddress
    if ([string]::IsNullOrWhiteSpace($ip)) { return "OFFLINE" }
    return $ip
}

function prompt {
    $user = [Environment]::UserName
    $ip = Get-IPAddress
    $time = (Get-Date).ToString("HH:mm:ss")
    
    $status = if ($?) { "[OK]" } else { "[FAIL]" }
    $statusColor = if ($?) { [ConsoleColor]::Green } else { [ConsoleColor]::Red }
    
    Write-Host ""
    Write-Host " $user " -NoNewline -ForegroundColor Black -BackgroundColor Cyan
    Write-Host " | " -NoNewline -ForegroundColor White
    Write-Host " $ip " -NoNewline -ForegroundColor Black -BackgroundColor Yellow
    Write-Host " | " -NoNewline -ForegroundColor White
    Write-Host " $time " -NoNewline -ForegroundColor Black -BackgroundColor Green
    Write-Host " | " -NoNewline -ForegroundColor White
    Write-Host " $status " -ForegroundColor $statusColor
    
    Write-Host " $($PWD.ProviderPath) " -ForegroundColor Cyan
    return "> "
}

# Load MOTD on startup
Get-BlindHackerMotd

'@

Set-Content -Path $BlindHackerScript -Value $BHTermConfig

# 4. Inject into $PROFILE if not already present
$profileContent = ""
if (Test-Path $PROFILE) { 
    $rawContent = Get-Content $PROFILE -Raw
    if ($rawContent) { $profileContent = $rawContent }
}

if ($profileContent -notmatch "BHTerm_Profile.ps1") {
    Add-Content -Path $PROFILE -Value "`n# Load BHTerm Windows Config"
    Add-Content -Path $PROFILE -Value "if (Test-Path `"$BlindHackerScript`") { . `"$BlindHackerScript`" }"
    Write-Host "[+] Injected BHTerm execution hook into $PROFILE" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "[+] Installation Complete!" -ForegroundColor Green
Write-Host "[*] To activate BHTerm, run: . `$PROFILE" -ForegroundColor Yellow
Write-Host "=====================================================" -ForegroundColor Yellow
