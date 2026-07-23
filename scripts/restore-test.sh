#!/usr/bin/env bash
#
# restore-test.sh — prove a restore actually works.
#
# Restores the latest snapshot's copy of a chosen path into a throwaway temp dir,
# then diffs it against the live source and reports PASS/FAIL. This is the
# automation behind "I test my restores" — run it on a schedule and log the
# result in ../DRILLS.md.
#
# Usage:
#   ./restore-test.sh /etc/hostname          # test-restore one file/dir and diff it
#   ./restore-test.sh /srv/someapp/config
#
# Env: reads restic.env the same way backup.sh does.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESTIC_ENV="${RESTIC_ENV:-$SCRIPT_DIR/restic.env}"

TARGET_PATH="${1:-}"
if [[ -z "$TARGET_PATH" ]]; then
  echo "Usage: $0 <absolute-path-to-restore-and-verify>" >&2
  exit 2
fi

if [[ ! -f "$RESTIC_ENV" ]]; then
  echo "ERROR: config not found at $RESTIC_ENV" >&2
  exit 1
fi
set -a
# shellcheck disable=SC1090
. "$RESTIC_ENV"
set +a

command -v restic >/dev/null 2>&1 || { echo "ERROR: restic not installed" >&2; exit 1; }

RESTORE_DIR="$(mktemp -d "${TMPDIR:-/tmp}/restore-test.XXXXXX")"
cleanup() { rm -rf "$RESTORE_DIR"; }
trap cleanup EXIT

echo "Restoring latest snapshot of '$TARGET_PATH' into $RESTORE_DIR ..."
# 'latest' + --path restricts to snapshots containing that path; --include limits what's extracted.
restic restore latest --path "$TARGET_PATH" --include "$TARGET_PATH" --target "$RESTORE_DIR"

restored_copy="$RESTORE_DIR$TARGET_PATH"
if [[ ! -e "$restored_copy" ]]; then
  echo "FAIL: expected restored path not found at $restored_copy" >&2
  exit 1
fi

echo "Comparing restored copy against live source ..."
if diff -rq "$TARGET_PATH" "$restored_copy"; then
  echo "PASS: restored copy of '$TARGET_PATH' is identical to the source."
  echo "(Record this drill in DRILLS.md.)"
  exit 0
else
  # Differences aren't always a failure — the live file may have changed since the
  # snapshot. Report so a human judges it, but exit non-zero so a scheduled run flags it.
  echo "DIFFERENCES found — the source may have changed since the snapshot, or the restore is incomplete." >&2
  echo "Review the diff above and record the outcome in DRILLS.md." >&2
  exit 1
fi
