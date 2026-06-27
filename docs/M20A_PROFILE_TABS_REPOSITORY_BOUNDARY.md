# M20A — Profile Tab Repository Boundary

Status: Repository boundary only.

## Purpose

M20A adds the guarded repository layer for profile tabs.

It does not add API routes and does not change Flutter.

## Added repository

- `server/profile/profileTabsRepository.js`

## Added check

- `scripts/m20a-profile-tabs-repository-disabled-check.js`

## Prepared repository reads

- posts by `owner_cid`
- reels by `owner_cid`
- media assets by `owner_cid`

## Tables used

- `cidentia_posts`
- `cidentia_reels`
- `cidentia_media_assets`

## Default disabled behavior

When DB gates are disabled, repository reads return:

- `DATABASE_DISABLED`
- `itemsRead:false`
- `items:[]`
- `dbConnected:false`
- `queryEnabled:false`
- `secretsExposed:false`

Missing CID returns:

- `PROFILE_CID_REQUIRED`

## Media URL policy

M20A does not create public media URLs.

Repository mapped items include:

- `publicMediaUrl:null`

Real media URL policy must be defined later before any public rendering.

## Locked boundaries preserved

M20A does not open:

- profile tab API routes
- Flutter real posts/reels/media rendering
- fake posts
- fake reels
- fake media assets
- fake counters
- public feed publishing
- public upload/media route
- Object Storage public URL exposure
- frontend secret
- fake CID/session/token
- wallet/payment/token/blockchain
- CidenBridge production route
- RTMP/WebRTC/live stream
- replay recording

## Server-only DB smoke

VPS smoke was executed with server-only DB gates enabled.

Result:

- `M20A_PROFILE_TABS_REPOSITORY_SMOKE_OK`
- `PROFILE_POSTS_READ_OK`
- `PROFILE_REELS_READ_OK`
- `PROFILE_MEDIA_READ_OK`
- `postsItems:1`
- `reelsItems:1`
- `mediaItems:1`
- `cleanupDone:true`
- `dbConnected:true`
- `queryEnabled:true`
- `secretsExposed:false`
- `publicMediaUrlsCreated:false`
- `fakeItemsCreated:false`
- `apiRoutesOpened:false`
- `flutterOpened:false`

The smoke inserted one private media asset, one private post, and one private reel for a temporary CID, verified repository reads, and cleaned all temporary rows.
