# OVH hosting

Host: `vps-543b5b89.vps.ovh.net` (`198.244.233.153`), SSH user `j0se`.
IPv6: `2001:41d0:801:2000::50ec`.
Public URL: https://dreamscape.198.244.233.153.sslip.io/ (temporary sslip.io hostname).
Deployment directory: `/opt/dreamscape`, owned by `j0se`; `www` is owned by the
restricted `dreamscape-deploy` account used by Actions.
Use `sudo` for Docker administration; membership of the Docker group is unnecessary.
Passwords are not stored in this repository. The old `ubuntu` password was
replaced with a cryptographically random, unretained password; `j0se` can reset it
with `sudo passwd ubuntu` if recovery is ever needed.

## Layout and operation

`compose.yaml` and `nginx.conf` run a static Web host on `127.0.0.1:8083`.
`www/releases/<release>/` contains an entire Web export, and `www/current` points
to the active release. A preparation page is installed until a game export is
uploaded. A dedicated empty PostgreSQL database is prepared; player schemas and
the multiplayer/account services are not implemented.

To provision a fresh directory, copy this directory's configuration files there,
create `www/releases/prepared/index.html` and a `www/current` symlink to
`releases/prepared`, then generate the database secret ONCE before first startup:

```sh
cd /opt/dreamscape
mkdir -p .secrets
chmod 700 .secrets
test -e .secrets/db_password || (umask 077; openssl rand -base64 36 > .secrets/db_password)
chmod 700 backup.sh
sudo docker compose up -d
sudo install -m 644 dreamscape-backup.service dreamscape-backup.timer /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now dreamscape-backup.timer
```

Changing the secret file after database initialization does not change the
database password; coordinate any future rotation inside PostgreSQL too.

```sh
ssh j0se@198.244.233.153
cd /opt/dreamscape
sudo docker compose config --quiet
sudo docker compose exec -T web nginx -t
sudo docker compose ps
curl -f http://127.0.0.1:8083/
```

The existing `/opt/gateway/Caddyfile` serves other applications and includes the
block recorded in `Caddyfile.fragment`:

```caddyfile
dreamscape.198.244.233.153.sslip.io {
    reverse_proxy 127.0.0.1:8083
}
```

Back up that file before editing. Validate then reload without restarting the
other sites:

```sh
cd /opt/gateway
sudo docker compose exec -T caddy caddy validate --config /etc/caddy/Caddyfile
sudo docker compose exec -T caddy caddy reload --config /etc/caddy/Caddyfile
```

Caddy handles HTTPS and redirects HTTP to HTTPS. The temporary hostname resolves
to the VPS IPv4 through sslip.io. Ports 22, 80 and 443 already have firewall rules
for IPv4 and IPv6. Do not open port 8083 publicly.

## Publish a Web export

The `CI` workflow publishes on pushes to `main` only, after both lint/safety checks
and the Godot test/export job succeed. Pull requests, other branches and manual CI
runs do not publish. Deployment downloads the artifact from that same workflow
run; it does not rebuild the game. Production runs are serialized without
cancelling an in-progress deployment.

GitHub environment `production` requires these secrets:

- `OVH_DEPLOY_KEY`: private ED25519 key for `dreamscape-deploy`.
- `OVH_KNOWN_HOSTS`: the verified SSH host-key line for `198.244.233.153`.

The deployment key is separate from administrator SSH access. Its server-side
`authorized_keys` entry uses `restrict` and a forced command:
`/usr/bin/timeout 300 /usr/local/bin/dreamscape-receive`. That root-owned Python
script accepts only `deploy <40-character commit SHA> <run-id>-<attempt>`, reads a
gzipped tar archive from stdin, rejects path traversal/links/oversized exports,
and requires HTML, WebAssembly and PCK files before switching `current` atomically.
It restores the previous symlink if local HTTP checks fail. Actions then verifies
the commit at the public HTTPS `/release.txt` endpoint. A failure only in that
external check marks the workflow failed; it does not revert a locally healthy
release. The SSH account has no sudo, Docker or database permissions.

The receiver is infrastructure, not part of each Web release. To update it:

```sh
scp deploy/ovh/receive-release.py j0se@198.244.233.153:/opt/dreamscape/
ssh -t j0se@198.244.233.153 \
  'sudo install -o root -g root -m 755 /opt/dreamscape/receive-release.py /usr/local/bin/dreamscape-receive'
```

