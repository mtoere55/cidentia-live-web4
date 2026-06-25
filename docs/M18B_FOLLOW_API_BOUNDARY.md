# M18B — Follow API Boundary

Status: Disabled API boundary.

## Purpose

M18B adds guarded API routes for follow relationships.

The routes are wired to the existing follows repository but remain disabled by default.

## Added routes

- `POST /api/social/follow`
- `POST /api/social/unfollow`
- `GET /api/social/followers`
- `GET /api/social/following`

## Added boundary

- `api/social/socialBoundary.js`

## Local backend wiring

The disabled local backend server now knows these routes:

- `scripts/m10h-disabled-backend-local-server.js`

## Default behavior

By default, write routes return:

- `SOCIAL_ROUTE_DISABLED`
- `followCreated:false`
- `followDeleted:false`

Read routes return:

- `SOCIAL_ROUTE_DISABLED`
- `followersRead:false`
- `followingRead:false`

Missing CID returns:

- `SOCIAL_CID_REQUIRED`

## Locked boundaries preserved

M18B does not open:

- public default follow persistence
- Flutter follow/unfollow behavior
- fake follow state
- fake CID/session/token
- profile UI persistence
- public upload/media route
- Object Storage public URL exposure
- wallet/payment/token/blockchain
- CidenBridge production route
- RTMP/WebRTC/live stream
- replay recording

## Verified VPS route smoke result

The guarded server-only VPS route smoke was executed with explicit smoke, route, and DB gates enabled.

Result:

- `M18B_FOLLOW_API_ROUTE_SMOKE_OK`
- `FOLLOW_CREATED`
- `FOLLOW_ALREADY_EXISTS`
- `FOLLOW_DELETED`
- `FOLLOWERS_READ_OK`
- `FOLLOWING_READ_OK`
- `followCreated:true`
- `duplicateBlocked:true`
- `followDeleted:true`
- `followersRead:true`
- `followingRead:true`
- `followerCount:1`
- `followingCount:1`
- `cleanupDone:true`
- `dbConnected:true`
- `queryEnabled:true`
- `secretsExposed:false`
- `publicRouteDefaultOpened:false`
- `flutterFollowOpened:false`

The smoke called the real social API handlers, created one temporary follow relation, verified duplicate blocking, read followers/following, deleted the relation, and confirmed cleanup.
