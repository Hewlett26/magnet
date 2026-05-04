#!/bin/bash
set -e

echo "== MagnetOS bootstrap starting =="

# Just in case someone runs this as root
if [[ $UID -eq 0 ]]; then
    echo "Do NOT run this as root."
    exit 1
fi

# Update the arch setup
# sudo pacman -Syu --noconfirm

# Install core packages
echo "== Installing necessary packages for distrobox =="
sudo pacman -S --needed --noconfirm \
    podman \
    distrobox \
    fuse-overlayfs \
    slirp4netns \
    wget \
    curl \
    git \
    base-devel

# Installing Yay
if ! command -v yay &>/dev/null; then
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ..
    rm -rf yay
else
    echo "Yay already installed."
fi

# Installing Magnet
echo "== Installing and initializing magnet =="
sudo install -m 755 magnet /usr/local/bin/magnet

# Initialize Magnet directories and files
LOGFILE="/var/log/magnet.log"
DB_DIR="/var/lib/magnet"
DB_FILE="$DB_DIR/packages.csv"
PROFILES_DIR="$DB_DIR/profiles"
PINS_FILE="$DB_DIR/pinned.txt"
LOCK_DIR="/tmp/magnet-locks"

sudo mkdir -p "$LOCK_DIR"
sudo mkdir -p "$DB_DIR"
sudo mkdir -p "$PROFILES_DIR"

# Create CSV with header if it doesn't exist
if [[ ! -f "$DB_FILE" ]]; then
    echo "package,source,date,user" | sudo tee "$DB_FILE" > /dev/null
fi

# Create pinned file if it doesn't exist
if [[ ! -f "$PINS_FILE" ]]; then
    sudo touch "$PINS_FILE"
fi

# Install bash completion
echo "== Installing bash completion =="
sudo install -m 644 magnet.bash-completion \
    /usr/share/bash-completion/completions/magnet
echo "Bash completion installed."

# Install fish completion only if fish is installed
if command -v fish &>/dev/null; then
    echo "== Installing fish completion =="
    # Install system-wide so all users get it
    sudo mkdir -p /usr/share/fish/vendor_completions.d
    sudo install -m 644 magnet.fish \
        /usr/share/fish/vendor_completions.d/magnet.fish
    echo "Fish completion installed."
else
    echo "Fish not installed — skipping fish completion."
fi

# Enable user namespaces
echo "== Ensuring user namespaces =="
sudo sysctl -w kernel.unprivileged_userns_clone=1

# Podman info
echo "Podman info: "
podman info >/dev/null

# Create containers for Debian and Fedora
distrobox create \
    --name magnet-debian \
    --image "docker.io/library/debian:stable"

podman pull "docker.io/library/fedora:latest"

distrobox create \
    --name magnet-fedora \
    --image fedora:latest

# Finishing touches
echo
echo "== Bootstrap complete =="
echo "== Available containers: =="
echo
distrobox list
echo
echo "== Just in case of magnet script bugs, enter the containers with: =="
echo
echo "distrobox enter magnet-(box name)"
