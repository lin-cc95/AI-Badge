# Third-party notices

AI Badge uses open-source dependencies. The following list summarizes the
licenses of direct runtime dependencies. The authoritative license text for
each dependency remains in that dependency's source distribution.

## Node.js services

| Project group | License |
|---|---|
| NestJS, RxJS, class-transformer, class-validator, BullMQ, ioredis, Argon2 bindings | MIT |
| Prisma tooling | Apache-2.0 |
| prom-client | Apache-2.0 |

## Flutter application

| Project group | License |
|---|---|
| Flutter and Dart SDK packages | BSD-3-Clause or Apache-2.0, depending on package |
| Riverpod, Dio, Drift, sqlite3, state_notifier | MIT |
| GoRouter, path_provider, flutter_secure_storage | BSD-3-Clause |
| flutter_reactive_ble | BSD-3-Clause |

Complete versions and transitive dependency graphs are recorded in
`pnpm-lock.yaml` and `apps/mobile/pubspec.lock`.

## Development service images

| Service | Upstream license |
|---|---|
| Valkey | BSD-3-Clause |
| PostgreSQL | PostgreSQL License |
| MinIO Server | GNU AGPLv3 |

These services run as separate processes and retain their upstream licenses.
Anyone redistributing container images or modified server builds is responsible
for satisfying the exact license and notice obligations of the pinned image.
