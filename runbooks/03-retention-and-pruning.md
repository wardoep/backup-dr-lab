# 03 — Retention and pruning

**Goal:** keep enough history to recover from a problem you didn't notice for weeks, without the repo growing forever.

## The policy

The backup uses a grandfather-father-son spread, set in `restic.env`:
- `KEEP_DAILY=7` — the last 7 days
- `KEEP_WEEKLY=4` — one per week for a month
- `KEEP_MONTHLY=6` — one per month for half a year

`restic forget` decides *which snapshots to keep*; `--prune` is the step that actually repacks the repo and reclaims disk. The wrapper runs both.

## Steps

1. **See what the policy would remove, without doing it** (dry run):
   ```bash
   set -a; . scripts/restic.env; set +a
   restic forget --tag "$BACKUP_TAG" \
     --keep-daily "$KEEP_DAILY" --keep-weekly "$KEEP_WEEKLY" --keep-monthly "$KEEP_MONTHLY" \
     --dry-run
   ```
   Read the "would remove" list and make sure it's dropping *old* snapshots, not recent ones.

2. **Apply it for real with a prune:**
   ```bash
   restic forget --tag "$BACKUP_TAG" \
     --keep-daily "$KEEP_DAILY" --keep-weekly "$KEEP_WEEKLY" --keep-monthly "$KEEP_MONTHLY" \
     --prune
   ```
   (The nightly `backup.sh` already does this — this is for understanding and one-off cleanups.)

3. **Watch the repo size** so the policy is doing its job:
   ```bash
   restic stats --mode raw-data
   ```

4. **Schedule a periodic integrity check** separate from the nightly prune — cheap metadata check often, full data check occasionally:
   ```bash
   restic check                 # verifies structure + metadata
   restic check --read-data-subset=5%   # actually re-reads a sample of the data
   ```

## Verify

```bash
restic snapshots --compact         # spread matches the policy (recent dailies, older weeklies/monthlies)
restic check                       # "no errors were found"
```

## If it breaks

- **`forget` wants to remove a snapshot I need.** Widen the keep counts, or `--keep-tag`/`--keep-last N` to protect specific ones.
- **Repo size not shrinking after forget.** You ran `forget` without `--prune` — the snapshots are dereferenced but the data isn't reclaimed until a prune.
- **`check` reports errors.** Stop trusting that repo for restores until resolved; re-run with `--read-data` to find the extent, and rely on the *other* repo (this is why there are two).

## What I learned

*Filled in after I complete this milestone.*

<!-- Prompts to answer once done:
     - What history depth do I actually want, and why? (How long might a problem go unnoticed?)
     - forget vs prune — did the size only drop after the prune?
     - How often is a full --read-data check worth its cost for my repo size? -->
