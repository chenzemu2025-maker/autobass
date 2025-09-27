#!/bin/bash
# archive.sh — compression + logging + config fallback + exclusions + dry-run (Feature 3)

set -o errexit
set -o pipefail
set -o nounset

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="$SCRIPT_DIR/archive.log"

_now() { date +"%Y-%m-%d %H:%M:%S"; }
log_info()  { local m="INFO: [$(_now)] $*";  echo "$m";      echo "$m" >> "$LOG_FILE"; }
log_error() { local m="ERROR: [$(_now)] $*"; echo "$m" 1>&2; echo "$m" >> "$LOG_FILE"; }

show_help() {
  cat <<'USAGE'
Usage:
  ./archive.sh [SOURCE] [TARGET] [--dry-run|-d]
  ./archive.sh [--dry-run|-d]   # read SOURCE/TARGET from archive.conf
Options:
  -h, --help   Show help
  -d, --dry-run  Simulate backup (no archive written)
USAGE
}

# ---------- Parse args ----------
DRY_RUN=0
ARGS=()
for a in "$@"; do
  case "$a" in
    -h|--help) show_help; exit 0 ;;
    -d|--dry-run) DRY_RUN=1 ;;
    *) ARGS+=("$a") ;;
  esac
done

SOURCE=""
TARGET=""

if [[ ${#ARGS[@]} -eq 2 ]]; then
  SOURCE="${ARGS[0]}"
  TARGET="${ARGS[1]}"
else
  CONF="$SCRIPT_DIR/archive.conf"
  if [[ -f "$CONF" ]]; then
    SOURCE="$(sed -n '1p' "$CONF" | sed 's/^\s*//;s/\s*$//')"
    TARGET="$(sed -n '2p' "$CONF" | sed 's/^\s*//;s/\s*$//')"
  fi
fi

if [[ -z "${SOURCE}" || -z "${TARGET}" ]]; then
  log_error "Missing source/target. Provide two args OR put two lines in archive.conf (source on line1, target on line2)."
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

# ---------- Exclusions ----------
EXCLUDE_OPT=()
EXCLUDE_FILE="$SCRIPT_DIR/.bassignore"
if [[ -f "$EXCLUDE_FILE" ]]; then
  EXCLUDE_OPT=( --exclude-from="$EXCLUDE_FILE" )
fi

# ---------- Compress / Dry-run ----------
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ARCHIVE_PATH="$TARGET/backup_${TIMESTAMP}.tar.gz"

Simulation: Compress the output and throw it to devnull; Enter the details of -v into logSimulation: Compress the output and throw it to devnull; Enter the details of -v into loglog_info "Backing up from $SOURCE to $ARCHIVE_PATH"

if [[ $DRY_RUN -eq 1 ]]; then
  log_info "Dry-run enabled. Simulating backup."
  # Simulation: Compress the output and throw it to dev/null; Enter the details of -v into log
  if tar -czvf /dev/null -C "$SOURCE" "${EXCLUDE_OPT[@]}" . >>"$LOG_FILE" 2>&1; then
    log_info "Backup completed successfully (dry-run)."
    exit 0
  else
    log_error "Backup failed during compression (dry-run)."
    exit 4
  fi
else
  if tar -czf "$ARCHIVE_PATH" -C "$SOURCE" "${EXCLUDE_OPT[@]}" . >>"$LOG_FILE" 2>&1; then
    log_info "Backup completed successfully."
    exit 0
  else
    log_error "Backup failed during compression."
    exit 4
  fi
fi
