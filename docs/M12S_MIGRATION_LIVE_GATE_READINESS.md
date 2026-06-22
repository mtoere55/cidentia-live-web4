# M12S — Migration Live Gate Readiness

M12S documents and checks the required order before any real migration can be
run.

## Added

- scripts/m12s-migration-live-gate-readiness-check.js
- docs/M12S_MIGRATION_LIVE_GATE_READINESS.md

## Required env keys

- CIDENTIA_DATABASE_ENABLED
- CIDENTIA_DATABASE_URL
- CIDENTIA_DATABASE_SSL_MODE
- CIDENTIA_DATABASE_POOL_MAX
- CIDENTIA_DATABASE_LIVE_SMOKE
- CIDENTIA_DATABASE_MIGRATION_ENABLED

## Required order

1. Configure the real `CIDENTIA_DATABASE_URL` only on the backend/server side.
2. Run guarded live DB smoke with `CIDENTIA_DATABASE_LIVE_SMOKE=true`.
3. Confirm `DATABASE_LIVE_SMOKE_OK`.
4. Enable migration gate with `CIDENTIA_DATABASE_MIGRATION_ENABLED=true`.
5. Run migration from the backend/VPS process only.

## Current checked behavior

Default live smoke:

- DATABASE_LIVE_SMOKE_DISABLED
- dbConnected:false
- queryExecuted:false

Default migration:

- MIGRATION_RUNNER_DISABLED
- migrationExecuted:false

Migration gate without DB enabled:

- MIGRATION_DB_NOT_CONNECTED
- databaseCode:DATABASE_DISABLED
- migrationExecuted:false

Live smoke gate without URL:

- DATABASE_URL_MISSING
- dbConnected:false

Migration gate without URL:

- MIGRATION_DB_NOT_CONNECTED
- databaseCode:DATABASE_URL_MISSING
- migrationExecuted:false

## Rules

The real database URL must never be committed, documented, pasted into chat, or
sent to Flutter.

Migration must never run from Flutter.

Migration must run only from backend/VPS after live smoke succeeds.

## Still Locked

- real PostgreSQL connection
- migration execution
- DB query execution
- profile read/write
- upload/storage/signed URL
- secrets
- fake CID/session/token
- UI filler/test buttons
