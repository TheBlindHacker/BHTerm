# 💀 BlindHacker Terminal (BHTerm)
**High-Speed, High-Contrast, Accessible Pentesting Shell**

A hardened environment for Linux, Kali, WSL, and Windows PowerShell, optimized for visually impaired offensive security professionals.

## Features
- **High-Contrast Prompt**: Easy to read colors, clear status indicators `[OK]` / `[FAIL]`.
- **Automated Tooling**: Safely installs missing requirements like Nmap automatically via platform-native package managers.
- **Target Management**: Easily manage targets using `set-target` and access them via `$T1`, `$T`, etc.
- **Cheat Codes Tool**: Instant access to `cht.sh` via the `cht [command]` alias for easy-to-read syntax cheat sheets right in the terminal without opening a browser (Windows).
- **Audio Feedback**: Terminal bells chime on successes and dual-chime on failures.
- **Workspace Generation**: Quick-start new engagements with `new-client`.
- **Background Scans**: `nscan` pushes nmap scans to background tmux windows or PowerShell jobs so you don't stall your main session.
- **Quick Restore/Backup**: Profiles are automatically backed up and easily restored with `restore-bashrc` (Linux) or `restore-profile` (Windows).
- **Readable Output Aliases**: Built-in replacements for standard listing tools (like `ll`, `df`) that automatically format into readable human metrics (KB, MB, GB).

---

## 🐧 Installation (Linux / Kali / WSL)
You can install BHTerm directly via `curl`:
```bash
curl -sL https://raw.githubusercontent.com/TheBlindHacker/BHTerm/main/install_blindhacker.sh | bash
source ~/.bashrc
```

Or by cloning the repository and running the script manually:
```bash
git clone https://github.com/TheBlindHacker/BHTerm.git
cd BHTerm
chmod +x install_blindhacker.sh
./install_blindhacker.sh
source ~/.bashrc
```

---

## 🪟 Installation (Windows PowerShell 5.1 & 7+)
Windows strictly controls script execution. You **must** be running PowerShell as an **Administrator** for this installation to configure your environment, install dependencies like Nmap, and manage OS-level tool updates.

### Option 1: Remote Install (`iex`)
The quickest way to install BHTerm on Windows without cloning the repository:
```powershell
# 1. Allow profile scripts to execute permanently (Required)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# 2. Download and execute the installer
irm https://raw.githubusercontent.com/TheBlindHacker/BHTerm/main/install_BHTerm_Windows.ps1 | iex

# 3. Load the new environment
. $PROFILE
```

### Option 2: Clone Repository (`git`)
Alternatively, if you prefer cloning the repository manually:
```powershell
# 1. Allow profile scripts to execute permanently (Required)
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# 2. Clone the repository and execute
git clone https://github.com/TheBlindHacker/BHTerm.git
cd BHTerm
.\install_BHTerm_Windows.ps1

# 3. Load the new environment
. $PROFILE
```

### Optional: Automate Full-System Upgrades on Install
By default, BHTerm does **not** upgrade your entire OS software suite during installation to save time (though it will install Nmap if missing). If you want the installer to update your entire system via Winget or Chocolatey automatically:
1. Open `install_BHTerm_Windows.ps1` in a text editor before running it.
2. Remove the `<#` and `#>` block around the `[+] Running winget upgrade` section at Line 24.
*(Note: You can still manually update your entire system at any time by running the `upnow` command from within BHTerm).*

---

## Shortcuts and Commands
- `new-client [Name]` : Setup /scans, /exploits, /loot, /targets folders for a new workspace.
- `set-target [IPs]`  : Define `$T1`, `$T2`, and `$T_ALL` (`$global:T1` in PowerShell).
- `nscan [IP]`        : Verbose Nmap in background session + Audio Alert. (If no IP is passed, uses `$T`).
- `cht [command]`     : Returns a highly-readable markdown cheat sheet for the queried command (Windows platform only).
- `upnow`             : Turbo-update system (uses `apt-fast` on Linux, `winget` on Windows) + Audio Alert.
- `restore-*`         : Restore your previous `~/.bashrc` or `$PROFILE` backup.
- `help-bh`           : Show the help command list.

### Quality-of-Life Formatting Aliases (Windows)
- `ll` : Lists all files cleanly, converting exact byte counts into human-readable formats (e.g., `1.42 GB` or `<DIR>`).
- `df` : Shows all connected volumes and drives mapped across MB/GB/TB metrics automatically.
- `procps`: Lists the top 20 processes currently running by memory footprint, natively formatted into readable variables.

## Security & Best Practices
- **No Hardcoded Passwords**: The script relies exclusively on standard OS privileges.
- **Failsafe Environment**: Always backs up your settings before modifying environment variables.
- **Clean Execution**: Strict execution flow guarantees that malicious environment variables cannot inject logic.
