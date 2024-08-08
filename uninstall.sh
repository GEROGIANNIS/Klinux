#!/bin/bash

# Define a function to check if a package is part of the core system
is_core_package() {
    local pkg=$1
    if dpkg-query -W --showformat='${Priority}\n' "$pkg" | grep -q 'required\|important\|standard'; then
        return 0
    else
        return 1
    fi
}

# Get a list of all installed packages
INSTALLED_PACKAGES=$(dpkg-query -W --showformat='${Package}\n')

# Loop through each installed package and check if it's part of the core system
for package in $INSTALLED_PACKAGES; do
    if ! is_core_package "$package"; then
        echo "Removing $package..."
        sudo apt remove "$package" -y
    fi
done

# Cleanup and update
sudo apt autoclean 
sudo apt autoremove -y
sudo apt update 

# Optionally remove all config files of removed packages
dpkg -l | grep '^rc' | awk '{print $2}' | sudo xargs dpkg --purge

echo "The script has been successfully executed"
echo "Unnecessary tools have been removed/uninstalled"
echo "Thanks for using this script"
