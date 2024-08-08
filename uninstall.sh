#!/bin/bash

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
    'wayland' 'xorg'

    # GNOME components
    'eog' 'evince' 'gdm3' 'gnome-backgrounds' 'gnome-control-center'
    'gnome-disk-utility' 'gnome-icon-theme' 'gnome-keyring' 'gnome-session'
    'gnome-settings-daemon' 'gnome-shell' 'gnome-shell-extensions' 'gnome-software'
    'gnome-screensaver' 'gnome-system-monitor' 'gnome-terminal' 'gnome-tweaks'
    'gucharmap' 'mutter' 'nautilus'

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

    # Text editors and file management
    'caja' 'dolphin' 'gedit' 'kate' 'mousepad' 'nano' 'nautilus' 'nemo' 'pcmanfm'
    'thunar' 'vim'

    # Bootloader and related utilities
    'grub-efi' 'grub-pc' 'grub2'

    # Compression tools
    'bzip2' 'gzip' 'unzip' 'xz-utils' 'zip'

    # Disk management
    'gparted' 'lvm2' 'parted' 'smartmontools'

    # System monitoring
    'htop' 'iotop' 'lsof' 'sysstat'

    # Security tools
    'firewalld' 'libpam*' 'polkit' 'sudo' 'ufw'

    # Multimedia
    'eog' 'gimp' 'gwenview' 'mpv' 'vlc'

    # Printer and scanner support
    'cups' 'printer-driver-*'

    # Ubuntu/Kubuntu/Kali-specific tools
    'discover' 'gnome-software' 'kali-desktop-*' 'kali-linux-core' 'kali-linux-default'
    'kali-linux-headless' 'kubuntu-desktop' 'muon' 'ubuntu-desktop' 'ubuntu-drivers-common'
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

# Get a list of all installed packages
INSTALLED_PACKAGES=$(dpkg-query -W --showformat='${Package}\n')

# Loop through each installed package and check if it's part of the whitelist
for package in $INSTALLED_PACKAGES; do
    if ! is_whitelisted "$package"; then
        echo "Skipping essential package: $package"
    else
        echo "Keeping whitelisted package: $package"
    fi
done

# Cleanup and update
sudo apt autoclean 
sudo apt autoremove -y
sudo apt update 

# Optionally remove all config files of removed packages
#dpkg -l | grep '^rc' | awk '{print $2}' | sudo xargs dpkg --purge

echo "The script has been successfully executed"
echo "No essential packages were removed"
echo "Thanks for using this script"
