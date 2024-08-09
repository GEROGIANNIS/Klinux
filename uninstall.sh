#!/bin/bash

# Define log files with timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="/var/log/package_cleanup.log"
WORKING_DIR="$(pwd)"
RELATIVE_LOG_DIR="$WORKING_DIR/logs"
RELATIVE_LOG_FILE="$RELATIVE_LOG_DIR/uninstall_${TIMESTAMP}.log"

# Ensure the logs directory exists
mkdir -p "$RELATIVE_LOG_DIR"

# Define a whitelist of critical packages and essential tools
whitelist=(
    # Core system utilities and libraries
    'apt' 'apt-transport-https' 'bash' 'btrfs-progs' 'coreutils' 'curl' 'dnsutils'
    'dpkg' 'dosfstools' 'e2fsprogs' 'gnupg' 'gnupg2' 'iptables' 'iproute2'
    'mount' 'net-tools' 'ntfs-3g' 'openssh-client' 'software-properties-common'
    'systemd' 'ufw' 'util-linux' 'wget'

    # Networking - include both client and server components
    'avahi-daemon' 'bind9-host' 'dnsutils' 'network-manager' 'network-manager-gnome'
    'openssh-client' 'openssh-server' 'wpasupplicant' 'wireless-tools'

    # Bluetooth
    'blueman' 'bluez' 'bluez-tools' 'bluetooth' 'pulseaudio-module-bluetooth'

    # Package management
    'apt' 'dnf' 'dpkg' 'flatpak' 'pacman' 'rpm' 'snapd'

    # Desktop environment components - GNOME, XFCE, and KDE
    'wayland' 'xorg*' 'x11*' 'xserver*'

    # GNOME components
    'eog' 'evince' 'gdm3' 'gnome-backgrounds' 'gnome-control-center'
    'gnome-disk-utility' 'gnome-icon-theme' 'gnome-keyring' 'gnome-session'
    'gnome-settings-daemon' 'gnome-shell' 'gnome-shell-extensions' 'gnome-software'
    'gnome-screensaver' 'gnome-system-monitor' 'gnome-terminal' 'gnome-tweaks'
    'gucharmap' 'mutter' 'nautilus' 'gnome*'

    # XFCE components
    'lightdm' 'lightdm-gtk-greeter' 'mousepad' 'ristretto' 'thunar' 'xfce4'
    'xfce4-appfinder' 'xfce4-goodies' 'xfce4-notifyd' 'xfce4-panel' 'xfce4-power-manager'
    'xfce4-session' 'xfce4-settings' 'xfce4-taskmanager' 'xfce4-terminal' 'xfdesktop4'
    'xfwm4'

    # KDE components
    'breeze' 'discover' 'dolphin' 'gwenview' 'kate' 'kde-full' 'kde-plasma-desktop'
    'kde-standard' 'kdeconnect' 'kinfocenter' 'khotkeys' 'konsole' 'krunner'
    'kscreen' 'ksysguard' 'kwin' 'okular' 'plasma-desktop' 'plasma-nm' 'plasma-pa'
    'plasma-workspace' 'sddm' 'systemsettings' 'yakuake'

    # Display managers
    'gdm3' 'lightdm' 'sddm' 'xdm'

    # Audio
    'alsa-utils' 'pulseaudio' 'pulseaudio-module-bluetooth' 'pavucontrol'

    # Development tools
    'build-essential' 'cmake' 'g++' 'gcc' 'git' 'make' 'nodejs' 'perl' 'python3' 'ruby'
    'clang' 'llvm' 'python-dev' 'php' 'automake' 'pkg-config' 'gdb'

    # Text editors and file management
    'caja' 'dolphin' 'gedit' 'kate' 'mousepad' 'nano' 'nautilus' 'nemo' 'pcmanfm'
    'thunar' 'vim'

    # Bootloader and related utilities
    'grub-efi' 'grub-pc' 'grub2'

    # Compression tools
    'bzip2' 'gzip' 'unzip' 'xz-utils' 'zip' '7zip'

    # Disk management
    'gparted' 'lvm2' 'cryptsetup' 'mdadm' 'parted' 'smartmontools'

    # System monitoring
    'htop' 'iotop' 'lsof' 'sysstat'

    # Security tools
    'firewalld' 'libpam*' 'polkit' 'sudo' 'ufw'

    # Multimedia
    'eog' 'gimp' 'gwenview' 'mpv' 'vlc'

    # Printer and scanner support
    'cups' 'system-config-printer' 'sane-utils' 'printer-driver-*'

    # Firmware
    'firmware-*'

    # Libraries
    'lib*'

    # Terminals - explicitly ensure common terminals are not removed
    'gnome-terminal' 'xfce4-terminal' 'konsole' 'xterm' 'terminator' 'tmux'

    # Ubuntu/Kubuntu/Kali-specific tools
    'discover' 'gnome-software' 'kali-desktop-*' 'kali-linux-core' 'kali-linux-default' 'kali*'
    'kali-linux-headless' 'kubuntu-desktop' 'muon' 'ubuntu-desktop' 'ubuntu-drivers-common'

    # Man pages and documentation
    'man-db' 'manpages' 'locales' 'dictionaries-common' 'hunspell-*'

    # Zsh and related
    'zsh*'

    # Basic Linux commands and utilities
    'coreutils' 'findutils' 'file' 'sed' 'grep' 'awk' 'cut' 'sort' 'tar' 'gzip'
    'bzip2' 'xz-utils' 'unzip' 'rsync' 'sudo' 'passwd' 'adduser' 'useradd'
    'groupadd' 'usermod' 'deluser' 'accountservice' 'mount' 'umount' 'lsb-release'
    'hostname' 'date' 'uptime' 'df' 'du' 'top' 'htop' 'ps' 'kill' 'killall'
    'wget' 'curl' 'ping' 'traceroute' 'netstat' 'ss' 'ifconfig' 'ip' 'ls' 'cp'
    'mv' 'rm' 'pwd' 'ln' 'chmod' 'chown' 'chgrp' 'touch' 'mkdir' 'rmdir' 'sh'
    'bash' 'zsh' 'accountsservice' 'attr' 'ca-cert*' 'java*' 'dbus*' 'cron*'
)

