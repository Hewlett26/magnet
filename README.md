# 🧲 Magnet

A unified package management wrapper for Arch Linux systems running [Distrobox](https://github.com/89luca89/distrobox). Magnet provides a single CLI interface that transparently delegates to `pacman`, `yay` (AUR), `apt` (via a Debian container), and `dnf` (via a Fedora container) — with a persistent database tracking everything it installs.

> **Current version:** v0.5 — [See what's new](CHANGELOG.md)

---

## Requirements

- Arch Linux
- [`yay`](https://github.com/Jguer/yay) (AUR helper)
- [`distrobox`](https://github.com/89luca89/distrobox) with two containers:
  - `magnet-debian` — a Debian-based container
  - `magnet-fedora` — a Fedora-based container
- `sudo` access

The bootstrap script handles container creation and all other setup automatically.

---

## Installation

```bash
git clone https://github.com/yourusername/magnet.git
cd magnet
chmod +x bootstrap.sh
sudo ./bootstrap.sh
cd .. && rm -rf magnet
```

That's it. The bootstrap installs the `magnet` script, sets up the Distrobox containers, and initializes the database at `/var/lib/magnet/`. You can safely delete the cloned folder afterwards.

---

## Usage

### Install packages
```bash
sudo magnet install vim
sudo magnet install vim htop curl          # multiple packages
sudo magnet install --source=aur paru      # force a specific source
sudo magnet install --dry-run vim          # preview without installing
```

Install priority (when no `--source` is given): `pacman` → `AUR` → `Debian container` → `Fedora container`

### Remove packages
```bash
sudo magnet remove vim
sudo magnet remove vim htop curl           # multiple packages
sudo magnet remove --dry-run vim           # preview without removing
```

### Search
```bash
sudo magnet search vim                     # search all sources
```

### Update everything
```bash
sudo magnet update                         # updates all sources in priority order
```

### Database & tracking
```bash
sudo magnet list                           # list all Magnet-managed packages
sudo magnet list --source=aur              # filter by source
sudo magnet info vim                       # show install metadata for a package
sudo magnet why vim                        # human-readable install attribution
```

### Profiles (export / import)
```bash
sudo magnet export myprofile               # export current DB as a named profile
sudo magnet import myprofile               # install all packages from a profile
```

Profiles are plain CSVs stored at `/var/lib/magnet/profiles/<name>.csv` and can be shared freely between machines.

### Log
```bash
sudo magnet log                            # pretty-print the Magnet log
```

---

## How It Works

Magnet delegates every operation to the appropriate underlying package manager. It uses per-package-manager lockfiles under `/tmp/magnet-locks/` to prevent concurrent conflicts, and maintains a CSV database at `/var/lib/magnet/packages.csv` that tracks every package it installs — including the source, timestamp, and the user who installed it.

### Database format

```
package,source,date,user
vim,pacman,2026-03-06 12:00:00,alice
htop,aur,2026-03-06 12:05:00,bob
```

### Source flag

The `--source` flag can appear anywhere in the argument list and applies to all packages in that invocation:

```bash
sudo magnet install pkg1 pkg2 --source=debian pkg3  # all three install from debian
```

---

## File Locations

| Path | Purpose |
|---|---|
| `/usr/local/bin/magnet` | The magnet script |
| `/var/lib/magnet/packages.csv` | Package database |
| `/var/lib/magnet/profiles/` | Saved profiles |
| `/var/log/magnet.log` | Operation log |
| `/tmp/magnet-locks/` | Runtime lockfiles (ephemeral) |

---

## Versioning

Magnet follows a simple `major.minor` scheme:

- **Major** — breaking changes to CLI or database format
- **Minor** — new features, non-breaking changes

---

## License

Magnet is licensed under the [GNU General Public License v3.0](LICENSE).
