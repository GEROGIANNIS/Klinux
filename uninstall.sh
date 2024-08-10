#!/bin/bash

# Define log files with timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="/var/log/package_cleanup.log"
WORKING_DIR="$(pwd)"
RELATIVE_LOG_DIR="$WORKING_DIR/logs"
RELATIVE_LOG_FILE="$RELATIVE_LOG_DIR/uninstall_${TIMESTAMP}.log"

# Ensure the logs directory exists
mkdir -p "$RELATIVE_LOG_DIR"

# Load the whitelist from the external file
WHITELIST_FILE="$(pwd)/whitelist.txt"
whitelist=()

while IFS= read -r line; do
    # Remove leading/trailing whitespace
    line=$(echo "$line" | xargs)
    # Skip comments and empty lines
    [[ $line =~ ^#.*$ || -z $line ]] && continue
    whitelist+=("$line")
done < "$WHITELIST_FILE"

# Function to check if a package is in the whitelist
is_whitelisted() {
    local pkg=$1
    for core_pkg in "${whitelist[@]}"; do
        # Handle wildcards
        if [[ $pkg == $core_pkg || $core_pkg == * && $pkg == ${core_pkg%%\*}* ]]; then
            return 0
        fi
    done
    return 1
}

# Function to check if a package is essential for the system
is_essential() {
    local pkg=$1
    if dpkg -s "$pkg" 2>/dev/null | grep -q 'Essential: yes'; then
        return 0
    fi
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
    if is_whitelisted "$package"; then
        echo "Keeping whitelisted package: $package" | tee -a "$LOG_FILE" "$RELATIVE_LOG_FILE"
    else
        if is_essential "$package"; then
            echo "Keeping essential package: $package" | tee -a "$LOG_FILE" "$RELATIVE_LOG_FILE"
        else
            echo "Identified non-whitelisted and non-essential package to remove: $package" | tee -a "$LOG_FILE" "$RELATIVE_LOG_FILE"
            packages_to_remove+="$package "
        fi
    fi
done

# Check if there are any packages to remove
if [ -n "$packages_to_remove" ]; then
    echo "Packages to remove: $packages_to_remove" | tee -a "$LOG_FILE" "$RELATIVE_LOG_FILE"

    # Loop through each package to remove
    for package in $packages_to_remove; do
        echo "Attempting to remove package: $package" | tee -a "$LOG_FILE" "$RELATIVE_LOG_FILE"
        if sudo apt remove "$package" -y >> "$LOG_FILE" 2>&1; then
            echo "Removed $package successfully ✔" | tee -a "$RELATIVE_LOG_FILE"
        else
            echo "Failed to remove $package" | tee -a "$LOG_FILE" "$RELATIVE_LOG_FILE"
        fi
    done
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
