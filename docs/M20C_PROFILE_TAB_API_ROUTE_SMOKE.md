# M20C — Profile Tab API Route Smoke

Status: Server-only guarded API route smoke.

## Purpose

M20C verifies that the M20B profile tab API routes can read real temporary DB rows when server-only DB gates are enabled.

## Routes tested

- `GET /api/profile/posts`
- `GET /api/profile/reels`
- `GET /api/profile/media`

## Smoke script

- `scripts/m20c-profile-tab-api-route-smoke.js`

## Smoke behavior

The smoke creates a temporary private media asset, one private post, and one private reel for a temporary CID.

It then calls the API route handlers directly with a mocked GET request and `x-cidentia-cid`.

After verification, all temporary rows are deleted.

## Required success result

- `M20C_PROFILE_TAB_API_ROUTE_SMOKE_OK`
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
- `flutterOpened:false`

## Locked boundaries preserved

M20C does not open:

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

## VPS server-only smoke result

VPS smoke was executed with server-only DB gates enabled.

Result:

- `M20C_PROFILE_TAB_API_ROUTE_SMOKE_OK`
- `postsStatusCode:200`
- `reelsStatusCode:200`
- `mediaStatusCode:200`
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
- `flutterOpened:false`

The smoke inserted one temporary private media asset, one private post, and one private reel for a temporary CID, verified the API route handlers, and cleaned all temporary rows.
