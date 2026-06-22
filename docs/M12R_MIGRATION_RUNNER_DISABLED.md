# M12R — Migration Runner Disabled Skeleton

M12R adds a guarded migration runner boundary for the existing M12A database
foundation SQL file.

## Added

- server/db/migrationRunner.js
- scripts/m12r-migration-runner-disabled-check.js
- docs/M12R_MIGRATION_RUNNER_DISABLED.md

## Migration file

- server/db/migrations/001_m12a_social_media_foundation.sql

The runner can read the migration file, but it does not execute it by default.

## Gates

Migration execution requires a future server-side gate:

- CIDENTIA_DATABASE_MIGRATION_ENABLED=true

Even when that gate is present, migration cannot execute unless the database
client is connected and query-enabled.

## Current checked behavior

Default env:

- MIGRATION_RUNNER_DISABLED
- migrationExecuted:false
- queryExecuted:false
- dbConnected:false

CIDENTIA_DATABASE_MIGRATION_ENABLED=true without DB enabled:

- MIGRATION_DB_NOT_CONNECTED
- databaseCode:DATABASE_DISABLED
- migrationExecuted:false

CIDENTIA_DATABASE_MIGRATION_ENABLED=true and DB enabled without URL:

- MIGRATION_DB_NOT_CONNECTED
- databaseCode:DATABASE_URL_MISSING
- migrationExecuted:false

## Still Locked

- real PostgreSQL connection
- pool creation through normal runtime
- migration execution
- DB query execution
- profile read/write
- upload/storage/signed URL
- secrets
- fake CID/session/token
- UI filler/test buttons
