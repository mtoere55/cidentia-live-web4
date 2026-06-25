# M17D — Guarded Media Metadata Write Smoke

Status: Server-only smoke boundary.

## Purpose

M17D prepares a guarded server-only smoke script for media metadata writes.

It verifies that `cidentia_media_assets` can receive a metadata row only when explicit smoke gates and database query gates are enabled.

## Added scripts

- `scripts/m17d-media-metadata-write-smoke.js`
- `scripts/m17d-media-metadata-write-smoke-disabled-check.js`

## Default behavior

By default, the smoke script refuses to write and returns:

- `M17D_SMOKE_GATES_DISABLED`
- `mediaMetadataCreated:false`
- `dbConnected:false`
- `queryEnabled:false`
- `cleanupDone:false`
- `secretsExposed:false`

## Required smoke gates

A real server-only smoke requires all of the following:

- `CIDENTIA_MEDIA_METADATA_WRITE_SMOKE=true`
- `CIDENTIA_MEDIA_METADATA_WRITE_ENABLED=true`
- `CIDENTIA_DATABASE_ENABLED=true`
- `CIDENTIA_DATABASE_QUERY_ENABLED=true`
- `CIDENTIA_DATABASE_URL` present

## Smoke behavior when explicitly enabled

The smoke script:

1. creates one test media metadata row for test CID `Cid-M17D-Metadata-Smoke`
2. verifies `MEDIA_METADATA_WRITE_OK`
3. deletes the test row by id
4. reports `cleanupDone:true`

## Locked boundaries preserved

M17D does not open:

- public API metadata write
- public upload route
- Flutter metadata persistence
- profile database update
- Object Storage public URL exposure
- frontend Object Storage secrets
- fake CID/session/token
- wallet/payment/token/blockchain
- CidenBridge production route
- RTMP/WebRTC/live stream
- replay recording

## Result

M17D allows a controlled server-only metadata write smoke without changing default runtime behavior.

## Verified VPS smoke result

The guarded server-only VPS smoke was executed with explicit smoke and DB gates enabled.

Result:

- `MEDIA_METADATA_WRITE_OK`
- `mediaMetadataCreated:true`
- `mediaAssetIdCreated:true`
- `cleanupDone:true`
- `dbConnected:true`
- `queryEnabled:true`
- `secretsExposed:false`
- `publicRouteOpened:false`
- `profileUpdated:false`

The test storage object key used the test CID namespace:

- `uploads/Cid-M17D-Metadata-Smoke/profile-cover/...-m17d-metadata-smoke.jpg`

The smoke inserted one temporary media metadata row and deleted it by id. No public API route was opened.
