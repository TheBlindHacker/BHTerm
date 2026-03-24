#!/bin/bash

# ==============================================================================
# BlindHacker Terminal Installer
# High-Speed, High-Contrast, Accessible Pentesting Shell
# Optimized for Debian, Kali Linux, and WSL environments.
# ==============================================================================

set -e

echo -e "\033[01;32m[+] Starting BlindHacker Terminal Installation...\033[00m"

# 1. Create a backup of the current .bashrc
if [ -f "$HOME/.bashrc" ]; then
    BACKUP_FILE="$HOME/.bashrc.bak_$(date +%s)"
    cp "$HOME/.bashrc" "$BACKUP_FILE"
    echo -e "\033[01;34m[+] Backed up existing ~/.bashrc to: $BACKUP_FILE\033[00m"
else
    echo -e "\033[01;33m[-] No ~/.bashrc found. A new one will be created.\033[00m"
    touch "$HOME/.bashrc"
fi

# 2. Write the BlindHacker configuration
BLINDHACKER_SCRIPT="$HOME/.blindhacker_sh"
echo -e "\033[01;34m[+] Writing BlindHacker configuration to $BLINDHACKER_SCRIPT...\033[00m"

cat << 'BLINDHACKER_FINAL' > "$BLINDHACKER_SCRIPT"
# ==============================================================================
# 💀 BlindHacker Terminal Configuration
# ==============================================================================

