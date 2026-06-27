# M20B — Disabled Profile Tab API Routes

Status: Disabled API boundary only.

## Purpose

M20B adds guarded default-disabled API routes for profile tabs.

## Added routes

- `GET /api/profile/posts`
- `GET /api/profile/reels`
- `GET /api/profile/media`

## Added helper

- `api/profile/profileTabBoundary.js`

## Repository source

Routes call the M20A repository:

- `readProfilePostsByCid`
- `readProfileReelsByCid`
- `readProfileMediaByCid`

## Missing CID behavior

Missing CID returns:

- HTTP `401`
- `PROFILE_CID_REQUIRED`

## Default locked behavior

CID-present calls in disabled runtime return:

- HTTP `503`
- `PROFILE_TABS_DISABLED`
- `repositoryCode:DATABASE_DISABLED`
- `itemsRead:false`
- `items:[]`
- `dbConnected:false`
- `queryEnabled:false`
- `secretsExposed:false`
- `publicMediaUrlsCreated:false`
- `fakeItemsCreated:false`

## Disabled backend wiring

The routes are wired only into the disabled local backend smoke server.

## Locked boundaries preserved

M20B does not open:

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

## Local disabled route check

Local disabled backend check passed.

Result:

- `M20B_PROFILE_TAB_API_ROUTES_DISABLED_OK`
- missing CID returned HTTP `401` with `PROFILE_CID_REQUIRED`
- `/api/profile/posts` returned HTTP `503` with `PROFILE_TABS_DISABLED`
- `/api/profile/reels` returned HTTP `503` with `PROFILE_TABS_DISABLED`
- `/api/profile/media` returned HTTP `503` with `PROFILE_TABS_DISABLED`
- all routes returned `repositoryCode:DATABASE_DISABLED`
- all routes returned `itemsRead:false`
- all routes returned `items:[]`
- `dbConnected:false`
- `queryEnabled:false`
- `secretsExposed:false`
- `publicMediaUrlsCreated:false`
- `fakeItemsCreated:false`
- `flutterOpened:false`
