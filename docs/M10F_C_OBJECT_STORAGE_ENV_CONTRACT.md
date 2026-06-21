# M10F-C Object Storage Environment Contract

M10F-C defines the backend-only environment contract for Hetzner Object Storage.

This is a safety contract only.

No upload route is opened.
No Object Storage write route is opened.
No real media upload is performed.
No frontend secret is added.
No production deploy is performed.

## Object Storage target

Provider: Hetzner Object Storage
Bucket: cidentia-live-media
Endpoint: fsn1.your-objectstorage.com
Location: Falkenstein / eu-central
Visibility: private

## Core security rule

Object Storage credentials must never be exposed to Flutter, public JavaScript, GitHub, screenshots or documentation.

Access key and secret key must exist only in trusted backend environment variables.

Flutter must never hold S3 credentials.

## Required backend env variables

Future backend env contract:

CIDENTIA_OBJECT_STORAGE_ENABLED=false
CIDENTIA_OBJECT_STORAGE_PROVIDER=hetzner
CIDENTIA_OBJECT_STORAGE_ENDPOINT=https://fsn1.your-objectstorage.com
CIDENTIA_OBJECT_STORAGE_REGION=fsn1
CIDENTIA_OBJECT_STORAGE_BUCKET=cidentia-live-media
CIDENTIA_OBJECT_STORAGE_ACCESS_KEY=
CIDENTIA_OBJECT_STORAGE_SECRET_KEY=
CIDENTIA_OBJECT_STORAGE_FORCE_PATH_STYLE=false
CIDENTIA_OBJECT_STORAGE_PUBLIC_BASE_URL=
CIDENTIA_OBJECT_STORAGE_SIGNED_URL_TTL_SECONDS=900
CIDENTIA_OBJECT_STORAGE_UPLOAD_MAX_BYTES=0
CIDENTIA_OBJECT_STORAGE_WRITE_ENABLED=false

Default state must be disabled.

Writes require:

CIDENTIA_OBJECT_STORAGE_ENABLED=true
CIDENTIA_OBJECT_STORAGE_WRITE_ENABLED=true

If either flag is not true, backend must not write to Object Storage.

## Flutter boundary

Flutter can later:

- ask backend for upload permission
- show upload limits
- show media status
- display URLs returned by backend

Flutter must not:

- store Object Storage access key
- store Object Storage secret key
- call S3 directly with permanent credentials
- fake successful upload
- bypass backend quota checks
- bypass CID/session checks

## Future upload flow

1. Flutter asks backend for upload permission.
2. Backend verifies CidenDB/CID session.
3. Backend checks quota, credit, Pro status and moderation rules.
4. Backend creates pending media metadata.
5. Backend returns short-lived signed upload permission.
6. Flutter uploads with that short-lived permission only.
7. Backend validates completion.
8. Worker creates thumbnail or transcodes if needed.
9. Backend marks media ready.

Permanent credentials never leave backend.

## Public and private delivery

Public media:

- published avatar
- published cover
- published post image
- public reel
- public thumbnail

Private or signed media:

- AI draft
- unpublished upload
- paid replay
- proof package
- creator private asset
- moderation-pending asset

## Suggested object key prefixes

avatars/
covers/
posts/images/
posts/videos/
reels/
live/replays/
live/thumbnails/
ai/images/
ai/videos/
proof/packages/
temp/uploads/
moderation/blocked/

Do not use raw email addresses in object keys.

CID or internal user IDs are preferred.

## Metadata rules

Database stores metadata only:

- media_id
- owner_cid
- media_type
- bucket
- object_key
- visibility
- signed_url_required
- size_bytes
- content_type
- duration_seconds
- thumbnail_object_key
- status
- moderation_status
- created_at
- expires_at

Database must not store raw media binaries.

## Locked responses

When Object Storage is disabled:

OBJECT_STORAGE_DISABLED
objectStorageWrite=false
uploadCreated=false

When write route is disabled:

OBJECT_STORAGE_WRITE_DISABLED
objectStorageWrite=false
uploadCreated=false

When CID session is missing:

CID_SESSION_REQUIRED
objectStorageWrite=false
uploadCreated=false

## VPS disk rule

The VPS may use temporary disk only during controlled processing.

Permanent media must not remain on VPS disk.

Do not store permanently on VPS:

- uploaded videos
- replay videos
- AI output
- thumbnails archive
- proof packages
- public media archive

## Locked boundaries

M10F-C does not open:

- real upload
- real Object Storage write
- real signed URL generation
- public media route
- CDN cutover
- production deploy
- payment
- wallet
- token
- blockchain
- NFT mint
- AI provider call
- RTMP/live stream
- replay recording

## Next safe steps

1. Document Storage Box backup contract.
2. Install Node.js, Nginx and PostgreSQL after contracts are sealed.
3. Add disabled backend Object Storage client skeleton.
4. Add disabled upload permission route.
5. Test locked responses only.
6. Keep all Object Storage secrets in backend env only.
