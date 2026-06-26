# M19B — Profile Stats Repository Boundary

Status: Repository boundary only.

## Purpose

M19B prepares the guarded repository layer for profile stats.

It does not add an API route and does not change Flutter.

## Added repository

- `server/profile/profileStatsRepository.js`

## Added check

- `scripts/m19b-profile-stats-repository-disabled-check.js`

## Stats prepared

The repository prepares guarded reads for:

- posts count
- reels count
- media count
- followers count
- following count
- trust score placeholder

## Verified schema sources

The real VPS staging database tables were checked:

- `cidentia_posts.owner_cid`
- `cidentia_reels.owner_cid`
- `cidentia_media_assets.owner_cid`
- `cidentia_follows.follower_cid`
- `cidentia_follows.followed_cid`
- `cidentia_profiles.owner_cid`

## Default behavior

When database gates are disabled, the repository returns:

- `DATABASE_DISABLED`
- `statsRead:false`
- `postsCount:null`
- `reelsCount:null`
- `mediaCount:null`
- `followersCount:null`
- `followingCount:null`
- `trustScore:null`
- `dbConnected:false`
- `queryEnabled:false`

Missing CID returns:

- `PROFILE_CID_REQUIRED`

## Locked boundaries preserved

M19B does not open:

- profile stats API route
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

## Server-only DB smoke

VPS server-only smoke passed with explicit gates:

- `CIDENTIA_PROFILE_STATS_REPOSITORY_SMOKE=true`
- `CIDENTIA_DATABASE_ENABLED=true`
- `CIDENTIA_DATABASE_QUERY_ENABLED=true`

Result:

- `M19B_PROFILE_STATS_REPOSITORY_SMOKE_OK`
- `PROFILE_STATS_READ_OK`
- `postsCount:2`
- `reelsCount:1`
- `mediaCount:3`
- `followersCount:1`
- `followingCount:1`
- `trustScore:null`
- `cleanupDone:true`
- `publicStatsRouteOpened:false`
- `flutterStatsOpened:false`
- `fakeCountersCreated:false`
