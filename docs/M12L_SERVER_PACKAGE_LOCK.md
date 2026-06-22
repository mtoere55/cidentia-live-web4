# M12L — Server Package Lock

M12L creates the backend package lock under `server/package-lock.json`.

## Added

- server/package-lock.json
- scripts/m12l-server-package-lock-check.js

## Behavior

`npm install --package-lock-only` was executed inside `server/`.

The lock resolves the declared `pg` dependency for the backend package boundary.

## Still Locked

- root package.json
- root package-lock.json
- databaseClient require('pg')
- PostgreSQL connection
- DB query execution
- migration execution
- profile read/write
- upload/storage/signed URL
- secrets
- fake CID/session/token
- UI filler/test buttons