# --- Branding & MOTD ---
function show_banner() {
cat << "EOF"
  ____  _ _           _ _   _            _             
 | __ )| (_)_ __   __| | | | | __ _  ___| | _____ _ __ 
 |  _ \| | | '_ \ / _` | |_| |/ _` |/ __| |/ / _ \ '__|
 | |_) | | | | | | (_| |  _  | (_| | (__|   <  __/ |   
 |____/|_|_|_| |_|\__,_|_| |_|\__,_|\___|_|\_\___|_|   
                                                       
EOF
}

function bh_motd() {
    show_banner
    echo -e "\033[01;33m--- BLINDHACKER COMMAND CENTER ---\033[00m"
    echo -e "\033[01;32mnew-client [Name]\033[00m : Setup /scans, /loot, /targets"
    echo -e "\033[01;32mset-target [IPs]\033[00m  : Define \$T1, \$T2, and \$T_ALL"
    echo -e "\033[01;32mnscan [IP]\033[00m        : Verbose Nmap in tmux + Audio Alert"
    echo -e "\033[01;32mupnow\033[00m             : Turbo-update system + Audio Alert"
    echo -e "\033[01;32mhelp-bh\033[00m           : Show this help command list"
    echo -e "\033[01;31mrestore-bashrc\033[00m    : Restore ~/.bashrc from backup"
    echo -e "\033[01;33m----------------------------------\033[00m\n"
}

alias banner='show_banner'
alias help-bh='bh_motd'

# Automatic Boot Reminder (Only in interactive shells)
if [[ $- == *i* ]]; then
    bh_motd
fi

# --- Audio Cues ---
function notify_success() { echo -ne "\a"; }
function notify_fail() { echo -ne "\a"; sleep 0.2; echo -ne "\a"; }

# --- Multi-Targeting Logic ---
function set-target() {
    unset T_ALL
    for i in {1..20}; do unset "T$i"; done
    local count=1
    for addr in "$@"; do
        export "T$count"=$addr
        T_ALL+="$addr "
        echo -e "\033[01;32m[+] T$count -> $addr\033[00m"
        ((count++))
    done
    export T_ALL=$(echo "$T_ALL" | sed 's/ $//')
    export T=$T1
}
alias targets='env | grep -E "^T[0-9]+|T_ALL" | sort -V'

# --- Workspace & Offensive Tools ---
function new-client() {
    local name=${1:-"Client_$(date +%F)"}
    mkdir -p "$name"/{scans,exploits,loot,notes,logs,creds,targets}
    cd "$name" || return
    touch targets/scope.txt
    echo -e "\033[01;32m[+] Workspace Ready: $name\033[00m"
    notify_success
}

function nscan() {
    local target=${1:-$T}
    if [ -z "$target" ]; then
        echo -e "\033[01;31m[!] No target IP set. Use 'set-target [IP]' first.\033[00m"
        notify_fail
        return 1
    fi
    
    # Check if tmux is installed
    if ! command -v tmux &> /dev/null; then
        echo -e "\033[01;31m[!] 'tmux' is not installed. Please install it (sudo apt install tmux).\033[00m"
        notify_fail
        return 1
    fi

    # Create scans directory if it doesn't exist
    mkdir -p scans
    tmux new-window -n "Nmap-Scan" "nmap -vv -A -Pn $target | tee -a scans/nmap_$(date +%s).log; echo -e '\a\nScan Finished.'; read -p 'Press Enter to exit...'"
}

function upnow() {
    echo -e "\033[01;33m[*] Starting Turbo Update (Multi-threaded)...\033[00m"
    if command -v apt-fast &> /dev/null; then
        sudo apt-fast update && sudo apt-fast full-upgrade -y && sudo apt-fast autoremove -y && clean_success "apt-fast"
    elif command -v apt &> /dev/null; then
        sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && clean_success "apt"
    else
        echo -e "\033[01;31m[-] apt package manager not found. This feature is optimized for Debian/Kali environments.\033[00m"
        notify_fail
    fi
}

function clean_success() {
    echo -e "\033[01;32m[+] System updated successfully using $1.\033[00m"
    notify_success
}

# --- Restore Backup ---
function restore-bashrc() {
    local latest_backup
    latest_backup=$(ls -t ~/.bashrc.bak_* 2>/dev/null | head -n 1)
    if [ -z "$latest_backup" ]; then
        echo -e "\033[01;31m[-] No backup found in $HOME.\033[00m"
        notify_fail
    else
        cp "$latest_backup" ~/.bashrc
        echo -e "\033[01;32m[+] Restored ~/.bashrc from $latest_backup\033[00m"
        echo -e "\033[01;33m[*] Please run 'source ~/.bashrc' or restart your terminal to apply changes.\033[00m"
        notify_success
    fi
}

# --- Accessibility UI (The Prompt) ---
function get_ip() {
    local ip
    if command -v ip &> /dev/null; then
        # Try eth0 first, fallback to first non-loopback IP
        ip=$(ip -4 addr show eth0 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
        if [ -z "$ip" ]; then
            ip=$(ip -4 addr show 2>/dev/null | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v '127.0.0.1' | head -n 1)
        fi
    fi
    if [ -z "$ip" ] && command -v hostname &> /dev/null; then
        ip=$(hostname -I 2>/dev/null | awk '{print $1}')
    fi
    echo "${ip:-OFFLINE}"
}

function get_status() {
    if [ $? -eq 0 ]; then
        echo -ne "\033[01;32m[OK]\033[00m"
    else
        echo -ne "\033[01;31m[FAIL]\033[00m"
    fi
}

# Dynamic, accessible PS1
export PS1="\n\[\033[01;36m\]\u@\h\[\033[00m\] | \[\033[01;33m\]\$(get_ip)\[\033[00m\] | \[\033[01;32m\]\t\[\033[00m\] | \$(get_status)\n\[\033[01;34m\]\$PWD\[\033[00m\] \[\033[01;35m\]\$(git branch 2>/dev/null | grep '^*' | cut -c 3- | xargs -I {} echo \"({})\")\[\033[00m\] \n$ "

# Quality of Life Aliases
alias ls='ls -h --color=auto'
alias ll='ls -halF'
alias df='df -h'
alias du='du -h'

BLINDHACKER_FINAL

# 3. Inject into .bashrc if not already present
if ! grep -q "source ~/.blindhacker_sh" "$HOME/.bashrc"; then
    echo "" >> "$HOME/.bashrc"
    echo "# Load BlindHacker Terminal Config" >> "$HOME/.bashrc"
    echo "if [ -f ~/.blindhacker_sh ]; then" >> "$HOME/.bashrc"
    echo "    source ~/.blindhacker_sh" >> "$HOME/.bashrc"
    echo "fi" >> "$HOME/.bashrc"
    echo -e "\033[01;34m[+] Injected execution hook into ~/.bashrc\033[00m"
else
    echo -e "\033[01;33m[*] BlindHacker execution hook already exists in ~/.bashrc\033[00m"
fi

# 4. Create README.md in current directory
echo -e "\033[01;34m[+] Generating README.md...\033[00m"
cat << 'EOF' > README.md
# 💀 BlindHacker Terminal (v9.2.4)
**High-Speed, High-Contrast, Accessible Pentesting Shell**

A hardened Linux environment for Kali and WSL, optimized for visually impaired offensive security professionals.

## Features
- **High-Contrast Prompt**: Easy to read colors, clear status indicators `[OK]` / `[FAIL]`.
- **Target Management**: Easily manage targets using `set-target` and access them via `$T1`, `$T`, etc.
- **Audio Feedback**: Terminal bells chime on successes and dual-chime on failures.
- **Workspace Generation**: Quick-start new engagements with `new-client`.
- **Background Scans**: `nscan` pushes nmap scans to tmux windows so you don't stall your main session.
- **Quick Restore**: Easy `restore-bashrc` command if you want your original `.bashrc` back.

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
EOF

echo -e "\033[01;32m[+] Installation Complete!\033[00m"
echo -e "\033[01;33m[*] Please run 'source ~/.bashrc' or restart your terminal to activate BlindHacker.\033[00m"
