# Changelog

All notable changes to BHTerm will be documented in this file.

## [Unreleased]

### Added
- **Windows PowerShell Support**: Added `install_BHTerm_Windows.ps1` standalone installer for Windows environments.
- **Admin Validation & Safety Checks**: Windows script strictly enforces elevated privileges and creates profile backups (`restore-profile`).
- **Cheat Codes (cht)**: Integrated `cheat.sh` syntax cheat sheets directly into the Windows terminal natively.
- **Readable Size Aliases**: Integrated highly-readable size formatters mapping MB/GB cleanly into `ll`, `df`, and `procps`.
- **System Automation**: Native Windows automation utilizing `winget` and `choco` to update toolsets and automatically install Nmap dependencies.

### Fixed
- **System Updates During Installation**: Automated full-system updates (`winget`/`choco` upgrade all) are now opt-in (commented out by default) during the initial Windows installation to significantly speed up deployment times. They remain fully functional via the `upnow` command post-install.
- **nscan command**: Fixed a bug where `nscan` failed with `error connecting to /tmp/tmux-xxx (No such file or directory)` if `tmux` wasn't already running. It now automatically launches a detached background `tmux` session (`bg_scans`) to host the nmap scan.
- **Installer Script**: Removed the hardcoded `README.md` generation logic. This prevents the installer from unintentionally dropping a new `README.md` file into the user's current directory when installing via the `curl` method.
