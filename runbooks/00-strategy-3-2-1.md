# 00 — The 3-2-1 strategy and threat model

**Goal:** decide what to protect, against what, and why the 3-2-1 shape follows — before touching any tool.

## What am I protecting, and from what?

List the data that would actually hurt to lose, and the disasters each backup layer defends against:

| Threat | What defends against it |
|---|---|
| Drive death / hardware failure | a second copy on other media |
| Fat-finger deletion / bad edit | snapshots with history (restore yesterday) |
| Ransomware / malware encrypting shares | an offsite copy the malware can't reach; append-only/immutable where possible |
| Fire / theft / site loss | the offsite copy |
| Silent corruption | integrity checks (`restic check`) + multiple restore points |

## 3-2-1, and why each number

- **3 copies** — the live data plus two backups. Two independent failures can't wipe you out.
- **2 media types** — so one failure *mode* (a bad drive batch, a filesystem bug) doesn't hit every copy.
- **1 offsite** — so a location-level disaster still leaves a survivor.

## The scope for this lab

- **Source data:** `/etc` (system config), `/srv` (service data), important home files, and `/var/lib/docker/volumes` (the self-hosted stack's data).
- **Copy 2 (local):** a restic repo on an external disk mounted at `/mnt/backup`.
- **Copy 3 (offsite):** a restic repo in an S3-compatible bucket, or on a second machine reached over Tailscale.
- **Encryption:** on by default (restic) — the offsite copy must not be a data breach if exposed.

## Verify (this milestone is a decision, verified on paper)

- I can name, for each backup layer, the specific disaster it defends against.
- I've written down my target **RPO** (how much data I can lose = backup frequency) and **RTO** (how long recovery may take) to hold myself to in [runbook 05](05-dr-runbook.md).

## If it breaks (i.e. the plan has a hole)

- **Two "copies" on the same disk** = one copy. Different partitions of one drive don't count as two media.
- **Offsite copy reachable/writable from the source at all times** = ransomware can reach it too. Prefer append-only/immutable offsite, or credentials the source doesn't normally hold.
- **No encryption on offsite** = the offsite copy is a breach waiting to happen.

## What I learned

*Filled in after I complete this milestone.*

<!-- Prompts to answer once done:
     - Which disaster was I most exposed to before this, and which layer closes it?
     - What did I decide NOT to back up, and am I comfortable losing it?
     - What RPO/RTO did I commit to, and is it realistic? -->
