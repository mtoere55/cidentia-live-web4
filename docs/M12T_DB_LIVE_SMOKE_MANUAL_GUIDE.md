# M12T — DB Live Smoke Manual Guide

M12T documents the manual process for running the guarded live DB smoke without
committing or exposing database secrets.

## Added

- docs/M12T_DB_LIVE_SMOKE_MANUAL_GUIDE.md
- scripts/m12t-db-live-smoke-manual-guide-check.js

## Rule

Do not paste the real URL into chat.

Do not commit the real URL to Git.

Do not send the real URL to Flutter.

`CIDENTIA_DATABASE_URL` is server-only.

## Manual live smoke sequence

Run this only in a private backend/server terminal where the real database env is
available outside Git.

```powershell
$env:CIDENTIA_DATABASE_LIVE_SMOKE="true"
$env:CIDENTIA_DATABASE_ENABLED="true"
$env:CIDENTIA_DATABASE_URL="<server-only-real-postgres-url>"
$env:CIDENTIA_DATABASE_SSL_MODE="require"
$env:CIDENTIA_DATABASE_POOL_MAX="5"

node -e "const { runGuardedLiveDatabaseSmoke } = require('./server/db/liveDatabaseSmoke'); runGuardedLiveDatabaseSmoke(process.env).then((r) => console.log(JSON.stringify({ ok:r.ok, code:r.code, dbConnected:r.dbConnected, queryExecuted:r.queryExecuted, secretsExposed:r.secretsExposed }, null, 2))).catch((e) => { console.error(e.message); process.exit(1); })"
