# M12M — Guarded PG Client Import

M12M adds a guarded PostgreSQL driver import path inside the backend database
client.

## Updated

- server/db/databaseClient.js
- scripts/m12e-db-connection-guard-check.js

## Added

- scripts/m12m-guarded-pg-client-import-check.js

## Behavior

Default env:

- DATABASE_DISABLED
- pg is not loaded
- dbConnected:false
- queryEnabled:false

CIDENTIA_DATABASE_ENABLED=true without URL:

- DATABASE_URL_MISSING
- pg is not loaded
- dbConnected:false

CIDENTIA_DATABASE_ENABLED=true with URL:

- pg import is attempted only after env gates pass
- if node_modules is not installed: PG_DRIVER_NOT_INSTALLED
- if pg is available: PG_DRIVER_GUARDED_NOT_CONNECTED
- no pool is created
- no query is executed
- dbConnected:false
- queryEnabled:false

## Still Locked

- PostgreSQL connection
- pool creation
- DB query execution
- migration execution
- profile read/write
- upload/storage/signed URL
- secrets
- fake CID/session/token
- UI filler/test buttons
