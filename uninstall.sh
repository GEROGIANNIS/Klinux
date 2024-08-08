#!/bin/bash

# Define a whitelist of critical packages and essential tools
whitelist=(
    # Core system utilities and libraries
    'bash' 'coreutils' 'apt' 'dpkg' 'systemd' 'init' 'util-linux' 'gnupg'
    'mount' 'e2fsprogs' 'btrfs-progs' 'xfsprogs' 'ntfs-3g' 'dosfstools'
    'iproute2' 'net-tools' 'openssh-client' 'curl' 'wget' 'dnsutils' 'iptables'
    'ufw' 'gnupg2' 'software-properties-common' 'apt-transport-https'
    
    # Networking
    'network-manager' 'openssh-server' 'dnsutils' 'bind9-host' 'net-tools'

    # Package management
    'apt' 'dpkg' 'snapd' 'flatpak' 'rpm' 'dnf' 'pacman'

    # Desktop environment components
    'xorg' 'wayland'
    'gnome-shell' 'gnome-session' 'gnome-control-center' 'gnome-settings-daemon' 'gnome-terminal'
    'kde-plasma-desktop' 'plasma-desktop' 'plasma-workspace' 'konsole'
    'xfce4' 'xfce4-terminal'
    'cinnamon-desktop-environment' 'cinnamon'
    'mate-desktop-environment' 'mate-terminal'
    'lxde' 'lxqt' 'lxterminal'

    # Display managers
    'gdm3' 'lightdm' 'sddm' 'xdm'

    # Audio
    'pulseaudio' 'alsa-utils' 'pavucontrol'

    # Development tools
    'gcc' 'g++' 'make' 'cmake' 'build-essential'
    'git'
    'python3' 'perl' 'ruby' 'nodejs'

    # Text editors and file management
    'nano' 'vim' 'gedit' 'kate' 'mousepad'
    'nautilus' 'dolphin' 'thunar' 'pcmanfm' 'nemo' 'caja'

    # Bootloader and related utilities
    'grub2' 'grub-pc' 'grub-efi'

    # Compression tools
    'gzip' 'bzip2' 'xz-utils' 'zip' 'unzip'

    # Disk management
    'parted' 'gparted' 'lvm2' 'smartmontools'

    # System monitoring
    'htop' 'sysstat' 'lsof' 'iotop'

    # Security tools
    'ufw' 'firewalld' 'sudo' 'polkit' 'libpam*'

    # Multimedia
    'vlc' 'mpv' 'gimp' 'eog' 'gwenview'

    # Printer and scanner support
    'cups' 'printer-driver-*'

    # Ubuntu/Kubuntu/Kali-specific tools
    'kubuntu-desktop' 'muon' 'discover'
    'ubuntu-desktop' 'gnome-software' 'ubuntu-drivers-common'
    'kali-linux-default' 'kali-desktop-*'
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
        echo "Removing $package..."
        sudo apt remove "$package" -y
    fi
done

# Cleanup and update
sudo apt autoclean 
sudo apt autoremove -y
sudo apt update 

# Optionally remove all config files of removed packages
#dpkg -l | grep '^rc' | awk '{print $2}' | sudo xargs dpkg --purge

echo "The script has been successfully executed"
echo "Non-essential tools and applications have been removed/uninstalled"
echo "Thanks for using this script"