For emergency rollback, connect as `j0se`, choose a known-good release from
`/opt/dreamscape/www/releases`, then switch it as the deployment account:

```sh
cd /opt/dreamscape/www
release=REPLACE_WITH_EXISTING_RELEASE_DIRECTORY
sudo -u dreamscape-deploy ln -s "releases/$release" current-rollback
sudo -u dreamscape-deploy mv -Tf current-rollback current
curl -f https://dreamscape.198.244.233.153.sslip.io/release.txt
```

Old releases are retained for rollback; monitor disk usage and remove obsolete
releases explicitly, preserving the active and previous versions. Revalidation
avoids retaining an old cached build across visits, but players should reload
after a release; this is not a seamless live-game update system.

## Database and backups

PostgreSQL 18.4 uses the `dreamscape_postgres_data` Docker volume and an internal
network without published ports. The bootstrap administrator is
`dreamscape_admin`; the database is `dreamscape`. Its generated password is in
`/opt/dreamscape/.secrets/db_password` with mode 600 inside a mode 700 directory.
Create restricted application roles before connecting future runtime services.
Never use `docker compose down -v` on a deployment with data.

`dreamscape-backup.timer` runs `backup.sh` daily at 04:30 UTC plus up to 15 minutes
jitter. It stores custom-format dumps under `/opt/dreamscape/backups`, retaining
approximately seven days. Files are root-only. These copies share the VPS disk;
offsite storage is still required to survive VPS or disk loss. Inspect failures:

```sh
sudo systemctl status dreamscape-backup.timer
sudo journalctl -u dreamscape-backup.service
sudo systemctl start dreamscape-backup.service
```

Restore into a NEW disposable database first (substitute an actual dump path):

```sh
cd /opt/dreamscape
sudo docker compose exec -T db createdb -U dreamscape_admin dreamscape_restore_check
sudo cat backups/DUMP_FILE.dump | sudo docker compose exec -T db pg_restore \
  -U dreamscape_admin -d dreamscape_restore_check --exit-on-error
sudo docker compose exec -T db psql -U dreamscape_admin -d dreamscape_restore_check -c '\dt'
# After checking the restored data, remove only the disposable restore database.
sudo docker compose exec -T db dropdb -U dreamscape_admin dreamscape_restore_check
```

## Recorded validation and outstanding work

Actions deployment preparation: five receiver tests pass on the VPS, including
archive rejection, size limits, successful activation and health-check rollback.
The workflow YAML parses and all ten shell steps pass `bash -n`. The installed
SSH key rejects arbitrary commands and malformed uploads without changing the
active page. The account's home and authorized keys are root-owned. GitHub's
`production` environment is configured with `OVH_DEPLOY_KEY` and
`OVH_KNOWN_HOSTS` and permits deployments only from the `main` branch.
The workflow still needs to be pushed to `main` and its first Actions run verified;
local validation is not a successful end-to-end Actions deployment.

Public hostname enabled on 2026-09-25: DNS resolves to `198.244.233.153`, Caddy
obtained a Let's Encrypt certificate, external HTTPS returned 200 with certificate
verification enabled, and HTTP returned 308 to HTTPS. All three existing sites
still returned 200. The public page currently reports that hosting is prepared;
it is not a deployed game build. The prior gateway configuration is backed up at
`/opt/gateway/Caddyfile.before-dreamscape-20260925`. Caddy validation succeeded
with a non-blocking formatting warning for the shared Caddyfile.

Verified on 2026-09-25: fresh password login and sudo as `j0se`, Compose and nginx
configuration, both containers healthy, HTTP 200, `application/wasm` and gzip on a
temporary probe (removed afterward), no published database port, and successful
backup plus restoration of the initial empty database into a disposable database.
The backup timer is enabled; the manual backup service completed successfully.
Existing containers remained running without restarts.
The three existing public hostnames returned HTTP 200 through the local HTTPS
gateway. `systemd-analyze verify` emitted OS-level warnings that `CPUAccounting`
is ignored in the pre-existing `xfs_scrub_all.service` and `system-xfs_scrub.slice`;
the new backup units passed and the backup completed.

See Spec 002 for scope. No gameplay code changes are needed for this host.
Browser gameplay validation still requires an actual export. Accounts, world
persistence and simultaneous players require a
separate implementation spec following ADR 004. Restore tests must be expanded
to real player/world data before launch. VPS capacity is shared with existing sites.
The OS reports a pending restart; schedule it around those applications.
