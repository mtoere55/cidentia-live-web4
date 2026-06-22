# M13A — Profile DB Read/Write

M13A connects the guarded profile repository to the real PostgreSQL query path while keeping the default runtime locked.

## What changed

- `server/db/databaseContract.js`
  - Adds `CIDENTIA_DATABASE_QUERY_ENABLED`.
  - Keeps database/query locked by default.
  - Does not expose secrets.

- `server/db/databaseClient.js`
  - Keeps `DATABASE_DISABLED` and `DATABASE_URL_MISSING` behavior unchanged.
  - Keeps guarded no-query behavior when `CIDENTIA_DATABASE_QUERY_ENABLED` is not enabled.
  - Creates a real `pg.Pool` only when:
    - `CIDENTIA_DATABASE_ENABLED=true`
    - `CIDENTIA_DATABASE_QUERY_ENABLED=true`
    - `CIDENTIA_DATABASE_URL` is present
  - Provides a real `query()` and `close()` path only behind that gate.

- `server/profile/profileRepository.js`
  - Implements `readProfileByCid(ownerCid)` with `SELECT`.
  - Implements `upsertProfileByCid(ownerCid, draft)` with `INSERT ... ON CONFLICT(owner_cid) DO UPDATE`.
  - Keeps default disabled behavior when DB/query gates are closed.

- `scripts/m13a-profile-db-read-write-check.js`
  - Confirms default locked behavior.
  - Confirms repository read/write behavior with a fake query-enabled DB adapter.

## Safety boundaries

- CID is still required by the API boundary.
- Guest profile access remains blocked with `PROFILE_CID_REQUIRED`.
- Default env remains locked.
- No Flutter DB secret is introduced.
- No upload, Object Storage write, signed URL, feed/reels real data, wallet/payment, RTMP/WebRTC, or live stream is opened.

## Verified checks

- `node --check server\db\databaseClient.js`
- `node --check server\db\databaseContract.js`
- `node --check server\profile\profileRepository.js`
- `node --check scripts\m13a-profile-db-read-write-check.js`
- `node scripts\m12m-guarded-pg-client-import-check.js`
- `node scripts\m12h-profile-api-local-smoke-check.js`
- `node scripts\m13a-profile-db-read-write-check.js`
- `git diff --check`
