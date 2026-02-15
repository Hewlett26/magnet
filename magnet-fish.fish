#!/usr/bin/env fish

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#  Magnet Package Management Wrapper (Fish Version)      #
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set LOGFILE "/var/log/magnet.log"

function log
    echo "[MAGNET] $argv[1]"
    echo "[MAGNET] $argv[1]" >> $LOGFILE 2>/dev/null; or true
end

#%%%%%%%%%%%%%%%%%%%%% Config %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set DEBIAN_BOX "magnet-debian"
set FEDORA_BOX "magnet-fedora"

#%%%%%%%%%%%%%%%%%%%%% Helpers %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function command_exists
    command -v $argv[1] >/dev/null 2>&1
end

function pacman_has
    pacman -Si $argv[1] >/dev/null 2>&1
end

function aur_has
    sudo -u $SUDO_USER yay -Si $argv[1] >/dev/null 2>&1
end

function apt_has
    sudo -u $SUDO_USER distrobox enter $DEBIAN_BOX -- apt-cache search $argv[1] >/dev/null 2>&1
end

function dnf_has
    sudo -u $SUDO_USER distrobox enter $FEDORA_BOX -- dnf search $argv[1] >/dev/null 2>&1
end

#%%%%%%%%%%%%%%%%%%%%%% Install %%%%%%%%%%%%%%%%%%%%%%%%%%%%

function install_pkg
    set PKG $argv[1]

    log "Searching for $PKG..."

    if pacman_has $PKG
        log "Installing via pacman..."
        sudo pacman -S --needed $PKG
        exit 0
    end

    if command_exists yay
        if aur_has $PKG
            log "Installing via AUR..."
            sudo -u $SUDO_USER yay -S $PKG
            exit 0
        end
    end

    if apt_has $PKG
        log "Installing via Debian Container..."
        sudo -u $SUDO_USER distrobox enter $DEBIAN_BOX -- sudo apt install -y $PKG
        exit 0
    end

    if dnf_has $PKG
        log "Installing via Fedora Container..."
        sudo -u $SUDO_USER distrobox enter $FEDORA_BOX -- sudo dnf install -y $PKG
        exit 0
    end

    log "Package not found anywhere."
    exit 1
end

#%%%%%%%%%%%%%%%%%%%%%% Remove %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function remove_pkg
    set PKG $argv[1]
    set FOUND 0

    log "Searching for $PKG..."

    if pacman -Qi $PKG >/dev/null 2>&1
        log "Removing via pacman..."
        sudo pacman -Rns $PKG
        set FOUND 1
    end

    if command_exists yay
        if yay -Qi $PKG >/dev/null 2>&1
            log "Removing via AUR..."
            sudo -u $SUDO_USER yay -Rns $PKG
            set FOUND 1
        end
    end

    if distrobox enter $DEBIAN_BOX -- dpkg -s $PKG >/dev/null 2>&1
        log "Removing via Debian container"
        sudo -u $SUDO_USER distrobox enter $DEBIAN_BOX -- sudo apt remove -y $PKG
        set FOUND 1
    end

    if distrobox enter $FEDORA_BOX -- rpm -q $PKG >/dev/null 2>&1
        log "Removing via Fedora container"
        sudo -u $SUDO_USER distrobox enter $FEDORA_BOX -- sudo dnf remove -y $PKG
        set FOUND 1
    end

    if test $FOUND -eq 0
        log "Package '$PKG' is not installed anywhere."
        exit 1
    end

    log "Removal Finished."
end

#%%%%%%%%%%%%%%%%%%%%%% Update %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function update_all

    log "Updating Arch packages..."
    sudo pacman -Syu

    if command_exists yay
        log "Updating AUR (yay) packages..."
        sudo -u $SUDO_USER yay -Syu
    end

    log "Updating Debian Container..."
    sudo -u $SUDO_USER distrobox enter $DEBIAN_BOX -- sudo apt update; and sudo -u $SUDO_USER distrobox enter $DEBIAN_BOX -- sudo apt upgrade -y

    log "Updating Fedora Container..."
    sudo -u $SUDO_USER distrobox enter $FEDORA_BOX -- sudo dnf upgrade -y

    log "Update complete."
end

#%%%%%%%%%%%%%%%%%%%%%%%%%% CLI %%%%%%%%%%%%%%%%%%%%%%%%%%%%

if test (count $argv) -eq 0
    echo "Magnet Package Management Wrapper"
    echo ""
    echo "Usage:"
    echo " magnet install <pkg>"
    echo " magnet remove <pkg>"
    echo " magnet update"
    exit 1
end

switch $argv[1]

    case install
        install_pkg $argv[2]

    case remove
        remove_pkg $argv[2]

    case update
        update_all

    case '*'
        echo "Magnet Package Management Wrapper"
        echo ""
        echo "Usage:"
        echo " magnet install <pkg>"
        echo " magnet remove <pkg>"
        echo " magnet update"

end
