# systemd/

Scheduling for the backup. `restic-backup.service` is a one-shot unit that runs `scripts/backup.sh`; `restic-backup.timer` fires it daily with catch-up (`Persistent=true`) if the host was off.

## Install

```bash
sudo cp restic-backup.service restic-backup.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now restic-backup.timer
```

## Check it

```bash
systemctl list-timers restic-backup.timer     # next/last run
systemctl status restic-backup.service        # last run result
journalctl -u restic-backup.service -n 50     # last run's log
sudo systemctl start restic-backup.service    # run one now, on demand
```

Edit the `ExecStart` path in the service file to match where you cloned this repo.
