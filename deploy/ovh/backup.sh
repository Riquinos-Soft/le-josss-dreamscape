#!/bin/sh
set -eu
cd /opt/dreamscape
umask 077
mkdir -p backups
exec 9>backups/.backup.lock
flock -n 9 || exit 0
stamp=$(date -u +%Y%m%dT%H%M%SZ)
partial="backups/dreamscape-$stamp.dump.partial"
trap 'rm -f "$partial"' EXIT HUP INT TERM
docker compose exec -T db pg_dump -U dreamscape_admin -d dreamscape -Fc > "$partial"
docker compose exec -T db pg_restore --list < "$partial" > /dev/null
mv "$partial" "backups/dreamscape-$stamp.dump"
# Delete only this application's complete local dumps older than seven days.
find /opt/dreamscape/backups -maxdepth 1 -type f -name 'dreamscape-*.dump' -mtime +7 -delete
