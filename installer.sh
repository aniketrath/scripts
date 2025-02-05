#!/bin/bash

# Define the paths
CONFIG_FILE="/etc/nixos/configuration.nix"
BACKUP_FILE="/etc/nixos/configuration.nix.bak"

# Check if the backup file exists
if [ -f "$BACKUP_FILE" ]; then
    echo "Backup file exists. Deleting it..."
    rm "$BACKUP_FILE"
fi

# Create a new backup file
echo "Creating a new backup file..."
cp "$CONFIG_FILE" "$BACKUP_FILE"

# Copy the current configuration file to /etc/nixos/configuration.nix
echo "Copying the current configuration file to $CONFIG_FILE..."
cp /home/sh0r3s/Projects/Github/scripts/configuration.nix "$CONFIG_FILE"

echo "Operation completed."