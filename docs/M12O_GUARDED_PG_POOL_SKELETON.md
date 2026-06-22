# M12O — Guarded PG Pool Skeleton

M12O prepares the PostgreSQL pool configuration boundary without opening a real
database connection.

## Updated

- server/db/databaseClient.js
- scripts/m12m-guarded-pg-client-import-check.js

## Added

- scripts/m12o-guarded-pg-pool-skeleton-check.js

## Behavior

Default env:

- DATABASE_DISABLED
- no pg load
- no pool
- dbConnected:false
- queryEnabled:false

CIDENTIA_DATABASE_ENABLED=true without URL:

- DATABASE_URL_MISSING
- no pool
- dbConnected:false

CIDENTIA_DATABASE_ENABLED=true with URL:

- pg driver may load if server/node_modules exists
- pool config is prepared
- pool is not created
- no query is executed
- PG_POOL_GUARDED_NOT_CONNECTED
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
