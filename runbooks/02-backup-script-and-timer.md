# 02 — Backup script + systemd timer

**Goal:** an unattended, logged nightly backup that catches up if the machine was off.

## Steps

1. **Run the wrapper by hand first** to confirm it backs up and prunes:
   ```bash
   cd scripts
   ./backup.sh
   ```
   Expected: a "Backup snapshot created" line, the retention step, and the last few snapshots printed. [`backup.sh`](../scripts/backup.sh) reads `restic.env`, runs `restic backup` of `BACKUP_PATHS`, then `restic forget --prune` per the keep-policy.

2. **Decide excludes.** Create `scripts/excludes.txt` (one glob per line) for things you don't want — caches, temp, huge reproducible files:
   ```
   **/node_modules
   **/.cache
   /var/lib/docker/volumes/*/._*
   ```
   Point `BACKUP_EXCLUDES_FILE` at it in `restic.env`.

3. **Install the systemd units** (edit the `ExecStart` path first):
   ```bash
   sudo cp ../systemd/restic-backup.service ../systemd/restic-backup.timer /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable --now restic-backup.timer
   ```

4. **Force a run through systemd** to confirm the unit works end-to-end:
   ```bash
   sudo systemctl start restic-backup.service
   journalctl -u restic-backup.service -n 30 --no-pager
   ```

## Verify

```bash
systemctl list-timers restic-backup.timer          # shows NEXT and LAST run
set -a; . scripts/restic.env; set +a
restic snapshots --compact | tail                  # a fresh snapshot from the run
```
The timer lists a next run; a new snapshot exists with today's timestamp.

## If it breaks

- **Service fails with "config not found".** The `ExecStart` path or `RESTIC_ENV` is wrong — the unit runs as root, so `restic.env` and the password file must be readable by root.
- **Runs by hand but not via systemd.** Almost always environment/paths — systemd has a minimal env; the script sources `restic.env` itself, so make sure that file has everything (it should, via the exported vars).
- **Backup succeeds but nothing is pruned.** `forget` without `--prune` doesn't reclaim space — the script includes `--prune`; if you edited it, put that back.

## What I learned

*Filled in after I complete this milestone.*

<!-- Prompts to answer once done:
     - What did I exclude, and how much space did that save?
     - Why does the timer need Persistent=true for my host specifically?
     - Running as root vs a dedicated backup user — what did I choose and why? -->
