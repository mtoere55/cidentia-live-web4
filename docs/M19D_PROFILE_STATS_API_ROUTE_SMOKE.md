# M19D — Guarded Profile Stats API Route Smoke

Status: Server-only route smoke.

## Purpose

M19D verifies the guarded `GET /api/profile/stats` route against the real staging database only when explicit smoke gates are enabled.

## Added scripts

- `scripts/m19d-profile-stats-api-route-smoke.js`
- `scripts/m19d-profile-stats-api-route-smoke-disabled-check.js`

## Required smoke gates

- `CIDENTIA_PROFILE_STATS_API_ROUTE_SMOKE=true`
- `CIDENTIA_DATABASE_ENABLED=true`
- `CIDENTIA_DATABASE_QUERY_ENABLED=true`

## Expected disabled behavior

Without smoke gates, the script returns:

- `M19D_SMOKE_GATES_DISABLED`
- `routeRead:false`
- `cleanupDone:false`
- `dbConnected:false`
- `queryEnabled:false`
- `secretsExposed:false`

## Expected server-only smoke behavior

When explicit smoke gates are enabled on VPS, the route should return:

- `M19D_PROFILE_STATS_API_ROUTE_SMOKE_OK`
- `PROFILE_STATS_READ_OK`
- `routeStatusCode:200`
- `statsRead:true`
- `postsCount:2`
- `reelsCount:1`
- `mediaCount:3`
- `followersCount:1`
- `followingCount:1`
- `trustScore:null`
- `cleanupDone:true`

## Locked boundaries preserved

M19D does not open:

- public stats route by default
- Flutter real stats
- fake counters
- fake posts/reels/media data
- public feed publishing
- public upload/media route
- Object Storage public URL exposure
- frontend secret
- fake CID/session/token
- wallet/payment/token/blockchain
- CidenBridge production route
- RTMP/WebRTC/live stream
- replay recording

## Server-only VPS smoke result

VPS server-only route smoke passed with explicit gates:

- `CIDENTIA_PROFILE_STATS_API_ROUTE_SMOKE=true`
- `CIDENTIA_DATABASE_ENABLED=true`
- `CIDENTIA_DATABASE_QUERY_ENABLED=true`

Result:

- `M19D_PROFILE_STATS_API_ROUTE_SMOKE_OK`
- `routeStatusCode:200`
- `PROFILE_STATS_READ_OK`
- `statsRead:true`
- `postsCount:2`
- `reelsCount:1`
- `mediaCount:3`
- `followersCount:1`
- `followingCount:1`
- `trustScore:null`
- `cleanupDone:true`
- `dbConnected:true`
- `queryEnabled:true`
- `secretsExposed:false`
- `publicStatsRouteDefaultOpened:false`
- `flutterStatsOpened:false`
- `fakeCountersCreated:false`
