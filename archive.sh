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
log_info "archive script started."

# ======== source/target check ========
if [[ ! -d "$SOURCE" || ! -r "$SOURCE" ]]; then
    log_error "Source directory ($SOURCE) does not exist or is not readable. Exiting."
    exit 2
fi

if [[ ! -d "$TARGET" ]]; then
    if ! mkdir -p "$TARGET" 2>/dev/null; then
        log_error "Target directory ($TARGET) does not exist or could not be created. Exiting."
        exit 3
    fi
fi

# ========== Compressed archiving ==========
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ARCHIVE_PATH="$TARGET/backup_${TIMESTAMP}.tar.gz"
log_info "Backing up from $SOURCE to $ARCHIVE_PATH"

if tar -czf "$ARCHIVE_PATH" -C "$SOURCE" . >>"$LOG_FILE" 2>&1; then
    log_info "Backup completed successfully."
else
    log_error "Backup failed during compression."
    exit 4
fi
