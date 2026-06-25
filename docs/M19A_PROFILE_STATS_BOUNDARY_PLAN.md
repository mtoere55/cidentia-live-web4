# M19A — Profile Stats Boundary Plan

Status: Planning boundary only.

## Purpose

M19A defines the safe path for replacing static profile stats with guarded backend stats.

Current Flutter profile stats are visual placeholders:

- Posts: `128`
- Followers: `24.8K`
- Following: `386`
- Trust: `98.4`

These values must not be treated as real backend data.

## Target future stats

The future profile stats boundary should support:

- post count
- reel count
- follower count
- following count
- profile trust/proof signal
- media count
- live/replay count

## Required backend sources

Future stats must come only from guarded backend repositories:

- `cidentia_posts`
- `cidentia_reels`
- `cidentia_media_assets`
- `cidentia_follows`
- `cidentia_profiles`
- future proof/trust service boundary

## Required API behavior

A future stats API should be CID-gated and default-disabled.

Suggested route:

- `GET /api/profile/stats`

Required locked/default response:

- `PROFILE_STATS_DISABLED`
- `statsRead:false`
- `postsCount:null`
- `followersCount:null`
- `followingCount:null`
- `trustScore:null`
- `dbConnected:false`
- `queryEnabled:false`

Missing CID response:

- `PROFILE_CID_REQUIRED`

## Flutter behavior

Flutter may show the existing visual placeholders until real stats are released.

When the stats boundary is added, Flutter should:

1. call the stats route only for verified CID
2. show locked boundary status when disabled
3. never increment counts locally
4. never fake follow/follower state
5. never fake posts/reels/media counts

## Safe implementation order

Recommended next milestones:

1. M19B — profile stats repository boundary
2. M19C — disabled profile stats API route
3. M19D — guarded server-only profile stats DB smoke
4. M19E — Flutter stats boundary read, locked by default
5. M19F — profile tabs media/posts/reels boundary plan

## Locked boundaries preserved

M19A does not open:

- real profile stats API
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