# Function to check if a package is in the whitelist
is_whitelisted() {
    local pkg=$1
    for core_pkg in "${whitelist[@]}"; do
        if [[ $pkg == $core_pkg || $pkg == ${core_pkg%%\*}* ]]; then
            return 0
        fi
    done
    return 1
}

# Start logging to both files
echo "Starting package cleanup script at $(date)" | tee -a "$LOG_FILE" "$RELATIVE_LOG_FILE"

# Get a list of all installed packages
INSTALLED_PACKAGES=$(dpkg-query -W --showformat='${Package}\n')

# Variable to store the list of installed packages to remove
packages_to_remove=""

# Loop through each installed package and check if it's NOT part of the whitelist
for package in $INSTALLED_PACKAGES; do
    if ! is_whitelisted "$package"; then
        echo "Identified non-whitelisted package to remove: $package" | tee -a "$LOG_FILE" "$RELATIVE_LOG_FILE"
        packages_to_remove+="$package "
    else
        echo "Keeping whitelisted package: $package" | tee -a "$LOG_FILE" "$RELATIVE_LOG_FILE"
    fi
done

# Check if there are any packages to remove
if [ -n "$packages_to_remove" ]; then
    echo "Packages to remove: $packages_to_remove" | tee -a "$LOG_FILE" "$RELATIVE_LOG_FILE"
    sudo apt remove $packages_to_remove -y | tee -a "$LOG_FILE" "$RELATIVE_LOG_FILE"
else
    echo "No non-whitelisted packages to remove" | tee -a "$LOG_FILE" "$RELATIVE_LOG_FILE"
fi

# Perform the cleanup
echo "Performing system cleanup at $(date)" | tee -a "$LOG_FILE" "$RELATIVE_LOG_FILE"
sudo apt autoclean | tee -a "$LOG_FILE" "$RELATIVE_LOG_FILE"
sudo apt autoremove -y | tee -a "$LOG_FILE" "$RELATIVE_LOG_FILE"
sudo apt update | tee -a "$LOG_FILE" "$RELATIVE_LOG_FILE"

# Optionally remove all config files of removed packages
# echo "Removing configuration files of removed packages" | tee -a "$LOG_FILE" "$RELATIVE_LOG_FILE"
# dpkg -l | grep '^rc' | awk '{print $2}' | sudo xargs dpkg --purge | tee -a "$LOG_FILE" "$RELATIVE_LOG_FILE"

echo "The script has been successfully executed" | tee -a "$LOG_FILE" "$RELATIVE_LOG_FILE"
echo "Thanks for using this script" | tee -a "$LOG_FILE" "$RELATIVE_LOG_FILE"
