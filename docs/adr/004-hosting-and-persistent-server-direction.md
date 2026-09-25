# ADR 004: hosting and persistent server direction

Date: 2026-09-25. Hosting/database preparation authorized; runtime design is a
proposed direction until its implementation spec is agreed.

## Context

The developer now requests a persistent multiplayer game with accounts, hosted on
an existing OVH VPS. This supersedes the earlier exclusion of backend preparation
for this deployment task, without expanding the implemented single-player slice.
The VPS has four CPUs and approximately 8 GB RAM and already hosts other sites.

## Deployment decision

Reuse Docker Compose and the existing Caddy HTTPS gateway. Run an isolated static
Web host and a dedicated PostgreSQL 18 database with a persistent Docker volume.
Do not reuse the databases of unrelated applications. Publish no database port.
Keep credentials on the host, outside Git. Make daily logical backups and verify
restoration into a disposable database. Local backups are a first layer only;
offsite backup storage and recovery objectives remain required before launch.

## Proposed runtime boundary

- The browser renders and sends player intentions; it cannot write authoritative
  item state or access PostgreSQL directly.
- A headless Godot server owns simulation, item identity, movement validation and
  world state. Browser clients connect over WSS through Caddy.
- A small account/session service handles password hashing, login throttling,
  session revocation and short-lived game connection tickets. Its language and
  implementation are not chosen by this infrastructure step.
- PostgreSQL stores accounts and durable world/player state. Runtime services use
  restricted roles, never the bootstrap database administrator.
- Transactions protect item transfers and other durable operations. Define save
  boundaries and recovery behavior before implementing inventory persistence.

Do not introduce Redis, Kubernetes, sharding or microservice orchestration now.
An in-memory multiplayer test alone will not establish persistence. A database
alone will not establish multiplayer. Do not promise an MMO player capacity until
representative load tests have been run on the shared VPS.

## Next implementation spec

Define an initial concurrent-player target, one shared test map, account lifecycle,
authoritative movement and item transfer, reconnect behavior, schema migrations,
save/recovery tests and offsite backup policy. Implement one end-to-end slice
before extending the world. No gameplay networking is added by this ADR.
