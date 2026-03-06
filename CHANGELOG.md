# Changelog

All notable changes to Magnet are documented here.

---

## [0.4] - 2026-03-06

### Added
- **CSV database** at `/var/lib/magnet/packages.csv` — tracks every Magnet-managed package with its source, install date, and installing user
- **`magnet list`** — lists all tracked packages, with optional `--source=` filtering
- **`magnet info <pkg>`** — shows full install metadata for a package
- **`magnet why <pkg>`** — human-readable install attribution ("vim was installed by alice on ... from pacman")
- **`magnet export <profile>`** — exports the current database as a named profile CSV
- **`magnet import <profile>`** — installs all packages from a saved profile, respecting original sources
- **`magnet log`** — pretty-prints `/var/log/magnet.log` with color-coded output
- **`--dry-run` flag** for `install` and `remove` — previews what would happen without making any changes
- **Color output** throughout — green for success, red for errors, yellow for warnings, cyan for progress
- **Progress indicators** before slow Distrobox container operations
- **Timestamps** now written to the log file on every entry
- **Per-package-manager lockfiles** under `/tmp/magnet-locks/` — replaces the previous single global lock, allowing concurrent operations on different sources
- **`magnet remove`** now accepts multiple packages, mirroring `install` behavior

### Fixed
- `remove_pkg`: missing `$` on `FOUND` variable caused the "not installed anywhere" check to never trigger
- `update_all`: `apt update && apt upgrade` was running partially on the host instead of fully inside the Debian container
- `apt_has`: switched from `apt-cache search` (fuzzy) to `apt-cache show` (exact) to prevent false positive matches
- `remove_pkg`: Distrobox container checks were missing `sudo -u "$SUDO_USER"`, inconsistent with all other container calls

### Changed
- Database and profile initialization moved to the bootstrap script — Magnet no longer creates directories or files at runtime
- `SUDO_USER` is now validated at startup; Magnet exits cleanly if not run via sudo
- `set -u` upgraded to `set -uo pipefail` for stricter error handling
- `install` and `remove` CLI blocks now use a shared `FAILED[]` array pattern for consistent multi-package error reporting

---

## [0.3] - Initial release

- Basic `install`, `remove`, `search`, `update` commands
- Priority order: pacman → AUR → Debian container → Fedora container
- `--source=` flag to force a specific package manager
- Single global lockfile
- Logging to `/var/log/magnet.log`
