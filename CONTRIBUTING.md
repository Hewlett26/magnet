# Contributing to Magnet

Thanks for your interest in contributing. Magnet is a small focused tool and contributions are welcome, but please read this first to avoid wasted effort.

---

## Before You Start

**Open an issue before writing code.** If you're planning a new feature or a non-trivial change, open an issue first to discuss it. This avoids situations where a PR gets rejected because it conflicts with the project's direction.

For bug fixes and small improvements, a PR without a prior issue is fine.

---

## What's In Scope

- Bug fixes
- Improvements to existing commands
- New commands that fit the project's model (single CLI, delegates to a package manager, updates the DB)
- Bootstrap improvements
- Documentation improvements

## What's Out of Scope

- Supporting package managers outside of pacman, AUR, apt, and dnf
- Adding a GUI or TUI
- Rewriting in another language
- Features that require internet access outside of normal package manager operations

---

## Setup

```bash
git clone https://github.com/yourusername/magnet.git
cd magnet
chmod +x bootstrap.sh
sudo ./bootstrap.sh
```

You'll need a working Arch Linux system with `yay` and `distrobox` installed, with `magnet-debian` and `magnet-fedora` containers set up. The bootstrap handles this.

---

## Code Style

Magnet is a Bash script. Please keep contributions consistent with the existing style:

- 4-space indentation
- All functions use `local` for their variables
- All user-facing output goes through `log_ok`, `log_err`, `log_warn`, or `log_info` — never raw `echo` for status messages
- Every operation that touches a package manager must acquire and release the appropriate lockfile
- Every successful install or remove must update the database via `db_add` or `db_remove`
- New commands must be added to both the `case` block and the help text at the bottom
- Run `bash -n magnet` before submitting to catch syntax errors

---

## Testing

There is no automated test suite yet. Before submitting, manually test:

1. `--dry-run` for any install/remove paths your change touches
2. The relevant command against a real package on a real system
3. Edge cases: package not found, wrong source, empty database, multiple packages

Document in your PR what you tested and how.

---

## Submitting a PR

- Keep PRs focused — one feature or fix per PR
- Update `CHANGELOG.md` under an `[Unreleased]` section at the top
- If your change affects CLI usage, update `README.md` accordingly
- PR title should be short and descriptive: `Fix remove_pkg FOUND check` not `fix bug`

---

## Reporting Bugs

Open an issue with:
- What you ran
- What you expected
- What actually happened
- Relevant output from `sudo magnet log`
- Your distrobox version (`distrobox --version`) and whether the containers were running
