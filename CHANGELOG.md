# Changelog

All notable changes to Magnet are documented here.

---

## [0.6] - 2026-04-28

### Added
- `magnet pin <pkg>` — pin a package to skip it during `magnet update`
- `magnet unpin <pkg>` — unpin a previously pinned package
- `magnet list --profile=<name>` — list profile contents with installed/not installed status
- `magnet doctor` — checks and auto-fixes common issues (yay, distrobox, containers, DB integrity, orphaned entries, lock directory)
- `magnet search` now shows the version available in each source and which source Magnet would pick by default
- `magnet list` now shows `[pinned]` marker next to pinned packages
- Bash tab completion — install to `/usr/share/bash-completion/completions/magnet`
- Fish tab completion — install to `/usr/share/fish/vendor_completions.d/magnet.fish`
- Both completion files are installed automatically by the bootstrap script (fish only if installed)

### Changed
- `PINS_FILE` at `/var/lib/magnet/pinned.txt` initialized by bootstrap
- Bootstrap now installs completions and initializes `pinned.txt`
- `update_all` passes pinned packages to yay via `--ignore` flags

---

## [0.5] - 2026-03-23

### Added
- `magnet add-profile` — create a new empty profile
- `magnet remove-profile` — delete an existing profile
- `magnet profile-add <profile> <pkg> --source=` — add a package to a profile without installing it
- `magnet profile-remove <profile> <pkg>` — remove a package from a profile
- `--source` flag for `magnet remove` — force removal from a specific package manager
- `-h` / `--help` flag — show usage without needing to pass an invalid command
- Distrobox auto-export after container installs via `distrobox-export`
- XDG desktop entry and icon cleanup on container package removal
- `--no-purge` flag to skip XDG cleanup on remove

### Fixed
- Lockfile bug — `local fd` declaration missing in `acquire_lock` caused `fd: unbound variable` error
- `acquire_lock` now defensively creates the lock directory itself rather than relying on startup state
- Flatpak removed from all commands pending a proper reimplementation in a future version

### Changed
- Install and search priority order clarified: `pacman → AUR → Debian → Fedora`
- Profile management overhauled — profiles are now curated manually rather than being snapshots of the installed database
- Unknown commands now show an error instead of silently printing help

---

## [0.4] - 2026-03-06

### Added
- CSV database at `/var/lib/magnet/packages.csv` — tracks every Magnet-managed package with its source, install date, and installing user
- `magnet list` — lists all tracked packages, with optional `--source=` filtering
- `magnet info <pkg>` — shows full install metadata for a package
- `magnet why <pkg>` — human-readable install attribution
- `magnet export <profile>` — exports the current database as a named profile CSV
- `magnet import <profile>` — installs all packages from a saved profile, respecting original sources
- `magnet log` — pretty-prints `/var/log/magnet.log` with color-coded output
- `--dry-run` flag for `install` and `remove` — previews what would happen without making any changes
- Color output throughout — green for success, red for errors, yellow for warnings, cyan for progress
- Progress indicators before slow Distrobox container operations
- Timestamps now written to the log file on every entry
- Per-package-manager lockfiles under `/tmp/magnet-locks/`
- `magnet remove` now accepts multiple packages

### Fixed
- `remove_pkg`: missing `$` on `FOUND` variable caused the "not installed anywhere" check to never trigger
- `update_all`: `apt update && apt upgrade` was running partially on the host instead of fully inside the Debian container
- `apt_has`: switched from `apt-cache search` (fuzzy) to `apt-cache show` (exact) to prevent false positive matches
- `remove_pkg`: Distrobox container checks were missing `sudo -u "$SUDO_USER"`

### Changed
- Database and profile initialization moved to the bootstrap script
- `SUDO_USER` is now validated at startup
- `set -u` upgraded to `set -uo pipefail`

---

## [0.3] - Initial release

- Basic `install`, `remove`, `search`, `update` commands
- Priority order: pacman → AUR → Debian container → Fedora container
- `--source=` flag to force a specific package manager
- Single global lockfile
- Logging to `/var/log/magnet.log`
