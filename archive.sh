# This is minimal viable product script
#!/bin/bash

# Function to show usage instructions
show_help() {
    echo "Usage: $0 [source_directory] [target_directory]"
    echo "Options:"
    echo "  -h, --help    Show this help message"
}

# If user asks for help
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# Check if two arguments are given
if [[ $# -ne 2 ]]; then
    echo "Error: You must provide a source and a target directory."
    show_help
    exit 1
fi

# Assign arguments to variables
SOURCE=$1
TARGET=$2

# Check if source exists
if [[ ! -d "$SOURCE" ]]; then
    echo "Error: Source directory does not exist."
    exit 1
fi

# Create a timestamp (e.g., 20250924_223000)
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create new backup folder inside target directory
NEW_FOLDER="$TARGET/backup_$TIMESTAMP"
mkdir -p "$NEW_FOLDER"

# Copy files (you can use rsync or cp, here I use cp)
cp -r "$SOURCE"/* "$NEW_FOLDER"/

echo "Backup completed!"
echo "Files from $SOURCE were copied to $NEW_FOLDER"
