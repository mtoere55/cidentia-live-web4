# M17F — Guarded Profile API Persistence Boundary

Status: Server-only API route persistence smoke boundary.

## Purpose

M17F verifies the existing profile API routes through their real handlers:

- `POST /api/profile/update`
- `GET /api/profile/me`

The smoke confirms that the route layer can write and read a profile only when explicit smoke and database query gates are enabled.

## Existing route behavior

The profile routes already flow through the guarded repository layer:

- `/api/profile/update` uses `upsertProfileByCid()`
- `/api/profile/me` uses `readProfileByCid()`

CID remains required through profile boundary helpers.

## Added scripts

- `scripts/m17f-profile-api-persistence-smoke.js`
- `scripts/m17f-profile-api-persistence-smoke-disabled-check.js`

## Default behavior

By default, the smoke refuses to write and returns:

- `M17F_SMOKE_GATES_DISABLED`
- `profileUpdated:false`
- `profileRead:false`
- `routeUpdateOk:false`
- `routeReadOk:false`
- `cleanupDone:false`
- `dbConnected:false`
- `queryEnabled:false`
- `secretsExposed:false`

## Required smoke gates

A real server-only smoke requires:

- `CIDENTIA_PROFILE_API_PERSISTENCE_SMOKE=true`
- `CIDENTIA_DATABASE_ENABLED=true`
- `CIDENTIA_DATABASE_QUERY_ENABLED=true`
- `CIDENTIA_DATABASE_URL` present

## Smoke behavior when explicitly enabled

The smoke script:

1. calls the actual `/api/profile/update` handler
2. writes one temporary test profile
3. calls the actual `/api/profile/me` handler
4. verifies the profile can be read back
5. deletes the temporary test profile row

## Locked boundaries preserved

M17F does not open:

- public default profile persistence
- Flutter persistence
- public upload route
- public metadata route
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

- `M17F_PROFILE_API_PERSISTENCE_OK`
- `updateStatusCode:200`
- `readStatusCode:200`
- `PROFILE_WRITE_OK`
- `PROFILE_READ_OK`
- `profileUpdated:true`
- `profileRead:true`
- `routeUpdateOk:true`
- `routeReadOk:true`
- `cleanupDone:true`
- `dbConnected:true`
- `queryEnabled:true`
- `secretsExposed:false`
- `publicRouteDefaultOpened:false`
- `flutterPersistenceOpened:false`

The smoke called the real profile API handlers, wrote one temporary profile row, read it back, verified the result, and deleted the temporary row.
