# What this lab is really teaching — and why

The runbooks say *how* to run restic. This says *why* the regime is shaped this way. If I can explain everything here without notes, the lab did its job.

## The big picture

Backup is the one area of IT where being almost right is the same as being wrong: a backup that "runs every night" but can't be restored is worse than no backup, because it buys false confidence. So this lab is built around a single uncomfortable question — **"when did you last restore?"** — and everything else follows from taking that seriously: multiple copies so one failure isn't fatal, offsite so a fire or ransomware event doesn't take the backups with the originals, encryption so the offsite copy isn't itself a breach, scheduling so it doesn't depend on me remembering, retention so it doesn't grow without bound, and **drills** so "it works" is a fact I've verified this month, not a hope.

A mental model that holds up: **backups are an insurance policy, and a restore drill is reading the fine print.** Nobody wants to discover an exclusion clause at claim time. The drill is how you find out the policy pays out *before* you need it.

## Milestone-by-milestone: what, why, takeaway

### 0 — The 3-2-1 strategy
**Builds:** the plan — **3** copies of the data, on **2** different media, with **1** offsite.
**Why each number:** three copies means two independent failures can't wipe you out. Two media types means a single failure *mode* (a bad batch of drives, a filesystem bug) doesn't hit all copies. One offsite means a location-level disaster (fire, theft, ransomware that reaches every local share) still leaves a survivor. The threat model — drive death, fat-finger deletion, ransomware, fire — is what justifies each part; skip a part and you're exposed to a specific, nameable disaster.
**Takeaway:** 3-2-1 isn't a slogan; each digit closes off a specific way of losing everything.

### 1 — restic and encrypted repos
**Builds:** local and offsite restic repositories.
**Why restic:** it's encrypted by default (the offsite copy is useless to whoever finds the bucket), deduplicated (a daily backup of mostly-unchanged data is cheap), and snapshot-based (every backup is a point you can restore *from*, not a single mirror that overwrites yesterday). The critical operational detail: **the repo password is not recoverable.** Lose it and the backups are cryptographic noise — which is why it lives in a `0600` password file and why the DR runbook treats "where's the repo password" as a first-class question.
**Takeaway:** encryption makes offsite safe, but it moves the single point of failure to the password — protect and back up the password itself.

### 2 — Script + timer
**Builds:** an unattended, logged backup.
**Why systemd, why `Persistent=true`:** a backup that depends on a human is a backup that eventually doesn't happen. The timer runs it nightly and, crucially, *catches up* if the machine was off at 02:30 — a laptop or a homelab box that isn't on 24/7 would otherwise silently skip days.
**Takeaway:** automate it and make it catch up on misses; a backup you have to remember isn't reliable.

### 3 — Retention and pruning
**Builds:** a policy that keeps useful history without growing forever.
**Why `forget` *and* `--prune`:** `forget` just drops which snapshots you keep (daily/weekly/monthly); `--prune` is what actually repacks the repo and reclaims the space. Keeping a grandfather-father-son spread (7 daily, 4 weekly, 6 monthly) means you can recover from a problem you didn't notice for weeks, not just last night.
**Takeaway:** retention balances "how far back can I go" against space; pruning is what makes the policy real on disk.

### 4 — Restore drills
**Builds:** proof, on a schedule, that a restore works — the whole point of the repo.
**Why automate the diff:** `restore-test.sh` restores a path to a temp dir and compares it to the source, so a drill is one command with a PASS/FAIL, which means it actually gets done. Drilling the *offsite* repo specifically also tests the credentials and the network path, which is where silent failures hide.
**Takeaway:** a backup is only proven by a restore; make the drill one command and do it on a cadence.

### 5 — DR runbook
**Builds:** the "the whole host is gone" plan — recovery order, and **RPO/RTO**.
**Why the numbers matter:** **RPO** (recovery point objective) is how much data you can afford to lose — set by your backup *frequency*. **RTO** (recovery time objective) is how long recovery may take — and the only honest way to know it is to have rehearsed a full restore and timed it. A DR plan you've never rehearsed is fiction with a nice cover.
**Takeaway:** know how much data you can lose (RPO) and how long recovery takes (RTO) — and the second number is only real once you've timed a rehearsal.

## If I only remember five things

1. "When did you last restore?" is the only question that proves a backup. Drill it on a schedule.
2. 3-2-1: three copies, two media, one offsite — each part closes a specific disaster.
3. Encryption makes offsite safe but shifts the risk to the password; protect and back up the password.
4. Automate with catch-up (`Persistent=true`) so missed days don't happen silently.
5. RPO is set by backup frequency; RTO is only real once you've rehearsed and timed a full recovery.

---
Built and maintained by **Edward J. Penna** — [github.com/wardoep](https://github.com/wardoep)
