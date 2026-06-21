# M10F-B Media Storage and Replay Architecture Plan

M10F-B defines how Cidentia.Live should store, deliver and retain media without filling the VPS disk or creating uncontrolled storage costs.

This is a planning document only.

No upload route is opened.
No Object Storage write route is opened.
No replay recording is opened.
No CDN cutover is performed.
No production deploy is performed.

## Core rule

The VPS must not be permanent media storage.

The VPS may temporarily process files, but final media must be stored in Object Storage.

Permanent media belongs in:

- Hetzner Object Storage
- future CDN/media delivery layer
- backup copies in Storage Box only when needed

The database stores metadata only.

## Infrastructure basis

Current prepared infrastructure:

- VPS: cidentia-live-api-01
- VPS IP: 167.233.122.49
- Object Storage bucket: cidentia-live-media
- Object Storage endpoint: fsn1.your-objectstorage.com
- Storage Box: cidentia-live-backup-01
- Storage Box host: u618982.your-storagebox.de
- Cloudflare: future DNS, SSL, firewall and edge layer

## Media categories

Cidentia.Live media should be separated by purpose.

Suggested Object Storage prefixes:

- avatars/
- covers/
- posts/images/
- posts/videos/
- reels/
- live/replays/
- live/thumbnails/
- ai/images/
- ai/videos/
- proof/packages/
- proof/thumbnails/
- temp/uploads/
- moderation/blocked/

These are prefixes inside the bucket, not separate required buckets.

Starting with one private bucket is safer:

- cidentia-live-media

More buckets can be added later if separation becomes necessary.

## Public vs private media

Not all media should be public.

Public or semi-public media:

- public profile avatar
- public profile cover
- published post image
- published reel
- public thumbnail
- public replay preview

Private or signed media:

- AI draft output
- unpublished upload
- paid replay
- proof package
- creator private asset
- moderation-pending media
- deleted or blocked media

Private media should be delivered through signed URLs or backend-authorized routes.

## Upload flow

Correct future upload flow:

1. Flutter asks backend for an upload permission.
2. Backend verifies CidenDB/CID session.
3. Backend checks quota, credit, Pro status or feature access.
4. Backend creates a pending media metadata record.
5. Backend returns a short-lived signed upload URL or upload policy.
6. Flutter uploads directly to Object Storage.
7. Backend receives/validates completion.
8. Worker creates thumbnail or transcodes if needed.
9. Backend marks media ready.
10. Flutter displays final public or signed media URL.

Flutter must not hold Object Storage access keys.

## Replay flow

Live replay must be treated as expensive storage.

Correct future replay flow:

1. Live session starts.
2. Replay recording is enabled only if allowed.
3. Recording chunks are processed by backend/worker.
4. Final replay file is stored in Object Storage.
5. Thumbnail is generated.
6. Database stores replay metadata.
7. Replay is shown based on retention and access rules.

Replay must not be saved permanently on VPS disk.

## Retention rules

Suggested starting retention:

Free users:

- short replay retention
- limited draft media
- limited AI output retention
- lower video duration limit

Verified CID users:

- account-bound media
- standard profile and post storage
- limited replay retention

Pro users:

- longer replay retention
- higher upload quota
- larger media duration
- higher AI output retention
- proof-ready package access

Paid extension:

- extend replay retention
- extend AI output retention
- unlock proof-ready package
- unlock higher resolution export

## Storage cost control

Storage must be controlled by:

- file size limits
- duration limits
- upload type limits
- retention expiration
- Pro plan rules
- credit rules
- cleanup jobs
- moderation state
- duplicate protection when possible

Never allow unlimited uploads, unlimited replay archive or unlimited AI video output.

## Metadata model

Database should store metadata only.

Suggested fields:

- media_id
- owner_cid
- owner_user_id
- media_type
- visibility
- object_key
- bucket
- endpoint
- public_url
- signed_url_required
- thumbnail_object_key
- duration_seconds
- size_bytes
- width
- height
- status
- moderation_status
- credit_cost
- source_type
- created_at
- expires_at
- deleted_at

For replays:

- replay_id
- live_session_id
- creator_cid
- object_key
- thumbnail_object_key
- duration_seconds
- retention_tier
- access_tier
- expires_at
- replay_status

## Worker requirements

Future workers should handle:

- thumbnail generation
- video duration detection
- media validation
- transcoding
- replay finalization
- expired media cleanup
- AI output packaging
- proof package preparation
- backup export jobs

The API should not block while video processing runs.

## Backup rules

Storage Box is for backups, not live media serving.

Backup candidates:

- PostgreSQL dumps
- Nginx config
- backend service config
- deployment manifest
- selected metadata exports
- recovery scripts

Do not mirror all public media blindly to Storage Box unless a paid backup policy is defined.

Object Storage lifecycle and retention should be the first cost-control tool.

## Cloudflare role

Cloudflare should be used for:

- DNS
- SSL/TLS
- firewall rules
- future cache layer
- API protection
- media domain routing

Possible future records:

- api.cidentia.live -> VPS
- media.cidentia.live -> media delivery route
- cdn.cidentia.live -> future CDN
- uploads.cidentia.live -> optional upload route

No DNS change is part of M10F-B.

## Locked boundaries

M10F-B does not open:

- real upload
- real replay recording
- real media write route
- real Object Storage write route
- CDN cutover
- payment
- wallet
- token
- blockchain
- NFT mint
- AI provider call
- RTMP/live stream production route
- public production deploy

## Next safe steps

Recommended next steps:

1. Document Object Storage environment contract.
2. Document Storage Box backup contract.
3. Install Node.js, Nginx and PostgreSQL on VPS.
4. Create a local/staging health route.
5. Add backend-only Object Storage client skeleton.
6. Keep all keys in server env only.
7. Add disabled upload boundary before enabling real uploads.
