# M12P — DB Connection Readiness

M12P documents and checks the database connection readiness boundary before any
real PostgreSQL connection is opened.

## Added

- scripts/m12p-db-connection-readiness-check.js
- docs/M12P_DB_CONNECTION_READINESS.md

## Required env keys for a future real DB connection

- CIDENTIA_DATABASE_ENABLED
- CIDENTIA_DATABASE_URL
- CIDENTIA_DATABASE_SSL_MODE
- CIDENTIA_DATABASE_POOL_MAX

## Rules

The real database URL must never be committed to Git, pasted into docs, or sent
to the frontend.

The frontend must not receive database credentials.

CIDENTIA_DATABASE_URL is server-only.

## Current behavior

Default env:

- DATABASE_DISABLED
- dbConnected:false
- queryEnabled:false

CIDENTIA_DATABASE_ENABLED=true without URL:

- DATABASE_URL_MISSING
- dbConnected:false
- queryEnabled:false

CIDENTIA_DATABASE_ENABLED=true with URL-shaped placeholder:

- pool config is prepared
- pool is not created
- no query is executed
- PG_POOL_GUARDED_NOT_CONNECTED
- dbConnected:false
- queryEnabled:false

## Future real smoke command

Only after a real server-side env is configured outside Git:

```powershell
$env:CIDENTIA_DATABASE_ENABLED="true"
$env:CIDENTIA_DATABASE_URL="<server-only-postgres-url>"
$env:CIDENTIA_DATABASE_SSL_MODE="require"
$env:CIDENTIA_DATABASE_POOL_MAX="5"
node scripts\<future-db-live-smoke-check>.js
