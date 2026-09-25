# Spec 002: prepare OVH hosting

Scope authorized by the developer on 2026-09-25: rotate the initial Ubuntu
password, create the administrator `j0se`, and prepare the VPS to host the game.
The intended future product is a persistent MMORPG with player accounts. The
developer subsequently authorized proceeding with the architectural preparation.

## Current deliverable

- Verify a fresh SSH login and sudo access as `j0se`.
- Reuse the VPS's existing Docker Compose and Caddy gateway.
- Isolate the game's static Web host on loopback port 8083; preserve existing sites.
- Serve WebAssembly with the correct MIME type, compression and revalidation.
- Support separate release directories and an atomic `current` symlink switch.
- Configure the public HTTPS route at the developer-selected temporary hostname
  `dreamscape.198.244.233.153.sslip.io`.
- Prepare isolated PostgreSQL with persistent storage and local backup/restore.
- On pushes to `main`, Actions publishes the exact Web artifact after lint and
  tests pass. Pull requests and other branches never deploy. Use restricted SSH,
  verify the server host key, and restore the previous release on local HTTP failure.

## Boundaries

Hosting does not add persistence or multiplayer to the current single-player
prototype. An authoritative game server, account authentication, storage model,
offsite backup policy and capacity targets require a separate implementation spec.
ADR 004 records the database preparation and proposed runtime boundary. Do not
expose game-server or database ports for this step.
Builds use the repository's pinned Godot toolchain; the static host needs no editor.

## Acceptance

Validate Compose and nginx configuration, container health, HTTP responses,
WebAssembly MIME and gzip, and continued operation of existing containers.
Record missing build/domain and any pending maintenance explicitly.
