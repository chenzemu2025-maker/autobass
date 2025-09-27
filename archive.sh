#!/bin/bash
# archive.sh - with compression + logging

# ========== log tool ==========
_now() { date +"%Y-%m-%d %H:%M:%S"; }

LOG_FILE="$(cd "$(dirname "$0")" && pwd)/archive.log"

log_info()  { local m="INFO: [$(_now)] $*";  echo "$m";      echo "$m" >> "$LOG_FILE"; }
log_error() { local m="ERROR: [$(_now)] $*"; echo "$m" 1>&2; echo "$m" >> "$LOG_FILE"; }

# ========== enter check ==========
show_help() {
    echo "Usage: $0 [source_directory] [target_directory]"
    echo "Options:"
    echo "  -h, --help    Show this help message"
}

# help 
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# Two argument
if [[ $# -ne 2 ]]; then
    echo "Error: You must provide a source and a target directory."
    show_help
    exit 1
fi

SOURCE=$1
TARGET=$2

# Source dirction must exist
if [[ ! -d "$SOURCE" ]]; then
    echo "Error: Source directory does not exist: $SOURCE"
    exit 1
fi

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
NEW_FOLDER="$TARGET/backup_$TIMESTAMP"
mkdir -p "$NEW_FOLDER"  # -p make sure even if parent is not exist, it will be created together 

echo "Created: $NEW_FOLDER"

cp -a "$SOURCE"/. "$NEW_FOLDER"/ 2>/dev/null

if [[ $? -ne 0 ]]; then
    echo "Error: Copy failed."
    exit 1
fi

echo "Backup completed!"
echo "Copied from: $SOURCE"
echo "To          : $NEW_FOLDER"
exit 0
