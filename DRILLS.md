# Restore-drill log

An untested backup is a hope, not a backup. This log is where I record every restore drill — because "when did you last restore?" is the question that matters. Each drill is written **after** running it, in the format below.

## Why this page exists

Backups fail silently: a misconfigured exclude, an expired offsite credential, a repo that won't decrypt because the password was never really saved. The only way to know a backup works is to restore from it, on a schedule, and write down what happened. This is that record.

## Entry format

```
### <date> — <what was restored>
Repo:          local | offsite
Snapshot:      <id / "latest">
Method:        restore-test.sh | manual restic restore | full DR rehearsal
Result:        PASS | FAIL | PASS-with-notes
Time taken:    <minutes>
Notes:         anything surprising — a wrong exclude, a perms issue, how long it took
```

## Drill schedule (target)

| Cadence | Drill |
|---|---|
| Weekly | `restore-test.sh` on one file/dir from the **local** repo |
| Monthly | Restore a directory from the **offsite** repo (proves the offsite copy + credentials work) |
| Quarterly | Full DR rehearsal per [runbook 05](runbooks/05-dr-runbook.md) — rebuild a scratch host from bare metal |

## Entries

_No drills logged yet — entries go here as I run them, newest first._

<!-- Example of the format once I start (do NOT treat as a real completed drill):
### YYYY-MM-DD — /etc from local repo
Repo:          local
Snapshot:      latest
Method:        restore-test.sh /etc/hostname
Result:        PASS
Time taken:    ~2 min
Notes:         ...
-->
