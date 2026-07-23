# 05 — Disaster-recovery runbook

**Goal:** a written, rehearsed plan for "the whole host is gone" — the recovery order, and honest RPO/RTO numbers.

## RPO / RTO

- **RPO (Recovery Point Objective)** — how much data I can afford to lose. Set by backup *frequency*: nightly backups ⇒ up to ~24h of data at risk. Tighten by backing up more often.
- **RTO (Recovery Time Objective)** — how long recovery may take. The *only* honest way to know this is to rehearse a full restore and time it (step below).

Record the committed targets here once decided: `RPO = ____`, `RTO = ____`.

## Recovery order (bare-metal / total loss)

1. **Retrieve the repo password FIRST.** Everything depends on it and it's not on the dead host. From the password manager / offline copy.
2. **Provision a replacement host** — reinstall the OS to a known baseline.
3. **Install restic**, recreate `restic.env` (or restore it), point at the surviving repo (offsite if the local disk died with the host).
4. **Restore system config** (`/etc`) and service data (`/srv`, docker volumes) to the new host.
5. **Rebuild services** — for the containerised stack, restore volumes then `docker compose up` from the compose repo ([docker-selfhosted-lab](https://github.com/wardoep/docker-selfhosted-lab)).
6. **Verify** each service comes up and the data is current to within RPO.
7. **Re-point DNS / clients** as needed.

## The rehearsal (do this quarterly)

Don't wait for a real disaster to discover the plan is fiction. On a scratch VM:
1. Start a stopwatch.
2. Follow the recovery order using only the offsite repo and the password from your manager.
3. Stop the clock when a chosen service is back and serving correct data.
4. That time **is** your real RTO — record it in [DRILLS.md](../DRILLS.md) and update the target above if reality disagreed.

## Verify

- I have restored a working service on a *different* machine from the *offsite* repo, and timed it.
- The measured recovery time is at or under my RTO target (or the target is updated to the honest number).

## If it breaks

- **Can't decrypt the repo — password lost.** Game over for that repo. This is why the password lives in a manager independent of the host; a DR rehearsal that skips "retrieve the password from scratch" is skipping the most likely real failure.
- **Restore is far slower than expected.** Offsite bandwidth is the usual limit — consider seeding a local copy or a faster offsite for large data; adjust the RTO to the truth.
- **Service won't start on the new host.** Config restored but a dependency (a package, a user, a mount) wasn't — the DR runbook should list those explicitly; add what you find during the rehearsal.

## What I learned

*Filled in after I complete this milestone.*

<!-- Prompts to answer once done:
     - What was my measured RTO from the rehearsal vs what I'd guessed?
     - What did the rehearsal reveal was missing from this runbook?
     - If the password manager were also gone, what's my plan? -->
