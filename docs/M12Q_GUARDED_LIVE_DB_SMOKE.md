# M12Q — Guarded Live DB Smoke Skeleton

M12Q adds a separate guarded live database smoke path.

This path is not used by the normal app runtime.

## Added

- server/db/liveDatabaseSmoke.js
- scripts/m12q-guarded-live-db-smoke-check.js
- docs/M12Q_GUARDED_LIVE_DB_SMOKE.md

## Gate

A real smoke attempt requires all of these server-side env values:

- CIDENTIA_DATABASE_LIVE_SMOKE=true
- CIDENTIA_DATABASE_ENABLED=true
- CIDENTIA_DATABASE_URL
- CIDENTIA_DATABASE_SSL_MODE
- CIDENTIA_DATABASE_POOL_MAX

Without `CIDENTIA_DATABASE_LIVE_SMOKE=true`, the script returns:

- DATABASE_LIVE_SMOKE_DISABLED
- dbConnected:false
- queryExecuted:false

## Current checked behavior

The committed check does not use a real database URL.

It verifies only locked paths:

- DATABASE_LIVE_SMOKE_DISABLED
- DATABASE_DISABLED
- DATABASE_URL_MISSING

## Rules

The real database URL must never be committed, documented, pasted into chat, or
sent to Flutter.

CIDENTIA_DATABASE_URL is server-only.

## Still Locked

- Normal app DB connection
- profile read/write
- migration execution
- upload/storage/signed URL
- secrets
- fake CID/session/token
- UI filler/test buttons
