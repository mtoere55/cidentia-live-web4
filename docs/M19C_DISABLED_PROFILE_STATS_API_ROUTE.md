# M19C — Disabled Profile Stats API Route

Status: Disabled API route boundary.

## Purpose

M19C adds the guarded profile stats API route while keeping real stats reads locked by default.

## Added route

- `GET /api/profile/stats`

## Wired local disabled backend

- `scripts/m10h-disabled-backend-local-server.js`

## Added check

- `scripts/m19c-profile-stats-route-disabled-check.js`

## Default behavior

Missing CID returns:

- HTTP `401`
- `PROFILE_CID_REQUIRED`

CID-present request with default locked runtime returns:

- HTTP `503`
- `PROFILE_STATS_DISABLED`
- `repositoryCode:DATABASE_DISABLED`
- `statsRead:false`
- `postsCount:null`
- `reelsCount:null`
- `mediaCount:null`
- `followersCount:null`
- `followingCount:null`
- `trustScore:null`
- `dbConnected:false`
- `queryEnabled:false`
- `secretsExposed:false`

## Locked boundaries preserved

M19C does not open:

- public real profile stats
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
