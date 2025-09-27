#!/bin/bash
# archive.sh — compression + logging + config fallback (Feature 2)

set -o errexit
set -o pipefail
set -o nounset

# ---------- Paths & log ----------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="$SCRIPT_DIR/archive.log"

# ---------- Time & logging ----------
_now() { date +"%Y-%m-%d %H:%M:%S"; }
log_info()  { local m="INFO: [$(_now)] $*";  echo "$m";      echo "$m" >> "$LOG_FILE"; }
log_error() { local m="ERROR: [$(_now)] $*"; echo "$m" 1>&2; echo "$m" >> "$LOG_FILE"; }

show_help() {
  cat <<'USAGE'
Usage:
  ./archive.sh [SOURCE] [TARGET]
  ./archive.sh                  # read SOURCE/TARGET from archive.conf
Options:
  -h, --help  Show help
USAGE
}

# ---------- Parse args (no dry-run here; Feature 3 再加) ----------
if [[ $# -ge 1 && ( "$1" == "-h" || "$1" == "--help" ) ]]; then
  show_help; exit 0
fi

SOURCE=""
TARGET=""

if [[ $# -eq 2 ]]; then
  SOURCE="$1"
  TARGET="$2"
else
  # read from archive.conf (two-line format)
  CONF="$SCRIPT_DIR/archive.conf"
  if [[ -f "$CONF" ]]; then
    # 读取前两行
    SOURCE="$(sed -n '1p' "$CONF" | sed 's/^\s*//;s/\s*$//')"
    TARGET="$(sed -n '2p' "$CONF" | sed 's/^\s*//;s/\s*$//')"
  fi
fi

# 校验 conf/参数有效
if [[ -z "${SOURCE}" || -z "${TARGET}" ]]; then
  log_error "Missing source/target. Provide two args OR put two lines in archive.conf (source on line 1, target on line 2)."
  show_help
  exit 1
fi

log_info "archive script started."

# ---------- Validate source & target ----------
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

# ---------- Compress to tar.gz ----------
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ARCHIVE_PATH="$TARGET/backup_${TIMESTAMP}.tar.gz"
log_info "Backing up from $SOURCE to $ARCHIVE_PATH"

if tar -czf "$ARCHIVE_PATH" -C "$SOURCE" . >>"$LOG_FILE" 2>&1; then
  log_info "Backup completed successfully."
else
  log_error "Backup failed during compression."
  exit 4
fi
