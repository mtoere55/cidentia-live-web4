# M19E — Flutter Profile Stats Boundary Read

Status: Flutter boundary read only.

## Purpose

M19E connects the Flutter profile stat cards to the guarded profile stats boundary.

## Changed Flutter behavior

The profile stats row can now request:

- `GET /api/profile/stats`

The request sends:

- `x-cidentia-cid`

## UI behavior

Stats cards remain visual placeholders until real stats release:

- Posts: `128`
- Followers: `24.8K`
- Following: `386`
- Trust: `98.4`

The UI may show the backend boundary response in a sheet.

## Default locked behavior

When backend is locked/default-disabled, Flutter should surface:

- `PROFILE_STATS_DISABLED`
- `repository=DATABASE_DISABLED`
- null counts

## Locked boundaries preserved

M19E does not open:

- Flutter real stats replacement
- fake counters
- fake posts/reels/media data
- public stats route by default
- public feed publishing
- public upload/media route
- Object Storage public URL exposure
- frontend secret
- fake CID/session/token
- wallet/payment/token/blockchain
- CidenBridge production route
- RTMP/WebRTC/live stream
- replay recording
