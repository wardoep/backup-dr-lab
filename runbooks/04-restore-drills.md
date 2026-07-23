# 04 — Restore drills

**Goal:** prove — repeatedly, on a schedule — that a restore actually works. This is the whole point of the repo.

## Steps

1. **Single-file restore-and-verify** with the helper (restores the latest snapshot's copy of a path to a temp dir and diffs it against the source):
   ```bash
   cd scripts
   ./restore-test.sh /etc/hostname
   ```
   Expected: `PASS: restored copy of '/etc/hostname' is identical to the source.` Then **log it in [DRILLS.md](../DRILLS.md)**.

2. **Restore a whole directory to an alternate path** (never restore over the live copy during a drill):
   ```bash
   set -a; . restic.env; set +a
   restic restore latest --path /srv --target /tmp/restore-srv
   diff -rq /srv /tmp/restore-srv/srv | head
   ```

3. **Drill the OFFSITE repo, not just local.** Point at the offsite repo and restore something — this is the only thing that proves the offsite credentials and network path work:
   ```bash
   RESTIC_ENV=./restic.offsite.env ./restore-test.sh /etc/hostname
   ```

4. **Browse a snapshot without restoring** (useful to find the right file):
   ```bash
   restic mount /mnt/restic-browse    # explore snapshots as a filesystem, then unmount
   ```

5. **Log every drill** in [DRILLS.md](../DRILLS.md) with repo, method, result, and time taken. The schedule target is weekly (local), monthly (offsite), quarterly (full DR rehearsal).

## Verify

```bash
./restore-test.sh /etc/hostname && echo "drill passed — now record it in DRILLS.md"
```
A drill isn't done until its outcome is written in DRILLS.md.

## If it breaks

- **`restore-test.sh` reports DIFFERENCES.** Often the live file changed since the snapshot (legit) — inspect the diff. If the restored copy is missing files, the backup's excludes are too aggressive.
- **Offsite restore fails but local works.** Credentials expired or the network path is down — exactly the silent failure drills exist to catch. Fix and re-drill.
- **`restic mount` unavailable.** Needs FUSE; install `fuse` or use `restic restore`/`dump` instead.

## What I learned

*Filled in after I complete this milestone.*

<!-- Prompts to answer once done:
     - Did my FIRST real restore work, or did it surface a problem? (Most people's first drill finds something.)
     - What did drilling the offsite repo catch that the local drill couldn't?
     - How long did a realistic restore actually take — does it fit my RTO? -->
