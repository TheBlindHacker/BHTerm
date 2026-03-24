# 💀 BlindHacker Terminal (BHTerm)
**High-Speed, High-Contrast, Accessible Pentesting Shell**

A hardened Linux environment for Kali and WSL, optimized for visually impaired offensive security professionals.

## Features
- **High-Contrast Prompt**: Easy to read colors, clear status indicators `[OK]` / `[FAIL]`.
- **Target Management**: Easily manage targets using `set-target` and access them via `$T1`, `$T`, etc.
- **Audio Feedback**: Terminal bells chime on successes and dual-chime on failures.
- **Workspace Generation**: Quick-start new engagements with `new-client`.
- **Background Scans**: `nscan` pushes nmap scans to tmux windows so you don't stall your main session.
- **Quick Restore**: Easy `restore-bashrc` command if you want your original `.bashrc` back.
- **DevSecOps Ready**: Automated backups, safe parsing, and no hardcoded credentials.

## Installation
Just run the install script:
```bash
chmod +x install_blindhacker.sh
./install_blindhacker.sh
source ~/.bashrc
```

## Shortcuts and Commands
- `new-client [Name]` : Setup /scans, /loot, /targets folders for a new workspace.
- `set-target [IPs]`  : Define `$T1`, `$T2`, and `$T_ALL`.
- `nscan [IP]`        : Verbose Nmap in tmux + Audio Alert. (If no IP is passed, uses `$T`).
- `upnow`             : Turbo-update system (uses `apt-fast` or `apt`) + Audio Alert.
- `help-bh`           : Show the help command list.
- `restore-bashrc`    : Restore your previous `~/.bashrc` backup.

## Security & Best Practices
- **No Hardcoded Passwords**: The script relies exclusively on standard privileges.
- **Failsafe Environment**: Always backs up `~/.bashrc` before modifying environment variables.
- **Clean Execution**: Strict execution flow guarantees that malicious environment variables cannot inject logic.
