# M19F — Profile Tabs Media Posts Reels Boundary Plan

Status: Planning boundary only.

## Purpose

M19F defines the safe path for connecting profile tabs to guarded backend boundaries.

Current profile tabs are visual/local UI only. They must not be treated as real backend data.

Target tabs:

- Posts
- Reels
- Media
- Tagged / Proof-related future tab

## Current safe state

M19E connected profile stat cards to the guarded stats boundary.

M19F does not change Flutter behavior.

## Future backend boundaries

Suggested future routes:

- `GET /api/profile/posts`
- `GET /api/profile/reels`
- `GET /api/profile/media`

Each route must be CID-gated and default-disabled.

## Required missing CID behavior

Missing CID must return:

- HTTP `401`
- `PROFILE_CID_REQUIRED`

## Required default locked behavior

CID-present request in default locked runtime must return:

- HTTP `503`
- `PROFILE_TABS_DISABLED`
- `repositoryCode:DATABASE_DISABLED`
- `itemsRead:false`
- `items:[]`
- `dbConnected:false`
- `queryEnabled:false`
- `secretsExposed:false`

## Required data sources

Future repository boundaries may read only from guarded backend tables:

- `cidentia_posts`
- `cidentia_reels`
- `cidentia_media_assets`
- `cidentia_profiles`

## Required repository behavior

The repository layer should support:

- read posts by `owner_cid`
- read reels by `owner_cid`
- read media assets by `owner_cid`
- filter by visibility/moderation only when the policy is explicitly defined
- return empty locked result when DB gates are disabled

## Required Flutter behavior

Flutter may keep current visual placeholders until real tab data is released.

When future tab boundary read is added, Flutter should:

1. call only after verified CID exists
2. show locked boundary status when disabled
3. never create fake posts
4. never create fake reels
5. never create fake media assets
6. never expose Object Storage public URLs by default
7. never publish local demo content as real user content

## Safe implementation order

Recommended next milestones:

1. M20A — profile tab repository boundary
2. M20B — disabled profile tab API routes
3. M20C — guarded server-only profile tab DB smoke
4. M20D — Flutter profile tab boundary read, locked by default
5. M20E — real media URL policy plan before any public media rendering

## Locked boundaries preserved

M19F does not open:

- real profile tabs API
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
