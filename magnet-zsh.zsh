#!/usr/bin/env zsh

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Magnet Package Management Wrapper (Zsh Version)       #
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set -u

LOGFILE="/var/log/magnet.log"

log() {
    print "[MAGNET] $1"
    print "[MAGNET] $1" >> "$LOGFILE" 2>/dev/null || true
}

#%%%%%%%%%%%%%%%%%%%%% Config %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DEBIAN_BOX="magnet-debian"
FEDORA_BOX="magnet-fedora"

#%%%%%%%%%%%%%%%%%%%%% Helpers %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

command_exists() {
    (( $+commands[$1] ))
}

pacman_has() {
    pacman -Si "$1" >/dev/null 2>&1
}

aur_has() {
    sudo -u "$SUDO_USER" yay -Si "$1" >/dev/null 2>&1
}

apt_has() {
    sudo -u "$SUDO_USER" distrobox enter "$DEBIAN_BOX" -- apt-cache search "$1" >/dev/null 2>&1
}

dnf_has() {
    sudo -u "$SUDO_USER" distrobox enter "$FEDORA_BOX" -- dnf search "$1" >/dev/null 2>&1
}

#%%%%%%%%%%%%%%%%%%%%%% Install %%%%%%%%%%%%%%%%%%%%%%%%%%%%

install_pkg() {
    local PKG="$1"

    log "Searching for $PKG..."

    if pacman_has "$PKG"; then
        log "Installing via pacman..."
        sudo pacman -S --needed "$PKG"
        exit 0
    fi

    if command_exists yay && aur_has "$PKG"; then
        log "Installing via AUR..."
        sudo -u "$SUDO_USER" yay -S "$PKG"
        exit 0
    fi

    if apt_has "$PKG"; then
        log "Installing via Debian Container..."
        sudo -u "$SUDO_USER" distrobox enter "$DEBIAN_BOX" -- sudo apt install -y "$PKG"
        exit 0
    fi

    if dnf_has "$PKG"; then
        log "Installing via Fedora Container..."
        sudo -u "$SUDO_USER" distrobox enter "$FEDORA_BOX" -- sudo dnf install -y "$PKG"
        exit 0
    fi

    log "Package not found anywhere."
    exit 1
}

#%%%%%%%%%%%%%%%%%%%%%% Remove %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

remove_pkg() {
    local PKG="$1"
    local FOUND=0

    log "Searching for $PKG..."

    if pacman -Qi "$PKG" >/dev/null 2>&1; then
        log "Removing via pacman..."
        sudo pacman -Rns "$PKG"
        FOUND=1
    fi

    if command_exists yay && yay -Qi "$PKG" >/dev/null 2>&1; then
        log "Removing via AUR..."
        sudo -u "$SUDO_USER" yay -Rns "$PKG"
        FOUND=1
    fi

    if distrobox enter "$DEBIAN_BOX" -- dpkg -s "$PKG" >/dev/null 2>&1; then
        log "Removing via Debian container"
        sudo -u "$SUDO_USER" distrobox enter "$DEBIAN_BOX" -- sudo apt remove -y "$PKG"
        FOUND=1
    fi

    if distrobox enter "$FEDORA_BOX" -- rpm -q "$PKG" >/dev/null 2>&1; then
        log "Removing via Fedora container"
        sudo -u "$SUDO_USER" distrobox enter "$FEDORA_BOX" -- sudo dnf remove -y "$PKG"
        FOUND=1
    fi

    if [[ $FOUND -eq 0 ]]; then
        log "Package '$PKG' is not installed anywhere."
        exit 1
    fi

    log "Removal Finished."
}

#%%%%%%%%%%%%%%%%%%%%%% Update %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

update_all() {

    log "Updating Arch packages..."
    sudo pacman -Syu

    if command_exists yay; then
        log "Updating AUR (yay) packages..."
        sudo -u "$SUDO_USER" yay -Syu
    fi

    log "Updating Debian Container..."
    sudo -u "$SUDO_USER" distrobox enter "$DEBIAN_BOX" -- sudo apt update && \
    sudo -u "$SUDO_USER" distrobox enter "$DEBIAN_BOX" -- sudo apt upgrade -y

    log "Updating Fedora Container..."
    sudo -u "$SUDO_USER" distrobox enter "$FEDORA_BOX" -- sudo dnf upgrade -y

    log "Update complete."
}

#%%%%%%%%%%%%%%%%%%%%%%%%%% CLI %%%%%%%%%%%%%%%%%%%%%%%%%%%%

if [[ $# -eq 0 ]]; then
    print "Magnet Package Management Wrapper"
    print ""
    print "Usage:"
    print " magnet install <pkg>"
    print " magnet remove <pkg>"
    print " magnet update"
    exit 1
fi

case "$1" in

    install)
        install_pkg "$2"
        ;;

    remove)
        remove_pkg "$2"
        ;;

    update)
        update_all
        ;;

    *)
        print "Magnet Package Management Wrapper"
        print ""
        print "Usage:"
        print " magnet install <pkg>"
        print " magnet remove <pkg>"
        print " magnet update"
        ;;

esac

