# Fish completion for magnet
# Install to: ~/.config/fish/completions/magnet.fish
# or: /usr/share/fish/vendor_completions.d/magnet.fish

# Helper functions
function __magnet_profiles
    set profiles_dir /var/lib/magnet/profiles
    if test -d $profiles_dir
        find $profiles_dir -name "*.csv" -printf "%f\n" 2>/dev/null | sed 's/\.csv$//'
    end
end

function __magnet_installed
    set db /var/lib/magnet/packages.csv
    if test -f $db
        tail -n +2 $db | cut -d',' -f1
    end
end

function __magnet_pinned
    set pins /var/lib/magnet/pinned.txt
    if test -f $pins
        cat $pins
    end
end

function __magnet_sources
    echo pacman
    echo aur
    echo debian
    echo fedora
end

function __magnet_no_subcommand
    not __fish_seen_subcommand_from \
        install remove search update list info why \
        pin unpin export import add-profile remove-profile \
        profile-add profile-remove doctor log --help -h
end

# Subcommands
complete -c magnet -f -n __magnet_no_subcommand -a install       -d "Install packages"
complete -c magnet -f -n __magnet_no_subcommand -a remove        -d "Remove packages"
complete -c magnet -f -n __magnet_no_subcommand -a search        -d "Search all sources"
complete -c magnet -f -n __magnet_no_subcommand -a update        -d "Update all sources"
complete -c magnet -f -n __magnet_no_subcommand -a list          -d "List tracked packages"
complete -c magnet -f -n __magnet_no_subcommand -a info          -d "Show package info"
complete -c magnet -f -n __magnet_no_subcommand -a why           -d "Show who installed a package"
complete -c magnet -f -n __magnet_no_subcommand -a pin           -d "Pin a package to skip updates"
complete -c magnet -f -n __magnet_no_subcommand -a unpin         -d "Unpin a package"
complete -c magnet -f -n __magnet_no_subcommand -a export        -d "Export DB as a named profile"
complete -c magnet -f -n __magnet_no_subcommand -a import        -d "Install all packages from a profile"
complete -c magnet -f -n __magnet_no_subcommand -a add-profile   -d "Create a new empty profile"
complete -c magnet -f -n __magnet_no_subcommand -a remove-profile -d "Delete a profile"
complete -c magnet -f -n __magnet_no_subcommand -a profile-add   -d "Add a package to a profile"
complete -c magnet -f -n __magnet_no_subcommand -a profile-remove -d "Remove a package from a profile"
complete -c magnet -f -n __magnet_no_subcommand -a doctor        -d "Check and fix Magnet health"
complete -c magnet -f -n __magnet_no_subcommand -a log           -d "Pretty-print the Magnet log"
complete -c magnet -f -n __magnet_no_subcommand -a --help        -d "Show usage"
complete -c magnet -f -n __magnet_no_subcommand -a -h            -d "Show usage"

# install flags
complete -c magnet -f -n "__fish_seen_subcommand_from install" \
    -a "--dry-run" -d "Preview without installing"
complete -c magnet -f -n "__fish_seen_subcommand_from install" \
    -a "--source=" -d "Force a specific source"
complete -c magnet -f -n "__fish_seen_subcommand_from install; and string match -q -- '--source=*' (commandline -t)" \
    -a "(__magnet_sources | sed 's/^/--source=/')"

# remove flags
complete -c magnet -f -n "__fish_seen_subcommand_from remove" \
    -a "--dry-run" -d "Preview without removing"
complete -c magnet -f -n "__fish_seen_subcommand_from remove" \
    -a "--no-purge" -d "Skip XDG cleanup"
complete -c magnet -f -n "__fish_seen_subcommand_from remove" \
    -a "--source=" -d "Force a specific source"
complete -c magnet -f -n "__fish_seen_subcommand_from remove" \
    -a "(__magnet_installed)" -d "Installed package"

# list flags
complete -c magnet -f -n "__fish_seen_subcommand_from list" \
    -a "--source=" -d "Filter by source"
complete -c magnet -f -n "__fish_seen_subcommand_from list" \
    -a "--profile=" -d "Show profile contents"
complete -c magnet -f -n "__fish_seen_subcommand_from list; and string match -q -- '--profile=*' (commandline -t)" \
    -a "(__magnet_profiles | sed 's/^/--profile=/')"

# info / why — complete installed packages
complete -c magnet -f -n "__fish_seen_subcommand_from info why" \
    -a "(__magnet_installed)" -d "Tracked package"

# pin — complete installed packages
complete -c magnet -f -n "__fish_seen_subcommand_from pin" \
    -a "(__magnet_installed)" -d "Tracked package"

# unpin — complete pinned packages only
complete -c magnet -f -n "__fish_seen_subcommand_from unpin" \
    -a "(__magnet_pinned)" -d "Pinned package"

# export / import / remove-profile — complete profile names
complete -c magnet -f -n "__fish_seen_subcommand_from export import remove-profile" \
    -a "(__magnet_profiles)" -d "Profile"

# profile-add — first arg is profile, then package, then --source
complete -c magnet -f -n "__fish_seen_subcommand_from profile-add" \
    -a "(__magnet_profiles)" -d "Profile"
complete -c magnet -f -n "__fish_seen_subcommand_from profile-add" \
    -a "--source=" -d "Package source"

# profile-remove — first arg is profile
complete -c magnet -f -n "__fish_seen_subcommand_from profile-remove" \
    -a "(__magnet_profiles)" -d "Profile"
