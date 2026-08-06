# Backup & Disaster Recovery Lab

A 3-2-1 backup and disaster-recovery practice for my homelab, built on **restic**: encrypted local *and* offsite repositories, scheduled with systemd, a real retention policy, and — the part that actually matters — **regularly tested restores**. Documented the same way I'd document a backup regime I was responsible for.

## Overview

"Do you have backups?" is the wrong question; "when did you last *restore* from one?" is the right one. Plenty of shops have backups that have never been tested and quietly don't work. This lab builds the whole discipline: three copies of the data on two kinds of media with one copy offsite, encrypted so an offsite copy isn't a data-breach waiting to happen, scheduled so it happens without me remembering, pruned so it doesn't grow forever — and **drilled**, so I can prove a restore works and know how long a real recovery takes. The headline skill here is *"I test my restores,"* so the restore drills are the centre of the repo, not an afterthought.

The runbooks are the *how*; **[TAKEAWAYS.md](TAKEAWAYS.md) is the *why*** — why 3-2-1, why encryption, why an untested backup isn't a backup.

## Architecture

```
                 ┌───────────────────────┐
                 │   Homelab host        │  source data (/etc, /srv, configs, DBs)
                 └───────────┬───────────┘
                    restic backup (encrypted, deduped)
              ┌─────────────┴──────────────┐
     ┌────────┴─────────┐        ┌──────────┴───────────┐
     │  LOCAL repo      │        │  OFFSITE repo        │
     │  external disk   │        │  S3-compatible bucket │
     │  /mnt/backup     │        │  OR 2nd host / Tailscale sftp
     └──────────────────┘        └──────────────────────┘
        copy 2, media A             copy 3, offsite
      (copy 1 = the live data)      3-2-1 satisfied
```

## Milestones

| # | Runbook |
|---|---------|
| 0 | [The 3-2-1 strategy and threat model](runbooks/00-strategy-3-2-1.md) |
| 1 | [Install restic, init local + offsite repos](runbooks/01-install-init-repos.md) |
| 2 | [Backup script + systemd timer](runbooks/02-backup-script-and-timer.md) |
| 3 | [Retention and pruning](runbooks/03-retention-and-pruning.md) |
| 4 | [Restore drills](runbooks/04-restore-drills.md) |
| 5 | [Disaster-recovery runbook](runbooks/05-dr-runbook.md) |

Restore drills get logged in [`DRILLS.md`](DRILLS.md) as I run them.

## What's in this repo

- [`scripts/backup.sh`](scripts/backup.sh) — restic wrapper: reads config from an env file, backs up the configured paths to a repo, then applies the retention policy (`forget --prune`), and logs the result.
- [`scripts/restore-test.sh`](scripts/restore-test.sh) — restores the latest snapshot of a chosen path into a temp dir and diffs it against the source, reporting PASS/FAIL — the automation behind "I test my restores."
- [`scripts/restic.env.example`](scripts/restic.env.example) — repo location, password source, and paths (copy to `restic.env`, which is gitignored).
- [`systemd/`](systemd/) — a service + timer to run the backup on a schedule.
- [`DRILLS.md`](DRILLS.md) — the restore-drill log (template + format).

## Skills this lab exercises

Backup strategy (3-2-1), the restic backup tool (encrypted, deduplicated, snapshot-based repos), local and offsite/S3 repositories, systemd services and timers for scheduling, retention policies (`forget`/`prune`), integrity checking (`restic check`), tested restores, and disaster-recovery planning (RPO/RTO, recovery order).

## What I learned

Filled in per milestone as the lab progresses — see the closing section of each runbook and the [drill log](DRILLS.md). The point of this repo is to prove I don't just *make* backups, I *restore* from them — on a schedule, and I know how long it takes.

---
Built and maintained by **Edward J. Penna** — [github.com/wardoep](https://github.com/wardoep)
