# M18A — Follows Repository Boundary

Status: Repository boundary only.

## Purpose

M18A prepares the backend repository layer for profile follow relationships.

It does not expose a public API route and does not change Flutter.

## Table

The real database table was verified on the VPS:

- `cidentia_follows.id`
- `cidentia_follows.follower_cid`
- `cidentia_follows.followed_cid`
- `cidentia_follows.created_at`

## Added repository

- `server/social/followsRepository.js`

## Repository functions

- `followCid(followerCid, followedCid)`
- `unfollowCid(followerCid, followedCid)`
- `readFollowers(ownerCid)`
- `readFollowing(ownerCid)`

## Guard behavior

When DB query gates are disabled, the repository returns disabled results and does not write:

- `FOLLOW_WRITE_DISABLED`
- `FOLLOW_DELETE_DISABLED`
- `FOLLOWERS_READ_DISABLED`
- `FOLLOWING_READ_DISABLED`

Self-follow is blocked with:

- `SELF_FOLLOW_BLOCKED`

## Locked boundaries preserved

M18A does not open:

- public follow API route
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

## Verified VPS smoke result

The guarded server-only VPS smoke was executed with explicit smoke and DB gates enabled.

Result:

- `M18A_FOLLOWS_REPOSITORY_SMOKE_OK`
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
- `publicRouteOpened:false`
- `flutterFollowOpened:false`

The smoke created one temporary follow relation, verified duplicate blocking, read followers/following, deleted the relation, and confirmed cleanup.
