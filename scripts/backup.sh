#!/usr/bin/env bash
#
# backup.sh — restic backup wrapper for the homelab.
#
# Reads configuration from restic.env (repository, password source, paths,
# retention), runs an encrypted deduplicated backup, then applies the retention
# policy with a prune, and logs the outcome. Designed to be run by hand or from
# the systemd timer in ../systemd/.
#
# Usage:
#   ./backup.sh                       # uses ./restic.env
#   RESTIC_ENV=/path/to/restic.env ./backup.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESTIC_ENV="${RESTIC_ENV:-$SCRIPT_DIR/restic.env}"

if [[ ! -f "$RESTIC_ENV" ]]; then
  echo "ERROR: config not found at $RESTIC_ENV (copy restic.env.example to restic.env)" >&2
  exit 1
fi

# Load config (exported vars: RESTIC_REPOSITORY, RESTIC_PASSWORD_FILE, BACKUP_PATHS, ...)
set -a
# shellcheck disable=SC1090
. "$RESTIC_ENV"
set +a

command -v restic >/dev/null 2>&1 || { echo "ERROR: restic not installed" >&2; exit 1; }
: "${RESTIC_REPOSITORY:?RESTIC_REPOSITORY must be set in restic.env}"
: "${BACKUP_PATHS:?BACKUP_PATHS must be set in restic.env}"

TAG="${BACKUP_TAG:-homelab}"
log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*"; }

# Build the exclude argument only if the file exists.
exclude_args=()
if [[ -n "${BACKUP_EXCLUDES_FILE:-}" && -f "${BACKUP_EXCLUDES_FILE}" ]]; then
  exclude_args=(--exclude-file "${BACKUP_EXCLUDES_FILE}")
fi

log "Backup starting -> repo: $RESTIC_REPOSITORY"
log "Paths: $BACKUP_PATHS"

# restic wants the paths as separate words; BACKUP_PATHS is intentionally unquoted here.
# shellcheck disable=SC2086
restic backup --tag "$TAG" "${exclude_args[@]}" $BACKUP_PATHS
log "Backup snapshot created."

# Apply retention. --prune actually reclaims space (repacks the repo).
log "Applying retention: daily=${KEEP_DAILY:-7} weekly=${KEEP_WEEKLY:-4} monthly=${KEEP_MONTHLY:-6}"
restic forget --tag "$TAG" \
  --keep-daily "${KEEP_DAILY:-7}" \
  --keep-weekly "${KEEP_WEEKLY:-4}" \
  --keep-monthly "${KEEP_MONTHLY:-6}" \
  --prune
log "Retention applied."

# Cheap consistency check every run; a full --read-data check belongs on a slower schedule.
restic check || log "WARNING: restic check reported repository errors"

# Show the most recent snapshots so the run log ends with proof the new backup exists.
restic snapshots --tag "$TAG" --compact | tail -n 5
log "Backup run complete."
