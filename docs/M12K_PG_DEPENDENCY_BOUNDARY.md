# M12K — PostgreSQL Dependency Boundary

M12K records the PostgreSQL driver dependency under the backend package boundary.

## Updated

- server/package.json

## Added

- scripts/m12k-pg-dependency-boundary-check.js

## Dependency Boundary

The `pg` dependency is declared only under `server/package.json`.

The Flutter root remains clean:

- no root package.json
- no root package-lock.json

## Not Done In M12K

- npm install was not executed
- server/package-lock.json was not created
- databaseClient.js does not require pg yet
- PostgreSQL connection is not opened
- DB query execution is not opened
- migration execution is not opened
- DATABASE_URL is not committed
- secrets are not committed

## Still Locked

- profile read/write
- media metadata write
- upload/storage/signed URL
- fake CID/session/token
- UI filler/test buttons

M12L can add a guarded driver import/client implementation, but it must still
respect env gates and must not expose secrets.
