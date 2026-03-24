# Changelog

All notable changes to BHTerm will be documented in this file.

## [Unreleased]

### Fixed
- **nscan command**: Fixed a bug where `nscan` failed with `error connecting to /tmp/tmux-xxx (No such file or directory)` if `tmux` wasn't already running. It now automatically launches a detached background `tmux` session (`bg_scans`) to host the nmap scan.
- **Installer Script**: Removed the hardcoded `README.md` generation logic. This prevents the installer from unintentionally dropping a new `README.md` file into the user's current directory when installing via the `curl` method.
