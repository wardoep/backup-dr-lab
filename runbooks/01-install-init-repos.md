# 01 — Install restic, init local + offsite repos

**Goal:** restic installed, a strong repo password stored safely, and both the local and offsite repositories initialised.

## Steps

1. **Install restic:**
   ```bash
   sudo apt-get update && sudo apt-get install -y restic
   restic version
   ```

2. **Create the repo password — and treat it as precious.** The password is not recoverable; lose it and every backup is unreadable. Store it in a `0600` file, and record it somewhere independent of this machine (a password manager):
   ```bash
   umask 077
   openssl rand -base64 32 | sudo tee /root/.restic-password >/dev/null
   sudo chmod 600 /root/.restic-password
   ```

3. **Configure the env file:**
   ```bash
   cd scripts
   cp restic.env.example restic.env
   chmod 600 restic.env
   # edit restic.env: set RESTIC_REPOSITORY (local), RESTIC_PASSWORD_FILE, BACKUP_PATHS
   ```

4. **Initialise the LOCAL repo:**
   ```bash
   set -a; . ./restic.env; set +a
   restic init
   ```
   Expected: `created restic repository <id> at /mnt/backup/restic-repo`.

5. **Initialise the OFFSITE repo.** Point `RESTIC_REPOSITORY` at the S3 bucket (with `AWS_ACCESS_KEY_ID`/`AWS_SECRET_ACCESS_KEY`) or an sftp path over Tailscale, then `restic init` again. Keep a separate env file per repo, or swap `RESTIC_REPOSITORY` per run.
   ```bash
   # S3 example:
   export RESTIC_REPOSITORY="s3:https://s3.example.com/my-backup-bucket"
   export AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=...
   restic init
   ```

## Verify

```bash
set -a; . ./restic.env; set +a
restic cat config          # prints the repo config = password + repo both work
restic snapshots           # empty list (no error) = repo reachable and decryptable
```
Do the same against the offsite repo. Both must return without a password/permission error.

## If it breaks

- **`wrong password or no key found`.** `RESTIC_PASSWORD_FILE` points at the wrong file, or the file has a trailing newline mismatch — regenerate carefully and re-init if the repo is empty.
- **S3 `AccessDenied` / `NoSuchBucket`.** Wrong credentials, region, or the bucket doesn't exist — restic won't create the bucket, only the repo inside it.
- **Permission denied on `/mnt/backup`.** The external disk isn't mounted or isn't writable by the user running restic — check `mount` and ownership.

## What I learned

*Filled in after I complete this milestone.*

<!-- Prompts to answer once done:
     - Where did I store the repo password so a total host loss doesn't lose it too?
     - Local vs offsite init — what was different about getting the offsite one working?
     - What does `restic cat config` succeeding actually prove? -->
