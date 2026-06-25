# M17E — Guarded Profile Cover Persistence Smoke

Status: Server-only smoke boundary.

## Purpose

M17E verifies that a profile cover can be linked safely in the database after media metadata exists.

It does this only through explicit smoke gates.

## Added scripts

- `scripts/m17e-profile-cover-persistence-smoke.js`
- `scripts/m17e-profile-cover-persistence-smoke-disabled-check.js`

## Default behavior

By default, the smoke refuses to write and returns:

- `M17E_SMOKE_GATES_DISABLED`
- `mediaMetadataCreated:false`
- `profileUpdated:false`
- `profileRead:false`
- `coverLinked:false`
- `cleanupDone:false`
- `dbConnected:false`
- `queryEnabled:false`
- `secretsExposed:false`

## Required smoke gates

A real server-only smoke requires:

- `CIDENTIA_PROFILE_COVER_PERSISTENCE_SMOKE=true`
- `CIDENTIA_MEDIA_METADATA_WRITE_ENABLED=true`
- `CIDENTIA_PROFILE_WRITE_ENABLED=true`
- `CIDENTIA_DATABASE_ENABLED=true`
- `CIDENTIA_DATABASE_QUERY_ENABLED=true`
- `CIDENTIA_DATABASE_URL` present

## Smoke behavior when explicitly enabled

The smoke script:

1. creates one test media metadata row
2. creates or updates one test profile row
3. writes `cover_media_id`
4. reads the profile back
5. verifies that `coverMediaId` matches the created media asset id
6. deletes the test profile row
7. deletes the test media row

## Locked boundaries preserved

M17E does not open:

- public profile persistence route
- public metadata write route
- Flutter persistence
- public upload route
- Object Storage public URL exposure
- frontend Object Storage secrets
- fake CID/session/token
- wallet/payment/token/blockchain
- CidenBridge production route
- RTMP/WebRTC/live stream
- replay recording

## Verified VPS smoke result

The guarded server-only VPS smoke was executed with explicit smoke and DB gates enabled.

Result:

- `M17E_PROFILE_COVER_PERSISTENCE_OK`
- `mediaMetadataCreated:true`
- `profileUpdated:true`
- `profileRead:true`
- `coverLinked:true`
- `profileCleanupDone:true`
- `mediaCleanupDone:true`
- `cleanupDone:true`
- `dbConnected:true`
- `queryEnabled:true`
- `secretsExposed:false`
- `publicRouteOpened:false`
- `flutterPersistenceOpened:false`

The smoke created one temporary media metadata row, linked it to one temporary profile through `cover_media_id`, verified it by reading the profile back, and then deleted both rows.
