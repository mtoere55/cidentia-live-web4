# M12E — DB Connection Guard

M12E adds a guarded database client boundary for the future PostgreSQL
connection.

## Added

- server/db/databaseClient.js
- scripts/m12e-db-connection-guard-check.js

## Updated

- server/db/databaseContract.js

## Behavior

Default:

- DATABASE_DISABLED
- dbConnected:false
- queryEnabled:false
- migrationExecuted:false

With CIDENTIA_DATABASE_ENABLED=true but no URL:

- DATABASE_URL_MISSING
- dbConnected:false

With CIDENTIA_DATABASE_ENABLED=true and CIDENTIA_DATABASE_URL present:

- DATABASE_CLIENT_NOT_IMPLEMENTED
- dbConnected:false
- queryEnabled:false

## Still Locked

- PostgreSQL connection
- DB query execution
- migration execution
- profile read/write
- media metadata write
- upload
- Object Storage
- signed URL
- fake CID/session/token
- secret logging

M12F can prepare real profile repository functions, still disabled until the
database client is implemented and env gates are explicitly opened.
